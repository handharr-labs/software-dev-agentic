# Pattern KMS Initiative

**Status:** Phase 0 complete — ready for Phase 1
**Goal:** Replace static `lib/platforms/*/reference/*.md` files with a queryable SQLite-backed knowledge store — agents fetch implementation patterns via MCP instead of grepping flat files.

---

## Progress

### Phase 0 — Restructure reference files

| Task | Status |
|---|---|
| Schema + hierarchy finalized | ✅ Done |
| Initiative doc written | ✅ Done |
| Trial: `flutter-mobile-talenta/engineering/domain/` restructured | ✅ Done |
| Trial verified — taxonomy fits | ✅ Done |
| Full extraction: all `*-impl.md` sections → pattern files | ✅ Done |
| Extract `flutter/` platform-base from shared content | ✅ Done |
| Repeat for `flutter-mobile-jurnal`, `flutter-qontak-chat`, `flutter-qontak-crm` | ✅ Done |
| Repeat for `ios-talenta`, `web` | ✅ Done |
| Add per-topic `index.md` to each `{platform}/engineering/{topic}/` | ✅ Done |
| Update procedure skills — replace `*-impl.md` citations with `knowledge_scope:` | ✅ Done |
| Update agents — add cascade resolution logic (`{project}/` → `{platform}/`) | ✅ Done |
| Extract `android-talenta` | ✅ Done |
| Merge theory content into `## Theory` sections of pattern files | ✅ Done |
| Update agents — remove separate theory file references | ✅ Done |
| Verify no agent/skill still references old paths | ✅ Done |
| Delete `lib/platforms/*/reference/code-architecture/` (old impl files) | ✅ Done |
| Delete `lib/core/reference/code-architecture/*-theory.md` (merged into pattern files) | ✅ Done |

### Phase 1 — Core KMS

| Task | Status |
|---|---|
| `kms/domain/entities.py` — `KnowledgeNode`, `KnowledgeSection` types | ⬜ Pending |
| `kms/domain/repository.py` — `KnowledgeRepository` interface | ⬜ Pending |
| `kms/domain/use_cases/list_knowledge.py` — merged TOC (project + platform + universal) | ⬜ Pending |
| `kms/domain/use_cases/fetch_knowledge.py` — cascade fetch (project → platform → universal) | ⬜ Pending |
| `kms/domain/use_cases/query_knowledge.py` — vector search + optional metadata filter | ⬜ Pending |
| `kms/domain/use_cases/upsert_knowledge.py` | ⬜ Pending |
| `kms/data/chroma_repository.py` — implements `KnowledgeRepository` via ChromaDB embedded | ⬜ Pending |
| `kms/application/mcp_server.py` — `kms_list`, `kms_fetch`, `kms_query`, `kms_upsert` | ⬜ Pending |
| `kms/scripts/seed_kms.py` — bootstrap: reads `lib/core/knowledge/` → upserts into ChromaDB; extracts summary from first sentence of `## Theory` | ⬜ Pending |
| `build-plugin.sh` updated — run seed_kms.py, bundle `chroma/` dir + `kms/` Python package | ⬜ Pending |
| Flutter base knowledge seeded as first collection | ⬜ Pending |
| Update agent + skill `knowledge_scope:` — simplify to `discipline + platform` scope only | ⬜ Pending |
| Update agent Step 0 — primary: `kms_list` → reason → `kms_fetch`; fallback: `Read lib/core/knowledge/{platform}/engineering/{topic}/index.md` → Read pattern files | ⬜ Pending |

### Phase 2 — Scan Agent

| Task | Status |
|---|---|
| `sync-platform` extended to extract `code_pattern` sections | ⬜ Pending |
| Flutter base covered | ⬜ Pending |
| Project-specific (talenta, jurnal) covered | ⬜ Pending |
| Web + iOS covered | ⬜ Pending |

### Phase 3 — Dashboard

| Task | Status |
|---|---|
| Local web UI — hierarchical nav + section editor | ⬜ Pending |

### Phase 4 — Extraction

| Task | Status |
|---|---|
| `RemoteChromaKnowledgeRepository` implemented — points to hosted ChromaDB | ⬜ Pending |
| Standalone ChromaDB deployment | ⬜ Pending |
| Plugin `settings.json` points to remote MCP instead of local script | ⬜ Pending |

---

## Problem

Current implementation knowledge lives in manually-maintained `.md` files per platform:

