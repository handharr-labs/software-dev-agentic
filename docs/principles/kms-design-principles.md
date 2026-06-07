> Author: Puras Handharmahua · 2026-06-04
> Related: kms-initiative.md

## What is the KMS?

A ChromaDB-backed knowledge store shipped inside the Claude Code plugin. Agents retrieve implementation patterns, SDLC processes, and role knowledge via MCP tools instead of grepping flat files. Single DB, two query modes — exact metadata fetch for precision, vector search for discovery.

> One store. Two query modes. All SDLC knowledge.

---

## Design Goals

1. **Drop-in knowledge** — drop any doc into `kms/knowledge-sources/` and the system derives discipline, platform, topic, and pattern from the path — no frontmatter or manual structuring required
2. **Cascade by specificity** — project overrides platform overrides universal; agents always get the most relevant knowledge
3. **Section ownership** — each source owns specific sections of a node; no source can corrupt another's contribution
4. **Resilient seeding** — unavailable sources are skipped silently; existing knowledge is never removed by a failed seed
5. **SDLC-scale vocabulary** — disciplines cover all roles and processes, not just engineering

---

## Core Principles

### 1. Single collection — cascade via metadata

One ChromaDB collection for all knowledge. Scope is enforced by `scope + platform + project` metadata fields, not by collection separation. Splitting by platform would break cascade fallthrough which requires all tiers queryable in a single call.

Nodes from multiple platforms and projects naturally accumulate in a single ChromaDB instance — this is expected. Agents always query with explicit `platform` and `project` filters, so cross-platform nodes are never surfaced to an agent working in a different context. The presence of flutter or android nodes in an iOS plugin's ChromaDB is not an error.

### 2. Cascade resolution — specific overrides general

Three tiers, resolved in order:

```
universal                    → WHAT: general principles (Clean Architecture, SOLID, SDLC-wide)
  └─ platform (flutter)      → HOW: implemented in this platform (BLoC, get_it, layer structure)
       └─ project (talenta)  → WHERE: deviations for this project only (constraints, exceptions)
```

`kms_fetch` resolves `project → platform → universal`, returns first match. A project node is only created when a real deviation exists — most knowledge lives at platform or universal tier.

### 3. Section ownership — enforced at domain layer

Each knowledge source declares which sections it owns. `UpsertKnowledge` use case strips non-owned sections before merge. Adapters are dumb producers — they never enforce ownership themselves.

| Source type | Default owned sections |
|---|---|
| `directory` | `theory`, `definition`, `code_pattern`, `rationale` |
| `markdown` | `theory`, `definition` |
| `codebase` | `code_pattern`, `source_file` |
| `confluence` | `theory`, `rationale` |

### 4. `kms/domain/schema.py` is the single vocabulary contract

All allowed values for `scope`, `platform`, `project`, `discipline`, `schema_version`, and field classifications (mandatory vs optional) live here. Seed runner, adapters, use cases, and agents all import from this file. Never hardcode vocabulary elsewhere.

### 5. Incremental seeding via content hash

Change detection uses a SHA hash of the full document body stored as `content_hash` in metadata. Uniform across all source types — no dependency on filesystem timestamps or git. Only changed nodes are re-upserted.

### 6. Skip-on-unavailable — never destructive

If a source path or URL is inaccessible at seed time, that source is skipped with a warning. Existing nodes from that source are never removed or overwritten. The DB is always left in a valid state.

### 7. `kms/knowledge-sources/` is the primary knowledge store

Raw documents live here — any format (`.md`, `.txt`), any origin. Engineers drop files in the right location; the seed runner derives all metadata from the path automatically. No frontmatter, no manual structuring.

**Discipline templates — schema-first seeding:**

Each discipline folder contains a `_template.md` (universal) and/or `{platform}-_template.md` (platform-specific) that defines the canonical `##` heading vocabulary for that discipline. These are seeded as `content_type: stub` nodes — they populate the TOC so agents can discover what topics exist even before real content is written. When real content is seeded, it overwrites the stub. The rule is one-way: **stubs never overwrite real content**.

| Template file | Scope | Example |
|---|---|---|
| `{discipline}/_template.md` | universal or discipline-wide | `qa/_template.md`, `agile/_template.md` |
| `{discipline}/{platform}-_template.md` | platform | `engineering/flutter-_template.md` |

Three path conventions:

**1. Platform / universal knowledge — `{discipline}/{filename}.md`:**
```
engineering/flutter-standard-architecture.md  → platform=flutter, discipline=engineering, scope=platform
agile/sprint-retrospective-guide.md           → platform=None, discipline=agile, scope=universal
```

