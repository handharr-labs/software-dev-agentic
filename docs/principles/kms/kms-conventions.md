> Author: Puras Handharmahua · 2026-06-12
> Related: [kms-glossary.md](kms-glossary.md) · [kms-design-principles.md](kms-design-principles.md) · [kms-seeding.md](kms-seeding.md)

Path conventions, chunk strategy, metadata schema, discipline vocabulary, and retrieval protocol — the practical reference for authoring knowledge docs and writing agents that query the KMS.

---

## `kms/knowledge-sources/` — Path Conventions

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

See [kms-glossary.md](kms-glossary.md#terms-as-a-scoping-funnel-for-retrieval) for the full term-to-parameter mapping and a worked example of this narrowing.

**Why this matters:** `kms_query` ranks top-k across *all* matching nodes — a cross-cutting convention that applies to nearly every artifact (e.g. null-safety unwrapping) can be crowded out of the top-k by more numerous architecture-pattern nodes. When a topic's heading is uniform across platforms, prefer `kms_fetch` for guaranteed retrieval over hoping `kms_query` surfaces it.

---

## Changelog

See git history for this file.