```
lib/platforms/flutter-mobile-talenta/reference/
  code-architecture/
    domain-impl.md
    data-impl.md
    presentation-impl.md
    ...
  index.md
```

Pain points:
- **Drift** — files don't auto-update when real code changes; `sync-platform` is pull-triggered and manual
- **Flat graph** — no cross-platform linking; "error handling" lives separately in Flutter, web, iOS with no shared node
- **Grep-only retrieval** — agents must know the exact file and section header to retrieve. No intent-based lookup
- **Manual index** — `index.md` tables are written by hand; not derived from content

---

## Solution

A ChromaDB-backed knowledge store shipped inside the Claude Code plugin. Single DB, two query modes — metadata-filtered fetch for precision, vector search for discovery. Agents replace grep calls with a single MCP tool call.

**Before:**
```
Grep "^## UseCase" reference/code-architecture/domain-impl.md
→ Read domain-impl.md offset=N limit=M
```

**After:**
```
# Agent knows exactly what it needs → metadata-filtered fetch (exact, no vector)
kms_fetch({ platform: "flutter", project: "talenta", topic: "domain", pattern: "use_case" })
→ returns full pattern doc (theory + definition + code_pattern)

# Agent discovering by intent → semantic search with optional scope filter
kms_query("how is authentication handled", { discipline: "engineering" })
→ returns top-k matching pattern docs ranked by relevance
```

**Why ChromaDB over SQLite:** Knowledge will scale beyond engineering patterns into feature system design, product, and design disciplines. At that scale agents need intent-based discovery — they won't always know the exact topic+pattern upfront. ChromaDB supports both exact metadata lookup and vector similarity in one store, eliminating the need to maintain two separate DBs.

---

## Architecture

Clean Architecture + SOLID — repository pattern as the abstraction boundary so ChromaDB → any other vector store is a data source swap with zero changes to domain or MCP layer.

```
MCP Server (application)
  └─ Use Cases (domain)
       └─ KnowledgeRepository (abstract interface)
            └─ ChromaKnowledgeRepository (data)
```

**Dependency rule:** MCP Server → Use Cases → KnowledgeRepository (abstract). ChromaKnowledgeRepository implements the interface. Nothing in domain or application imports ChromaDB directly.

**Runtime:** Python — MCP server and seed script both use the ChromaDB Python client. Single runtime, no cross-language friction.

**Source of truth:** ChromaDB is authoritative after initial seed. `lib/core/knowledge/` `.md` files are the bootstrap source — seeded once into ChromaDB. Subsequent edits go through the dashboard → ChromaDB directly. `.md` files are not kept in sync after initial seed.

**Agent fallback:** `lib/core/knowledge/` acts as a read-only fallback when the MCP server is unavailable. Agent Step 0: try `kms_list` → `kms_fetch` first; if KMS unavailable, fall back to `Read {topic}/index.md` → `Read {pattern}.md` directly.

### Directory structure

```
kms/
  domain/
    entities.py              # KnowledgeNode, KnowledgeSection types
    repository.py            # KnowledgeRepository interface
    use_cases/
      fetch_knowledge.py     # metadata-filtered fetch + cascade (project → platform → universal)
      list_knowledge.py      # merged TOC view — project + platform + universal
      query_knowledge.py     # vector search + optional metadata filter
      upsert_knowledge.py
  data/
    chroma_repository.py     # implements KnowledgeRepository via ChromaDB embedded client
  application/
    mcp_server.py            # wires use cases → MCP tools (kms_fetch, kms_query, kms_list, kms_upsert)
  scripts/
    seed_kms.py              # one-time bootstrap: reads lib/core/knowledge/ → upserts into ChromaDB
  requirements.txt           # chromadb, sentence-transformers (or openai embeddings)
```

---

## Knowledge Hierarchy

```
platform → discipline → topic → pattern
```

**Cascade resolution** — specific overrides general, three tiers:

```
null (universal)             -- clean arch theory, SOLID, SDLC-wide knowledge
  └─ platform (flutter)      -- all flutter projects share this base
       └─ project (talenta)  -- talenta-specific deviations only
```

Query resolution order: `project-specific → platform-base → universal`. A project node is only created when a real deviation exists — 95% of knowledge lives at platform-base.

**Hierarchy examples:**

