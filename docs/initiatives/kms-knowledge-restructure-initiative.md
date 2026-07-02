# KMS Knowledge Structure Restructure Initiative

> **⚠ Partially superseded (2026-07-03)** by the [knowledge-management redesign](2026-07-03-kms-knowledge-management-redesign.md). Still valid: the scope/discipline/area directory tiers. **Reversed:** this doc made the *path authoritative and frontmatter documentation-only*, and chunked with `###`→`pattern` promotion. The redesign makes **frontmatter authoritative** (path fallback) and chunks at **`##` = one node** (`###` stays as body), adds `layer`/`owner` facets and opaque uuid ids. Where the two conflict, the redesign wins.

**Status:** Complete — all implementation done, smoke test passed (653 nodes seeded)
**Goal:** Restructure `kms/knowledge-sources/` to mirror the two knowledge axes explicitly, so agents can scope queries with precision and engineers can place knowledge without ambiguity.

---

## Problem

The original `kms/knowledge-sources/` structure mixed two orthogonal axes in the same directory level:

```
kms/knowledge-sources/
├── engineering/     ← discipline axis
├── qa/              ← discipline axis
└── projects/        ← scope axis — wrong level
```

This caused:
- **Conceptual mismatch** — `projects/` is a scope concept, not a discipline; it didn't belong alongside `engineering/`, `qa/`, etc.
- **Platform encoded in filenames** — `flutter-standard-architecture.md` derived platform from a filename prefix, which is fragile and non-obvious
- **No clear placement rule** — engineers had no unambiguous answer for "where does this file go?"
- **Agent scope ambiguity** — agents couldn't filter by scope from the path alone; they relied on derived metadata

Additional issues found in the content files:
- **Topic collision** — `flutter-standard-architecture.md` had `## Creation Order` under both `# Domain` and `# Data`, producing the same ChromaDB node ID; the second silently overwrote the first
- **Layer context lost** — `# Domain`, `# Data`, `# Presentation` markers in the monolithic architecture file were invisible to the chunker (splits at `##` only), so layer context wasn't captured in any metadata field

---

## Design Decisions

### Two axes govern all knowledge

| Axis | Field | Values |
|---|---|---|
| **Domain** | `discipline` | `engineering`, `design`, `qa`, `agile`, `architecture`, `devops`, `security`, `product`, `code_review` |
| **Scope** | `scope` + `platform` + `project` | `universal` / `platform={flutter,ios,android,web}` / `project={name}` |

`platform` and `project` are not separate axes — they are values on the scope axis expressing *how narrowly* the knowledge applies.

### Scope as top-level, discipline as second-level, artifact as third-level

The folder structure mirrors all metadata axes directly:

```
knowledge-sources/
├── universal/              ← scope=universal
│   ├── engineering/        ← discipline
│   │   └── conventions/    ← artifact
│   ├── qa/
│   └── disciplines.json    ← discipline registry
├── platform/               ← scope=platform
│   ├── platforms.json      ← platform registry
│   ├── flutter/            ← platform value
│   │   ├── engineering/    ← discipline
│   │   │   ├── conventions/          ← artifact
│   │   │   └── standard-architecture/
│   │   └── design/
│   │       └── mekari-pixel-catalog/
│   └── ios/
│       └── engineering/
│           ├── conventions/
│           └── standard-architecture/
└── projects/               ← scope=project
    └── mobile-talenta/
        ├── feature-inventory/  ← artifact
        ├── conventions/
        └── api-endpoints/
```

Every path segment maps to a metadata field — no filename prefix magic. `platform/flutter/engineering/conventions/conventions.md` fully describes: scope=platform, platform=flutter, discipline=engineering, artifact=conventions.

### Platform and discipline registries

Two JSON registries make known values discoverable without reading `schema.py`:

- `universal/disciplines.json` — all discipline IDs + display names
- `platform/platforms.json` — all platform IDs + display names

### YAML frontmatter on every `.md` file

Each knowledge file carries its own metadata at the top — self-documenting and redundant with the path (by design).

`scope` encodes both the tier and its qualifier in a single path-style field, so the coupling is explicit without needing a separate field:

```yaml
# universal
---
scope: universal
discipline: engineering
---

# platform
---
scope: platform/flutter
discipline: engineering
---

# project
---
scope: project/mobile-talenta
platform: flutter
discipline: engineering
---
```

A human reads `scope: platform/flutter` and immediately knows tier + platform. A program splits on `/` — no custom format beyond standard YAML string parsing. Project files keep `platform` as a separate field because a project is named independently of its platform.

### Templates removed

`_template.md` stub files were removed. They served schema discovery before real content existed. Now that the directory structure is explicit, the path itself is the schema contract.

---

## Progress

### Folder Restructure

| Task | Status |
|---|---|
| Identify axes (domain + scope) | ✅ Done |
| Rename `universal/` → `disciplines/` → back to `universal/` (settled on scope-first) | ✅ Done |
| Create `platform/{platform}/{discipline}/` structure | ✅ Done |
| Move all platform files from flat `disciplines/engineering/` into `platform/{platform}/{discipline}/` | ✅ Done |
| Move `platforms.json` into `platform/` | ✅ Done |
| Create `universal/disciplines.json` | ✅ Done |
| Remove all `_template.md` stub files | ✅ Done |
| Add YAML frontmatter to all `.md` files | ✅ Done — 27 files updated, path-style scope + artifact field |
| Move all `.md` files into artifact subdirectories | ✅ Done — 27 files moved |
| Add `artifact` field to `KnowledgeNode` entity and `id` formula | ✅ Done |
| Update `DirectorySource` to traverse artifact level for platform, universal, and project docs | ✅ Done |
| Clean up empty/leftover directories | ✅ Done |

