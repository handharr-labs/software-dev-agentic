> Author: Puras Handharmahua · 2026-06-04
> Related: [kms-glossary.md](../../docs/principles/kms/kms-glossary.md) · [kms-design-principles.md](../docs/principles/kms/kms-design-principles.md) · [kms-conventions.md](../docs/principles/kms/kms-conventions.md)

## What This Doc Covers

Authoring rules for every file written to `kms/knowledge-sources/`. These rules enforce the chunking contract: the seeder maps `#` headings to `topic`, splits at `##` boundaries into one ChromaDB node each, and treats `###` as internal structure within a node. A file that violates these rules seeds incorrectly — either as an unsearchable blob or as nodes with colliding or vague retrieval keys.

---

## Chunking Contract

The `DirectorySource` seeder applies a three-level heading hierarchy before inserting into ChromaDB:

| Level | Role | Maps to |
|---|---|---|
| `#` | Topic — thematic group | `topic` field on all child `##` nodes |
| `##` | Sub-topic — one `KnowledgeNode` | `pattern` field; the retrieval key |
| `###` | Section — internal body structure | Content only; not a chunk boundary |

- Each `##` heading → one `KnowledgeNode`
- `##` heading text → `pattern` slug (lowercased, spaces → underscores, symbols stripped)
- Parent `#` heading text → `topic` slug on that node; artifact name if no `#` above
- `###` headings stay inside the `##` chunk — not split further
- Files with no `##` headings → one blob node for the whole file (avoid — blob is only reachable via vector search)

**`pattern` is the retrieval key.** Name `##` headings as you would name a concept: `entity`, `use_case`, `di_setup`, `bloc`. Agents query by semantic text and ChromaDB matches against these chunk contents.

---

## Placement Decision Guide

Before creating a file, decide which bucket it belongs in by answering two questions:

**1. Does the concept change depending on the platform?**

```
No  → universal/
Yes → platform/{platform}/
```

**2. Is this a deviation from the platform standard for one specific project?**

```
Yes → projects/{project-name}/
No  → universal/ or platform/{platform}/ (from question 1)
```

### Decision table

| Knowledge type | Example | Bucket |
|---|---|---|
| SDLC process applies to all platforms | Sprint retrospective guide, PR review checklist | `universal/{discipline}/` |
| Architecture principle applies to all platforms | Clean Architecture layers, SOLID rules | `universal/engineering/` |
| Implementation pattern tied to one platform | Flutter BLoC pattern, iOS UIKit coordinator | `platform/{platform}/engineering/{artifact}/` |
| UI component catalog for one platform | Flutter Mekari Pixel catalog | `platform/{platform}/design/{artifact}/` |
| Project deviates from the platform standard | Custom DI pattern, non-standard folder structure | `projects/{project-name}/{artifact}/` |
| Project inventory (features, endpoints) | Feature list, API endpoints | `projects/{project-name}/{artifact}/` |

### The deviation test for `projects/`

A project doc is only justified when the project **actually diverges** from what the platform doc already says. Ask: *"If an agent read the platform doc, would it get this wrong for this project?"*

- Yes → write a project deviation doc
- No → the platform doc already covers it; no project doc needed

Most knowledge lives at `universal/` or `platform/` tier. `projects/` is the exception, not the default.

### Discipline placement by natural scope

| Discipline | Default bucket | Rationale |
|---|---|---|
| `engineering` | `platform/{platform}/` | Implementation patterns are always platform-specific |
| `design` | `platform/{platform}/` for component catalogs, `universal/` for UX principles | Components are platform-specific; UX principles are not |
| `qa` | `universal/` | Test strategy and checklists are platform-agnostic |
| `agile` | `universal/` | Ceremonies and rituals are team-wide |
| `architecture` | `universal/` | ADRs and system design span platforms |
| `devops` | `universal/` for general CI/CD, `platform/{platform}/` for platform-specific build config | Depends on content |
| `security` | `universal/` | Threat models and controls apply across platforms |
| `product` | `projects/{project-name}/` | PRDs and requirements are project-specific by definition |
| `code_review` | `universal/` for general rules, `platform/{platform}/` for platform-specific linting | Depends on content |

---