```
-- Engineering (architecture layers as topics)
flutter, talenta, engineering, domain,       use_case
flutter, talenta, engineering, data,         repository_impl
flutter, talenta, engineering, presentation, screen_structure

-- Engineering (cross-cutting concerns as topics)
flutter, null, engineering, state_management,     bloc
flutter, null, engineering, state_management,     cubit
flutter, null, engineering, dependency_injection, get_it
flutter, null, engineering, navigation,           go_router
flutter, null, engineering, error_handling,       failure_types

-- Other disciplines (platform=null for universal)
null, null, design,    components, button
null, null, qa,        unit_testing, mock_setup
null, null, devops,    ci_pipeline,  github_actions
null, null, security,  auth_patterns, jwt_handling
```

**Discipline vocabulary (current):**
`engineering` · `design` · `qa` · `devops` · `security` · `code_review` · `product`

---

## Knowledge Schema

Each pattern file becomes one ChromaDB document. Full content is the vector-searchable body; structured dimensions are metadata fields for exact filtering.

```python
collection.add(
  ids=["flutter:null:engineering:domain:use_case"],
  documents=["## Theory\n...\n## Definition\n...\n## Code Pattern\n..."],
  metadatas=[{
    "platform":   "flutter",           # flutter | web | ios | android | null (universal)
    "project":    None,                # talenta | jurnal | qontak-crm | null (platform-base)
    "discipline": "engineering",       # engineering | design | qa | devops | security | product | ...
    "topic":      "domain",            # domain | state_management | components | ci_pipeline | ...
    "pattern":    "use_case",          # use_case | bloc | button | github_actions | ...
    "tags":       "[]",                # JSON array string
    "source_file": "lib/core/knowledge/flutter/engineering/domain/use_case.md",
    "updated_at": "2026-06-03"
  }]
)
```

**`kms_fetch` — exact metadata lookup (no vector):**
```python
collection.get(
  where={"platform": "flutter", "topic": "domain", "pattern": "use_case"}
)
```

**`kms_query` — semantic search with optional scope:**
```python
collection.query(
  query_texts=["how is authentication handled"],
  where={"discipline": "engineering"},   # optional scope filter
  n_results=3
)
```

**Section types per discipline** (stored as free text within the document body — no schema change to add a new discipline):

| Discipline | Section types |
|---|---|
| engineering | theory, definition, code_pattern |
| design | rationale, usage_guidelines, examples |
| qa | strategy, checklist, test_template |
| devops | overview, config_example, runbook |
| security | threat_model, mitigation, checklist |
| code_review | rules, examples, rationale |
| product | context, decisions, acceptance_criteria |

---

## Agent Query Flow

Agents always start with `kms_list` — not `kms_fetch`. The index is the reasoning step.

```
1. kms_list({ platform, discipline? })   ← scoped TOC, metadata only, cheap
        ↓
2. Agent reasons over TOC
   "I'm building a Flutter domain layer — I need domain + dependency_injection.
    No product/ or design/ nodes exist for this platform yet — skip them."
        ↓
3. kms_fetch(platform, topic, pattern) × N   ← only what agent decided it needs
```

**Why TOC-first:**
- Agent sees exactly what exists — no assumptions about missing patterns
- Sparse knowledge is fine — index is honest about gaps, agent adapts
- Selection is explicit and traceable — visible in agent reasoning
- New knowledge added via dashboard appears in `kms_list` immediately — no scope config update, no rebuild

**`kms_query` is for unscoped discovery** — when the agent doesn't know which discipline or topic is relevant (e.g. feature planner reasoning across all knowledge before delegating to workers).

---

## MCP Tools

Four tools exposed by `kms-server.ts`:

| Tool | Input | Output |
|---|---|---|
| `kms_list` | `platform?, project?, discipline?, topic?` | Scoped TOC — metadata only, no content |
| `kms_fetch` | `platform, project, discipline, topic, pattern` | Full node content (cascade applied) |
| `kms_query` | `text, where?` | Top-k nodes ranked by semantic similarity |
| `kms_upsert` | full node + content payload | Written/updated node (dashboard + scan agent) |

**`kms_list`** — returns merged TOC: project-specific + platform-base + universal nodes combined. Each entry includes `id`, `discipline`, `topic`, `pattern`, `summary` (first sentence of `## Theory`, extracted at seed time). No content returned — metadata only. Agents reason over this before fetching.

**`kms_fetch`** — cascade fetch: resolves `project → platform → universal`, returns first match with full content. Caller passes most specific context it has.

