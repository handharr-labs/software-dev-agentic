> Author: Puras Handharmahua · 2026-06-04
> Related: kms-initiative.md

## What is the KMS?

A ChromaDB-backed knowledge store shipped inside the Claude Code plugin. Agents retrieve implementation patterns, SDLC processes, and role knowledge via MCP tools instead of grepping flat files. Single DB, two query modes — exact metadata fetch for precision, vector search for discovery.

> One store. Two query modes. All SDLC knowledge.

---

## Design Goals

1. **Drop-in knowledge** — drop any doc into `kms/knowledge-sources/` and the system derives scope, platform, discipline, artifact, topic, and pattern from the path — frontmatter is documentation-only, not required by the seeder
2. **Cascade by specificity** — project overrides platform overrides universal; agents always get the most relevant knowledge
3. **Section ownership** — each source owns specific sections of a node; no source can corrupt another's contribution
4. **Resilient seeding** — unavailable sources are skipped silently; existing knowledge is never removed by a failed seed
5. **SDLC-scale vocabulary** — disciplines cover all roles and processes, not just engineering

---

## Core Principles

### 1. Single collection — cascade via metadata

One ChromaDB collection for all knowledge. Scope is enforced by `scope + platform + project + discipline + artifact` metadata fields, not by collection separation. Splitting by platform would break cascade fallthrough which requires all tiers queryable in a single call.

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

All allowed values for `scope`, `platform`, `project`, `discipline`, `schema_version`, and field classifications (mandatory vs optional) live here. `artifact` is mandatory but open-ended — no controlled enum, any folder name under a discipline dir is valid. Seed runner, adapters, use cases, and agents all import from this file. Never hardcode vocabulary elsewhere.

### 5. Incremental seeding via content hash

Change detection uses a SHA hash of the full document body stored as `content_hash` in metadata. Uniform across all source types — no dependency on filesystem timestamps or git. Only changed nodes are re-upserted.

### 6. Skip-on-unavailable — never destructive

If a source path or URL is inaccessible at seed time, that source is skipped with a warning. Existing nodes from that source are never removed or overwritten. The DB is always left in a valid state.

### 7. `kms/knowledge-sources/` is the primary knowledge store

Raw documents live here — any format (`.md`, `.txt`), any origin. Engineers drop files in the right location; the seed runner derives all metadata from the path automatically.

Four path segments map directly to metadata fields. Three top-level buckets mirror the cascade tiers:

```
kms/knowledge-sources/
├── universal/              → scope=universal — general principles, all platforms
│   ├── engineering/        → discipline
│   │   └── conventions/    → artifact
│   └── qa/
├── platform/               → scope=platform — implemented for a specific platform
│   ├── flutter/            → platform
│   │   ├── engineering/    → discipline
│   │   │   ├── conventions/          → artifact
│   │   │   └── standard-architecture/
│   │   └── design/
│   └── ios/
│       └── engineering/
└── projects/               → scope=project — deviations for a specific project
    └── mobile-talenta/
        ├── feature-inventory/  → artifact
        └── api-endpoints/
```

Three path conventions:

**1. Universal knowledge — `universal/{discipline}/{artifact}/{filename}.md`:**
```
universal/agile/sprint-ceremonies/sprint-ceremonies.md   → scope=universal, discipline=agile, artifact=sprint-ceremonies
universal/engineering/conventions/conventions.md         → scope=universal, discipline=engineering, artifact=conventions
```

- `discipline` → subdirectory (must match `DISCIPLINE_VALUES`)
- `artifact` → next subdirectory — the named body of knowledge within the discipline
- `scope` → always `universal`

**2. Platform knowledge — `platform/{platform}/{discipline}/{artifact}/{filename}.md`:**
```
platform/flutter/engineering/conventions/conventions.md           → scope=platform, platform=flutter, discipline=engineering, artifact=conventions
platform/flutter/engineering/standard-architecture/standard-architecture.md  → scope=platform, platform=flutter, discipline=engineering, artifact=standard-architecture
```

- `platform` → subdirectory under `platform/` (one of `flutter`, `ios`, `android`, `web`)
- `discipline` → next subdirectory (must match `DISCIPLINE_VALUES`)
- `artifact` → next subdirectory — named knowledge body
- `scope` → always `platform`