## File Naming Rules

### Universal knowledge — `kms/knowledge-sources/universal/{discipline}/{artifact}/`

| Path | Example | Derived metadata |
|---|---|---|
| `universal/{discipline}/{artifact}/{file}.md` | `universal/agile/sprint-ceremonies/sprint-ceremonies.md` | `scope=universal, discipline=agile, artifact=sprint-ceremonies` |

- `{discipline}` — must match `DISCIPLINE_VALUES`
- `{artifact}` — kebab-case folder name; the named body of knowledge within the discipline
- `{file}.md` — typically matches the artifact name; multiple files per artifact are allowed for sub-areas

### Platform knowledge — `kms/knowledge-sources/platform/{platform}/{discipline}/{artifact}/`

| Path | Example | Derived metadata |
|---|---|---|
| `platform/{platform}/{discipline}/{artifact}/{file}.md` | `platform/flutter/engineering/conventions/conventions.md` | `scope=platform, platform=flutter, discipline=engineering, artifact=conventions` |

- `{platform}` — one of `flutter`, `ios`, `android`, `web`
- `{discipline}` — must match `DISCIPLINE_VALUES`
- `{artifact}` — kebab-case folder; the named body of knowledge
- No platform prefix in filenames — all metadata is directory-encoded

### Project knowledge — `kms/knowledge-sources/projects/{project-name}/{artifact}/`

| Path | Example | Derived metadata |
|---|---|---|
| `projects/{project}/{artifact}/{file}.md` | `projects/mobile-talenta/feature-inventory/feature-inventory.md` | `scope=project, artifact=feature-inventory` |

- `platform` and `project` read from `repo.yaml` — not encoded in filename
- `{artifact}` — the aspect of the project this covers (`feature-inventory`, `api-endpoints`, `deviations`, etc.)

---

## Section Structure Rules

### R1 — Use `#` to group, `##` to define retrieval units

Every file must have at least one `##` heading — it is the chunk boundary and the retrieval key. Use `#` headings to group related `##` sections under a named topic. A file with only `###` headings or no headings at all seeds as one blob.

```markdown
# Domain                  ← topic group
## Entity                 ← one node: topic=domain, pattern=entity
## Use Case               ← one node: topic=domain, pattern=use_case

# Presentation            ← topic group
## Screen Structure       ← one node: topic=presentation, pattern=screen_structure
```

### R2 — One concept per `##` heading

Each `##` section must cover exactly one concept — one pattern, one layer rule, one process template. Do not bundle multiple concepts under one heading.

```markdown
## Entity               ← one concept — correct
## Use Case             ← one concept — correct
## Entity and Use Case  ← two concepts — wrong
```

### R3 — `##` heading names are retrieval keys — name them precisely

The `##` heading text becomes the `pattern` slug. Use the canonical name for the concept — the same name used across all platforms for equivalent concepts.

```markdown
## Entity            → pattern: entity
## Use Case          → pattern: use_case
## DI Setup          → pattern: di_setup
## Screen Structure  → pattern: screen_structure
```

Avoid vague headings (`## Overview`, `## Notes`, `## Misc`) — they produce meaningless slugs and pollute query results.

### R4 — No duplicate `##` headings under the same `#` group

A duplicate `##` heading under the same parent `#` produces two nodes with identical `(discipline, artifact, topic, pattern)` — the second upsert silently overwrites the first. The same `##` heading is allowed under *different* `#` groups because `topic` (from `#`) differs.

```markdown
# Domain
## Creation Order    ← ok: topic=domain, pattern=creation_order
# Data
## Creation Order    ← ok: topic=data, pattern=creation_order — different topic, no collision

# Domain
## Entity            ← first
## Entity            ← duplicate under same # — wrong
```

### R5 — Each `##` section must be self-contained

A section returned by `kms_query` arrives without surrounding context. The agent reading it must be able to apply the knowledge without seeing the rest of the file.

Include in each section:
- A brief statement of what the concept is (1–3 lines)
- The code pattern or process template
- Any constraints or invariants the agent must enforce

Do not write sections that say "see above" or reference other sections by name.

### R6 — Internal structure uses `###` — never `##`

