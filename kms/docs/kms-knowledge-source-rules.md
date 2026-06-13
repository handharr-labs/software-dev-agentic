> Author: Puras Handharmahua · 2026-06-04
> Related: [kms-glossary.md](../../docs/principles/kms/kms-glossary.md) · [kms-design-principles.md](../docs/principles/kms/kms-design-principles.md) · [kms-conventions.md](../docs/principles/kms/kms-conventions.md)

## What This Doc Covers

Authoring rules for every file written to `kms/knowledge-sources/`. These rules enforce the chunking contract: the seeder maps `#` headings to `topic`, `##` headings to `subtopic`, and — depth-aware — either `###` headings or the `##` heading itself to `pattern`, with `####`+ as internal structure within a node. A file that violates these rules seeds incorrectly — either as an unsearchable blob or as nodes with colliding or vague retrieval keys.

---

## Chunking Contract

The `DirectorySource` seeder applies a depth-aware, three-level heading hierarchy before inserting into ChromaDB:

| Level | Role | Maps to |
|---|---|---|
| `#` | Topic — thematic group | `topic` field on all child nodes |
| `##` | Sub-topic — groups related patterns, or is the node itself if it has no `###` children | `subtopic` field on all child nodes; also `pattern` when there are no `###` children |
| `###` | Pattern — one `KnowledgeNode`, when present under a `##` | `pattern` field; one node per `###` |
| `####`+ | Internal body structure | Content only; not a chunk boundary |

- If a `##` heading has `###` children: each `###` heading → one `KnowledgeNode`, `subtopic` = `##` slug, `pattern` = `###` slug
- If a `##` heading has no `###` children: the `##` heading itself → one `KnowledgeNode`, `subtopic == pattern` = `##` slug
- `##`/`###` heading text → slug (lowercased, spaces → underscores, symbols stripped)
- Parent `#` heading text → `topic` slug on that node; artifact name if no `#` above
- Content between a `##` heading and its first `###` child (if any) is discarded — give it its own `###` section if it needs to be retrievable
- `####`+ headings stay inside the enclosing `###` (or `##`, if no `###` children) — not split further
- Files with no `##` headings → one blob node for the whole file (avoid — blob is only reachable via vector search)

**`pattern` is the retrieval key.** Name `##`/`###` headings as you would name a concept: `entity`, `use_case`, `theory`, `code_pattern`. Agents query by semantic text and ChromaDB matches against these chunk contents.

**Two valid shapes for a `##` section:**
- **Flat** (catalog-style, e.g. a design-system component catalog): `## MpButton` with no `###` children — one node, `subtopic == pattern == mp_button`.
- **Nested** (theory-heavy, e.g. standard architecture docs): `## Use Case` with `### Theory`, `### Code Pattern`, `### Example` children — three nodes, all `subtopic=use_case`, `pattern` = `theory` / `code_pattern` / `example`.

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
| SDLC process applies to all platforms | Sprint retrospective guide, PR review checklist | `universal/{discipline}/core/` |
| Architecture principle applies to all platforms | Clean Architecture layers, SOLID rules | `universal/engineering/core/` |
| Implementation pattern tied to one platform | Flutter BLoC pattern, iOS UIKit coordinator | `platform/{platform}/engineering/core/{artifact}/` |
| UI component catalog for one platform | Flutter Mekari Pixel catalog | `platform/{platform}/design/design-system/{artifact}/` |
| Project deviates from the platform standard | Custom DI pattern, non-standard folder structure | `projects/{project-name}/core/{artifact}/` |
| Project inventory (features, endpoints) | Feature list, API endpoints | `projects/{project-name}/core/{artifact}/` |

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

### Universal knowledge — `kms/knowledge-sources/universal/{discipline}/{area}/{artifact}/`

| Path | Example | Derived metadata |
|---|---|---|
| `universal/{discipline}/{area}/{artifact}/{file}.md` | `universal/agile/core/sprint-ceremonies/sprint-ceremonies.md` | `scope=universal, discipline=agile, area=core, artifact=sprint-ceremonies` |

- `{discipline}` — must match `DISCIPLINE_VALUES`
- `{area}` — must match `AREA_VALUES` (`core` | `design-system`); fixed vocabulary, inserted between `discipline` and `artifact`
- `{artifact}` — kebab-case folder name; the named body of knowledge within the discipline
- `{file}.md` — typically matches the artifact name; multiple files per artifact are allowed for sub-areas

### Platform knowledge — `kms/knowledge-sources/platform/{platform}/{discipline}/{area}/{artifact}/`

| Path | Example | Derived metadata |
|---|---|---|
| `platform/{platform}/{discipline}/{area}/{artifact}/{file}.md` | `platform/flutter/engineering/core/conventions/conventions.md` | `scope=platform, platform=flutter, discipline=engineering, area=core, artifact=conventions` |

