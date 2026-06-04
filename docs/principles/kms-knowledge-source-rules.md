> Author: Puras Handharmahua · 2026-06-04
> Related: kms-design-principles.md

## What This Doc Covers

Authoring rules for every file written to `kms/knowledge-sources/`. These rules enforce the chunking contract: the seeder splits files by `##` headings, and each heading becomes one ChromaDB node. A file that violates these rules seeds incorrectly — either as an unsearchable blob or as malformed nodes.

---

## Chunking Contract

The `DirectorySource` seeder chunks every file by `##` (level-2) headings before inserting into ChromaDB:

- Each `##` heading → one `KnowledgeNode`
- Heading text → `topic` and `pattern` slug (lowercased, spaces → underscores, symbols stripped)
- Files with no `##` headings → one node for the whole file (blob, avoid)

This means **heading names are the retrieval keys**. Name them as you would name a pattern: `entity`, `use_case`, `di_setup`, `bloc`. Agents query by semantic text, and ChromaDB matches against these chunk contents.

---

## File Naming Rules

### Platform / universal knowledge — `kms/knowledge-sources/{discipline}/`

| Convention | Example | Derived metadata |
|---|---|---|
| `{platform}-{topic-slug}.md` | `ios-standard-architecture.md` | `platform=ios, scope=platform` |
| `{topic-slug}.md` | `sprint-retrospective-guide.md` | `platform=None, scope=universal` |

- `{discipline}` — subdirectory must match a value in `DISCIPLINE_VALUES` (`engineering`, `design`, `qa`, etc.)
- `{platform}` prefix — one of `flutter`, `ios`, `android`, `web` exactly
- `{topic-slug}` — kebab-case, describes the file's subject area

### Project knowledge — `kms/knowledge-sources/projects/{project-name}/`

| Convention | Example | Derived metadata |
|---|---|---|
| `{topic-slug}.md` | `feature-inventory.md` | `scope=project, topic=feature_inventory` |

- `platform` and `project` read from `repo.yaml` in the project directory — not encoded in the filename
- Each file covers one aspect of the project (features, endpoints, deviations, etc.)

---

## Section Structure Rules

### R1 — Every file must use `##` headings

A file with no `##` headings seeds as one blob. A blob is retrievable only if the query happens to match the whole file's embedding — effectively unsearchable for specific concepts.

**Required:** every knowledge file must have at least one `##` heading.

### R2 — One concept per `##` heading

Each `##` section must cover exactly one concept — one artifact pattern, one layer rule, one process template. Do not bundle multiple concepts under one heading.

```markdown
## Entity          ← one concept — correct
## Use Case        ← one concept — correct
## Entity and Use Case  ← two concepts — wrong
```

### R3 — Heading names are retrieval keys — name them precisely

The heading text becomes the `topic` and `pattern` slug. Use the canonical name for the concept — the same name used across all platforms for equivalent concepts.

```markdown
## Entity            → slug: entity
## Use Case          → slug: use_case
## DI Setup          → slug: di_setup
## Screen Structure  → slug: screen_structure
```

Avoid vague headings (`## Overview`, `## Notes`, `## Misc`) — they produce meaningless slugs and pollute query results.

### R4 — No duplicate `##` headings within a file

Duplicate headings produce two nodes with identical `(platform, discipline, topic, pattern)` — the second upsert silently overwrites the first.

```markdown
## Dependency Rule   ← first occurrence
## Data Layer
## Dependency Rule   ← duplicate — wrong; use ## Data Layer Dependency Rule instead
```

### R5 — Each section must be self-contained

A section returned by `kms_query` arrives without surrounding context. The agent reading it must be able to apply the knowledge without seeing the rest of the file.

Include in each section:
- A brief statement of what the concept is (1–3 lines)
- The code pattern or process template
- Any constraints or invariants the agent must enforce

Do not write sections that say "see above" or reference other sections by name.

### R6 — Subsection headings use `###` — never `##`

Within a section, use `###` for internal structure (`### Theory`, `### Definition`, `### Code Pattern`). Using `##` for internal structure creates extra nodes with likely-vague slugs.

```markdown
## Entity
### Theory
### Definition
### Code Pattern
```

### R7 — Oversized sections are a split signal

A `##` section over ~4,000 characters likely contains multiple concepts. Split into separate `##` sections. Use `###` only for internal structure within a single concept.

---

## Discipline-Specific Heading Templates

Each discipline has a natural unit of knowledge — one `##` heading per unit. Use the table below when authoring files for a specific discipline.

| Discipline | Natural `##` unit | Example headings |
|---|---|---|
| `engineering` | One pattern or concept within a layer | `## Entity`, `## Use Case`, `## DI Setup`, `## Screen Structure` |
| `design` | One component or design token | `## MkTextField`, `## MkButton`, `## Color Tokens` |
| `qa` | One checklist type or test template | `## Regression Checklist`, `## API Contract Test`, `## Smoke Test` |
| `agile` | One ceremony or ritual | `## Sprint Retrospective`, `## Refinement`, `## Daily Standup` |
| `architecture` | One ADR or architectural decision | `## ADR-001 Monorepo Structure`, `## ADR-002 BFF Pattern` |
| `devops` | One runbook or operational process | `## Deploy to Staging`, `## Rollback Procedure`, `## Alert Triage` |
| `security` | One threat class or control | `## SQL Injection`, `## JWT Expiry`, `## Secret Rotation` |
| `product` | One feature or product requirement | `## Leave Request`, `## Payroll Run`, `## Reimbursement` |

**Naming rule:** heading text = the canonical name for that unit — the name engineers, designers, or PMs use day-to-day. This becomes the retrieval key in ChromaDB. Avoid generic names like `## Overview` or `## General` (violates R3).

**File scope:** one file covers one subject area within a discipline. Do not mix disciplines or platforms in a single file. Platform-specific files use the `{platform}-` filename prefix.

Examples:

```
engineering/flutter-standard-architecture.md   → ## Entity, ## Use Case, ## Bloc ...
design/flutter-mekari-pixel-catalog.md         → ## MkTextField, ## MkButton ...
qa/mobile-regression-checklist.md             → ## Auth Flow, ## Payment Flow ...
agile/sprint-ceremonies.md                    → ## Sprint Planning, ## Retrospective ...
architecture/flutter-adr.md                   → ## ADR-001 Clean Architecture Adoption ...
```

---

## Project Doc Rules

Project docs live in `kms/knowledge-sources/projects/{project-name}/` and are generated by `kms-extract-worker`. The same chunking contract applies.

| Doc type | Recommended `##` structure |
|---|---|
| `feature-inventory.md` | One `##` per feature — `## FeatureName` |
| `api-endpoints.md` | One `##` per resource or domain group — `## Auth`, `## Payroll` |
| `shared-components.md` | One `##` per component — `## MkTextField` |
| `deviations.md` | One `##` per deviation — `## Custom DI Pattern` |
| `third-party-integrations.md` | One `##` per integration — `## Firebase` |

---

## What `kms_upsert` Callers Must Follow

`kms_upsert` writes directly to ChromaDB with explicit `topic`, `pattern`, and `content`. No chunking applies — the caller is responsible for granularity.

Rules for `kms_upsert` content:
- `topic` and `pattern` must use snake_case slugs matching the canonical concept name
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