Within a `##` section, use `###` for internal headings (`### Theory`, `### Code Pattern`, `### Example`). Using `##` for internal structure creates extra nodes with vague slugs.

```markdown
## Entity
### Theory
### Code Pattern
### Example
```

### R7 — Oversized `##` sections are a split signal

A `##` section over ~4,000 characters likely contains multiple concepts. Split into separate `##` sections. Use `###` only for internal structure within a single concept.

---

## Discipline-Specific Heading Conventions

Each discipline has a natural `##` unit — the level at which concepts are granular enough to be individually retrievable but complete enough to be self-contained.

| Discipline | Natural `#` group | Natural `##` unit |
|---|---|---|
| `engineering` | Architecture layer (`# Domain`, `# Data`, `# Presentation`) | One pattern or concept (`## Entity`, `## Repository`) |
| `design` | Component category (`# Atoms`, `# Molecules`) | One component or token (`## MkButton`, `## Color Primary`) |
| `qa` | Test area (`# Auth`, `# Payment`) | One checklist type or test template |
| `agile` | Phase (`# Planning`, `# Review`) | One ceremony or ritual |
| `architecture` | Decision area | One ADR or architectural decision |
| `devops` | Environment or pipeline stage | One runbook or operational process |
| `security` | Threat category | One threat class or control |
| `product` | Epic or domain | One feature or product requirement |

**Naming rule:** `##` heading text = the canonical name engineers, designers, or PMs use day-to-day. This becomes the `pattern` retrieval key in ChromaDB.

**File scope:** one file per artifact folder covers one subject area. Do not mix disciplines or platforms in a single file.

Examples:
```
platform/flutter/engineering/standard-architecture/standard-architecture.md
  # Domain → ## Entity, ## Use Case, ## Repository
  # Data   → ## Repository Impl, ## Data Source
  # Presentation → ## BLoC, ## Screen

platform/flutter/design/mekari-pixel-catalog/mekari-pixel-catalog.md
  # Atoms → ## MkButton, ## MkTextField
  # Molecules → ## MkCard, ## MkBottomSheet

universal/qa/mobile-regression-checklist/mobile-regression-checklist.md
  # Auth Flow → ## Login, ## SSO
  # Payment Flow → ## Payslip, ## Reimbursement
```

---

## Project Doc Rules

Project docs live in `kms/knowledge-sources/projects/{project-name}/{artifact}/` and are generated by `kms-extract-worker`. The same chunking contract applies — artifact folder name sets the artifact metadata, `#` groups set topic, `##` headings are the retrieval units.

| Artifact folder | Recommended `#` groups | Recommended `##` unit |
|---|---|---|
| `feature-inventory` | Module or domain area | One `##` per feature — `## TimeManagement` |
| `api-endpoints` | Domain group | One `##` per resource — `## Auth`, `## Payroll` |
| `shared-components` | Component category | One `##` per component — `## MkTextField` |
| `deviations` | Deviation category | One `##` per deviation — `## Custom DI Pattern` |
| `third-party-integrations` | Integration category | One `##` per integration — `## Firebase` |

---

## What `kms_upsert` Callers Must Follow

`kms_upsert` writes directly to ChromaDB with explicit `discipline`, `artifact`, `topic`, `pattern`, and `content`. No chunking applies — the caller is responsible for granularity.

Rules for `kms_upsert` content:
- `artifact` must match the artifact folder name the knowledge belongs to (e.g. `conventions`, `standard-architecture`)
- `topic` must be the slug of the parent `#` group (or the artifact name if no `#` grouping applies)
- `pattern` must use a snake_case slug matching the canonical concept name — equivalent to a `##` heading
- `content` should cover exactly one concept — same R2 rule applies
- Do not pass a multi-section document as a single `kms_upsert` call; split and call once per concept

---

## Audit

Run `/kms-audit` to validate all files in `kms/knowledge-sources/` against these rules before seeding. The audit reports violations by severity:

| Severity | Meaning |
|---|---|
| **Error** | Blocks correct seeding — must fix before running `/kms-seed` |
| **Warning** | Degrades retrieval quality — fix before shipping to downstream plugins |

See the audit findings format in `.claude/agents/kms-source-audit-worker.md`.