**`kms_query`** — semantic search with optional metadata filter. Used by feature planners for cross-discipline discovery before delegating to scoped workers.

**`kms_upsert`** — writes to ChromaDB directly. Used by dashboard (live edits) and scan agent. ChromaDB is authoritative — `.md` files are bootstrap-only.

```python
# Step 1 — Agent gets merged TOC for its context
kms_list(platform="flutter", project="talenta", discipline="engineering")
# → [
#     { topic: "domain", pattern: "use_case", summary: "Single-responsibility business logic unit" },
#     { topic: "data", pattern: "repository_impl", summary: "Implements domain repository interface" },
#     ...  # platform-base + universal nodes merged in
#   ]

# Step 2 — Agent reasons over TOC, fetches what it needs
kms_fetch(platform="flutter", project="talenta", discipline="engineering", topic="domain", pattern="use_case")

# Feature planner — cross-discipline semantic discovery
kms_query("authentication flow and token handling", platform="flutter")
```

---

## Distribution — Claude Code Plugin

ChromaDB runs in embedded mode (no server) — the collection persists as a directory on disk, seeded at plugin build time.

```
dist/plugins/flutter-mobile-talenta/
  chroma/               ← seeded ChromaDB collection dir
  kms/
    mcp_server.py       ← Python MCP server
    domain/             ← entities, repository, use cases
    data/               ← chroma_repository.py
  requirements.txt
  .claude/
    settings.json       ← MCP server auto-configured
```

**Engineer experience:** install plugin → MCP server is auto-wired → `kms_fetch` available immediately.

**Knowledge updates:** update pattern files in this repo → rebuild plugin → engineers reinstall.

`build-plugin.sh` additions:
1. Compile `kms/` TypeScript
2. Seed ChromaDB collection from `lib/core/knowledge/` pattern files
3. Copy compiled JS + `chroma/` dir into plugin directory
4. Add MCP server entry to plugin `settings.json`

**Dependency:** Python + ChromaDB (`pip install chromadb sentence-transformers`). Required both at build time (seeding) and at runtime (MCP server). Engineers need Python installed.

**Source of truth:** ChromaDB. `lib/core/knowledge/` `.md` files bootstrap the initial collection via `seed_kms.py` — after that, edits go through dashboard → ChromaDB directly. `.md` files are not updated after initial seed.

---

## Knowledge Population

**Two sources — by design:**

| Source | Fills | How |
|---|---|---|
| Scan agent (extends `sync-platform`) | `code_pattern`, `source_file` | Reads real codebase → upserts via `kms_upsert` |
| Engineers via dashboard | `theory`, `definition`, discipline-specific sections | Manual — can't be reliably extracted from code |

`code_pattern` is extractable (concrete, observable). `theory` and `definition` require human judgment.

**Dashboard (Phase 3):** Local web UI served by a companion script — hierarchical nav + section editor per node, vector search across disciplines.

---

## Migration Path

Current `.md` files stay untouched while KMS is built and populated in parallel. Switch is per-platform, not all-at-once:

1. KMS covers `flutter` base fully → agents use `kms_fetch` for Flutter, grep for others
2. Seed project-specific nodes (talenta, jurnal, etc.) where real deviations exist
3. Repeat for `web`, `ios`
4. Delete old `lib/platforms/*/reference/code-architecture/` once all platforms migrated
5. `index.md` files deleted last — they become redundant

---

## Extraction Path (when stable)

When multi-project real-time sync is needed (knowledge updates without submodule bumps):

1. Write `RemoteChromaKnowledgeRepository` implementing `KnowledgeRepository` — points to hosted ChromaDB
2. Swap binding in `mcp-server.ts` — one line change
3. Deploy ChromaDB as standalone service
4. Plugin `settings.json` points to remote MCP instead of local script

Nothing in domain or use case layer changes. Clean Arch pays off here.

---

## Build Phases

### Phase 0 — Restructure existing reference files (fallback layer)

Restructure `lib/platforms/*/reference/` from monolithic `code-architecture/*.md` files into the new `{discipline}/{topic}/{pattern}.md` hierarchy. This serves as the agent fallback when the MCP server is unavailable, and makes Phase 1 seeding trivial (file path = DB key).

**File path mirrors DB key:**
```
lib/core/knowledge/{project}/{discipline}/{topic}/{pattern}.md
  ↕
knowledge_nodes: project={project}, discipline={discipline}, topic={topic}, pattern={pattern}
```

