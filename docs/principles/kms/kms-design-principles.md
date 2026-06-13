> Author: Puras Handharmahua · 2026-06-04
> Related: [kms-glossary.md](kms-glossary.md) · [kms-conventions.md](kms-conventions.md) · [kms-seeding.md](kms-seeding.md)

## What is the KMS?

A ChromaDB-backed knowledge store shipped inside the Claude Code plugin. Agents retrieve implementation patterns, SDLC processes, and role knowledge via MCP tools instead of grepping flat files. Single DB, two query modes — exact metadata fetch for precision, vector search for discovery.

> One store. Two query modes. All SDLC knowledge.

---

## Design Goals

1. **Drop-in knowledge** — drop any doc into `kms/knowledge-sources/` and the system derives scope, platform, discipline, artifact, topic, subtopic, and pattern from the path and headings — frontmatter is documentation-only, not required by the seeder. This path → metadata derivation is the **Knowledge Path Structure**, defined in [kms-conventions.md](kms-conventions.md#kmsknowledge-sources--path-conventions)
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

---

## Architecture

```
MCP Server (application)
  └─ Use Cases (domain)
       └─ KnowledgeRepository (abstract interface)
            └─ ChromaKnowledgeRepository (data)
```

**Dependency rule:** nothing in domain or application imports ChromaDB directly. Swapping ChromaDB for another vector store is a data layer change only.

---

## What Does Not Belong Here

- **Feature knowledge** (API contracts, data models, HLD) → Feature KMS (`librarian` persona, `docs/feature-docs/`)
- **Agent/skill conventions** → `docs/principles/agentic/agentic-conventions.md`
- **Raw knowledge documents** (the actual content) → `kms/knowledge-sources/`

---

## Changelog

See git history for this file.
