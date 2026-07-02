> Author: Puras Handharmahua · 2026-06-13
> Related: [kms-conventions.md](kms-conventions.md) · [kms-design-principles.md](kms-design-principles.md) · [kms-glossary.md](kms-glossary.md) · [../repo-structure.md](../repo-structure.md)

What is where inside `kms/` — the map. For path → metadata rules, chunk strategy, and retrieval protocol, see [kms-conventions.md](kms-conventions.md). For the Clean Architecture rationale behind `domain/`/`data/`/`application/`, see [kms-design-principles.md](kms-design-principles.md).

---

## `kms/` — Top Level

```
kms/
├── knowledge-sources/  → raw knowledge docs — the Knowledge Path Structure lives here (see below)
├── domain/             → KMS domain layer — schema, entities, repository interface, use cases
│   ├── schema.py       → single vocabulary contract (scope/platform/project/discipline values)
│   ├── entities.py     → KnowledgeNode and related entities
│   ├── repository.py   → abstract KnowledgeRepository interface
│   ├── sources/        → source adapters — markdown, directory, codebase, confluence
│   └── use_cases/      → fetch_knowledge, list_knowledge, query_knowledge, upsert_knowledge
├── data/               → ChromaKnowledgeRepository — ChromaDB implementation of the domain interface
├── application/        → MCP server (mcp_server.py) — exposes kms_list/kms_fetch/kms_query/kms_upsert
├── db/                 → local ChromaDB store (not committed)
├── scripts/            → seed_kms.py — seed runner driven by sources.yaml
├── dashboard/          → local browser UI for inspecting seeded knowledge (server.py + index.html)
├── docs/               → kms-knowledge-source-rules.md — authoring rules for knowledge-sources/
├── sources.yaml        → registered knowledge sources (seed targets)
└── README.md
```

**Dependency rule:** `application/` → `domain/` ← `data/`. Nothing in `domain/` imports ChromaDB directly — see [kms-design-principles.md — Architecture](kms-design-principles.md#architecture).

---

## `kms/knowledge-sources/` — Knowledge Path Structure

Three top-level buckets mirror the cascade tiers (`scope`); each then nests `{discipline}/{artifact}.md` (or `{platform}/{discipline}/{artifact}.md` under `platform/`) — **3-level, no `area` segment** (removed 2026-07-03):

```
knowledge-sources/
├── _inbox/                 → loose contribution drafts — NOT seeded (see /kms-contribute)
├── universal/              → scope=universal — general principles, all platforms
│   ├── engineering/
│   ├── qa/
│   └── … (one dir per discipline)
│       └── {artifact}.md
├── platform/               → scope=platform — implemented for a specific platform
│   ├── android/
│   ├── flutter/
│   └── ios/
│       └── {discipline}/{artifact}.md
└── projects/               → scope=project — deviations for a specific project
    ├── flex-mobile/
    └── … (one dir per project)
        └── {discipline}/{artifact}.md   (+ repo.yaml)
```

Design-system catalogs live under `discipline: design` with `tags: [design-system]` in frontmatter (e.g. `platform/flutter/design/mekari-pixel.md`) — `area` no longer exists as a path segment.

Each `{artifact}.md` is then chunked by heading: `#` → `topic` (and engineering CLEAN-layer marker), each `##` → **one node** (`section`, stored as `subtopic == pattern`); `###`/`####` are that node's body. See [kms-conventions.md — Path Conventions](kms-conventions.md#kmsknowledge-sources--path-conventions) and the [redesign initiative](../../initiatives/2026-07-03-kms-knowledge-management-redesign.md) for the full rules, and [kms-glossary.md](kms-glossary.md) for term definitions.

---

## Changelog

See git history for this file.