**New knowledge root:** `lib/core/knowledge/` — sits alongside existing `lib/core/reference/` during migration. Old `reference/` deleted once all platforms are migrated.

**Directory layout:**
```
lib/core/knowledge/
  flutter/                          ← platform-base (project=null, shared all flutter projects)
    engineering/
      domain/
        use_case.md
        entity.md
        ...
  flutter-mobile-talenta/           ← project-specific overrides only
    engineering/
      domain/
        use_case.md                 ← only if talenta deviates from flutter base
  flutter-mobile-jurnal/            ← same — only real deviations
  ios-talenta/
    engineering/
      ...
  web/
    engineering/
      ...
```

**Each pattern file — frontmatter + sections:**
```markdown
---
platform: flutter
project: flutter-mobile-talenta     # omit if platform-base
discipline: engineering
topic: domain
pattern: use_case
---

## Theory
...

## Definition
...

## Code Pattern
...
```

**Section headers per discipline:**

| Discipline | Sections |
|---|---|
| engineering | `## Theory`, `## Definition`, `## Code Pattern` |
| design | `## Rationale`, `## Usage Guidelines`, `## Examples` |
| qa | `## Strategy`, `## Checklist`, `## Test Template` |
| devops | `## Overview`, `## Config Example`, `## Runbook` |

**Fallback agent resolution (no MCP):**
```
1. lib/core/knowledge/{project}/{discipline}/{topic}/{pattern}.md   (project-specific)
2. lib/core/knowledge/{platform}/{discipline}/{topic}/{pattern}.md  (platform-base)
```

**Section-to-file mapping — flutter-mobile-talenta (full):**

| Old file § Section | New file |
|---|---|
| `domain-impl.md` § Dependency Rule | `engineering/domain/dependency_rule.md` |
| `domain-impl.md` § Entities | `engineering/domain/entity.md` |
| `domain-impl.md` § Repository Interfaces | `engineering/domain/repository_interface.md` |
| `domain-impl.md` § Use Cases | `engineering/domain/use_case.md` |
| `domain-impl.md` § Domain Services | `engineering/domain/domain_service.md` |
| `domain-impl.md` § Domain Errors | `engineering/domain/domain_error.md` |
| `domain-impl.md` § Domain Enums | `engineering/domain/domain_enum.md` |
| `domain-impl.md` § Creation Order | `engineering/domain/creation_order.md` |
| `data-impl.md` § DTOs | `engineering/data/dto.md` |
| `data-impl.md` § Payload (Write Models) | `engineering/data/payload.md` |
| `data-impl.md` § Mappers | `engineering/data/mapper.md` |
| `data-impl.md` § Data Sources | `engineering/data/data_source.md` |
| `data-impl.md` § Repository Implementation | `engineering/data/repository_impl.md` |
| `data-impl.md` § Exceptions | `engineering/data/exception.md` |
| `data-impl.md` § HTTP Client | `engineering/data/http_client.md` |
| `data-impl.md` § Endpoint Constants | `engineering/data/endpoint_constants.md` |
| `data-impl.md` § Local Data Source | `engineering/data/local_data_source.md` |
| `presentation-impl.md` § StateHolder | `engineering/state_management/bloc.md` |
| `presentation-impl.md` § Screen Structure | `engineering/presentation/screen_structure.md` |
| `presentation-impl.md` § BlocListener | `engineering/presentation/bloc_listener.md` |
| `presentation-impl.md` § Component | `engineering/presentation/component.md` |
| `di-impl.md` § Setup + Annotations + Scope Rules | `engineering/dependency_injection/get_it.md` |
| `di-impl.md` § Registration Order | `engineering/dependency_injection/registration_order.md` |
| `di-impl.md` § External Dependencies | `engineering/dependency_injection/external_dependencies.md` |
| `navigation-impl.md` § Router Configuration | `engineering/navigation/go_router.md` |
| `navigation-impl.md` § Navigating from BLoC | `engineering/navigation/navigate_from_bloc.md` |
| `navigation-impl.md` § Nested Navigation | `engineering/navigation/nested_navigation.md` |
| `navigation-impl.md` § Deep Link Support | `engineering/navigation/deep_link.md` |
| `error-handling-impl.md` § Error Types + Flow | `engineering/error_handling/failure_types.md` |
| `error-handling-impl.md` § AppException | `engineering/error_handling/app_exception.md` |
| `error-handling-impl.md` § Validation Errors | `engineering/error_handling/validation_errors.md` |
| `error-handling-impl.md` § Error UI | `engineering/error_handling/error_ui.md` |
| `testing-impl.md` § Presenter Tests | `engineering/testing/presenter_test.md` |
| `testing-impl.md` § Use Case Tests | `engineering/testing/use_case_test.md` |
| `testing-impl.md` § Repository Tests | `engineering/testing/repository_test.md` |
| `testing-impl.md` § Mock Generation | `engineering/testing/mock_generation.md` |
| `testing-impl.md` § Test Pyramid | `engineering/testing/test_pyramid.md` |
| `app-layer-impl.md` § Hybrid Embedding | `engineering/app/hybrid_embedding.md` |
| `app-layer-impl.md` § Module Registration | `engineering/app/module_registration.md` |
| `utilities-impl.md` § StorageService | `engineering/utilities/storage_service.md` |
| `utilities-impl.md` § DateService | `engineering/utilities/date_service.md` |
| `utilities-impl.md` § Logger | `engineering/utilities/logger.md` |