### Code Updates

| Task | Status |
|---|---|
| `_parse_filename` — remove platform prefix extraction (platform now comes from directory) | ✅ Done |
| `_is_template_file` — remove `{platform}-_template.md` detection | ✅ Done |
| `_read_universal_docs` / `_read_platform_docs` — split into scope-aware traversal with shared `_read_scope_dir` | ✅ Done |
| Rename `_DISCIPLINES_DIR` constant to `_UNIVERSAL_DIR`, update path to `universal/` | ✅ Done |
| Update `DirectorySource` docstring to reflect `universal/` path convention | ✅ Done |
| Add `artifact` traversal level to `_read_scope_dir` and `_read_project_docs` | ✅ Done |
| Add `artifact` field to `KnowledgeNode` entity; include in `id` formula | ✅ Done |
| Add `artifact` to `schema.py` `MANDATORY_FIELDS` | ✅ Done |
| Rewrite `_chunk_by_sections` — `#`→topic, `##`→pattern, `###`→content; discard preamble | ✅ Done |
| Add `_strip_frontmatter` — strip YAML block before chunking to prevent ghost nodes | ✅ Done |
| `chroma_repository.py` — add `artifact` to `_to_meta`, `_from_meta`, `list`, `fetch_exact` | ✅ Done |
| `domain/repository.py` abstract interface — add `artifact` param to `list` and `fetch_exact` | ✅ Done |
| `fetch_knowledge.py` — add `artifact` param; pass through cascade chain | ✅ Done |
| `list_knowledge.py` — add `artifact` param; update dedup key to `(discipline, artifact, topic, pattern)` | ✅ Done |
| `upsert_knowledge.py` — update `fetch_exact` call to include `artifact` | ✅ Done |
| `seed_kms.py` — update `fetch_exact` call to include `artifact` | ✅ Done |
| `mcp_server.py` — add `artifact` param to `kms_list` and `kms_fetch`; add to return dicts | ✅ Done |
| Smoke test seed run — 653 nodes seeded, artifact/topic/pattern verified correct | ✅ Done |
| Update `kms-design-principles.md` — path conventions, chunk strategy, metadata schema | ✅ Done |
| Update `kms-knowledge-source-rules.md` — file naming, section rules, placement guide, heading conventions | ✅ Done |

---

## Current Structure

```
kms/knowledge-sources/
├── universal/
│   ├── disciplines.json
│   ├── agile/              (empty — no content yet)
│   ├── architecture/       (empty)
│   ├── design/             (empty)
│   ├── devops/             (empty)
│   ├── engineering/        (empty)
│   ├── product/            (empty)
│   ├── qa/                 (empty)
│   └── security/           (empty)
├── platform/
│   ├── platforms.json
│   ├── android/
│   │   └── engineering/
│   │       ├── conventions/
│   │       │   └── conventions.md
│   │       └── standard-architecture/
│   │           └── standard-architecture.md
│   ├── flutter/
│   │   ├── design/
│   │   │   └── mekari-pixel-catalog/
│   │   │       └── mekari-pixel-catalog.md
│   │   └── engineering/
│   │       ├── conventions/
│   │       │   └── conventions.md
│   │       └── standard-architecture/
│   │           └── standard-architecture.md
│   └── ios/
│       └── engineering/
│           ├── conventions/
│           │   └── conventions.md
│           └── standard-architecture/
│               └── standard-architecture.md
└── projects/
    ├── flex-mobile/
    │   ├── api-endpoints/
    │   ├── deviations/
    │   ├── feature-inventory/
    │   ├── shared-components/
    │   └── third-party-integrations/
    ├── mobile-talenta/     (same artifact structure)
    ├── talenta-ios/        (same artifact structure)
    └── talenta-mobile-android/ (same artifact structure)
```

---

## Pending

- **Frontmatter validation at seed time** — frontmatter fields are documentation-only; the seeder derives all metadata from the path. A future improvement: warn at seed time when frontmatter `scope`/`discipline`/`artifact` disagrees with the derived path values (catches misplaced files).
- **Populate `universal/` disciplines** — all universal discipline directories are empty. Universal engineering knowledge (Clean Architecture rules, SOLID), QA strategy, agile ceremonies, etc. need to be authored and placed here.
- **Update `kms-source-audit-worker`** — audit agent references old path conventions; update its knowledge of the new four-level path structure and the `artifact` field.

---

## Relation to KMS Initiative

This restructure is a refinement of the storage layer described in `kms-initiative.md` (Phase 4 — Stable Architecture). Scope of changes:
- **On-disk**: `kms/knowledge-sources/` directory structure (four-level path)
- **Domain**: `KnowledgeNode` entity (`artifact` field, updated `id` formula)
- **Schema**: `schema.py` mandatory fields
- **Seeder**: `DirectorySource` traversal, `_chunk_by_sections` (heading hierarchy), `_strip_frontmatter`
- **Data layer**: `ChromaKnowledgeRepository` (`_to_meta`, `_from_meta`, `list`, `fetch_exact`)
- **Use cases**: `FetchKnowledge`, `ListKnowledge`, `UpsertKnowledge`
- **MCP tools**: `kms_list`, `kms_fetch` — `artifact` param added to both
- **Docs**: `kms-design-principles.md`, `kms-knowledge-source-rules.md`
