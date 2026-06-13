> Author: Puras Handharmahua · 2026-06-13
> Related: [glossary.md](glossary.md) · [repo-structure.md](repo-structure.md) · [agentic/](agentic/) · [kms/](kms/)

## What This Doc Covers

How docs in `docs/principles/` are classified. Every doc answers a fixed combination of questions — use this to find the right doc, or to know where a new doc belongs.

## The Framework

| # | Category | Answers | File suffix |
|---|----------|---------|--------------|
| 1 | **Glossarium** | What does this term mean? | `*-glossary.md` |
| 2 | **Core Design** | What is this, and why does it exist this way? | `*-design-principles.md` |
| 3 | **Convention** | What are the rules — how and when do I apply them? | `*-conventions.md` |
| 4 | **Directory Structure** | What lives where? | `*-directory-structure.md`, `repo-structure.md` |
| 5 | **Process** | What is the sequence of steps — what+how+when+order? | `*-<process-name>.md` (e.g. `*-seeding.md`) |

Each module (`agentic/`, `kms/`) has one doc per category 1-4. Category 5 is optional per module — only present when a module has a multi-step workflow that doesn't fit the static rulebook shape of Convention. Root-level docs (`glossary.md`, `repo-structure.md`) are the cross-module roll-ups for categories 1 and 4 — start there if you don't know which module a term or path belongs to.

## Classification

### Root (cross-module)

| Doc | Category |
|-----|----------|
| [glossary.md](glossary.md) | 1 — Glossarium (index across all modules) |
| [repo-structure.md](repo-structure.md) | 4 — Directory Structure (delivery mechanism, plugin layout) |

### agentic/

| Doc | Category |
|-----|----------|
| [agentic-glossary.md](agentic/agentic-glossary.md) | 1 — Glossarium |
| [agentic-design-principles.md](agentic/agentic-design-principles.md) | 2 — Core Design |
| [agentic-conventions.md](agentic/agentic-conventions.md) | 3 — Convention |
| [agentic-directory-structure.md](agentic/agentic-directory-structure.md) | 4 — Directory Structure |

### kms/

| Doc | Category |
|-----|----------|
| [kms-glossary.md](kms/kms-glossary.md) | 1 — Glossarium (quick-reference term definitions) |
| [kms-design-principles.md](kms/kms-design-principles.md) | 2 — Core Design |
| [kms-conventions.md](kms/kms-conventions.md) | 3 — Convention (incl. Rosetta Stone: paths, metadata fields, worked examples, retrieval funnel) |
| [kms-directory-structure.md](kms/kms-directory-structure.md) | 4 — Directory Structure |
| [kms-seeding.md](kms/kms-seeding.md) | 5 — Process (seeding workflow — how knowledge enters the KMS, in sequence) |

## Adding a New Doc

1. Pick the module (`agentic/`, `kms/`, or root if cross-module).
2. Pick the category from the table above — if a doc would answer two categories, split it.
3. Name it `<module>-<category-suffix>.md` (e.g. `kms-conventions.md`).
4. Add `> Author:` and `> Related:` header lines pointing to the other docs in the same module.
5. Add a row to this file.
