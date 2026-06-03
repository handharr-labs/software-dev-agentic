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
| `kms/domain/entities.ts` — `KnowledgeNode`, `KnowledgeSection` | ⬜ Pending |
| `kms/domain/repository.ts` — `KnowledgeRepository` interface | ⬜ Pending |
| `kms/domain/use-cases/` — fetch (cascade), query, upsert | ⬜ Pending |
| `kms/data/schema.sql` — `knowledge_nodes` + `knowledge_sections` | ⬜ Pending |
| `kms/data/sqlite-repository.ts` | ⬜ Pending |
| `kms/application/mcp-server.ts` — 4 tools wired | ⬜ Pending |
| `build-plugin.sh` updated to compile + bundle KMS | ⬜ Pending |
| Flutter base knowledge seeded as first nodes | ⬜ Pending |

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
| `PostgresKnowledgeRepository` implemented | ⬜ Pending |
| Standalone deployment | ⬜ Pending |
| Plugin points to remote MCP | ⬜ Pending |

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

A SQLite-backed knowledge store shipped inside the Claude Code plugin. Agents replace grep calls with a single MCP tool call.

**Before:**
```
Grep "^## UseCase" reference/code-architecture/domain-impl.md
→ Read domain-impl.md offset=N limit=M
```

**After:**
```
kms_fetch({ platform: "flutter", project: "talenta", topic: "domain", pattern: "use_case" })
→ returns sections: [{ type: "theory", content }, { type: "code_pattern", content }]
```

---

## Architecture

Clean Architecture + SOLID — repository pattern as the abstraction boundary so SQLite → Postgres is a data source swap with zero changes to domain or MCP layer.

```
MCP Server (application)
  └─ Use Cases (domain)
       └─ KnowledgeRepository (abstract interface)
            └─ SQLiteKnowledgeRepository (data)
```

**Dependency rule:** MCP Server → Use Cases → KnowledgeRepository (abstract). SQLiteKnowledgeRepository implements the interface. Nothing in domain or application imports SQLite directly.

### Directory structure

```
kms/
  domain/
    entities.ts              # KnowledgeNode, KnowledgeSection types
    repository.ts            # KnowledgeRepository interface
    use-cases/
      fetch-knowledge.ts     # applies cascade resolution
      query-knowledge.ts
      upsert-knowledge.ts
  data/
    sqlite-repository.ts     # implements KnowledgeRepository
    schema.sql
  application/
    mcp-server.ts            # wires use cases → MCP tools (kms_fetch, kms_query, kms_list, kms_upsert)
  knowledge.db               # gitignored locally; seeded at plugin build time
  package.json
  tsconfig.json
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

```sql
CREATE TABLE knowledge_nodes (
  id          TEXT PRIMARY KEY,  -- "{platform}:{project}:{discipline}:{topic}:{pattern}"
  platform    TEXT,              -- flutter | web | ios | null (universal)
  project     TEXT,              -- talenta | jurnal | qontak-crm | null (shared)
  discipline  TEXT NOT NULL,     -- engineering | design | qa | devops | security | ...
  topic       TEXT NOT NULL,     -- domain | state_management | components | ci_pipeline | ...
  pattern     TEXT NOT NULL,     -- use_case | bloc | button | github_actions | ...
  tags        TEXT,              -- JSON array
  source_file TEXT,              -- repo path scan agent pulled from
  updated_at  TEXT
);

CREATE TABLE knowledge_sections (
  id            TEXT PRIMARY KEY,
  node_id       TEXT NOT NULL REFERENCES knowledge_nodes(id),
  section_type  TEXT NOT NULL,   -- discipline-defined: theory | definition | code_pattern | checklist | ...
  content       TEXT NOT NULL,
  display_order INTEGER DEFAULT 0
);
```

**Section types per discipline:**

| Discipline | Section types |
|---|---|
| engineering | theory, definition, code_pattern |
| design | rationale, usage_guidelines, examples |
| qa | strategy, checklist, test_template |
| devops | overview, config_example, runbook |
| security | threat_model, mitigation, checklist |
| code_review | rules, examples, rationale |

No schema change to add a new discipline — `section_type` is a free string. Each discipline defines its own vocabulary.

---

## MCP Tools

Four tools exposed by `kms-server.ts`:

| Tool | Input | Output |
|---|---|---|
| `kms_fetch` | `platform, project, discipline, topic, pattern` | Resolved node + sections (cascade applied) |
| `kms_query` | any subset of dimensions | Array of matching nodes |
| `kms_list` | `platform?, project?, discipline?, topic?` | Available patterns as index |
| `kms_upsert` | full node + sections payload | Written/updated node (scan agent uses this) |

**`kms_fetch` applies cascade automatically** — caller passes the most specific context it has; the tool resolves project → platform → universal and returns the first match per dimension.

```ts
// Agent building flutter-talenta domain layer
kms_fetch({ platform: "flutter", project: "talenta", discipline: "engineering", topic: "domain", pattern: "use_case" })