**3. Project-specific knowledge — `projects/{project-name}/{artifact}/{filename}.md`:**
```
projects/mobile-talenta/feature-inventory/feature-inventory.md  → project=mobile-talenta, artifact=feature-inventory, scope=project
projects/mobile-talenta/api-endpoints/api-endpoints.md          → project=mobile-talenta, artifact=api-endpoints, scope=project
```

- `platform` and `project` read from `repo.yaml` in the project directory — not encoded in filenames
- `discipline` defaults to `engineering` — project docs are always codebase-derived
- `scope` is always `project`

Each project directory requires a `repo.yaml`:
```yaml
name: flutter-mobile-talenta
platform: flutter
remote: null
last_scanned: null
last_scanned_local_path: null
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

### 10. Chunk strategy — heading hierarchy maps to metadata

`DirectorySource` uses a three-level heading hierarchy. Each `##` heading produces one `KnowledgeNode`; its parent `#` heading sets the `topic` context carried on that node.

```
# Domain             → topic=domain  (context carrier, not a node itself)
## Creation Order    → node: topic=domain, pattern=creation_order
## Entity            → node: topic=domain, pattern=entity

# Data               → topic=data
## Creation Order    → node: topic=data, pattern=creation_order  ← no collision with the one above
## Repository        → node: topic=data, pattern=repository

## Standalone        → node: topic=<artifact-name>, pattern=standalone  (no # parent → artifact as topic)
(no headings at all) → one node: topic=<artifact-name>, pattern=<artifact-name>
```

| Heading level | Role | Maps to |
|---|---|---|
| `#` | Topic — groups related sub-topics | `topic` field on all child nodes |
| `##` | Sub-topic — the actual chunk boundary and retrieval unit | `pattern` field; one node per `##` |
| `###` | Section — internal structure within a sub-topic | Content body only; not chunked |

**Why `###` is not chunked:** `###` headings are internal structure (`### Theory`, `### Code Pattern`, `### Example`). A sub-topic node is only useful if it's self-contained — splitting at `###` produces fragments that are meaningless in isolation.

**Consequence for authoring:** every distinct concept that must be retrievable by exact metadata match needs its own `##` heading. Content under `###` is indexed but only reachable via vector search. The `#` heading is mandatory whenever a file contains multiple thematic groups — it prevents `topic` collision across `##` headings with the same name.

**Content hash** is computed per `##` section after chunking, not per-file. Only sections that changed are re-upserted on the next seed run.

---

## Metadata Schema

| Field | Mandatory | Source | Values |
|---|---|---|---|
| `scope` | ✅ | path (tier) | `universal`, `platform`, `project` — encoded as `platform/flutter` or `project/name` in frontmatter |
| `discipline` | ✅ | path (dir) | `engineering`, `design`, `qa`, `devops`, `security`, `code_review`, `product`, `architecture`, `agile` |
| `artifact` | ✅ | path (dir) | named knowledge body within a discipline — `conventions`, `standard-architecture`, `feature-inventory`, etc. |
| `topic` | ✅ | `#` heading | slug of the parent `#` heading; artifact name if no `#` present |
| `pattern` | ✅ | `##` heading | slug of the `##` heading — the sub-topic and retrieval key |
| `schema_version` | ✅ | constant | `"1"` — increment on breaking field changes |
| `platform` | ⬜ | path / repo.yaml | `flutter`, `ios`, `android`, `web` — omit if `scope=universal` |
| `project` | ⬜ | repo.yaml | project name — omit if `scope != project` |
| `tags` | ⬜ | manual | JSON array string |
| `source_file` | ⬜ | derived | absolute path to source file |
| `updated_at` | ⬜ | derived | ISO date string |
| `content_hash` | ⬜ | derived | SHA hash of `##` section body — used for incremental seed detection |
| `content_type` | ⬜ | derived | `"real"` (default) — reserved, stub seeding removed |

**`pattern` is discipline-neutral** — it means sub-topic in engineering, checklist item in QA, ceremony step in agile. The field name is stable; its meaning is domain-relative.

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
2. For known, exact nodes — when artifact, topic, and pattern are known (e.g. `## Null Safety Extensions` under `platform/flutter/engineering/conventions/` → `artifact=conventions, topic=conventions, pattern=null_safety_extensions`): `kms_fetch(discipline, artifact, topic, pattern, platform)` — guaranteed, cascade-resolved retrieval
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
