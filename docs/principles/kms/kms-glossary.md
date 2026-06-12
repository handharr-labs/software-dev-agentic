> Author: Puras Handharmahua · 2026-06-13
> Related: [kms-design-principles.md](kms-design-principles.md) · [kms-conventions.md](kms-conventions.md) · [kms-seeding.md](kms-seeding.md) · [kms-knowledge-source-rules.md](../../../kms/docs/kms-knowledge-source-rules.md)

## What This Doc Covers

One Rosetta Stone for every KMS vocabulary term — `scope`, `platform`, `project`, `discipline`, `artifact`, `topic`, `pattern` (aka "sub-topic"). For each term: what it means, where it lives in `kms/knowledge-sources/`, which ChromaDB metadata field it becomes, and where its allowed values are defined.

Read this first if a term's meaning is unclear in another KMS doc — the other docs assume this mapping.

---

## The Rosetta Stone

| Term | What it represents | Storage path segment | DB metadata field | Vocabulary source |
|---|---|---|---|---|
| **Scope** | Cascade tier — how general vs. specific this knowledge is | Top-level bucket: `universal/`, `platform/`, `projects/` | `scope` | `SCOPE_VALUES` in `kms/domain/schema.py` — `universal`, `platform`, `project` |
| **Platform** | Which client platform this knowledge applies to | `platform/{platform}/...` directory; for project docs, read from `repo.yaml: platform` | `platform` | `PLATFORM_VALUES` — `flutter`, `ios`, `android`, `web` |
| **Project** | Which specific codebase this is a deviation or inventory for | `projects/{project-name}/...` directory | `project` | `repo.yaml: name` — the folder name under `projects/` |
| **Discipline** | Which role / work-area this knowledge serves | Directory directly under `universal/` or `platform/{platform}/` (project docs default to `engineering`) | `discipline` | `DISCIPLINE_VALUES` — `engineering`, `design`, `qa`, `devops`, `security`, `code_review`, `product`, `architecture`, `agile` |
| **Artifact** | The named body of knowledge within a discipline | Directory under `{discipline}/` — e.g. `conventions/`, `standard-architecture/`, `feature-inventory/` | `artifact` | Open-ended — any kebab-case folder name, no enum |
| **Topic** | Thematic grouping of related concepts within an artifact | `#` heading in the `.md` file | `topic` | Derived: slug of the `#` heading text (or the artifact name if no `#` heading precedes it) |
| **Subtopic** (aka **Pattern**) | One self-contained, retrievable concept — the actual unit of retrieval | `##` heading in the `.md` file | `pattern` | Derived: slug of the `##` heading text |

**Path → field, in order:** `{scope-bucket}/[{platform}/]{discipline}/{artifact}/{file}.md`, then `#`/`##` headings inside the file produce `topic`/`pattern`.

---

## Subtopic and `pattern` are the same thing

This is the most common point of confusion: **"Subtopic" is not an eighth term** — it's the conceptual name for what the `pattern` field stores.

- The `##` heading is the chunk boundary, the unit `kms_fetch`/`kms_query` return, and the retrieval key.
- "Sub-topic" describes its *role* (a sub-division of the parent `#` topic).
- `pattern` is its *field name* in ChromaDB metadata — kept discipline-neutral so it means "sub-topic" in engineering, "checklist item" in QA, "ceremony step" in agile.

One concept, two names depending on whether you're talking about document structure (sub-topic) or DB metadata (`pattern`).

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

## Terms as a Scoping Funnel for Retrieval

The Rosetta Stone terms aren't just path/metadata mappings — they're the `kms_list` filter parameters, in narrowing order: `platform`/`project` (cascade tier) → `discipline` → `artifact` → `topic` → `pattern`. Each term you supply shrinks the TOC by one level. **`pattern` is never a `kms_list` filter** — it's the funnel's output, the value the agent is narrowing down *to*.

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

**`kms_query` is the bypass**, not part of the funnel: when `artifact`/`topic`/`pattern` aren't known yet, semantic ranking substitutes for the narrowing steps — only `platform`/`discipline` remain as filters.

| Tool | Funnel role | Params (Rosetta terms only) |
|---|---|---|
| `kms_list` | Narrow the TOC, one term at a time | `platform, project, discipline, artifact, topic` (no `pattern`) |
| `kms_fetch` | Exact retrieval once the funnel bottoms out | `discipline, artifact, topic, pattern` required; `platform, project` for cascade |
| `kms_query` | Bypass — semantic search when the funnel can't be walked | `platform, discipline` only |

---

## `kms_upsert` — manual mapping

`kms_upsert` bypasses path-derivation entirely — the caller supplies `discipline`, `artifact`, `topic`, `pattern` directly. Same Rosetta Stone applies:

- `artifact` = the artifact folder this knowledge belongs to
- `topic` = slug of the parent `#` group (or artifact name if no grouping)
- `pattern` = snake_case slug of the canonical concept name — equivalent to a `##` heading

See [kms-knowledge-source-rules.md](../../../kms/docs/kms-knowledge-source-rules.md) for full authoring rules.

---

## Known Inconsistency

`kms/domain/schema.py` defines `PROJECT_VALUES = ["talenta", "jurnal", "qontak-crm", "qontak-chat"]`, but no code references this constant, and it doesn't match actual project folder names under `kms/knowledge-sources/projects/` (`mobile-talenta`, `talenta-ios`, `talenta-mobile-android`, `flex-mobile`). `project` values are sourced from `repo.yaml: name` in practice, not from an enum. Treat `PROJECT_VALUES` as stale/unused — candidate for removal in a future cleanup.

---

## See Also

| Doc | Covers |
|---|---|
| [kms-design-principles.md](kms-design-principles.md) | Why the KMS exists, cascade resolution, section ownership |
| [kms-conventions.md](kms-conventions.md) | Path conventions, chunk strategy, full metadata schema, retrieval protocol |
| [kms-seeding.md](kms-seeding.md) | How knowledge gets into the DB — sources, change detection, agentic workflow |
| [kms-knowledge-source-rules.md](../../../kms/docs/kms-knowledge-source-rules.md) | Authoring rules for files under `kms/knowledge-sources/` — heading structure, naming, audit |

---

## Changelog

See git history for this file.