- `{platform}` — one of `flutter`, `ios`, `android`, `web`
- `{discipline}` — must match `DISCIPLINE_VALUES`
- `{area}` — must match `AREA_VALUES` (`core` | `design-system`); fixed vocabulary, inserted between `discipline` and `artifact`
- `{artifact}` — kebab-case folder; the named body of knowledge
- No platform prefix in filenames — all metadata is directory-encoded

**`area` convention:** `core` is for standard platform-owned artifacts (conventions, standard-architecture, etc.). `design-system` is for design-system catalogs, where `{artifact}` becomes the specific design system name (e.g. `mekari-pixel`) — this lets multiple design systems coexist per platform (e.g. a future `legacy-kit`) without folder-name collisions.

### Project knowledge — `kms/knowledge-sources/projects/{project-name}/{area}/{artifact}/`

| Path | Example | Derived metadata |
|---|---|---|
| `projects/{project}/{area}/{artifact}/{file}.md` | `projects/mobile-talenta/core/feature-inventory/feature-inventory.md` | `scope=project, area=core, artifact=feature-inventory` |

- `platform` and `project` read from `repo.yaml` — not encoded in filename
- `{area}` — must match `AREA_VALUES` (`core` | `design-system`); fixed vocabulary, inserted between the project directory and `artifact`
- `{artifact}` — the aspect of the project this covers (`feature-inventory`, `api-endpoints`, `deviations`, etc.)

---

## Section Structure Rules

### R1 — Use `#` to group, `##` to define retrieval units (or groups of them)

Every file must have at least one `##` heading — it is the chunk boundary. Use `#` headings to group related `##` sections under a named topic. A file with only `###` headings or no headings at all seeds as one blob.

```markdown
# Domain                  ← topic group
## Entity                 ← one node: topic=domain, subtopic=entity, pattern=entity (no ### children)
## Use Case               ← group node: topic=domain, subtopic=use_case
### Theory                ←   node: topic=domain, subtopic=use_case, pattern=theory
### Code Pattern          ←   node: topic=domain, subtopic=use_case, pattern=code_pattern

# Presentation            ← topic group
## Screen Structure       ← one node: topic=presentation, subtopic=screen_structure, pattern=screen_structure
```

### R2 — One concept per pattern (`##` or `###`)

Each retrieval unit — a `##` with no `###` children, or each `###` under a `##` — must cover exactly one concept: one pattern, one layer rule, one process template. Do not bundle multiple concepts under one heading.

```markdown
## Entity               ← one concept — correct
## Use Case             ← group, fine if split into ### Theory / ### Code Pattern / ### Example
## Entity and Use Case  ← two concepts in one flat heading — wrong

### Theory              ← one concept — correct
### Theory and Example  ← two concepts — wrong
```

### R3 — Heading names are retrieval keys — name them precisely

The `##` heading text becomes the `subtopic` slug (and `pattern`, if it has no `###` children). The `###` heading text becomes the `pattern` slug when present. Use the canonical name for the concept — the same name used across all platforms for equivalent concepts.

```markdown
## Entity            → subtopic: entity,    pattern: entity      (no ### children)
## DI Setup          → subtopic: di_setup,  pattern: di_setup    (no ### children)
## Use Case          → subtopic: use_case
### Theory           →   pattern: theory
### Code Pattern     →   pattern: code_pattern
```

Avoid vague headings (`## Overview`, `## Notes`, `## Misc`, `### Misc`) — they produce meaningless slugs and pollute query results.

### R4 — No duplicate headings at the same level under the same parent

A duplicate `##` heading under the same parent `#` produces two nodes with identical `(discipline, artifact, topic, subtopic, pattern)` — the second upsert silently overwrites the first. The same applies to duplicate `###` headings under the same `##`. The same heading is allowed under *different* parents because the parent slug (`topic` or `subtopic`) differs.

```markdown
# Domain
## Creation Order    ← ok: topic=domain, subtopic=creation_order, pattern=creation_order
# Data
## Creation Order    ← ok: topic=data, subtopic=creation_order, pattern=creation_order — different topic, no collision

# Domain
## Entity            ← first
## Entity            ← duplicate ## under same # — wrong

## Use Case
### Theory           ← first
### Theory           ← duplicate ### under same ## — wrong (this is why subtopic is in the node id)
```

### R5 — Each retrieval unit must be self-contained

A node returned by `kms_query` arrives without surrounding context. The agent reading it must be able to apply the knowledge without seeing the rest of the file. This applies to whichever level is the retrieval unit — a flat `##` with no `###` children, or each `###` under a `##`.

