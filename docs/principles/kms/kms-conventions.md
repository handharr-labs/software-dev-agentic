> Author: Puras Handharmahua · 2026-06-12
> Related: [kms-glossary.md](kms-glossary.md) · [kms-design-principles.md](kms-design-principles.md) · [kms-seeding.md](kms-seeding.md) · [kms-directory-structure.md](kms-directory-structure.md)

Path conventions, chunk strategy, metadata schema, discipline vocabulary, and retrieval protocol — the practical reference for authoring knowledge docs and writing agents that query the KMS.

> **Knowledge Path Structure** — the directory + heading convention defined across this doc (Path Conventions, Chunk Strategy, and Metadata Schema below) that every Knowledge Path is an instance of: `{scope}/[{platform}|{project}]/{discipline}/{artifact}/{file}.md`, then `#`→`topic`/`##`→`pattern` inside the file. See [kms-glossary.md](kms-glossary.md#glossary) for one-line definitions of each term.

---

## `kms/knowledge-sources/` — Path Conventions

Raw documents live here — any format (`.md`, `.txt`), any origin. Engineers drop files in the right location; the seed runner derives all metadata from the path automatically.

> For the directory tree (what's actually under `knowledge-sources/`, and the rest of `kms/`), see [kms-directory-structure.md](kms-directory-structure.md).

Four path segments map directly to metadata fields. Three top-level buckets mirror the cascade tiers — three path conventions:

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

---

## Chunk Strategy — Heading Hierarchy

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

**"Subtopic" and `pattern` are the same thing** — not an eighth term. The `##` heading is the chunk boundary, the unit `kms_fetch`/`kms_query` return, and the retrieval key. "Sub-topic" describes its *role* (a sub-division of the parent `#` topic); `pattern` is its *field name* in ChromaDB metadata.

---

## Worked Examples

### Platform-tier doc

File: `kms/knowledge-sources/platform/flutter/engineering/standard-architecture/standard-architecture.md`

```markdown
# Domain
## Entity
```

| Term | Value | From |
|---|---|---|
| scope | `platform` | top-level bucket |
| platform | `flutter` | path segment |
| discipline | `engineering` | path segment |
| artifact | `standard-architecture` | path segment |
| topic | `domain` | `#` heading slug |
| pattern (subtopic) | `entity` | `##` heading slug |

### Project-tier doc

File: `kms/knowledge-sources/projects/mobile-talenta/feature-inventory/feature-inventory.md`, with `repo.yaml: { name: mobile-talenta, platform: flutter }`

```markdown
# Time Management
## Clock In/Out
```

| Term | Value | From |
|---|---|---|
| scope | `project` | top-level bucket |
| project | `mobile-talenta` | folder name / `repo.yaml: name` |
| platform | `flutter` | `repo.yaml: platform` |
| discipline | `engineering` | default for project docs |
| artifact | `feature-inventory` | path segment |
| topic | `time_management` | `#` heading slug |
| pattern (subtopic) | `clock_in_out` | `##` heading slug |

### Universal-tier doc

File: `kms/knowledge-sources/universal/agile/sprint-ceremonies/sprint-ceremonies.md`

```markdown
# Planning
## Sprint Planning Meeting
```

| Term | Value | From |
|---|---|---|
| scope | `universal` | top-level bucket |
| platform | _(omitted)_ | not applicable at universal scope |
| discipline | `agile` | path segment |
| artifact | `sprint-ceremonies` | path segment |
| topic | `planning` | `#` heading slug |
| pattern (subtopic) | `sprint_planning_meeting` | `##` heading slug |

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

## Retrieval Protocol

Three MCP tools serve different retrieval needs. Agents should combine them, not pick just one:

| Tool | Returns | When to use |
|---|---|---|
| `kms_list` | Metadata only (TOC) — no content | Step 0: scan what topics exist before deciding what to fetch |
| `kms_fetch` | Full content of one exact node, cascade-resolved (`project → platform → universal`) | The agent already knows the exact `topic`/`pattern` — deterministic retrieval |
| `kms_query` | Full content of top-k nodes, ranked by similarity | The agent doesn't know the exact topic — semantic / intent-based discovery |

**Combination pattern — `kms_list` narrows, `kms_fetch` retrieves:**
1. `kms_list(discipline, platform)` — scan the TOC, reason over which artifacts/topics exist
2. If the TOC is still large, narrow further with the same call — `kms_list(discipline, platform, artifact)` or `kms_list(discipline, platform, artifact, topic)` — each added param shrinks the TOC by one level. `pattern` is never a `kms_list` filter; it's what step 1-2 are narrowing down *to*.
3. Once `artifact`, `topic`, and `pattern` are known (e.g. `## Null Safety Extensions` under `platform/flutter/engineering/conventions/` → `artifact=conventions, topic=conventions, pattern=null_safety_extensions`): `kms_fetch(discipline, artifact, topic, pattern, platform)` — guaranteed, cascade-resolved retrieval
4. For exploratory or intent-based needs (e.g. "what conventions apply when writing this artifact type"): `kms_query(text, discipline, platform, n_results)` — semantic ranking, bypasses the narrowing steps entirely

**Why this matters:** `kms_query` ranks top-k across *all* matching nodes — a cross-cutting convention that applies to nearly every artifact (e.g. null-safety unwrapping) can be crowded out of the top-k by more numerous architecture-pattern nodes. When a topic's heading is uniform across platforms, prefer `kms_fetch` for guaranteed retrieval over hoping `kms_query` surfaces it.

### Terms as a Scoping Funnel

The Rosetta Stone terms above aren't just path/metadata mappings — they're the `kms_list` filter parameters, in narrowing order: `platform`/`project` (cascade tier) → `discipline` → `artifact` → `topic` → `pattern`. Each term you supply shrinks the TOC by one level. **`pattern` is never a `kms_list` filter** — it's the funnel's output, the value the agent is narrowing down *to*.

```
kms_list(platform="flutter", discipline="engineering")
  → TOC across every artifact in flutter engineering (conventions, standard-architecture, ...)
       artifact=standard-architecture  topic=domain  pattern=entity
       artifact=standard-architecture  topic=domain  pattern=use_case
       artifact=standard-architecture  topic=data    pattern=repository_impl
       artifact=conventions            topic=conventions  pattern=null_safety_extensions
       ...

kms_list(platform="flutter", discipline="engineering", artifact="standard-architecture")
  → narrowed to one artifact's TOC
       topic=domain  pattern=entity
       topic=domain  pattern=use_case
       topic=data    pattern=repository_impl

kms_fetch(discipline="engineering", artifact="standard-architecture",
          topic="domain", pattern="entity", platform="flutter")
  → exact node, cascade-resolved project → platform → universal
```

Once `kms_list` returns a TOC small enough to read every `(topic, pattern)` pair, the agent has everything `kms_fetch` needs — the four required params are exactly the path-derived terms (`discipline`, `artifact`, `topic`, `pattern`), with `platform`/`project` carried forward from the funnel to drive cascade resolution.

| Tool | Funnel role | Params (Rosetta terms only) |
|---|---|---|
| `kms_list` | Narrow the TOC, one term at a time | `platform, project, discipline, artifact, topic` (no `pattern`) |
| `kms_fetch` | Exact retrieval once the funnel bottoms out | `discipline, artifact, topic, pattern` required; `platform, project` for cascade |
| `kms_query` | Bypass — semantic search when the funnel can't be walked | `platform, discipline` only |

---

## `kms_upsert` — Manual Mapping

`kms_upsert` bypasses path-derivation entirely — the caller supplies `discipline`, `artifact`, `topic`, `pattern` directly. Same Rosetta Stone applies:

- `artifact` = the artifact folder this knowledge belongs to
- `topic` = slug of the parent `#` group (or artifact name if no grouping)
- `pattern` = snake_case slug of the canonical concept name — equivalent to a `##` heading

See [kms-knowledge-source-rules.md](../../../kms/docs/kms-knowledge-source-rules.md) for full authoring rules.

---

## Known Inconsistencies

`kms/domain/schema.py` defines `PROJECT_VALUES = ["talenta", "jurnal", "qontak-crm", "qontak-chat"]`, but no code references this constant, and it doesn't match actual project folder names under `kms/knowledge-sources/projects/` (`mobile-talenta`, `talenta-ios`, `talenta-mobile-android`, `flex-mobile`). `project` values are sourced from `repo.yaml: name` in practice, not from an enum. Treat `PROJECT_VALUES` as stale/unused — candidate for removal in a future cleanup.

---

## Changelog

See git history for this file.
