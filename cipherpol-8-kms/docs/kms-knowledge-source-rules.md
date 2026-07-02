> Author: Puras Handharmahua · 2026-06-04 · **Reconciled 2026-07-03** for the [knowledge-management redesign](../../docs/initiatives/2026-07-03-kms-knowledge-management-redesign.md)
> Related: [kms-glossary.md](../../docs/principles/kms/kms-glossary.md) · [kms-design-principles.md](../docs/principles/kms/kms-design-principles.md) · [kms-conventions.md](../docs/principles/kms/kms-conventions.md)

> **⚠ Chunking contract changed (2026-07-03).** The seeder now chunks at **`##` (one concept per node)** — `###`/`####` stay as content *inside* the node, no longer promoted to separate nodes. Facets are **frontmatter-authoritative** (path is a fallback), with new `layer` and `owner` facets. Rules below reflect the new model; the composite-id `###`-promotion contract is retired.

## What This Doc Covers

Authoring rules for every file written to `knowledge-sources/`. These rules enforce the chunking contract: the seeder maps `#` headings to `topic` and each `##` heading to **one self-contained `KnowledgeNode`** (its `###`/`####` children are the node's body). A file that violates these rules seeds incorrectly — as an unsearchable blob, or as nodes with colliding or vague retrieval keys.

---

## Chunking Contract

The `DirectorySource` seeder chunks at the `##` level — **one concept per node** — before inserting into ChromaDB:

| Level | Role | Maps to |
|---|---|---|
| `#` | Topic — thematic group (and CLEAN-layer marker for engineering: `# Domain`/`# Data`/`# Presentation`) | `topic` field; also derives `layer` |
| `##` | The retrieval unit — **one `KnowledgeNode`**, including everything beneath it | `subtopic` **and** `pattern` (they are equal — the `section` slug) |
| `###` / `####`+ | Internal body structure within the node (theory, code pattern, examples) | Content only; **not** a chunk boundary |

- Each `##` heading → exactly one `KnowledgeNode`. Its `###`/`####` children (theory, code, examples) stay **inside** that node — they are no longer split out.
- `##` heading text → `section` slug (lowercased, spaces → underscores, symbols stripped); stored as both `subtopic` and `pattern`.
- Parent `#` heading text → `topic` slug; artifact name if no `#` above.
- **Preamble** before the first `##` is captured as an `overview` node when it holds real prose — never discarded.
- Files with no `##` headings → one node for the whole file.

**The `##` section is the retrieval key.** Name it as a complete concept: `entity`, `use_case`, `null_safety_extensions`. The node carries its own theory + code together, so a single retrieval is enough to act on.

---

## Frontmatter & Facets

Facets are **frontmatter-authoritative** — a value in the file's YAML frontmatter wins; the directory path is the fallback. Invalid facet values are **reported and skipped** (never silently mis-seeded).

| Facet | Source | Values |
|---|---|---|
| `platform` / `project` | frontmatter → path/`repo.yaml` | `PLATFORM_VALUES` / project name |
| `discipline` | frontmatter → path | `DISCIPLINE_VALUES` |
| `layer` | frontmatter → `#`-topic marker → `cross` | `domain` / `data` / `presentation` / `cross` |
| `owner` | frontmatter (default `curated`) | `curated` (hand-owned) / `extracted` (scanner-regenerated) |
| `tags` | frontmatter | free-form (design-system catalogs use `tags: [design-system]` under `discipline: design`) |

- **`layer`** enables per-agent scoping — a `domain-planner` retrieves `layer ∈ {domain, cross}` and never sees data-layer nodes. If you don't set it, engineering docs inherit it from the `#` topic marker; everything else floors to `cross` (always in-scope).
- **`owner: extracted`** marks machine-generated files (feature-inventory, api-endpoints) that scanners regenerate wholesale — never hand-edit them.

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
| Implementation pattern tied to one platform | Flutter BLoC pattern, iOS UIKit coordinator | `platform/{platform}/engineering/` |
| UI component catalog for one platform | Flutter Mekari Pixel catalog | `platform/{platform}/design/` (`tags: [design-system]`) |
| Project deviates from the platform standard | Custom DI pattern, non-standard folder structure | `projects/{project-name}/{discipline}/` |
| Project inventory (features, endpoints) | Feature list, API endpoints | `projects/{project-name}/{discipline}/` |

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

Paths are **3-level** — no `area` segment (removed 2026-07-03). Design-system catalogs live under `discipline: design` with `tags: [design-system]`.

### Universal knowledge — `knowledge-sources/universal/{discipline}/`

| Path | Example | Derived metadata |
|---|---|---|
| `universal/{discipline}/{artifact}.md` | `universal/agile/sprint-ceremonies.md` | `scope=universal, discipline=agile, artifact=sprint-ceremonies` |

- `{discipline}` — must match `DISCIPLINE_VALUES`
- `{artifact}.md` — kebab-case filename stem; the named body of knowledge within the discipline

### Platform knowledge — `knowledge-sources/platform/{platform}/{discipline}/`

| Path | Example | Derived metadata |
|---|---|---|
| `platform/{platform}/{discipline}/{artifact}.md` | `platform/flutter/engineering/conventions.md` | `scope=platform, platform=flutter, discipline=engineering, artifact=conventions` |

- `{platform}` — one of `flutter`, `ios`, `android`, `web`
- `{discipline}` — must match `DISCIPLINE_VALUES`
- `{artifact}.md` — kebab-case filename stem; the named body of knowledge
- No platform prefix in filenames — all metadata is directory- or frontmatter-encoded
- Design-system catalog: `platform/{platform}/design/{system}.md` (e.g. `mekari-pixel.md`) with `tags: [design-system]`

### Project knowledge — `knowledge-sources/projects/{project-name}/{discipline}/`

| Path | Example | Derived metadata |
|---|---|---|
| `projects/{project}/{discipline}/{artifact}.md` | `projects/mobile-talenta/engineering/feature-inventory.md` | `scope=project, discipline=engineering, artifact=feature-inventory` |

- `platform` and `project` read from `repo.yaml` — not encoded in filename
- `{artifact}.md` — kebab-case filename stem; the aspect of the project this covers (`feature-inventory`, `api-endpoints`, `deviations`, etc.)

---

## Section Structure Rules

### R1 — Use `#` to group, `##` to define the retrieval unit

Every file must have at least one `##` heading — it is the chunk boundary and the node. Use `#` headings to group related `##` sections under a named topic (and, for engineering, to mark the CLEAN layer). A file with no `##` headings seeds as one node for the whole file.

```markdown
# Domain                  ← topic group + layer marker (layer=domain)
## Entity                 ← one node: topic=domain, section=entity
## Use Case               ← one node: topic=domain, section=use_case
### Theory                ←   body of the use_case node (not a separate node)
### Code Pattern          ←   body of the use_case node

# Presentation            ← topic group + layer marker (layer=presentation)
## Screen Structure       ← one node: topic=presentation, section=screen_structure
```

### R2 — One concept per `##`

Each `##` section is one node and must cover exactly one concept: one pattern, one layer rule, one process template. Its `###` children are facets *of that one concept* (theory, code, example) — not separate concepts. Do not bundle two concepts under one `##`.

```markdown
## Entity                        ← one concept — correct
## Use Case                      ← one concept; ### Theory / ### Code Pattern are its body — correct
## Entity and Use Case           ← two concepts in one heading — wrong (split into two ##)
```

### R3 — Heading names are retrieval keys — name them precisely

The `##` heading text becomes the `section` slug (stored as both `subtopic` and `pattern`). Use the canonical name for the concept — the same name used across all platforms for equivalent concepts.

```markdown
## Entity            → section: entity
## DI Setup          → section: di_setup
## Use Case          → section: use_case   (### Theory / ### Code Pattern are its body)
```

Avoid vague headings (`## Overview`, `## Notes`, `## Misc`) — they produce meaningless slugs and pollute query results.

### R4 — No duplicate `##` headings under the same `#`

A duplicate `##` heading under the same parent `#` produces two nodes with the same id key `(source_file, topic, section)` — the second silently overwrites the first. The same `##` is allowed under *different* `#` topics because the `topic` slug differs (this is why `topic` is part of the node id).

```markdown
# Domain
## Creation Order    ← ok: topic=domain, section=creation_order
# Data
## Creation Order    ← ok: topic=data, section=creation_order — different topic, distinct node

# Domain
## Entity            ← first
## Entity            ← duplicate ## under same # — wrong (second overwrites first)
```

### R5 — Each `##` node must be self-contained

A node returned by `kms_query` arrives without surrounding context. The agent reading it must be able to apply the knowledge without seeing the rest of the file.

Include in each `##` node:
- A brief statement of what the concept is (1–3 lines)
- The code pattern or process template (as `###`/`####` body)
- Any constraints or invariants the agent must enforce

Do not write nodes that say "see above" or reference other sections by name. (Preamble before the first `##` is captured as an `overview` node, so intro context is retained — but each `##` should still stand alone.)

### R6 — `###`/`####` are the node's internal structure — use them freely

`###` and deeper headings live **inside** the enclosing `##` node — theory, code pattern, examples, edge cases. They are no longer promoted to separate nodes, so you can structure a concept as richly as it needs without fragmenting retrieval.

```markdown
## Use Case
### Theory          ← body of the use_case node
### Code Pattern    ← body of the use_case node
#### Edge Cases     ← body of the use_case node
### Example         ← body of the use_case node
```

### R7 — Oversized sections are a split signal

A `##` node over ~4,000 characters likely bundles multiple concepts. Split it into **sibling `##` sections**, each a distinct concept — not into `###` (which stay inside a single node now). Use `###`/`####` for the internal structure of one concept, not to separate concepts.

---

## Discipline-Specific Heading Conventions

Each discipline has a natural `##` unit (the node) and — for theory-heavy disciplines — a natural `###` internal structure *within* that node. Concepts must be granular enough to be individually retrievable but complete enough to be self-contained.

| Discipline | Natural `#` group | Natural `##` unit (the node) | Natural `###` internal structure |
|---|---|---|---|
| `engineering` | Architecture layer (`# Domain`, `# Data`, `# Presentation`) | One pattern or concept (`## Entity`, `## Use Case`) | `### Theory`, `### Code Pattern`, `### Example` |
| `design` | Component category (`# Atoms`, `# Molecules`) | One component or token (`## MkButton`, `## Color Primary`) | usually none — flat |
| `qa` | Test area (`# Auth`, `# Payment`) | One checklist type or test template | optional — `### Steps`, `### Expected Result` |
| `agile` | Phase (`# Planning`, `# Review`) | One ceremony or ritual | usually none |
| `architecture` | Decision area | One ADR or architectural decision | optional — `### Context`, `### Decision`, `### Consequences` |
| `devops` | Environment or pipeline stage | One runbook or operational process | optional — `### Steps`, `### Rollback` |
| `security` | Threat category | One threat class or control | optional — `### Threat`, `### Mitigation` |
| `product` | Epic or domain | One feature or product requirement | usually none |

**Naming rule:** the `##` heading text = the canonical name engineers, designers, or PMs use day-to-day. It becomes the `section` key in ChromaDB. `###` headings organize that node's body; they are not separate keys.

**File scope:** one file per artifact folder covers one subject area. Do not mix disciplines or platforms in a single file.

Examples:
```
platform/flutter/engineering/standard-architecture.md
  # Domain → ## Entity, ## Use Case (### Theory, ### Code Pattern are the node body)
  # Data   → ## Repository Impl, ## Data Source
  # Presentation → ## BLoC

platform/flutter/design/mekari-pixel.md   (tags: [design-system])
  # Atoms → ## MpButton, ## MpTextField
  # Components → ## MpCard, ## MpBottomSheet

universal/qa/mobile-regression-checklist.md
  # Auth Flow → ## Login, ## SSO
  # Payment Flow → ## Payslip, ## Reimbursement
```

---

## Project Doc Rules

Project docs live in `knowledge-sources/projects/{project-name}/{discipline}/` and are generated by `kms-extract-worker`. The same chunking contract applies — the artifact filename stem sets the artifact metadata, `#` groups set topic, and each `##` heading is one retrieval node (its `###`/`####` are the node body).

| Artifact folder | Recommended `#` groups | Recommended `##` unit |
|---|---|---|
| `feature-inventory` | Module or domain area | One `##` per feature — `## TimeManagement` |
| `api-endpoints` | Domain group | One `##` per resource — `## Auth`, `## Payroll` |
| `shared-components` | Component category | One `##` per component — `## MkTextField` |
| `deviations` | Deviation category | One `##` per deviation — `## Custom DI Pattern` |
| `third-party-integrations` | Integration category | One `##` per integration — `## Firebase` |

---

## What `kms_upsert` Callers Must Follow

`kms_upsert` writes directly to ChromaDB with explicit `discipline`, `artifact`, `topic`, `pattern`, `content`, and optionally `subtopic`. No chunking applies — the caller is responsible for granularity.

Rules for `kms_upsert` content:
- `artifact` must match the artifact filename (without extension, snake_cased) the knowledge belongs to (e.g. `conventions`, `standard_architecture`)
- `topic` must be the slug of the parent `#` group (or the artifact name if no `#` grouping applies)
- `pattern` = the `section` slug — the canonical concept name, equivalent to a `##` heading. `subtopic` should match `pattern` (they are equal under the `##`-concept model); omit it to default to `pattern`
- `content` should cover exactly one `##` concept, theory + code together — same R2 rule applies
- Do not pass a multi-section document as a single `kms_upsert` call; split and call once per `##` concept

---

## Audit

Run `/kms-audit` to validate all files in `kms/knowledge-sources/` against these rules before seeding. The audit reports violations by severity:

| Severity | Meaning |
|---|---|
| **Error** | Blocks correct seeding — must fix before running `/kms-seed` |
| **Warning** | Degrades retrieval quality — fix before shipping to downstream plugins |

See the audit findings format in `.claude/agents/kms-source-audit-worker.md`.