Include in each node:
- A brief statement of what the concept is (1–3 lines)
- The code pattern or process template
- Any constraints or invariants the agent must enforce

Do not write nodes that say "see above" or reference other sections by name. Content written between a `##` heading and its first `###` child is discarded by the seeder — it cannot carry context into the `###` nodes.

### R6 — `###` becomes its own retrievable node when present — name it like a pattern

When a `##` heading has `###` children, each `###` is promoted to its own `KnowledgeNode` (`subtopic` = `##` slug, `pattern` = `###` slug). Name `###` headings as you would name `##` headings under R3 — they are retrieval keys, not free-form notes. `####`+ is the level reserved for true internal structure that should never be split (code blocks, sub-steps, examples within a pattern).

```markdown
## Use Case
### Theory          ← own node: pattern=theory
### Code Pattern    ← own node: pattern=code_pattern
#### Edge Cases     ← stays inside the Code Pattern node — not split further
### Example         ← own node: pattern=example
```

If a `##` section has no natural `###` split (e.g. one catalog component, one checklist item), leave it flat — it becomes a single node with `subtopic == pattern`.

### R7 — Oversized sections are a split signal

A node (flat `##`, or a `###` under a `##`) over ~4,000 characters likely contains multiple concepts. If it's a flat `##`, split it into `### Theory` / `### Code Pattern` / `### Example` (or similar) children — each becomes its own node. If it's already a `###`, split it into a separate `###` sibling under the same `##`. Use `####`+ only for internal structure within a single pattern.

---

## Discipline-Specific Heading Conventions

Each discipline has a natural `##` unit, and — for theory-heavy disciplines — a natural `###` split within it. Concepts must be granular enough to be individually retrievable but complete enough to be self-contained.

| Discipline | Natural `#` group | Natural `##` unit | Natural `###` split (if any) |
|---|---|---|---|
| `engineering` | Architecture layer (`# Domain`, `# Data`, `# Presentation`) | One pattern or concept (`## Entity`, `## Use Case`) | `### Theory`, `### Code Pattern`, `### Example` |
| `design` | Component category (`# Atoms`, `# Molecules`) | One component or token (`## MkButton`, `## Color Primary`) | usually none — flat, `subtopic == pattern` |
| `qa` | Test area (`# Auth`, `# Payment`) | One checklist type or test template | optional — `### Steps`, `### Expected Result` |
| `agile` | Phase (`# Planning`, `# Review`) | One ceremony or ritual | usually none |
| `architecture` | Decision area | One ADR or architectural decision | optional — `### Context`, `### Decision`, `### Consequences` |
| `devops` | Environment or pipeline stage | One runbook or operational process | optional — `### Steps`, `### Rollback` |
| `security` | Threat category | One threat class or control | optional — `### Threat`, `### Mitigation` |
| `product` | Epic or domain | One feature or product requirement | usually none |

**Naming rule:** `##`/`###` heading text = the canonical name engineers, designers, or PMs use day-to-day. The retrieval-unit heading becomes the `pattern` key in ChromaDB; its parent `##` becomes `subtopic`.

**File scope:** one file per artifact folder covers one subject area. Do not mix disciplines or platforms in a single file.

Examples:
```
platform/flutter/engineering/core/standard-architecture/standard-architecture.md
  # Domain → ## Entity (flat), ## Use Case → ### Theory, ### Code Pattern, ### Example
  # Data   → ## Repository Impl, ## Data Source
  # Presentation → ## BLoC → ### Theory, ### Code Pattern

platform/flutter/design/design-system/mekari-pixel/mekari-pixel-design-system.md
  # Atoms → ## MpButton, ## MpTextField   (flat — subtopic == pattern)
  # Components → ## MpCard, ## MpBottomSheet

universal/qa/mobile-regression-checklist/mobile-regression-checklist.md
  # Auth Flow → ## Login, ## SSO
  # Payment Flow → ## Payslip, ## Reimbursement
```

---

## Project Doc Rules

Project docs live in `kms/knowledge-sources/projects/{project-name}/{area}/{artifact}/` (typically `area=core`) and are generated by `kms-extract-worker`. The same chunking contract applies — artifact folder name sets the artifact metadata, `#` groups set topic, `##` headings are the subtopic/retrieval units (split into `###` only if a feature/endpoint/component needs Theory/Code Pattern/Example granularity).

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
- `artifact` must match the artifact folder name the knowledge belongs to (e.g. `conventions`, `standard-architecture`)
- `topic` must be the slug of the parent `#` group (or the artifact name if no `#` grouping applies)
- `subtopic` must be the slug of the parent `##` group — omit it to default to `pattern` (no `##`/`###` split)
- `pattern` must use a snake_case slug matching the canonical concept name — equivalent to a `###` heading if a `##` parent exists, else a `##` heading
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