// Agent querying by layer across all flutter projects
kms_query({ platform: "flutter", discipline: "engineering", topic: "domain" })

// Agent querying by discipline only
kms_query({ discipline: "security", topic: "auth_patterns" })
```

---

## Distribution — Claude Code Plugin

`knowledge.db` is seeded at plugin build time and ships inside the plugin directory. No env vars, no network, no hosted service.

```
dist/plugins/flutter-mobile-talenta/
  knowledge.db          ← seeded DB bundled by build-plugin.sh
  kms/
    mcp-server.js       ← compiled TypeScript
  .claude/
    settings.json       ← MCP server auto-configured
```

**Engineer experience:** install plugin → MCP server is auto-wired → `kms_fetch` available immediately.

**Knowledge updates:** update `knowledge.db` in this repo → rebuild plugin → engineers reinstall.

`build-plugin.sh` additions:
1. Compile `kms/` TypeScript
2. Seed `knowledge.db` from canonical data
3. Copy both into plugin directory
4. Add MCP server entry to plugin `settings.json`

---

## Knowledge Population

**Two sources — by design:**

| Source | Fills | How |
|---|---|---|
| Scan agent (extends `sync-platform`) | `code_pattern`, `source_file` | Reads real codebase → upserts via `kms_upsert` |
| Engineers via dashboard | `theory`, `definition`, discipline-specific sections | Manual — can't be reliably extracted from code |

`code_pattern` is extractable (concrete, observable). `theory` and `definition` require human judgment.

**Dashboard (v1):** SQLite GUI (TablePlus / DB Browser for SQLite) — engineers navigate `platform → discipline → topic → pattern` and CRUD sections directly. Zero build needed.
**Dashboard (v2):** Local web UI served by a companion script — hierarchical nav + section editor per node, one section type at a time.

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

1. Write `PostgresKnowledgeRepository` implementing `KnowledgeRepository` — same interface
2. Swap binding in `mcp-server.ts` — one line change
3. Deploy as standalone service
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
- [ ] `kms/domain/entities.ts` — `KnowledgeNode`, `KnowledgeSection` types
- [ ] `kms/domain/repository.ts` — `KnowledgeRepository` interface
- [ ] `kms/domain/use-cases/` — `fetch-knowledge` (with cascade), `query-knowledge`, `upsert-knowledge`
- [ ] `kms/data/schema.sql` — `knowledge_nodes` + `knowledge_sections` tables
- [ ] `kms/data/sqlite-repository.ts` — implements `KnowledgeRepository`
- [ ] `kms/application/mcp-server.ts` — `kms_fetch`, `kms_query`, `kms_list`, `kms_upsert`
- [ ] `build-plugin.sh` updated to compile + bundle KMS
- [ ] Flutter base knowledge seeded as first `platform=flutter, project=null` nodes

### Phase 2 — Scan Agent
- [ ] Extend `sync-platform` to extract `code_pattern` sections and upsert via `kms_upsert`
- [ ] Cover flutter base → project-specific (talenta, jurnal) → web → ios progressively

### Phase 3 — Dashboard (local web UI)
- [ ] TypeScript/Node local server — `platform → discipline → topic → pattern` nav + section editor
- [ ] Replaces SQLite GUI for teams that want a polished CRUD experience

### Phase 4 — Extraction (when needed)
- [ ] `PostgresKnowledgeRepository` implementing same `KnowledgeRepository` interface
- [ ] Standalone deployment — zero domain/use-case changes
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