- `discipline` → subdirectory name (must match `DISCIPLINE_VALUES`)
- `platform` → filename prefix (`flutter-*`, `ios-*`, `android-*`, `web-*`) — absent means universal
- `scope` → `platform` if prefix found, `universal` otherwise

**2. Discipline templates — `{discipline}/_template.md` or `{discipline}/{platform}-_template.md`:**
```
engineering/flutter-_template.md  → platform=flutter, discipline=engineering, content_type=stub
qa/_template.md                   → platform=None, discipline=qa, content_type=stub
```

- Same path derivation rules as platform/universal knowledge above
- Seeded as `content_type: stub` — populate the TOC before real content exists
- Each `##` heading in the template seeds one stub node
- `UpsertKnowledge` skips upsert if an incoming stub would overwrite an existing real node

**3. Project-specific knowledge — `projects/{project-name}/{filename}.md`:**
```
projects/flutter-mobile-talenta/feature-inventory.md  → project=flutter-mobile-talenta, scope=project
projects/flutter-mobile-talenta/api-endpoints.md      → project=flutter-mobile-talenta, scope=project
```

- `platform` and `project` read from `repo.yaml` in the project directory — not encoded in filenames
- `discipline` defaults to `engineering` — project docs are always codebase-derived
- `scope` is always `project`

Each project directory requires a `repo.yaml`:
```yaml
name: flutter-mobile-talenta
platform: flutter
remote: null            # auto-populated from git remote get-url origin on first scan
last_scanned: null
last_scanned_local_path: null  # path used by the last engineer who ran the scan
```

**What belongs in project docs** — things unique to the project, not covered by the platform standard architecture doc:
- Feature inventory (what features exist + their module paths)
- API endpoints (actual endpoints per feature)
- Shared components (reusable widget catalog)
- Deviations from standard architecture
- Third-party integrations

### 8. Source registration in `kms/sources.yaml`

All knowledge sources are registered here. The seed runner reads this manifest — it never hardcodes sources. The primary entry covers all of `kms/knowledge-sources/` in one registration:

```yaml
sources:
  - name: knowledge-sources
    type: directory
    path: kms/knowledge-sources
    owns: [theory, definition, code_pattern, rationale]
    last_seeded: 2026-06-04
```

Additional sources (codebase scans, Confluence) are registered as separate entries with their own `owns` declarations.

### 9. `--add` auto-registers new sources

`seed_kms.py --add <path|url>` detects source type from the input, derives a name, presents the full proposed entry (name, type, owns) to the user for one confirmation, then seeds and appends to `sources.yaml`. One step, no manual yaml editing.

**Type detection rules:**

| Signal | Detected type |
|---|---|
| Local directory (no codebase markers) | `directory` |
| Local path + `pubspec.yaml` | `codebase` (flutter) |
| Local path + `package.json` | `codebase` (web) |
| Local path + `*.xcodeproj` | `codebase` (ios) |
| URL matching `confluence.` | `confluence` |
| GitHub URL | `codebase` (remote) |

### 10. Chunk strategy — one `##` heading, one node

`DirectorySource` splits every document at `##` heading boundaries before seeding. Each section becomes its own `KnowledgeNode`; `topic` and `pattern` are derived from the heading slug. A file with no `##` headings seeds as a single node using the filename as `topic`/`pattern`.

```
## Naming Convention          → topic=naming_convention, pattern=naming_convention
## Repository Implementation  → topic=repository_implementation, pattern=repository_implementation
(no headings)                 → topic=<filename-stem>, pattern=<filename-stem>
```

**Consequence for authoring:** any knowledge that must be retrievable by topic via `kms_fetch` must live under its own `##` heading. Content embedded inline within a broader section is indexed but only reachable via vector search — it cannot be fetched by exact metadata match.

**Rule:** when adding a new topic to an existing platform doc (e.g. naming conventions, error handling rules), give it a dedicated `##` heading. Never bury distinct topics as prose under an unrelated section.

**Content hash** is computed per-section after chunking, not per-file. Only sections that changed are re-upserted on the next seed run.

---

## Metadata Schema

| Field | Mandatory | Values |
|---|---|---|
| `scope` | ✅ | `universal`, `platform`, `project` |
| `discipline` | ✅ | `engineering`, `design`, `qa`, `devops`, `security`, `code_review`, `product`, `architecture`, `agile` |
| `topic` | ✅ | free string — process area or architecture layer |
| `pattern` | ✅ | free string — neutral term across all disciplines |
| `schema_version` | ✅ | `"1"` — increment on breaking field changes |
| `platform` | ⬜ | `flutter`, `ios`, `android`, `web` — omit if `scope=universal` |
| `project` | ⬜ | `talenta`, `jurnal`, `qontak-crm`, `qontak-chat` — omit if `scope != project` |
| `tags` | ⬜ | JSON array string |
| `source_file` | ⬜ | absolute path to source file |
| `updated_at` | ⬜ | ISO date string |
| `content_hash` | ⬜ | SHA hash of document body — used for incremental seed detection |
| `content_type` | ⬜ | `"real"` (default) \| `"stub"` — stubs seed schema; never overwrite real nodes |

