> Author: Puras Handharmahua · 2026-06-12
> Related: [kms-glossary.md](kms-glossary.md) · [kms-design-principles.md](kms-design-principles.md) · [kms-seeding.md](kms-seeding.md) · [kms-directory-structure.md](kms-directory-structure.md)

Path conventions, chunk strategy, metadata schema, discipline vocabulary, and retrieval protocol — the practical reference for authoring knowledge docs and writing agents that query the KMS.

> **Knowledge Path Structure** — the directory + heading convention defined across this doc (Path Conventions, Chunk Strategy, and Metadata Schema below) that every Knowledge Path is an instance of: `{scope}/[{platform}|{project}]/{discipline}/{artifact}/{file}.md`, then `#`→`topic`/`##`→`subtopic`/`###`→`pattern` (depth-aware, see Chunk Strategy below) inside the file. See [kms-glossary.md](kms-glossary.md#glossary) for one-line definitions of each term.

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

`DirectorySource` uses a depth-aware, three-level heading hierarchy with a fallback. Each `#` heading sets a `topic` context. Each `##` heading sets a `subtopic` context: if it has `###` children, each `###` becomes its own `KnowledgeNode` (`pattern`); if it has none, the `##` heading itself becomes the node (`subtopic == pattern`).

```
# Domain                  → topic=domain (context carrier, not a node itself)

## Entity                 → no ### children
                            → node: topic=domain, subtopic=entity, pattern=entity

## Use Case               → has ### children — each becomes its own node:
### Theory                →   node: topic=domain, subtopic=use_case, pattern=theory
### Code Pattern          →   node: topic=domain, subtopic=use_case, pattern=code_pattern
### Example               →   node: topic=domain, subtopic=use_case, pattern=example

## Standalone             → node: topic=<artifact-name>, subtopic=standalone, pattern=standalone
                            (no # parent → artifact name used as topic)

(no ## headings at all)   → one node: topic=<artifact-name>, subtopic=<artifact-name>, pattern=<artifact-name>
```

| Heading level | Role | Maps to |
|---|---|---|
| `#` | Topic — groups related sub-topics | `topic` field on all child nodes |
| `##` | Sub-topic — groups related patterns, or is the node itself if it has no `###` children | `subtopic` field on all child nodes; also `pattern` when there are no `###` children |
| `###` | Pattern — the retrieval unit, when present under a `##` | `pattern` field; one node per `###` |
| `####`+ | Internal structure within a pattern | Content body only; not chunked |

**Depth-aware fallback, why:** some artifacts (catalog-style docs like a ~228-component design system) use `##` as the natural one-concept-per-heading unit with no `###` substructure — these keep the original chunking behavior (`subtopic == pattern == ## slug`). Other artifacts (heavy standard-architecture docs) use `## <Layer Concept>` → `### Theory` / `### Code Pattern` / `### Example`, sometimes 80–200+ `###` headings per file — promoting each `###` to its own node prevents a single `##` section (occasionally ~500 lines) from being returned as one content blob on `kms_fetch`/`kms_query`.

**Why `subtopic` is part of the node `id`:** two different `##` subtopics under the same `#` topic can each contain a `### Code Pattern` — without `subtopic` in the `id`, both would collide on `(topic, pattern)` and the second upsert would silently overwrite the first.

**Consequence for authoring:** if a `##` section contains `###` headings, each `###` heading must be individually self-contained and retrievable — the same self-containment rule as before, now applied at the `###` level (see R5 in [kms-knowledge-source-rules.md](../../../kms/docs/kms-knowledge-source-rules.md)). `####`+ headings remain unchunked content within whichever `###` (or `##`, if it has no `###` children) node they fall under. Content between a `##` heading and its first `###` child is discarded — if that intro material needs to be retrievable, give it its own `###` section.

**Content hash** is computed per node after chunking, not per-file. Only nodes that changed are re-upserted on the next seed run.

---

## Metadata Schema

| Field | Mandatory | Source | Values |
|---|---|---|---|
| `scope` | ✅ | path (tier) | `universal`, `platform`, `project` — encoded as `platform/flutter` or `project/name` in frontmatter |
| `discipline` | ✅ | path (dir) | `engineering`, `design`, `qa`, `devops`, `security`, `code_review`, `product`, `architecture`, `agile` |
| `artifact` | ✅ | path (dir) | named knowledge body within a discipline — `conventions`, `standard-architecture`, `feature-inventory`, etc. |
| `topic` | ✅ | `#` heading | slug of the parent `#` heading; artifact name if no `#` present |
| `subtopic` | ✅ | `##` heading | slug of the `##` heading — equals `pattern` when the `##` has no `###` children |
| `pattern` | ✅ | `##` or `###` heading | slug of the `###` heading if the parent `##` has `###` children, else the `##` heading itself — the retrieval key |
| `schema_version` | ✅ | constant | `"1"` — increment on breaking field changes |
| `platform` | ⬜ | path / repo.yaml | `flutter`, `ios`, `android`, `web` — omit if `scope=universal` |
| `project` | ⬜ | repo.yaml | project name — omit if `scope != project` |
| `tags` | ⬜ | manual | JSON array string |
| `source_file` | ⬜ | derived | absolute path to source file |
| `updated_at` | ⬜ | derived | ISO date string |
| `content_hash` | ⬜ | derived | SHA hash of the node's content after chunking — used for incremental seed detection |
| `content_type` | ⬜ | derived | `"real"` (default) — reserved, stub seeding removed |

**`pattern` is discipline-neutral** — it means a layer concept's facet in engineering, a checklist item in QA, a ceremony step in agile. The field name is stable; its meaning is domain-relative.

**`subtopic` and `pattern` are usually the same, but not always.** When a `##` heading has no `###` children, `subtopic == pattern == ## slug` — the `##` heading is the chunk boundary, the unit `kms_fetch`/`kms_query` return, and the retrieval key, exactly as before. When a `##` heading has `###` children, each `###` becomes its own node: `subtopic` stays the `##` slug (the grouping concept), `pattern` becomes the `###` slug (the retrievable unit). `kms_list` exposes both fields so an agent can narrow by `subtopic` before picking a `pattern`.

---

## Worked Examples

### Platform-tier doc — no `###` children

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
| subtopic | `entity` | `##` heading slug |
| pattern | `entity` | == subtopic — no `###` children |

### Platform-tier doc — with `###` children

File: `kms/knowledge-sources/platform/flutter/engineering/standard-architecture/standard-architecture.md`

```markdown
# Domain
## Use Case
### Theory
### Code Pattern
```

Two separate nodes are produced from this `##` section:

| Term | Value (node 1) | Value (node 2) | From |
|---|---|---|---|
| scope | `platform` | `platform` | top-level bucket |
| platform | `flutter` | `flutter` | path segment |
| discipline | `engineering` | `engineering` | path segment |
| artifact | `standard-architecture` | `standard-architecture` | path segment |
| topic | `domain` | `domain` | `#` heading slug |
| subtopic | `use_case` | `use_case` | `##` heading slug |
| pattern | `theory` | `code_pattern` | `###` heading slug |

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
| subtopic | `clock_in_out` | `##` heading slug |
| pattern | `clock_in_out` | == subtopic — no `###` children |

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
| subtopic | `sprint_planning_meeting` | `##` heading slug |
| pattern | `sprint_planning_meeting` | == subtopic — no `###` children |

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
2. If the TOC is still large, narrow further with the same call — `kms_list(discipline, platform, artifact)`, then `..., topic)`, then `..., subtopic)` — each added param shrinks the TOC by one level. `pattern` is never a `kms_list` filter; it's what the funnel is narrowing down *to*.
3. Once `artifact`, `topic`, `subtopic`, and `pattern` are known (e.g. `### Code Pattern` under `## Use Case` under `# Domain` in `platform/flutter/engineering/standard-architecture/` → `artifact=standard_architecture, topic=domain, subtopic=use_case, pattern=code_pattern`): `kms_fetch(discipline, artifact, topic, subtopic, pattern, platform)` — guaranteed, cascade-resolved retrieval
4. For exploratory or intent-based needs (e.g. "what conventions apply when writing this artifact type"): `kms_query(text, discipline, platform, n_results)` — semantic ranking, bypasses the narrowing steps entirely

**Why this matters:** `kms_query` ranks top-k across *all* matching nodes — a cross-cutting convention that applies to nearly every artifact (e.g. null-safety unwrapping) can be crowded out of the top-k by more numerous architecture-pattern nodes. When a topic's heading is uniform across platforms, prefer `kms_fetch` for guaranteed retrieval over hoping `kms_query` surfaces it.

### Terms as a Scoping Funnel

The Rosetta Stone terms above aren't just path/metadata mappings — they're the `kms_list` filter parameters, in narrowing order: `platform`/`project` (cascade tier) → `discipline` → `artifact` → `topic` → `subtopic` → `pattern`. Each term you supply shrinks the TOC by one level. **`pattern` is never a `kms_list` filter** — it's the funnel's output, the value the agent is narrowing down *to*.

```
kms_list(platform="flutter", discipline="engineering")
  → TOC across every artifact in flutter engineering (conventions, standard-architecture, ...)
       artifact=standard-architecture  topic=domain  subtopic=entity     pattern=entity
       artifact=standard-architecture  topic=domain  subtopic=use_case   pattern=theory
       artifact=standard-architecture  topic=domain  subtopic=use_case   pattern=code_pattern
       artifact=standard-architecture  topic=data    subtopic=repository_impl  pattern=repository_impl
       artifact=conventions            topic=conventions  subtopic=null_safety_extensions  pattern=null_safety_extensions
       ...

kms_list(platform="flutter", discipline="engineering", artifact="standard-architecture")
  → narrowed to one artifact's TOC
       topic=domain  subtopic=entity    pattern=entity
       topic=domain  subtopic=use_case  pattern=theory
       topic=domain  subtopic=use_case  pattern=code_pattern
       topic=data    subtopic=repository_impl  pattern=repository_impl

kms_list(platform="flutter", discipline="engineering", artifact="standard-architecture",
         topic="domain", subtopic="use_case")
  → narrowed to one subtopic's patterns
       pattern=theory
       pattern=code_pattern

kms_fetch(discipline="engineering", artifact="standard-architecture",
          topic="domain", subtopic="use_case", pattern="code_pattern", platform="flutter")
  → exact node, cascade-resolved project → platform → universal
```

Once `kms_list` returns a TOC small enough to read every `(topic, subtopic, pattern)` triple, the agent has everything `kms_fetch` needs — the five required params are exactly the path-derived terms (`discipline`, `artifact`, `topic`, `subtopic`, `pattern`), with `platform`/`project` carried forward from the funnel to drive cascade resolution.

| Tool | Funnel role | Params (Rosetta terms only) |
|---|---|---|
| `kms_list` | Narrow the TOC, one term at a time | `platform, project, discipline, artifact, topic, subtopic` (no `pattern`) |
| `kms_fetch` | Exact retrieval once the funnel bottoms out | `discipline, artifact, topic, subtopic, pattern` required; `platform, project` for cascade |
| `kms_query` | Bypass — semantic search when the funnel can't be walked | `platform, discipline` only |

---

## `kms_upsert` — Manual Mapping

`kms_upsert` bypasses path-derivation entirely — the caller supplies `discipline`, `artifact`, `topic`, `pattern`, and optionally `subtopic` directly. Same Rosetta Stone applies:

- `artifact` = the artifact folder this knowledge belongs to
- `topic` = slug of the parent `#` group (or artifact name if no grouping)
- `subtopic` = slug of the parent `##` group (or `pattern` if there is no `##`/`###` split — this is the default when `subtopic` is omitted)
- `pattern` = snake_case slug of the canonical concept name — equivalent to a `###` heading if the content has a `##` parent, else a `##` heading

See [kms-knowledge-source-rules.md](../../../kms/docs/kms-knowledge-source-rules.md) for full authoring rules.

---

## Known Inconsistencies

`kms/domain/schema.py` defines `PROJECT_VALUES = ["talenta", "jurnal", "qontak-crm", "qontak-chat"]`, but no code references this constant, and it doesn't match actual project folder names under `kms/knowledge-sources/projects/` (`mobile-talenta`, `talenta-ios`, `talenta-mobile-android`, `flex-mobile`). `project` values are sourced from `repo.yaml: name` in practice, not from an enum. Treat `PROJECT_VALUES` as stale/unused — candidate for removal in a future cleanup.

---

## Changelog

See git history for this file.