**Deliverables:**
- [ ] Trial: create `lib/core/knowledge/flutter-mobile-talenta/engineering/domain/` — verify taxonomy fits before committing to full migration
- [ ] On approval: extract all sections from remaining old files into new structure
- [ ] Extract `flutter/` platform-base from content shared across talenta + jurnal
- [ ] Repeat for `ios-talenta`, `web`, `flutter-mobile-jurnal`, etc.
- [ ] Delete `lib/platforms/*/reference/code-architecture/` and `index.md` once all platforms migrated
- [ ] Update agent reference paths to point at `lib/core/knowledge/`

### Phase 1 — Core KMS (build here)
- [ ] `kms/domain/entities.py` — `KnowledgeNode`, `KnowledgeSection` types
- [ ] `kms/domain/repository.py` — `KnowledgeRepository` interface
- [ ] `kms/domain/use_cases/list_knowledge.py` — merged TOC (project + platform + universal)
- [ ] `kms/domain/use_cases/fetch_knowledge.py` — cascade fetch (project → platform → universal)
- [ ] `kms/domain/use_cases/query_knowledge.py` — vector search + optional metadata filter
- [ ] `kms/domain/use_cases/upsert_knowledge.py`
- [ ] `kms/data/chroma_repository.py` — implements `KnowledgeRepository` via ChromaDB embedded
- [ ] `kms/application/mcp_server.py` — `kms_list`, `kms_fetch`, `kms_query`, `kms_upsert`
- [ ] `kms/scripts/seed_kms.py` — bootstrap from `lib/core/knowledge/`; summary = first sentence of `## Theory`
- [ ] `build-plugin.sh` updated — run seed_kms.py, bundle `chroma/` + `kms/` Python package
- [ ] Flutter base knowledge seeded as first collection

### Phase 2 — Scan Agent
- [ ] Extend `sync-platform` to extract `code_pattern` sections and upsert via `kms_upsert`
- [ ] Cover flutter base → project-specific (talenta, jurnal) → web → ios progressively

### Phase 3 — Dashboard (local web UI)
- [ ] TypeScript/Node local server — `platform → discipline → topic → pattern` nav + section editor
- [ ] Vector search UI — intent-based knowledge discovery across disciplines

### Phase 4 — Extraction (when needed)
- [ ] `RemoteChromaKnowledgeRepository` — points to hosted ChromaDB instance
- [ ] Standalone ChromaDB deployment — zero domain/use-case changes
- [ ] Plugin `settings.json` points to remote MCP endpoint

---

## Relation to Feature KMS

This initiative is distinct from `knowledge-management-initiative.md` (the Librarian KMS):

| | Pattern KMS (this) | Feature KMS (Librarian) |
|---|---|---|
| Content | Implementation patterns — layers, concepts, code | Feature knowledge — API contracts, data models, HLD |
| Consumers | Builder agents (when generating code) | Planner agents + engineers |
| Source of truth | Real codebase via scan agent | PRD, Confluence, code scan |
| Current form | `lib/platforms/*/reference/*.md` | `.claude/reference/feature-docs/*.md` |
| Output | `kms_fetch` MCP call | Feature Doc read via `Read` tool |

Both feed into the builder workflow — Pattern KMS provides *how to build*, Feature KMS provides *what exists*.