**`pattern` is a neutral term** — it means code pattern in engineering, checklist type in QA, ceremony template in agile. Convention, not a type constraint.

---

## Discipline Vocabulary

| Discipline | Role / Work Area | Natural scope |
|---|---|---|
| `engineering` | Software engineers — layers, patterns, code | platform |
| `design` | Designers — UX/UI components, guidelines | universal → platform |
| `qa` | QA engineers — test strategy, checklists, templates | universal |
| `devops` | Platform/DevOps — CI/CD, infra, runbooks | universal → platform |
| `security` | Security engineers — threat models, mitigations | universal |
| `code_review` | All engineers — review rules, PR standards | universal → platform |
| `product` | Product managers — PRDs, decisions, acceptance criteria | project |
| `architecture` | Tech leads/Architects — ADRs, system design, tech strategy | universal → platform |
| `agile` | Scrum masters/Teams — ceremonies, retrospectives, sprint rituals | universal |

---

## Architecture Layers

```
MCP Server (application)
  └─ Use Cases (domain)
       └─ KnowledgeRepository (abstract interface)
            └─ ChromaKnowledgeRepository (data)
```

**Dependency rule:** nothing in domain or application imports ChromaDB directly. Swapping ChromaDB for another vector store is a data layer change only.

**Seeding layer:**

```
KnowledgeSource (abstract interface)
  ├─ DirectorySource   ← primary: kms/knowledge-sources/ (path-based metadata, no frontmatter)
  ├─ CodebaseSource    ← stub: scan agent writes via kms_upsert directly
  ├─ ConfluenceSource  ← stub: pending auth + parser
  └─ MarkdownSource    ← legacy: structured files with frontmatter (kept for compatibility)
       ↓
  Unified seed runner (reads sources.yaml)
       ↓
  UpsertKnowledge use case (enforces owns, merges sections)
       ↓
  ChromaKnowledgeRepository
```

---

## Retrieval Protocol — `kms_list`, `kms_fetch`, `kms_query`

Three MCP tools serve different retrieval needs. Agents should combine them, not pick just one:

| Tool | Returns | When to use |
|---|---|---|
| `kms_list` | Metadata only (TOC) — no content | Step 0: scan what topics exist before deciding what to fetch |
| `kms_fetch` | Full content of one exact node, cascade-resolved (`project → platform → universal`) | The agent already knows the exact `topic`/`pattern` — deterministic retrieval |
| `kms_query` | Full content of top-k nodes, ranked by similarity | The agent doesn't know the exact topic — semantic / intent-based discovery |

**Combination pattern:**
1. `kms_list(discipline, platform)` — scan the TOC, reason over which topics exist
2. For known, uniform topics — same heading seeded across every platform doc (e.g. `Null Safety Extensions` → `topic=null_safety_extensions`): `kms_fetch(topic, pattern, discipline, platform)` — guaranteed, cascade-resolved retrieval
3. For exploratory or intent-based needs (e.g. "what conventions apply when writing this artifact type"): `kms_query(text, discipline, platform, n_results)` — semantic ranking

**Why this matters:** `kms_query` ranks top-k across *all* matching nodes — a cross-cutting convention that applies to nearly every artifact (e.g. null-safety unwrapping) can be crowded out of the top-k by more numerous architecture-pattern nodes. When a topic's heading is uniform across platforms, prefer `kms_fetch` for guaranteed retrieval over hoping `kms_query` surfaces it.

---

## Agentic Seeding Workflow

| Component | Type | Responsibility |
|---|---|---|
| `/kms-seed` | skill | User-invocable entry point |
| `kms-seed-orchestrator` | orchestrator | Reads `sources.yaml`, filters by flags, spawns workers, reports summary |
| `kms-source-detect-worker` | worker | `--add` flow — detects type, derives name, confirms entry with user |
| `kms-seed-worker` | worker | One source — accessibility check, seed, update `last_seeded` |

---

## What Does Not Belong Here

- **Feature knowledge** (API contracts, data models, HLD) → Feature KMS (`librarian` persona, `.claude/reference/feature-docs/`)
- **Agent/skill conventions** → `core-design-principles.md`
- **Raw knowledge documents** (the actual content) → `kms/knowledge-sources/`
