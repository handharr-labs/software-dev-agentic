# Changelog

All notable changes to this starter kit will be documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [12.6.1] — 2026-06-12

### Fixed
- Test skills (`developer-test-create-domain/data/presentation/mock`, `developer-test-procedure`): replaced `topic="<testing topic>"` placeholder with the correct `topic="testing"` (consistent across flutter, iOS, Android); removed wrong `android → instrumented_tests` note
- `cipherpol-status` Step 5: fixed bare `kms_fetch` missing `pattern` — now does `kms_list(topic)` first then `kms_fetch(topic, pattern=<first from list>)`
- `developer-sysdesign-extract-worker` Step 1: removed redundant `kms_list` call whose TOC result was never used; the three `kms_fetch` calls already use hardcoded known slugs

---

## [12.6.0] — 2026-06-12

### Added
- `developer-sysdesign-extract-worker` — traces a screen entry point through all Clean Architecture layers (Presentation → Domain → Data) and writes a structured Screen System Design document
- `developer-sysdesign-consolidate-worker` — merges two or more Screen System Designs into a consolidated Flow System Design with deduplicated APIs and data models
- `/developer-extract-sysdesign` skill — orchestrates single-screen extraction or parallel multi-screen extraction followed by flow consolidation
- `screen_entry_points` KMS pattern added to `standard-architecture` for Flutter, iOS, and Android — provides layer-to-file glob patterns and grep tracing hints loaded by the extract worker at runtime

---

## [12.5.2] — 2026-06-12

### Fixed
- `developer-adjust-ticket`: detect custom subsections in existing Session Adjustment and ask user to keep or remove them before replacing

---

## [12.5.1] — 2026-06-12

### Fixed
- `saturn-jaygarcia`: removed `disable-model-invocation` from skill frontmatter

---

## [12.5.0] — 2026-06-12

### Changed
- Removed symlinks distribution path — plugin-only distribution model
- Updated `CLAUDE.md`, `submodule-repo-structure.md`, `core-design-principles.md` to reflect plugin-only setup
- `installer-doctor`: removed stale symlinks check (check #3), renumbered remaining checks
- `statusline-command.sh`: fixed ANSI escape codes using `$'...'` syntax; token counts now read from JSON stdin

---

## [12.4.0] — 2026-06-12

### Changed
- Renamed `saturn-descend` skill and reference dir to `saturn-jaygarcia` — named after Saturn's full One Piece name, Saint Jaygarcia Saturn

---

## [12.3.3] — 2026-06-12

### Fixed
- `saturn-descend` skill: ticket ID slug now preserves original casing (`PROJ-123` not `proj-123`)

---

## [12.3.2] — 2026-06-12

### Changed
- `saturn-descend` skill: run_dir slug now prefers the ticket ID extracted from the current git branch (e.g. `feature/PROJ-123-foo` → `proj-123`); falls back to task description if no ticket pattern found

---

## [12.3.1] — 2026-06-12

### Fixed
- `saturn-descend` skill: model was invoking `lucci-planner` via `Skill` tool instead of `Agent` — added explicit guard in Routing Contract
- `saturn-descend` skill: model was self-resolving open questions by reading source files, then skipping the approval gate and spawning `kaku-worker` directly — added prohibition on self-resolution and hard `NEVER` gate before Step 3

---

## [12.3.0] — 2026-06-12

### Changed
- Renamed `saturn-calamity` skill and reference dir to `saturn-descend` — better reflects the One Piece lore (Saturn personally descending signals the highest-priority task)

---

## [12.2.1] — 2026-06-11

### Changed
- Renamed `lib/core/skills/release` to `lib/core/skills/release-project` to avoid colliding with the internal `/release` skill (`.claude/skills/release`); added `user-invocable: true` and `disable-model-invocation: true` so it only fires on explicit `/release-project`

## [12.2.0] — 2026-06-11

### Added
- `saturn-calamity` persona — opusplan-style plan/build hand-off: `/saturn-calamity` skill routes to `lucci-planner` (opus, explores and writes `plan.md`) for review/approval, then `kaku-worker` (sonnet) executes unattended
- `lib/core/reference/saturn-calamity/plan-format.md` — `plan.md` schema and section contracts shared by lucci-planner, kaku-worker, and the saturn-calamity skill

### Changed
- Feature Docs relocated from `lib/core/reference/feature-docs/` to `docs/feature-docs/` — internal-only for now, no longer shipped downstream via submodule; updated `librarian-feature-strategist`, `librarian-explain`, `librarian-generate`, `librarian-merge`, `librarian-scan`, `feature-doc-principles.md`, `kms-design-principles.md`, and `lib/core/reference/README.md` to reference the new path

### Removed
- 6 stale `docs/initiatives/*.md` docs superseded by current principles docs (app-planner, contract-schema-improvement-backlog, kms-initiative, knowledge-management-example-timeoff, knowledge-management-initiative, worktree-isolation-initiative)
- Old Feature Doc copies at `lib/core/reference/feature-docs/{overtime,timeoff}.md` (moved to `docs/feature-docs/`)

---

## [12.1.0] — 2026-06-11

### Added
- `docs/initiatives/kms-retrieval-strategy-initiative.md` — fetch-by-topic KMS retrieval strategy, verified contract table of real KMS slugs per skill

### Changed
- 10 `lib/core/agents/**` agents (planners, workers, debugger, auditor, qa) migrated from `kms_list`->`kms_query` to `kms_list`->`kms_fetch` (fetch-by-topic), with `artifact` threaded through every call; `kms_query` reserved for cold-start discovery only
- 18 `lib/core/skills/**` leaf skills converted to fetch-by-topic KMS retrieval, removing dead flat-file fallbacks to deleted `kms/knowledge-sources/engineering/{platform}-standard-architecture.md` paths
- All `mcp__kms__*` tool references renamed to `mcp__cp8__*` to match the registered MCP server name
- `kms/db` wiped and cleanly reseeded (653 nodes; dropped 726 stale pre-restructure flat nodes + 8 template nodes)

### Fixed
- 8 of 10 KMS-calling agents declared only `mcp__cp8__kms_query` in `tools:` while calling `kms_list` (undeclared) — now declare `kms_list, kms_fetch, kms_query`
- `developer-feature-worker`'s null-safety `kms_fetch` used an invalid schema (`topic="null_safety_extensions"`) — corrected to `artifact="conventions", topic="conventions", pattern="null_safety_extensions"`
- 4 skills (`debugger-add-logs`, `debugger-remove-logs`, `auditor-arch-check`, `developer-test-procedure`) had `allowed-tools` excluding KMS entirely — now granted `mcp__cp8__kms_list, mcp__cp8__kms_fetch`

---

## [12.0.3] — 2026-06-11

### Fixed
- `server.sh`: replace PATH prepend with a `_find_python3` discovery function covering pyenv, asdf, rye, conda, homebrew, and system python3 — works in non-login shells regardless of version manager

---

## [12.0.2] — 2026-06-11

### Changed
- MCP server key renamed from `kms` to `cp8` in `.mcp.json` template and installer
- `FastMCP` server name updated to `cp8`

### Added
- README: Step 4 — MCP server setup with `.mcp.json` snippet and `CP8_*` env var table
- README: Step 2 now uses `claude plugin marketplace add` CLI command with migration note for `sda` users

---

## [12.0.1] — 2026-06-10

### Changed
- `KMS_ENABLE_LOGGING` → `CP8_ENABLE_LOGGING`, `KMS_LOG_MAX_MB` → `CP8_LOG_MAX_MB`

### Fixed
- README: `/cipherpol-status` description still referenced "Full SDA health check"

---

## [12.0.0] — 2026-06-10

### Changed
- Rebranded from **software-dev-agentic** to **CipherPol**
- Marketplace: `sda` → `cipherpol`
- Plugins: `sda-core` → `cipherpol-aegis` (CP0/Aegis), `sda-kms` → `cipherpol-8` (CP8)
- Env vars: `SDA_PLATFORM` → `CIPHERPOL_PLATFORM`, `SDA_PROJECT` → `CIPHERPOL_PROJECT`
- Skill: `sda-status` → `cipherpol-status`
- Platform registry: `sda.json` → `cipherpol.json`

---

## [11.0.2] — 2026-06-10

### Fixed
- `sda-status` project snapshot no longer false-positives `⚠ empty body` on `##`-chunked file-header stub nodes; skips nodes under 100 chars and surfaces real content nodes instead

---

## [11.0.1] — 2026-06-10

### Added
- `sda.json` projects now have `kms_id` (matching `kms/knowledge-sources/projects/` directory names) and optional `platform` hint
- `sda-status` reports active KMS MCP server version vs latest cached on disk; flags `⚠ stale session` if they differ

### Changed
- `install-plugin.sh` resolves project `kms_id` from `sda.json` and writes it to `SDA_PROJECT` in `settings.local.json`

---

## [11.0.0] — 2026-06-10

### Added
- `sda.json` — canonical platform registry mapping platform ids to KMS ids, labels, and codebase detection markers
- `lib/plugins/sda-core/` and `lib/plugins/sda-kms/` — per-plugin `build.config.json` + `build.sh` sourcing shared `plugin-lib.sh`
- `scripts/plugin-lib.sh` — shared build helpers (`copy_agents`, `copy_skills`, `write_manifest`, `update_marketplace`)
- `lib/core/skills/detect-platform/` — 4-tier platform/project detection (env var → CLAUDE.md → codebase markers → fail)
- `lib/core/skills/sda-status/` — full SDA health check: platform, project, plugin versions, KMS connectivity, knowledge coverage
- `scripts/install-plugin.sh` — new installer: validates `--platform` against `sda.json`, writes `SDA_PLATFORM`/`SDA_PROJECT` to `settings.local.json`, patches CLAUDE.md, installs `sda-core` + `sda-kms`

### Changed
- `scripts/build-plugin.sh` — now a thin orchestrator that discovers and runs `lib/plugins/*/build.sh`; replaced `--platform` with `--target`
- `lib/core/skills/installer-doctor/` — rewritten for plugin-only checks (no submodule assumptions)
- `.claude-plugin/marketplace.json` — now contains only `sda-core` and `sda-kms`

### Removed
- Per-platform plugins (`flutter`, `ios-swift`, `android-kotlin`, `web-nextjs`) — replaced by single `sda-core` with runtime platform detection
- Standalone `kms` plugin — replaced by `sda-kms`
- Installer persona agent and submodule installer skills (`installer-setup`, `installer-sync`, `installer-update`, `installer-migrate-plugin`)
- `kms-status` skill — replaced by `sda-status`
- Submodule-era scripts (`setup-symlinks.sh`, `sync.sh`, `check-skill-contracts.sh`, `setup-ai.sh`, `clean-ai.sh`, `sda.sh`)
- `lib/platforms/` directory (ios-swift, web-nextjs platform-specific files)
- `docs/contract/installer-skill-contract.md`

---

## [10.12.0] — 2026-06-10

### Changed
- **KMS usage log format** — replaced `kms-usage.jsonl` with `kms-usage.log`, a human-readable plain-text format. Each entry shows timestamp, tool, latency, inputs, and a compact result summary (count + top IDs / content_chars) instead of the full payload. Removes 200KB+ per `kms_list` call from the log file.

---

## [10.11.4] — 2026-06-10

### Added
- **KMS result logging** — `kms_list`, `kms_fetch`, and `kms_query` now write the full result payload into `kms-usage.jsonl` when `KMS_ENABLE_LOGGING=true`. Enables post-session inspection of exactly what the agent read from the knowledge store.

---

## [10.11.3] — 2026-06-10

### Fixed
- **KMS version sort in README and install-plugin.sh** — `ls -v` on macOS BSD sorts alphabetically, not by version. Replaced with `sort -t. -k1,1n -k2,2n -k3,3n` in `README.md` (personal setup and auto-install `.mcp.json` examples) and `scripts/install-plugin.sh` (version detection and `KMS_CMD` written to downstream `.mcp.json`).
- **installer-doctor marketplace check** — `sda` marketplace is registered at user scope (`~/.claude/settings.json`), not project scope. Updated the check to point to the global settings file.

---

## [10.11.2] — 2026-06-10

### Fixed
- **KMS stale server processes** — `server.sh` now kills any running `kms.application.mcp_server` processes that don't belong to the current plugin version on startup. Prevents zombie processes from older versions accumulating across Claude Code restarts and serving stale (pre-logging) code.

---

## [10.11.1] — 2026-06-10

### Fixed
- **KMS version picker on macOS** — `ls -v` on macOS sorts alphabetically, not by version, causing `10.9.0` to sort after `10.11.0` and the server to launch an old build without logging support. Replaced with `sort -t. -k1,1n -k2,2n -k3,3n` for correct numeric ordering. Fixes in both `build-plugin.sh` (template) and `~/.claude/mcp.json` (direct config).

---

## [10.11.0] — 2026-06-09

### Added
- **KMS usage logging** — `sda-kms` MCP server now supports opt-in JSONL logging of all tool calls (`kms_list`, `kms_fetch`, `kms_query`, `kms_upsert`). Each entry records timestamp, tool name, inputs, result count, and latency (ms). Disabled by default; enable via `KMS_ENABLE_LOGGING=true` in the `env` block of your MCP config or `mcp.json`. Size-based rotation: when the log exceeds `KMS_LOG_MAX_MB` (default 10 MB), the current file is renamed to `.old` and a fresh log starts. Log path defaults to `<db_parent>/logs/kms-usage.jsonl`, overridable via `KMS_LOG_PATH`.

---

## [10.10.0] — 2026-06-09

### Changed
- **Tracker persona merged into developer** — `tracker-issue-worker`, `tracker-jira-ticket-worker`, and skills `tracker-{issue,jira-ticket,adjust-ticket}` renamed to `developer-{issue-worker,jira-ticket-worker}` and `developer-{issue,jira-ticket,adjust-ticket}`. All cross-references updated. Tracker had no independent domain — issue lifecycle, Jira ticket creation, and session adjustment are all bookends of the developer workflow.

### Added
- **`## Bugs` section in `developer-adjust-ticket`** — optional checklist section in Session Adjustment for bugs found during a session

---

## [10.9.0] — 2026-06-08

### Added
- **Magic Constants convention** — `kms/knowledge-sources/engineering/{flutter,ios,android}-conventions.md` now document the no-magic-string/number rule: promote shared, domain-meaningful literals to a scoped `Constants` directory/namespace, co-locate file-local ones as `static const`/`private static let`/`companion object const val` (platform-idiomatic), with an exemption list for trivial sentinel values (`0`/`1`/`-1`, bools, empty-string guard checks)

---

## [10.8.1] — 2026-06-08

### Fixed
- **`kms_query` crash on combined `platform` + `discipline` filters** — `ChromaKnowledgeRepository.query()` passed multi-key `where` dicts straight to ChromaDB, which requires a single `{field: {"$eq": v}}` clause or a composite `$and`/`$or`. Any query combining both filters (e.g. `developer-feature-worker`'s pre-flight cross-cutting conventions load) crashed with `Expected where to have exactly one operator`. Now reuses `_build_where`, the same wrapper already used by `list()` and `fetch_exact()`

---

## [10.8.0] — 2026-06-08

### Added
- **Per-platform code convention docs** — `kms/knowledge-sources/engineering/{flutter,ios,android}-conventions.md` documenting null-safety/optional-handling extensions (`.orEmpty()`, `.orZero()`, `.orFalse()`, etc.) and helper extensions, derived from the actual downstream codebases
- **Universal engineering template** — `engineering/_template.md` stubs the common Clean Architecture `#` sections (Domain, Data, Presentation, DI, Navigation, Error Handling, Testing, Utilities) shared across all platforms
- **Retrieval Protocol section in `kms-design-principles.md`** — documents when agents should use `kms_list` (TOC discovery), `kms_fetch` (deterministic exact-match for uniform cross-platform topics), or `kms_query` (semantic search)

### Changed
- **`developer-feature-worker`** — pre-flight now combines `kms_list` + `kms_fetch` + `kms_query`; deterministically fetches the `null_safety_extensions` convention by exact topic instead of relying on `kms_query` ranking it against ~15 competing convention sections. Declared `mcp__kms__kms_list` and `mcp__kms__kms_fetch` in the tool list (kms_list was already being called undeclared)
- **`ios-standard-architecture.md`** — moved `Null Safety Extensions` and `Helper Extensions` sections (plus a duplicate `Conventions` block) out into `ios-conventions.md`

### Removed
- **`engineering/{flutter,ios,android}-_template.md`** — redundant with fully populated `{platform}-standard-architecture.md` docs; replaced by the single universal `_template.md`

---

## [10.7.0] — 2026-06-05

### Added
- **Personal setup path in README** — documents no-commit setup: platform plugin in `.claude/settings.local.json` (gitignored), `sda-kms` enabled via `claude plugin enable --scope user`, KMS MCP registered via `claude mcp add --scope user`

### Fixed
- **`ios-talenta` → `talenta-ios`** — renamed KMS project directory and `repo.yaml` name to match actual repo name; old nodes cleared via DB reset

---

## [10.6.0] — 2026-06-05

### Added
- **KMS chunk strategy principle** — Principle 10 in `kms-design-principles.md` documents the `##` heading → one ChromaDB node rule and the authoring requirement that distinct topics must have their own `##` heading to be exactly fetchable via `kms_fetch`

### Changed
- **`android-standard-architecture.md`** — promoted `### Conventions and Naming` from a buried sub-section of `## Project Structure` to a standalone `## Naming Convention` node; topic `naming_convention` is now reachable by exact metadata fetch
- **`android-_template.md`** — added `## Naming Convention` stub to the canonical Android vocabulary

---

## [10.5.2] — 2026-06-04

### Fixed
- **`.gitignore` over-broad `chroma/` pattern** — changed to `/chroma/` and `/kms/db/` (root-anchored); previously matched `dist/plugins/kms/chroma/` and silently excluded all HNSW vector files from git, causing `sda-kms` to ship an empty vector index

---

## [10.5.1] — 2026-06-04

### Fixed
- **`sda-kms` bundled chroma** — excluded `kms/db/` from the Python package copy; chroma now only lives at `$PLUGIN_ROOT/chroma`
- **`sda-kms` node count** — fresh reseed ensures 735 nodes including ios-talenta and mobile-talenta project-scoped nodes

---

## [10.5.0] — 2026-06-04

### Added
- **`sda-kms` dedicated plugin** — KMS MCP server now ships as its own plugin (`dist/plugins/kms/`); install once, shared across all platforms
- **`build-plugin.sh --platform=kms`** — builds `sda-kms` standalone; `--platform=all` builds `sda-kms` first then all platform plugins

### Changed
- **Platform plugins** (`sda-flutter`, `sda-ios-swift`, `sda-android-kotlin`, `sda-web-nextjs`) — no longer bundle KMS; agents/skills/hooks only
- **`project-mcp-template.json`** — now lives in `sda-kms`; points to `sda-kms` cache path (same config for all platforms)
- **`README.md`** — added `sda-kms` to plugin table; unified `.mcp.json` example; bumped version to v10.4.0

### Removed
- **KMS duplication** — `kms/`, `chroma/`, `server.sh`, and `project-mcp-template.json` removed from all platform plugin outputs

---

## [10.4.0] — 2026-06-04

### Fixed
- **`kms/db` is now the canonical ChromaDB** — `mcp_server.py` default, `build-plugin.sh` source, and `kms-seed-orchestrator` db_path all point to `kms/db`; previously seed wrote to `kms/db`, MCP server read from `chroma/`, and build bundled from `dist/.kms_seeds/.shared/chroma` — three different locations

---

## [10.3.0] — 2026-06-04

### Fixed
- **`kms_list(project=...)` returns empty** — `ListKnowledge` now fetches project-tier nodes when only `project` is given; previously required both `platform` and `project`
- **ios-talenta nodes stored under wrong project name** — `_load_repo_meta` now respects the `name` field in `repo.yaml` before falling back to remote URL derivation; `talenta-ios.git` remote no longer overrides `name: ios-talenta`
- **`kms_fetch` wrong discipline for project docs** — project knowledge nodes are seeded with `discipline="engineering"`, not `"projects"`

### Changed
- **`mobile-talenta/repo.yaml`** — added explicit `name: mobile-talenta` field
- **`kms/knowledge-sources/projects/ios-talenta/`** — deviations headings simplified (stripped verbose `— subtitle` pattern); `Moya/RxSwift` → `Moya RxSwift Integration`
- **`kms/knowledge-sources/projects/mobile-talenta/`** — `Overview` → `App Structure`; `Time Management (TM)` split into 9 top-level `##` sections; `Inbox / Approvals` split into `Inbox` + `Approval Requests`; `Account / Profile` → `Account Profile`; `Task & Timesheet (TNT)` → `Task Management`; `Presentation Widgets (Shared)` split into 7 `##` sections

---

## [10.2.0] — 2026-06-04

### Added
- **Discipline heading templates** — each discipline folder in `kms/knowledge-sources/` now has a `_template.md` (universal) and/or `{platform}-_template.md` (platform-specific) defining the canonical `##` heading vocabulary; covers all nine disciplines (`engineering`, `design`, `qa`, `devops`, `security`, `product`, `architecture`, `agile`) and all three engineering platforms (`flutter`, `ios`, `android`)
- **`content_type` field on `KnowledgeNode`** — `"real"` (default) or `"stub"`; templates seed as stubs so agents can discover available topics before real content is written; persisted in ChromaDB metadata
- **One-way seeding guard in `UpsertKnowledge`** — stubs never overwrite real nodes; re-seeding templates after real content exists is always a no-op

### Changed
- **`DirectorySource`** — detects `_template.md` / `{platform}-_template.md` files and marks all yielded nodes `content_type="stub"`
- **`kms-design-principles.md`** — added discipline templates section (Principle 7), third path convention for template files, `content_type` added to metadata schema table
- **`kms-knowledge-source-rules.md`** — file naming table updated with template filename patterns; Discipline-Specific Heading Templates section now points to template files; new **Template Files** section documents authoring rules and one-way seeding guarantees

---

## [10.1.0] — 2026-06-04

### Added
- **KMS section-level chunking** — `DirectorySource` now splits every knowledge file by `##` headings before seeding; each section becomes one ChromaDB node instead of one blob per file
- **`/kms-audit`** — new orchestrator skill + `kms-source-audit-worker` agent; validates all files in `kms/knowledge-sources/` against authoring rules (R1–R7) before seeding; reports errors and warnings
- **`docs/principles/kms-knowledge-source-rules.md`** — authoring rules for knowledge source files: chunking contract, file naming, section structure (R1–R7), discipline-specific heading templates, project doc rules, `kms_upsert` contract

### Changed
- **All agents and skills** — replaced `kms_list` + `kms_fetch` with `kms_query` (semantic search); agents no longer require exact `(topic, pattern)` metadata match — one architecture doc per platform is sufficient
- **`kms-extract-worker`** — all output formats updated to use `##`-per-entity structure (one heading per feature, endpoint group, component, integration); project docs now chunk correctly on seed
- **`kms-extract-codebase` skill** — added existence check before extraction; prompts user to choose `overwrite-all` / `missing-only` / `select` when docs already exist; supports new project bootstrap (creates `repo.yaml` when project directory doesn't exist yet)
- **`kms-extract-orchestrator`** — respects `doc_types` filter from skill; validates `##` headings in output files before proceeding to seed

### Removed
- **Stale v9.3.0 project-specific plugins** — `android-talenta`, `flutter-mobile-talenta`, `flutter-mobile-jurnal`, `flutter-qontak-chat`, `flutter-qontak-crm`, `ios-talenta`, `web` removed from `dist/plugins/` and `marketplace.json`; only generic platform plugins remain (`flutter`, `ios-swift`, `android-kotlin`, `web-nextjs`)

---

## [10.0.4] — 2026-06-04

### Fixed
- **`/kms-status`** — summary table now collapses all disciplines into one row per `platform+project`; non-engineering topics annotated with `[discipline]` tag (e.g. `mekari_pixel_catalog [design]`)

---

## [10.0.3] — 2026-06-04

### Added
- **`seed_kms.py --force`** — bypass content-hash check and re-upsert all nodes; useful when ChromaDB has nodes with empty content

### Fixed
- **`UpsertKnowledge`** — when owned section filtering produces empty content (e.g. project docs with `## Features` heading not in `owns`), fall back to storing full content instead of silently writing an empty node
- **`/kms-status` Step 7** — project summary now uses the first two topics returned from the load probe instead of hardcoded topic names

---

## [10.0.2] — 2026-06-04

### Added
- **`/kms-status`** — Step 7: project knowledge summary — fetches `project_structure` and `feature_inventory` nodes for the current project and shows a 2–3 line excerpt to confirm real content is retrievable

---

## [10.0.1] — 2026-06-04

### Added
- **Mekari Pixel Flutter catalog** — moved from `lib/core/reference/design-system/` to `kms/knowledge-sources/design/flutter-mekari-pixel-catalog.md`; seeded into ChromaDB under `discipline=design, platform=flutter`
- **`developer-feature-worker`** — pre-flight now queries `kms_list(discipline="design")` for component catalog; gracefully skips with a log line when no catalog exists (iOS, Android)
- **`/kms-status`** — scoped load probe: fires the same `kms_list` calls agents use in pre-flight (engineering + design per platform/project) and reports node counts and topics

### Changed
- **`/release`** — step 3 now flushes uncommitted working-tree changes into logical chunk commits before touching VERSION/CHANGELOG

---

## [10.0.0] — 2026-06-04

### Added
- **KMS-aware agents** — `developer-backend-worker`, `auditor-arch-review-worker`, `debugger-worker`, `qa-testcase-worker` now load patterns via `kms_list` → reason → `kms_fetch` before executing

### Changed
- **Platform consolidation** — `lib/platforms/` reduced from 7 project-specific dirs to 4 generic platforms: `flutter`, `ios-swift`, `android-kotlin`, `web-nextjs`
- **Project derivation** — all KMS-aware agents derive `project` from `basename $(pwd)` instead of reading CLAUDE.md; no downstream CLAUDE.md changes required
- **`ios-swift` / `web-nextjs`** — agents and skills removed; knowledge now sourced entirely from KMS
- **Plugin marketplace** — 4 generic plugins (`sda-flutter`, `sda-ios-swift`, `sda-android-kotlin`, `sda-web-nextjs`) replace 7 project-specific ones

### Removed
- **`lib/platforms/flutter-mobile-talenta`**, **`flutter-qontak-crm`**, **`flutter-mobile-jurnal`**, **`flutter-qontak-chat`** — consolidated into `flutter`
- **`lib/platforms/ios-talenta`** — renamed to `ios-swift`
- **`lib/platforms/android-talenta`** — renamed to `android-kotlin`
- **`lib/platforms/web`** — renamed to `web-nextjs`
- **`flutter-qontak-crm` legacy skills** — project-specific; belong in downstream `.claude/skills.local/`

---

## [9.3.0] — 2026-06-04

### Added
- **KMS stable architecture** — `kms/domain/schema.py` as single vocabulary contract (`SCOPE_VALUES`, `DISCIPLINE_VALUES`, `SOURCE_TYPE_OWNS`, `SEED_EXCLUDE_PATTERNS`, `SCHEMA_VERSION`)
- **`DirectorySource` adapter** — primary seed source; derives all metadata (discipline, platform, scope, topic, pattern) from path conventions; no frontmatter required
- **Project-specific knowledge convention** — `kms/knowledge-sources/projects/{repo-name}/` with `repo.yaml` (remote URL, platform, local_path); project name derived from remote URL
- **`kms/knowledge-sources/` directory** — drop-in knowledge store organized by discipline; replaces `lib/core/knowledge/` as primary source
- **Platform standard architecture docs** — `flutter-standard-architecture.md`, `ios-standard-architecture.md`, `android-standard-architecture.md` compiled from all platform pattern files
- **`kms/sources.yaml`** — source registry; seed runner reads this manifest, never hardcodes sources
- **`/kms-seed` skill** — seed ChromaDB from all sources, one source, by type, or add+register a new source
- **`/kms-extract-codebase` skill** — scan a local project repo and extract project-reality docs (feature inventory, API endpoints, shared components, deviations, integrations)
- **`kms-seed-orchestrator`**, **`kms-seed-worker`**, **`kms-source-detect-worker`** agents — agentic seeding workflow
- **`kms-extract-orchestrator`**, **`kms-extract-worker`** agents — platform-aware codebase extraction for Flutter/iOS/Android/Web
- **`docs/principles/kms-design-principles.md`** — full KMS design rationale, metadata schema, discipline vocabulary, cascade resolution rules
- **`kms/README.md`** — source adapter contract, seeding CLI reference, metadata schema

### Changed
- **`KnowledgeNode`** — added `scope` and `content_hash` fields; `scope` replaces null-inference on platform+project for cascade resolution
- **`UpsertKnowledge`** — enforces section ownership at domain layer; each source only writes its declared sections, merges with existing content
- **`seed_kms.py`** — full rewrite as unified runner with `--source`, `--type`, `--add` flags; incremental via content hash; skip-on-unavailable
- **`sync-platform` skill** — Step 3c updated from `agent-kms-scan-worker` to `/kms-extract-codebase`
- **`release` skill** — KMS freshness check updated to read `sources.yaml` `last_seeded` instead of git hash on `lib/core/knowledge`
- **Downstream skills** (`developer-*`, `auditor-*`, `debugger-*`) — fallback paths updated from `lib/core/knowledge/` to `kms/knowledge-sources/engineering/{platform}-standard-architecture.md`

### Removed
- **`lib/core/knowledge/`** — replaced by `kms/knowledge-sources/`; all pattern files compiled into consolidated platform architecture docs
- **`agent-kms-scan-worker`** — replaced by `kms-extract-worker` + `kms-extract-orchestrator`

---

## [9.2.12] — 2026-06-03

### Changed
- **Planner agents use KMS MCP as primary knowledge source** — added `mcp__kms__kms_list` and `mcp__kms__kms_fetch` to `tools:` frontmatter of all four planners (`developer-domain-planner`, `developer-data-planner`, `developer-pres-planner`, `developer-app-planner`) so KMS MCP tools are reachable and the primary path runs before any codebase search

### Fixed
- **Planner fallback no longer reads from `software-dev-agentic/` source** — previous fallback path coupled agents to submodule structure; primary distribution is Claude plugin, not submodule; fallback now skips pattern reference and infers naming conventions from found codebase files instead

---

## [9.2.11] — 2026-06-03

### Fixed
- **Planner agents skipping KMS Step 0 in groom mode** — `developer-domain-planner`, `developer-data-planner`, `developer-pres-planner`, and `developer-app-planner` were silently skipping `kms_list` → `kms_fetch` when spawned by the groom-ticket skill with a `grooming-only` mode prompt; the custom prompt overrode the agent workflow so the model never reached Step 0; fixed by annotating each Step 0/1 label as `(always — run before any codebase search, regardless of mode)` so the constraint is self-enforcing in the agent body, not delegated to the orchestrator

---

## [9.2.10] — 2026-06-03

### Fixed
- **Plugin `.mcp.json` conflict** — removed plugin-level `.mcp.json` from the build entirely; Claude Code was loading it alongside the project-level `.mcp.json`, causing two "kms" servers to compete for the same name and producing `-32000` errors; project `.mcp.json` is the only source of truth

---

## [9.2.9] — 2026-06-03

### Added
- **`knowledge/` shipped in plugin** — `build-plugin.sh` now copies `lib/core/knowledge/` into the plugin as `knowledge/`; agents can fall back to reading pattern files directly when KMS MCP is offline, and `kms-status` can verify the directory is present
- **`KMS_KNOWLEDGE_DIR` env var** — `server.sh` exports the knowledge directory path so `mcp_server.py` can expose it
- **`kms_info()` MCP tool** — returns `db_path`, `db_exists`, `total_nodes`, `knowledge_dir`, `knowledge_exists`, `knowledge_files`; called by `kms-status` as the first diagnostic step
- **`kms-status` knowledge dir reporting** — output now includes ChromaDB path and knowledge directory status with file count; flags missing directories as build issues

---

## [9.2.8] — 2026-06-03

### Removed
- **`dart-repo-knowledge` skill + `dart-knowledge` agents** — unrelated to KMS; was a separate dartdoc RAG pipeline that caused the model to suggest it as a KMS fix

### Fixed
- **`kms-status` skill** — replaced open-ended empty-case instruction with an explicit output block; model was hallucinating `/dart-repo-knowledge` as the fix when nodes = 0; now outputs a fixed restart instruction instead

---

## [9.2.7] — 2026-06-03

### Fixed
- **`ListKnowledge.execute()` returns 0 nodes when called with no args** — unfiltered calls (e.g. `kms-status`) forced a `platform=null` equality filter that matched nothing, since all seeded nodes have an explicit platform; fixed by short-circuiting to an unfiltered `repo.list()` when no scope args are provided

---

## [9.2.6] — 2026-06-03

### Added
- **`kms/project-mcp-template.json`** — each plugin dist now includes a portable `.mcp.json` template; downstream projects copy it to their project root once to enable KMS; uses `$HOME` so it's portable across machines without running any scripts

### Changed
- **`install-plugin.sh` KMS step** — now writes a `$HOME`-based version-agnostic launcher instead of an absolute versioned path

---

## [9.2.5] — 2026-06-03

### Fixed
- **`install-plugin.sh` KMS launcher** — replaced hardcoded versioned path with a version-agnostic `bash -c` command that resolves the latest installed plugin version at runtime (`ls -v ... | tail -1`); survives plugin updates without re-running `install-plugin.sh`

---

## [9.2.4] — 2026-06-03

### Fixed
- **KMS MCP server offline in downstream projects** — `install-plugin.sh` now writes a project-level `.mcp.json` with an absolute resolved path to `server.sh` after `claude plugin install`; Claude Code does not expand `${CLAUDE_PLUGIN_ROOT}` in `.mcp.json` args (passes it as a literal string to bash), so the plugin-level `.mcp.json` alone was insufficient to start the server
- **Plugin `.mcp.json` template** — switched from `args: ["${CLAUDE_PLUGIN_ROOT}/kms/server.sh"]` to `args: ["-c", "exec \"$CLAUDE_PLUGIN_ROOT/kms/server.sh\""]`; `bash -c` evaluates the string as a shell command so `$CLAUDE_PLUGIN_ROOT` is expanded from the env if Claude Code sets it

---

## [9.2.3] — 2026-06-03

### Fixed
- **`server.sh` dep check** — added `mcp` to the auto-install guard (`import chromadb, yaml, mcp`); previously only `chromadb` and `yaml` were checked so the `mcp` package was never installed on first run, causing `ModuleNotFoundError` and silently killing the MCP server
- **`kms-status` skill** — removed `allowed-tools: mcp__kms__kms_list`; when KMS MCP is offline the tool doesn't exist, causing Claude Code to fail loading the skill entirely and showing "Unknown command"

---

## [9.2.2] — 2026-06-03

### Added
- **`kms-status` skill** — user-invocable validation skill; calls `kms_list()` with no filters, groups by platform/project, reports node counts and topic coverage; surfaces KMS OFFLINE or empty-seed conditions

---

## [9.2.1] — 2026-06-03

### Fixed
- **Agent fallback guard** — added explicit `NEVER read from .claude/reference/code-architecture/` prohibition to fallback instruction in all 6 developer agents; model was ignoring the written fallback path and reverting to deleted legacy paths when KMS MCP was unavailable

---

## [9.2.0] — 2026-06-03

### Added
- **KMS Dashboard** — local web UI (`kms/dashboard/server.py` + `index.html`); pure-Python HTTP server reusing existing use cases; hierarchical `platform → discipline → topic → pattern` tree nav, per-section markdown editor, semantic vector search, new-node form; launcher `scripts/kms-dashboard.sh`; writes `dashboard:{timestamp}` to `dist/.kms_seeds/.version` on every upsert so `build-plugin.sh` skips file-based reseed

### Changed
- **6 developer agents** — `kms_list` → `kms_fetch` wired as primary knowledge source in `developer-domain-planner`, `developer-data-planner`, `developer-pres-planner`, `developer-app-planner`, `developer-feature-worker`, `developer-ui-worker`

### Fixed
- **Agent fallback paths** — corrected `lib/core/knowledge/` → `software-dev-agentic/lib/core/knowledge/` in all 6 agents; the old path does not exist at downstream project root, causing planners to silently fall back to the legacy `.claude/reference/code-architecture` search

---

## [9.1.0] — 2026-06-03

### Added
- **Pattern KMS — `kms/` Python package** — Clean Architecture implementation: `domain/entities.py` (`KnowledgeNode`), `domain/repository.py` (`KnowledgeRepository` interface), four use cases (`list_knowledge`, `fetch_knowledge`, `query_knowledge`, `upsert_knowledge`), `data/chroma_repository.py` (ChromaDB embedded), `application/mcp_server.py` (FastMCP — `kms_list`, `kms_fetch`, `kms_query`, `kms_upsert`), `scripts/seed_kms.py`
- **ChromaDB embedded** — 207 knowledge nodes seeded from `lib/core/knowledge/`; `all-MiniLM-L6-v2` embeddings for semantic search; cascade resolution (project → platform-base → universal) in `FetchKnowledge` and `ListKnowledge`
- **`build-plugin.sh` KMS step** — copies `kms/` package, generates self-locating `server.sh`, seeds ChromaDB, writes `.claude/settings.json` with `mcpServers.kms` entry

### Changed
- **17 core procedure skills** — `knowledge_scope:` simplified from `engineering/topic` → `engineering`; Step 1 now calls `kms_fetch(discipline, topic, pattern, platform, project)` with direct-Read fallback; `auditor-arch-check` uses `kms_list(platform, project, discipline)` instead of per-topic index reads

---

## [9.0.0] — 2026-06-03

### Added
- **Pattern KMS — `lib/core/knowledge/`** — new knowledge root replacing `lib/platforms/*/reference/code-architecture/`. All implementation patterns now live as individual pattern files under `{platform}/engineering/{topic}/{pattern}.md` with frontmatter (`platform`, `project`, `discipline`, `topic`, `pattern`) and structured sections (`## Theory`, `## Definition`, `## Code Pattern`)
- **8 platforms extracted** — `flutter`, `flutter-mobile-talenta`, `flutter-mobile-jurnal`, `flutter-qontak-chat`, `flutter-qontak-crm`, `ios-talenta`, `web`, `android-talenta` — all fully extracted with theory merged into pattern files
- **Per-topic `index.md`** — 38+ index files across all platforms listing available patterns with descriptions; agents use these for intent-based discovery
- **Cascade resolution convention** — agents resolve `{project}/engineering/{topic}/{pattern}.md` → `{platform}/engineering/{topic}/{pattern}.md`; procedure skills declare `knowledge_scope:` frontmatter key

### Changed
- **17 core procedure skills updated** — `developer-domain-*`, `developer-data-*`, `developer-pres-*`, `developer-test-*`, `debugger-*`, `auditor-arch-check` — all now reference `lib/core/knowledge/{platform}/engineering/{topic}/{pattern}.md` with cascade note; `knowledge_scope:` added to frontmatter
- **6 developer planner agents updated** — `developer-domain-planner`, `developer-data-planner`, `developer-pres-planner`, `developer-app-planner`, `developer-feature-worker`, `developer-ui-worker` — Step 0 now reads topic index then specific pattern files by scope; theory file references removed

### Removed
- **`lib/platforms/*/reference/code-architecture/`** — all `*-impl.md` files deleted across 7 platforms (content migrated to `lib/core/knowledge/`)
- **`lib/core/reference/code-architecture/*-theory.md`** — all 11 theory files deleted (content merged into `## Theory` sections of pattern files)

---

## [8.6.0] — 2026-06-02

### Added
- **18 platform-agnostic core procedure skills** — `developer-data-create-{datasource,mapper,repository-impl}`, `developer-domain-create-{entity,repository,usecase,service}`, `developer-pres-create-{stateholder,screen,component}`, `developer-test-create-{mock,domain,data,presentation}`, `debugger-{add,remove}-logs`, `auditor-arch-check`, `installer-setup-project` — all under `lib/core/skills/`; each skill delegates pattern lookup to `.claude/reference/code-architecture/*-impl.md`
- **`## Component` section** — added to `presentation-impl.md` on all 7 platforms with a reusable, state-management-unaware component pattern and path convention
- **`## Logging` section** — added to `presentation-impl.md` on all 7 platforms with the platform's debug log format (`debugPrint`/`print`/`Log.d`/`console.log`) and `[DebugTest]` prefix rules
- **`## StateHolder` section** — added to `flutter-qontak-crm` and `flutter-mobile-jurnal` `presentation-impl.md` (was missing)

### Changed
- **`presentation-impl.md` restructured on all 7 platforms** — `## StateHolder` now spans all implementation sub-sections as `###` children (BLoC/Presenter/ViewModel/Cubit patterns, State/Events/States, Layer Invariants) so a single `Read(file, offset, limit=N)` retrieves the full implementation; `## Screen Structure` is the canonical H2 for screen patterns (renamed from `## ViewController` on iOS, `## Activity / Fragment` on Android; added to web)
- **Platform contract skill dirs removed** — 126 files across 7 platforms deleted; procedure logic now lives in the 18 core skills above

### Removed
- **`lib/platforms/*/skills/contract/`** — all 7 platform contract skill directories (18 skills × 7 platforms = 126 files) replaced by the 18 core skills

---

## [8.5.0] — 2026-06-02

### Added
- **5-slot body structure (`## Input`, `## Output`, `## Knowledge`, `## Reasoning`)** — added to all six developer agents that were missing them: `developer-feature-strategist`, `developer-feature-worker`, `developer-groom-strategist`, `developer-ui-worker`, `developer-rfc-writer`, `developer-test-worker`
- **`arch-check-conventions`** — new Body Structure check in the Agent Checklist verifies the four conceptual slots (Input, Output, Knowledge, Reasoning) are present in every agent file; Warning for missing Input/Output, Info for missing Knowledge/Reasoning

### Changed
- **`developer-backend-strategist` → `developer-backend-worker`** — renamed to correct role label; agent writes source files directly and is a worker, not a strategist; updated all cross-references (`developer-backend/SKILL.md`, `perf-worker.md`, `presentation-theory.md`)
- **`developer-rfc-writer`** — `## Input Contract` renamed to `## Input`; Steps restructured under `## Reasoning` with `## Step 4` promoted to `## Output`
- **`developer-test-worker`** — `## Layer Routing` renamed to `## Reasoning`; removed spurious `user-invocable: true` (skill-only field)
- **Planner descriptions** — `developer-{domain,data,pres,app}-planner` descriptions updated from "No writes" to "Writes findings to run_dir only — no codebase writes"

### Fixed
- **`web/packages/feature.pkg`** — replaced non-existent agent names (`domain-worker`, `data-worker`, `presentation-worker`) with actual planner and worker agent names
- **`web/packages/backend.pkg`** — replaced non-existent agent names (`developer-backend-orchestrator`, `domain-worker`, `data-worker`, `presentation-worker`) with `developer-backend-worker developer-test-worker`

---

## [8.4.1] — 2026-06-02

### Fixed
- **Librarian agents** — added missing `user-invocable: false` to all five librarian workers (`android`, `ios`, `flutter`, `synthesizer`, `audit`)
- **Librarian skills** — renamed `allowed-tools:` → `tools:` in `librarian-explain`, `librarian-generate`, `librarian-merge`, `librarian-scan`
- **`agent-scaffold-worker`** — strategist template tools corrected to `Read, Glob, Grep` only (removed `Bash`, `AskUserQuestion`); skill template label updated from `Type W (Workflow)` to `Type O (Orchestrator)`; agent naming hint updated to `<persona>-[descriptive]-<role>` format
- **`arch-check-conventions`** — naming rule updated to `<persona>-[descriptive]-<role>.md`; persona subdir list corrected (`builder/` → `developer/`, added `qa/`)

---

## [8.4.0] — 2026-06-01

### Added
- **Principles: System Components section** — overview table and capability matrix covering all five components (Reference, Skill, Agent, MCP, Hooks); inserted before Core Design Principles; mirrors the anatomy and capability matrix slides in the deck
- **Principles: Principle 4 — MCP = Reach** — dedicated principle covering the codebase/external boundary, MCP servers in use, and when to use MCP vs skills
- **Principles: Principle 5 — Hooks = Automation** — dedicated principle covering four lifecycle events and the hooks vs skills decision table

### Changed
- **Principles: Principles renumbered** — former Principle 4 (Official Docs Compliance) → 6; former Principle 5 (Convention Enforcement) → 7

---

## [8.3.1] — 2026-06-01

### Changed
- **Deck: Slide 8 (In Practice) moved after Persona slide** — reordered from position 8 to after slide 10 (Persona = SDLC Phase); the concrete example now follows the persona model rather than preceding the capability matrix
- **Deck: Evolution slide P2/P3 swapped** — "One pass isn't enough" (convergence loop) moved to Problem 2; "Knowledge Coupling + Bloated Agent" moved to Problem 3; progression now follows naturally from the multi-agent setup
- **Deck: Problem 3 expanded** — renamed from "Agents bloat" to "Knowledge Coupling + Bloated Agent"; body now covers all three root causes: agent bloat, knowledge duplication across agents, and brittle updates when knowledge is inlined

---

## [8.3.0] — 2026-06-01

### Changed
- **Deck: Roadmap slide (s6)** — restructured from linear phases to a cycle model; core loop (Foundation → Build → Release → Evaluation) on the left with per-phase outputs; Research Tracks (A: Collaboration, B: Distribution, C: Expansion) on the right running in parallel; cycle framing in caption
- **Deck: Build phase added** — new phase 02 in the core loop between Foundation and Research Tracks; represents constructing agents, personas, and orchestrator skills against stable design principles
- **Deck: Slide 7 component definitions** — stripped design-principle content (Two types, agent anatomy slots, three-tier reference) from each card; cards now describe natural platform behavior and definition only
- **Deck: Capabilities added to slides 7+8** — "Spawns agents" and "Calls skills" added to Skill and Agent descriptions (slide 7) and as new rows in the capability matrix (slide 8); "Multiple invocation modes" added as Agent-only capability
- **Deck: Slides 20/22/23 moved after slide 8** — Evolution, Persona, and Limitations slides repositioned immediately after the capability matrix, before the component deep-dives; labeled Phase 01 — Foundation · Output
- **Deck: Slides 12+13 merged** — Skills overview (Type O/P) and Orchestrator high-level (owns/delegates/constraint) combined into one slide; owns/delegates/parallel spawn/convergence/constraint now shown as inline rows inside the Type O card
- **Deck: Evolution slide (s11-evolution) + Orchestrator checklist merged** — 4-question design checklist appended below the evolution story as a derived-principles section; s11-design removed as standalone slide
- **Deck: Persona slide moved before Evolution** — s11-persona now precedes s11-evolution (slide 9 → 10 swap); establishes the persona model before the design evolution story

---

## [8.2.0] — 2026-06-01

### Added
- **Principle: Orchestrator skill runtime environment** — explicit documentation that the Orchestrator skill runs in the main context window; covers 200K limit, compaction consequence, parallel spawning capability, and convergence loop capability
- **Principle: Orchestrator design checklist** — 4-question guide (Output → Input → Process → Budget) for building a new Orchestrator skill
- **Principle: Persona → SDLC role mapping** — table connecting each persona to its SDLC phase and real-world role; developer (Implementation/SE) and qa (Testing/QA) live; others research
- **Principle: Limitations — Why Not End-to-End** — new section covering context window, token billing, supervision, and gaps as current constraints on cross-persona automation; each framed as a research problem
- **Deck: agent anatomy deep-dive slide** (s8-agent-anatomy) — annotated agent file with per-slot explanation; positioned after the "why this anatomy" slide
- **Deck: Orchestrator skill intro slide** (s8-flow-intro) — high-level owns/delegates/constraint framing before the low-level detail slide
- **Deck: Orchestrator skill anatomy slide** (s8-flow) — three panels: parallel agents, convergence loop, context window constraint with compaction warning
- **Deck: design evolution slide** (s11-evolution) — origin story from raw skill through 4 problems and their solutions
- **Deck: Orchestrator design checklist slide** (s11-design) — 4-question checklist as a presentation slide
- **Deck: Persona = SDLC role slide** (s11-persona) — Persona→role mapping table + concrete Orchestrator skill examples per persona
- **Deck: Why not end-to-end slide** (s11-e2e) — 4 limitations as red cards; each framed as a research problem

### Changed
- **Persona docs renamed** — `docs/persona/builder.md` → `developer.md`; `docs/persona/detective.md` → `debugger.md`; headings, counts, and cross-references updated
- **developer-feature-strategist** — `run_dir` now resolves to `runs/developer/<feature>`; `process-findings` reads findings from `<run_dir>/findings/` via `find` + `Read` instead of receiving inline content
- **developer-plan-feature** — preflight `find` paths updated to `runs/developer/`; removed `restore_findings` handling; `run_dir` now passed to each planner spawn
- **All four planners** — aligned to disk-write findings pattern (write `<run_dir>/findings/<layer>-findings.md`, return short acknowledgment)
- **Deck slide 7** — agent card "Role examples" replaced with 5-part anatomy (Input / Knowledge / Reasoning / Output / Modes)
- **Deck slide 19** — distribution slide right panel updated from "Evaluating Monorepo" to shipped Claude Plugin path with install command and `enabledPlugins` format
- **submodule-repo-structure.md** — Delivery Mechanism note updated to document both supported distribution paths (submodule + Claude plugin)

---

## [8.1.0] — 2026-06-01

### Changed
- **Run state grouped by persona** — `developer-plan-feature` and `developer-feature-strategist` now store runs under `.claude/agentic-state/runs/developer/<feature>` (was `runs/<feature>`); leaves room for `runs/debugger/`, `runs/qa/`, etc.
- **Planner findings moved off main context** — all four planners (`developer-domain-planner`, `developer-data-planner`, `developer-pres-planner`, `developer-app-planner`) now write findings to `<run_dir>/findings/<layer>-findings.md` and return a short `## Findings Written` acknowledgment; findings are never pasted inline into the SKILL or strategist context
- **Planners: `run_dir` required input, `Bash`/`Write` tools added** — callers must now pass `run_dir` to all four planners
- **Strategist reads findings from disk** — `process-findings` and `synthesize` modes glob `<run_dir>/findings/*-findings.md` instead of receiving inline content

---

## [8.0.0] — 2026-06-01

### Changed
- **Reasoning agents renamed: `orchestrator` → `strategist`** — all `-orchestrator` agent files renamed to `-strategist`; `name:` frontmatter, skill spawn references, principle docs, and internal tooling updated throughout
- **Persona renamed: `builder` → `developer`** — directory, all 12 agent files, 10 core skills, and ~97 platform contract skill directories renamed across 6 platforms; slash commands now `/developer-build-feature`, `/developer-plan-feature`, `/developer-build-from-ticket`, etc.
- **Persona renamed: `detective` → `debugger`** — directory and 3 agent files renamed; agent names simplified (`detective-debug-*` → `debugger-*`); entry skill `detective-debug` → `debugger-debug`; platform contract skills `detective-debug-add-logs` / `detective-debug-remove-logs` → `debugger-add-logs` / `debugger-remove-logs`

### Removed
- All `builder-*` agent files, skill directories, and platform contract skill directories (superseded by `developer-*` equivalents)
- All `detective-*` agent files and skill directories (superseded by `debugger-*` equivalents)

---

## [7.28.7] — 2026-05-26

### Changed
- `builder-feature-orchestrator` — `process-findings` mode now synthesizes plan.md + context.md inline on convergence and returns `Decision: synthesized`, eliminating the separate `synthesize` round-trip spawn
- `builder-plan-feature` — Step 2b passes `run_dir` and `update_mode` context to `process-findings`; routes `Decision: synthesized` directly to Step 4, skipping Step 3

---

## [7.28.6] — 2026-05-26

### Fixed
- 13 skill files across `lib/core/skills/` and platform contract skills — corrected frontmatter `tools:` → `allowed-tools:` so skills load correctly in plugin context
- `builder-groom-orchestrator` — removed Phase 4 inline execution of `tracker-adjust-ticket` (agents cannot invoke skills); orchestrator now returns grooming summary and delegates ticket update to the calling skill
- `builder-groom-orchestrator` — updated description to reflect correct responsibility boundary
- `dart-repo-knowledge` — removed stale reference to non-existent `dart-knowledge-auditor` agent

---

## [7.28.5] — 2026-05-26

### Fixed
- `builder-groom-ticket` — blocked flow now re-spawns orchestrator with clarification in prompt instead of using `SendMessage` (which required a `summary` field)
- `builder-groom-ticket` — skill now invokes `tracker-adjust-ticket` directly after synthesis; orchestrator no longer tries to chain to it via extension (which failed silently)
- `tracker-adjust-ticket` — corrected frontmatter `tools:` → `allowed-tools:` so skill loads correctly in plugin context

---

## [7.28.4] — 2026-05-25

### Added
- `installer-migrate-plugin` skill — migrates a project from submodule path to plugin path (removes submodule + symlinks, installs plugin, verifies result)

### Changed
- `installer-doctor` skill — now auto-detects submodule vs plugin path and runs appropriate checks for each; includes plugin-specific checks (marketplace, skillListingBudgetFraction, stale symlinks)

---

## [7.28.3] — 2026-05-25

### Added
- `scripts/install-plugin.sh` — now patches `.gitignore` (adds `.claude/agentic-state/`) and applies platform `CLAUDE-template.md` on install
- `scripts/build-plugin.sh` — auto-upserts `marketplace.json` entry on every platform build
- `scripts/install-plugin.sh` — auto-sets `skillListingBudgetFraction: 0.03` in project `settings.json`

### Fixed
- `README.md` — added curl one-liner install command for plugin path

---

## [7.28.2] — 2026-05-25

### Added
- `scripts/install-plugin.sh` — installs the sda marketplace and platform plugin via `claude plugin` CLI
- `scripts/sda.sh` — new `install-plugin` command (option 5 in interactive menu)

### Fixed
- `marketplace.json` — corrected `pluginRoot` path from `./dist/plugins` to `../dist/plugins` (relative to `.claude-plugin/` location)
- `README.md` — corrected `enabledPlugins` format to `{ "plugin-id@marketplace-id": true }`

---

## [7.28.1] — 2026-05-25

### Fixed
- `README.md` — `enabledPlugins` corrected from array to record format (`{ "plugin-name": "marketplace" }`)
- `README.md` — repo URL corrected to `hndhr/software-dev-agentic`

---

## [7.28.0] — 2026-05-25

### Added
- `lib/core/reference/feature-docs/` — Feature Docs now ship downstream via submodule (previously written to `.claude/reference/`, which was internal-only)
- `timeoff` Feature Doc — full three-platform scan (iOS pre-Clean hybrid, Android pre-Clean MVP+Clean hybrid, Flutter Clean BLoC); covers API contracts, data model, HLD diagram, six data flow paths, artifacts table, platform variants, and gotchas
- `scripts/build-plugin.sh` — builds Claude Code plugins per platform from `lib/`; used in CI and release flow
- `.claude-plugin/marketplace.json` — plugin registry for marketplace distribution (flutter-mobile-talenta, flutter-mobile-jurnal, flutter-qontak-chat, flutter-qontak-crm, ios-talenta, android-talenta, web)

### Changed
- `librarian-scan` skill — Feature Doc output path updated from `.claude/reference/feature-docs/` to `lib/core/reference/feature-docs/` so docs are accessible to downstream projects
- `release` skill — Step 4 now runs `scripts/build-plugin.sh --platform=all` before committing, so `dist/plugins/` is always in sync with the release

---

## [7.27.0] — 2026-05-25

### Added
- `librarian` persona — internal KMS toolkit (`.claude/` only, not shipped downstream)
  - `librarian-feature-orchestrator` — plan-scan brain: reads `[pending-scan]` markers, resolves repo paths from flags, decides which platform workers to spawn
  - `librarian-synthesizer-worker` — merges PRD content or platform scan findings into a Feature Doc draft conforming to the schema
  - `librarian-audit-worker` (haiku) — validates draft against `docs/principles/feature-doc-principles.md`; violations block publish, warnings surface to reviewer
  - `librarian-ios-worker` — scans local iOS repo; discovers ViewControllers, Services, bridges; detects `[pre-Clean]`/`[Clean]`
  - `librarian-android-worker` — scans local Android repo; discovers Fragments, ViewModels, UseCases, Repositories; detects `[pre-Clean]`/`[Clean]`
  - `librarian-flutter-worker` — scans local Flutter module; discovers BLoC, UseCase, Repository, DataSource, Widget; always `[Clean]`
  - `librarian-scan` skill — backfills Feature Docs from code; repos passed as `--ios/--android/--flutter=<path>` flags; incremental `[pending-scan]` expansion
  - `librarian-generate` skill — generates Feature Doc from PRD file, Confluence URL, or Jira ticket ID; mmpa-optional with paste fallback
  - `librarian-merge` skill — consolidates 2+ Feature Docs; applies per-section merge strategies; archives originals on request
  - `librarian-explain` skill — read-only inline explanation; `--aspect` and `--for` flags; no agent spawn
- `docs/principles/feature-doc-principles.md` — canonical Feature Doc reference: schema, scoping model, mandatory sections, quality rules, structural rules, audit criteria, design decisions

### Changed
- `builder-feature-orchestrator` — G1a now enforces `AskUserQuestion` unconditionally; added "never infer" guard with explicit trigger-word examples ("re-work", "redo", "continue"). Added `New run directory` option to G1b so users can create a fresh run directory for an existing feature without abandoning it entirely.

---

## [7.26.1] — 2026-05-22

### Fixed
- `builder-feature-orchestrator` — G1b now enforces `AskUserQuestion` unconditionally. Added explicit guard: "Never infer the answer from the user's message or prior context, even if the intent seems obvious." Prevents the orchestrator from silently skipping the resume-intent confirmation when it feels confident about the user's choice.

---

## [7.26.0] — 2026-05-22

### Fixed
- `builder-plan-feature` — `resume-as-is` with `plan_status: approved` no longer proceeds directly to execution. Skill now asks "Continue as-is / Start from beginning" after checkpoint detection so the user consciously routes to Step 5 rather than silently re-executing a previously approved plan.

### Changed
- `builder-groom-ticket` — skill no longer reads the ticket file directly. Ticket path is passed as a raw path to `builder-groom-orchestrator`; the orchestrator owns the read in each mode. Skill is now a pure router (Steps 1–4).
- `builder-groom-orchestrator` — `detect-scope` Phase 2 expands `Decision: blocked` to cover thin/ambiguous tickets: fires when AC exists but maps to no layer signals, or when criteria are contradictory/incomplete. `question` field must be specific, not generic.
- `builder-groom-orchestrator` — `synthesize` Phase 4 introduces rich vs thin output paths. Rich path sets status `"Groomed — ready for /builder-plan-feature"`; thin path (open questions block work items) sets `"Needs clarification — answer open questions before planning"`. Each mode now reads the ticket file directly from `ticket-path` since modes run in separate agent contexts.

---

## [7.25.0] — 2026-05-21

### Changed
- `builder-ui-worker` — Figma reads restructured into three explicit sequential sub-steps per `.md` file (read `.md` → extract `layout_file`/`screenshot` paths, read JSX in full, read PNG). Step 4 now requires a **Layout Transcript** (structured extraction of sections, field inventory, bottom bar, conditional groups from JSX + screenshot) before any widget code is written. Step 5 requires a **Widget Plan** (one-to-one mapping of every Field Inventory row to a concrete widget call) with a gate checklist before the skill is invoked. Skill inputs updated: raw `## Figma Design Reference` replaced by `## Layout Transcript` + `## Widget Plan`.
- `builder-feature-worker` — added **Sibling API Verification** step after skill execution: constructors, event variant names, and model field names must be confirmed via Grep + Read before writing any call site. Assumption is explicitly disallowed.
- `builder-feature-worker`, `builder-ui-worker` — Validation Protocol updated to run the platform type-checker (`flutter analyze` / `tsc --noEmit` / skip for iOS) and fix errors by reading the actual definition, never by inference.

---

## [7.24.0] — 2026-05-21

### Changed
- `builder-feature-orchestrator` — `gather-intent` Step G1 replaced with a two-question resume flow. Q1 lists all existing runs with metadata (artifacts done, status) and a Start fresh option. Q2 (if a run is picked) asks "Start from beginning / Continue as-is". Start from beginning re-enters Step G2 with old plan history as context (`update_mode: true`). Continue as-is triggers Step G1c checkpoint detection.
- `builder-feature-orchestrator` — new Step G1c (checkpoint detection): inspects `run_dir` disk state and routes to the correct entry point (Step 1.5, Step 2, Step 4, or Step 5) based on what exists. Partial-planning runs (figma but no plan) and complete runs (plan pending or approved) are all handled here. Returns `restore_findings: true` when existing `findings-round-*.json` should be restored.
- `builder-feature-orchestrator` — `Decision: resume-as-is` now includes `plan_status: pending | approved` so the entry skill knows whether to resume at Step 4 (approve) or Step 5 (execute).
- `builder-feature-orchestrator` — `Decision: spawn-planners` gains `restore_findings` field.
- `builder-plan-feature` — routing updated: `resume-as-is` routes to Step 4 or Step 5 based on `plan_status`. `spawn-planners` restores `all_findings` from disk when `restore_findings: true`.

---

## [7.23.4] — 2026-05-21

### Fixed
- `builder-feature-orchestrator` — Step G0 now explicitly distills raw input content into a compact internal summary before proceeding. Raw file content must not be carried into the Decision block or intent questions — only Figma URLs and a distilled context summary are retained. Prevents orchestrator from dumping ticket/PRD content back into the skill's context and causing compaction.

---

## [7.23.3] — 2026-05-21

### Changed
- `builder-plan-feature` — Step 0 simplified: skill only fetches things requiring network tools (Jira via Atlassian MCP, PRD URLs via WebFetch). Local files and directories are collected as `raw_paths` and passed to the orchestrator — the skill never reads them. `pending_figma_urls` removed from skill responsibility.
- `builder-plan-feature` — Step 1 now passes `raw_paths` to the orchestrator alongside the user message and resolved inputs. `pending_figma_urls` for Step 1.5 is now extracted from the orchestrator's `Decision: spawn-planners` block (not computed by the skill).
- `builder-feature-orchestrator` — `gather-intent` gains Step G0: reads all `Raw Paths` (files and directories), extracts `figma.com` URLs from their content, and collects other relevant context before asking the user for intent. `pending_figma_urls` is now included in every `Decision: spawn-planners` block (empty list if none found).

---

## [7.23.2] — 2026-05-21

### Fixed
- `builder-plan-feature` — Routing Contract tightened: arguments are only what follows the invocation line; the user's message body is passed verbatim to the orchestrator, not acted on by the skill. Added explicit rule prohibiting extra confirmation questions between steps — skill routes directly on the orchestrator's Decision block.
- `builder-plan-feature` — Step 0 now scans the content of resolved `.md` files for `figma.com` URLs and appends them to `pending_figma_urls`, so Figma links referenced inside a local file are fetched via `builder-figma-worker` like any directly passed URL.
- `builder-plan-feature` — Step 1 now includes the full user message verbatim in the `gather-intent` prompt, so the orchestrator receives all context (directory hints, ticket references, instructions) without the skill acting on any of it first.

---

## [7.23.1] — 2026-05-21

### Fixed
- `builder-feature-orchestrator` — on "Continue existing" resume path, `gather-intent` now reads all archived plan versions (`plan-v1.md`, `plan-v2.md`, …) in order before the current `plan.md` + `context.md`. Full plan history gives the orchestrator context on how the plan evolved, which layers were already explored, and what changed across iterations.

---

## [7.23.0] — 2026-05-21

### Changed
- `builder-plan-feature` — added Routing Contract prohibiting the skill from reading source files, grepping, or writing code directly. Preflight now collects `found_plans`/`found_figma` without routing. Step 1 (`gather-intent`) owns all routing decisions; `run_dir` flows from the orchestrator's `Decision: spawn-planners` block. Step 1.5 no longer computes `run_dir` from the feature name. Post-Figma-grouping gate added: explicit "proceed to Step 2 only" enforces delegation to planners and workers.
- `builder-feature-orchestrator` — `gather-intent` mode expanded to own both fresh and resume flows (Steps G1–G3): classifies existing runs, surfaces partial/complete runs to user, reads existing `plan.md` + `context.md` as context for intent gathering, asks "continue as-is or describe changes", and returns `Decision: resume-as-is` or `Decision: spawn-planners` accordingly. `Decision: spawn-planners` block now includes `run_dir`, `feature`, `platform`, `module_path`, and `update_mode`. `Decision: resume-as-is` and `Decision: discard-partial` added to the Structured Decision Blocks reference.
- `builder-feature-orchestrator` — `Mode: resume` removed; its responsibilities fully absorbed into `gather-intent`.

---

## [7.22.7] — 2026-05-21

### Changed
- `builder-plan-feature` — Preflight reduced to two `find` commands + one agent spawn. All run selection, figma repair, and intent gathering moved into the orchestrator. Skill no longer calls `Read` or does any work before the orchestrator returns a decision.
- `builder-feature-orchestrator` — `review-resume` mode replaced by `resume` mode. Owns the full resume flow: run classification (partial vs complete), run selection via `AskUserQuestion`, figma repair, plan state load, intent gathering, and layer routing. Returns one of five decisions: `start-fresh`, `discard-partial`, `restore-partial`, `resume-as-is`, `spawn-planners`.

---

## [7.22.6] — 2026-05-21

### Fixed
- `builder-plan-feature` — Preflight "Continue existing" path no longer calls `Read` to get plan metadata. Replaced with a single bash one-liner that extracts `feature`, `status`, and `completed count` from `plan.md` + `state.json` via grep/python3. Skill never touches the `Read` tool before the orchestrator, removing the foothold that caused segues into ticket and code file reads.

---

## [7.22.5] — 2026-05-21

### Fixed
- `builder-plan-feature` — removed Step 0A (intent classification belongs to the orchestrator, not the skill). Preflight now explicitly states "Immediately call AskUserQuestion — no other work between reading and asking." After run selection, the only permitted next action is Step R — no analysis, no file reads. The orchestrator owns all intent gathering and codebase exploration.

---

## [7.22.4] — 2026-05-21

### Fixed
- `builder-plan-feature` — replaced text-based "Skill Scope" prohibitions with a structural `## Step 0A — Input Gate` that fires before any other work. Verification/review/check/test intent is intercepted immediately: skip directly to Preflight bash + Step R, pass the user's message to the orchestrator as `open_questions`, no inline source reads or test runs. Positive routing instruction instead of prohibition — cannot be overridden by explicit user instructions.

---

## [7.22.3] — 2026-05-21

### Fixed
- `builder-plan-feature` — added top-level `## Skill Scope — Hard Boundaries` block enumerating exactly which files `Read` is permitted for, and explicitly handling "verify / check / review / read the code" user instruction patterns — these must be passed as `open_questions` to the orchestrator, never read inline by the skill. Tightened run-selection handoff and Step R boundary to target source code files specifically (not ticket files, which are legitimate input context).

---

## [7.22.2] — 2026-05-20

### Fixed
- `builder-plan-feature` — added explicit scope boundary at Step R entry and at the preflight run-selection handoff. The skill was reading plan.md, context.md, state.json, ticket files, and code files inline before spawning the orchestrator. All codebase reading is now prohibited in the skill; only the listed shell commands in R0 are permitted.

---

## [7.22.1] — 2026-05-20

### Fixed
- `builder-plan-feature` — added explicit prohibition on codebase reading in Step R1 after receiving `Decision: spawn-planners`. The skill was exploring entity and mapper files before spawning planners, violating the principle that planners own all artifact knowledge.

---

## [7.22.0] — 2026-05-20

### Changed
- `builder-feature-orchestrator` — `review-resume` mode redesigned: stripped to minimal state read (plan.md artifact summary + completed_artifacts) + intent gathering only. Returns `Decision: resume-as-is` (no planning needed) or `Decision: spawn-planners` carrying `open_questions` from the user's stated issues. No longer reads figma inputs, computes repairs, or writes updated plan files — all analysis is now delegated to planners via the convergence loop.
- `builder-feature-orchestrator` — `synthesize` mode now accepts an `update: true` variant with `existing_plan`, `existing_context`, and `completed_artifacts` inline. Patches existing plan.md rather than rewriting from scratch — preserves completed artifact rows.
- `builder-plan-feature` — resume path now always runs the convergence loop when the user describes changes. Step R restructured: R0 handles figma repair pre-check + restores `figma_groups`; R1 gathers intent from orchestrator; on `Decision: spawn-planners`, feeds directly into Step 2 with `update_mode = true`.
- `builder-plan-feature` — Step 2a passes `open_questions` and `completed_artifacts` to planners when `update_mode` is true. Step 3 archives existing plan before synthesize and passes `existing_plan`/`existing_context`/`completed_artifacts` to orchestrator on update path.
- `builder-domain-planner`, `builder-data-planner`, `builder-pres-planner`, `builder-app-planner` — added `open_questions` and `completed_artifacts` optional parameters. Planners use `open_questions` to focus analysis on stated issues; treat `completed_artifacts` as locked (`exists` status, no recreation).

---

## [7.21.0] — 2026-05-20

### Added
- `builder-ui-worker` — new agent handling the UI layer (Screen, Component, Navigator) exclusively. Starts with a clean context after `builder-feature-worker` emits `## Layers Complete`; loads stateholder contract, presentation-impl UI sections, and Figma references fresh. Context checkpoint fires more aggressively (every Screen/Component + one additional signal).
- `builder-figma-worker` — `group-frames` mode: reads all downloaded screenshots, clusters frames by visual structure (primary signal), uses `parent_frame` metadata only as a tiebreaker. Designed for Figma files where designer structure does not follow user stories. Returns `## Figma Groups` block with optional `review` entries for ambiguous frames.
- `builder-pres-create-stateholder` (all 7 platforms) — skill now writes `stateholder-contract.md` to the run directory. Contract includes class/type names, import paths, state fields, event/action cases, ViewDataState variant handling, and a ready-to-compile wiring snippet. Platform-specific: Flutter (`getIt` + `@injectable`, `.when()`), Qontak (inline DI, `.status.isHasData`), iOS (RxSwift publisher binding), Android (MVP fragment wiring), Web (hook vs pure-function usage snippet).

### Changed
- `builder-plan-feature` — resume path no longer reads `plan.md`, `context.md`, or `state.json` inline; passes only `run_dir` to `builder-feature-orchestrator`. Step P (Figma Input Repair) removed from skill — absorbed into orchestrator `review-resume` mode.
- `builder-plan-feature` — Step 5 split into Phase 1 (`builder-feature-worker`: Domain/Data/Pres/App) and Phase 2 (`builder-ui-worker`: UI layer). Phase 2 skipped entirely when plan has no pending UI artifacts.
- `builder-plan-feature` — Step 1.5b now spawns `builder-figma-worker` in `group-frames` mode instead of grouping inline; surfaces `review` flags in the user verification prompt.
- `builder-feature-orchestrator` — `review-resume` mode rewritten: accepts `run_dir`, reads all files internally (plan.md, context.md, state.json, figma inputs), detects screenshots needing backfill, reconstructs `figma-groups.json` if missing, returns structured `figma_repair` and `figma_groups_json` fields for the skill to execute.
- `builder-feature-worker` — scope narrowed to Domain, Data, Presentation (StateHolder only), and App layers. UI Resolution Priority section and Screen/Component Figma reads removed. StateHolder Figma read now explicitly limited to `.md` body only — no `layout_file` or `screenshot`. Output signal changed to `## Layers Complete`.

---

## [7.20.1] — 2026-05-20

### Fixed
- `builder-feature-worker` — screenshot read restructured as an explicit numbered sequential step (md → jsx → png) with rationale; no longer a deprioritizable bullet point that workers skip under context pressure.
- `builder-plan-feature` — replaced flat "Figma Reference Files" list in both initial and checkpoint worker prompts with an explicit 4-step Figma read instruction tied to `## Figma Alignment` in context.md.

---

## [7.20.0] — 2026-05-20

### Added
- `builder-plan-feature` — **Step P (Figma Input Repair)** on every resume: scans `inputs/` for existing `figma-*.md` files, backfills missing screenshots via curl, reconstructs `figma-groups.json` from frontmatter `parent_frame` if absent, and offers a "Re-run UI with Figma" option that resets Screen/Component artifacts and rebuilds with full Figma layout + screenshot data.
- `builder-plan-feature` — compaction guards: persist `figma-groups.json` immediately after Step 1.5b confirmation and `findings-round-N.json` after every planner round; preflight detects partial-planning runs and offers resume or discard.
- `builder-pres-planner` — `Figma Files` column added to `### Figma Alignment` output table — lists absolute `.md` file paths per artifact so the feature worker can read them directly without Glob scanning.

### Fixed
- `builder-figma-worker` — screenshots now downloaded to disk via curl (`figma-<slug>-screenshot.png`); frontmatter writes local path instead of remote URL; `Bash` added to tools; verification step checks all three output files.
- `builder-pres-planner` — corrected `figma_groups` shape in Step 0a: iterates `states[*].file` instead of non-existent top-level `files` key — was silently producing empty Figma Alignment tables.
- `builder-feature-orchestrator` — Figma Alignment population merged into Step 5 (context.md write) rather than a deferred Step 6 patch; column header aligned with pres-planner output.
- `builder-feature-worker` — reads `layout_file` and `screenshot` from `.md` frontmatter directly; reads file paths from `Figma Files` column in `## Figma Alignment` table — no Glob or frontmatter scanning required.
- `builder-plan-feature` — `run_dir` now pinned from the found file's parent directory on both resume branches (partial-planning and full-plan) — never reconstructed from feature name.
- `builder-plan-feature` — stale `Step 0b` reference in Step 2a corrected to `Step 1.5b or P2`.

---

## [7.19.0] — 2026-05-20

### Added
- `builder-feature-worker` — **Context Checkpoint** mechanism: after each artifact, evaluates context pressure across three signals (heavy artifact type, accumulated impl references loaded, artifact count). Emits `## Context Checkpoint` and exits cleanly when 2+ signals are true — no mid-artifact data loss.
- `builder-plan-feature` (Step 5) — **checkpoint loop**: when worker returns `## Context Checkpoint`, immediately re-spawns a fresh worker with plan.md + context.md re-read from disk and resume instructions pointing at `state.json`. Repeats until worker returns `## Feature Complete`. No user intervention required.

---

## [7.18.1] — 2026-05-20

### Fixed
- `builder-figma-worker` — section nodes no longer fetch children inline; instead returns a `## Figma Section Detected` block with child frame IDs and stops. Prevents context overflow on large sections.
- `builder-plan-feature` (Step 1.5) — expands `## Figma Section Detected` blocks by spawning one fresh worker per child frame in parallel, each with a clean isolated context. Results merged back into `figma_resolved`.

---

## [7.18.0] — 2026-05-20

### Added
- `builder-figma-worker` — section node detection: when `get_design_context` returns sparse metadata (section containing multiple child frames), the worker extracts all child frame IDs, fetches each in parallel via `get_design_context` + `get_screenshot`, and writes three artifacts per child frame. Returns one `## Figma Worker Output` block per child, separated by blank lines.

### Changed
- `builder-plan-feature` (Step 1.5) — `figma_resolved` collection now handles multiple output blocks from a single worker invocation (section node case).

---

## [7.17.1] — 2026-05-20

### Fixed
- `builder-plan-feature` — Figma worker spawning deferred to Step 1.5 (after `feature` name is established by gather-intent) so `run_dir` can be correctly resolved. Step 0 now only classifies Figma URLs into `pending_figma_urls` without fetching. Step 1.5 spawns all workers in parallel then runs grouping + verification (Step 1.5b). Fixes unresolvable `<feature>` placeholder bug in run directory path.
- `builder-feature-orchestrator` (`gather-intent`) — notes pending Figma URLs as context without expecting fetched content.

---

## [7.17.0] — 2026-05-20

### Added
- `builder-figma-worker` — now writes three artifacts per Figma node: `figma-<slug>.md` (compact semantic reference), `figma-<slug>-layout.jsx` (raw JSX with exact spacing, design tokens, and component hierarchy), and captures `screenshot` URL — all isolated in the worker's context, persisted to `inputs/` on disk.

### Changed
- `builder-figma-worker` — migrated from old `mcp__Figma__get_figma_data` to `mcp__Figma_MCP__get_design_context` + `mcp__Figma_MCP__get_screenshot` (new official Figma MCP). Added `screenshot` and `layout_file` fields to the output block.
- `builder-feature-worker` — Figma lookup now uses all three artifacts per artifact type: StateHolder reads `.md` only (semantic layer); Screen/Component reads `.md` (semantic) + `-layout.jsx` (section-queried for exact tokens/layout) + screenshot URL (visual grounding for creation skill).
- `builder-plan-feature` — `figma_groups` structure extended to carry `layout_file` and `screenshot` per state entry alongside the `.md` file path.

---

## [7.16.0] — 2026-05-20

### Added
- `builder-plan-feature` — **Preflight** step: detects existing runs and asks to resume or start fresh. **Step R** (resume path): spawns orchestrator in `review-resume` mode to summarize progress and let the user adjust scope or add context before re-approving.
- `builder-feature-orchestrator` — new `review-resume` mode: cross-references completed artifacts against plan, asks resume-as-is / adjust scope / add context, returns `Decision: resume-as-is` or `Decision: resume-updated` with updated file contents.
- `builder-plan-feature` — **Step 0b**: after all Figma workers complete, groups fetched frames by `parent_frame` extracted from Figma hierarchy (no naming convention assumed), shows grouped screen→state table to the user for confirmation or correction before planning starts.
- `builder-pres-planner` — **Step 0a**: consumes pre-verified `figma_groups`, section-queries each state file in isolation, builds `figma_context` per screen (states, components, interactions), uses it to drive artifact classification and StateHolder state field / event case derivation.
- `builder-feature-orchestrator` (synthesize) — carries `Figma Alignment` table from pres planner findings into `context.md` as the authoritative frame→artifact mapping.

### Changed
- `builder-figma-worker` — slug now derived from fetched node name (not URL); extracts `parent_frame` from Figma hierarchy; `state` field added to output block. Each worker handles one node/state, grouping is done by the entry skill.
- `builder-feature-worker` — Figma reference lookup extended to StateHolder artifacts (not just Screen/Component); uses `Figma Alignment` table from `context.md` to resolve the correct frame name before section-querying figma files.
- `builder-pres-planner` — replaced `figma_summary` + `figma_files` inputs with `figma_groups` (pre-verified structured grouping). Output now includes `### Figma Alignment` table.
- `builder-feature-orchestrator` / `builder-feature-worker` — all artifact tables in `plan.md` gain a `Progress` column (`pending` → `in-progress` → `done`); worker updates it per artifact at checkpoint and completion.

---

## [7.15.0] — 2026-05-20

### Changed
- `builder-pres-resolve-design` — expanded output to include `## Custom Widgets` table (unmatched elements), Variants column in bindings table, and on-demand source fallback via pub-cache for deep constructor detail. `ui_description` input now explicitly accepts Figma section content as primary source over plan.md description.
- `builder-feature-worker` — replaced separate Component Reuse Check and design system steps with a unified **UI Resolution Priority** section: Level 1 = design system catalog (hard constraint), Level 2 = project shared components, Level 3 = create new. Figma reference is now collected alongside bindings and passed together to creation skills. Bindings are enforced as hard constraints ("do not substitute framework primitives for any element in this table").

---

## [7.14.2] — 2026-05-20

### Added
- `-catalog.md` as a third reference type in `core-design-principles.md` — alongside `-theory.md` (what/why) and `-impl.md` (how). Catalogs are queryable symbol inventories with `## Section <!-- N -->` and `### Symbol` entries. Added to Reference vocabulary table, By Scope table, and Decision Rules.

### Changed
- `mekari-pixel-flutter-catalog.md` — added `<!-- N -->` line-count annotations to all `## Atoms/Components/Pages/Templates` headings for correct section-query compliance.
- `agentic-deck.html` — slide 10 updated to show all three reference types (theory · impl · catalog) with a catalog example using MekariPixel.
- `workflow-deck.html` — slide 6 headline and layout updated to three-column view showing theory, impl, and catalog side by side.

---

## [7.14.1] — 2026-05-20

### Added
- `lib/core/reference/design-system/mekari-pixel-flutter-catalog.md` — 228 MekariPixel widgets extracted from pub-cache source, grouped by atoms/components/pages/templates with descriptions, key params, variants, and Figma links. Regenerate via `temp-dir/extract_catalog.py` on version bump.

### Changed
- `builder-pres-resolve-design` — rewritten to use `section-query` on the static catalog instead of ChromaDB/Python. No runtime deps. Soft-fails if catalog not present.
- `builder-feature-worker` — design system check now looks for `*catalog.md` in `.claude/reference/design-system/` instead of `dart-knowledge.yaml`.
- Flutter `ui-impl.md` (talenta, jurnal, qontak-chat, qontak-crm) — fixed widget prefix `Px` → `Mp` (correct MekariPixel prefix); updated catalog path reference.

---

## [7.14.0] — 2026-05-20

### Added
- `builder-pres-resolve-design` — new core skill that queries a project's design system RAG collection (via `dart-repo-knowledge` ChromaDB) and returns a `## Design System Bindings` table mapping UI element descriptions to design system symbols. Soft-fails with an empty table if no collection is configured.
- `ui-theory.md` — new `## Design System` section: canonical definition, invariants, and resolution flow for design system usage in the UI layer.
- `flutter-mobile-jurnal/ui-impl.md` — created missing UI layer reference for the Jurnal Flutter platform.
- `## Design System Bindings` section added to all platform `ui-impl.md` files — Flutter platforms (talenta, jurnal, qontak-chat, qontak-crm) include MekariPixel content; non-Flutter platforms (ios, web, android) include an empty placeholder.

### Changed
- `builder-feature-worker` — Screen and Component artifacts now check for a `kind: design_system` collection in `.claude/dart-knowledge.yaml`; if found, runs `builder-pres-resolve-design` and passes the binding table into the `pres-create-screen`/`pres-create-component` skill prompt. Config-driven — no platform condition.

---

## [7.13.3] — 2026-05-19

### Changed
- `agentic-deck.html` — updated skill type taxonomy from T/A/U to W/P throughout; added Hooks as a fifth anatomy component; moved capability matrix and runtime flow diagram to dedicated slides; capability matrix now reflects natural component behavior (not conventions); MCP examples updated from internal `mmpa` to official Atlassian MCP

---

## [7.13.2] — 2026-05-19

### Added
- `builder-figma-worker` — new builder worker that fetches a Figma file or node via Figma MCP in an isolated context window, extracts per-screen design details into a structured section-queryable `figma-<slug>.md`, and returns a compact summary. Raw Figma data never enters the main session.

### Changed
- `builder-plan-feature` — Step 0 now spawns `builder-figma-worker` per Figma URL (parallel if multiple) instead of attempting inline MCP call; Figma results tracked as `{ summary, file }`. Step 2a passes Figma summaries and file paths to `builder-pres-planner`. Step 5 injects Figma file paths into the feature worker spawn prompt.
- `builder-feature-worker` — Screen and Component artifacts now `section-query` Figma reference files before calling the skill; matched section passed as `## Figma Design Reference` in the skill prompt. No match proceeds silently.

---

## [7.13.1] — 2026-05-19

### Changed
- `builder-plan-feature` — added Step 0 (Resolve Inputs): parses skill arguments, classifies each as Jira ticket (Atlassian MCP), Figma design (Figma MCP), PRD/doc URL (`WebFetch`), or local `.md` file (`Read`). All fetches attempted in parallel; failures batched into a single `AskUserQuestion` (Continue / Provide manually / Cancel). Resolved inputs passed as `## Resolved Inputs` block into the gather-intent orchestrator call. Added `WebFetch` to `allowed-tools`.

---

## [7.13.0] — 2026-05-19

### Added
- `knowledge-query` term defined in `core-design-principles.md` — canonical name for the Grep → Read(offset, limit) lookup pattern, with two flavors: `section-query` (reference doc sections) and `symbol-query` (class/function bodies in source).
- `docs/initiatives/worktree-isolation-initiative.md` — initiative doc for running feature builds in isolated git worktrees; covers lifecycle design, branch naming, state-file co-location, resume behavior, and open questions.

### Changed
- `builder-feature-worker` — removed theory refs from pre-flight survey; cross-cutting convention load is now impl-only (`syntax-conventions-impl`, `utilities-impl`, `error-handling-impl`). Layer-specific impl refs (`domain-impl`, `data-impl`, `presentation-impl`, `app-layer-impl`) are now loaded per-artifact immediately before the skill call, keeping reference knowledge current after context compaction.
- `builder-feature-worker` — checkpoint discipline: `next_artifact` in `state.json` is now written at the **start** of each artifact (before any file work), not only on completion. Prevents ambiguous resume state after compaction or session interruption.
- `agentic-deck.html` — search protocol code panel updated to show `section-query` and `symbol-query` flavors by name.
- All 13 standard agents (workers + planners) — Search Protocol tables updated to reference `section-query` / `symbol-query` by name instead of repeating the full Grep → Read mechanic inline.

### Fixed
- `builder-test-worker` — added `Write, Edit` to tools frontmatter; previously could not write test files.

---

## [7.12.1] — 2026-05-19

### Fixed
- `sync.sh` — added `flutter-mobile-jurnal` to platform auto-detect table; updated usage comment and error message to point at `lib/platforms/` directory.

---

## [7.12.0] — 2026-05-19

### Added
- `dart-repo-knowledge` skill (`lib/core/skills/dart-repo-knowledge/`) — RAG pipeline for any Dart codebase; extracts dartdoc, embeds into ChromaDB, supports versioned snapshots, cross-version diffing, Jira/PR extraction.
- `dart-knowledge-builder` agent — guides generation and comparison tasks; delegates queries to `dart-knowledge-query`.
- `dart-knowledge-query` agent — read-only semantic lookup against ChromaDB collections; resolves collection from `.claude/dart-knowledge.yaml` (project-local config) rather than a hardcoded routing table.
- `flutter-mobile-jurnal` CLAUDE-template.md — new platform template scaffolded.

### Changed
- `setup-symlinks.sh` — auto-creates `.claude/dart-knowledge.yaml` stub on flutter platforms; usage comment now points to `lib/platforms/` directory instead of a hardcoded list.
- `sda.sh` — `ask_platform` now reads platform list dynamically from `lib/platforms/` directory; no manual updates needed when new platforms are added.
- All platform CLAUDE-template.md files — added `## Dart Knowledge` section instructing Claude to query `dart-knowledge-query` when `.claude/dart-knowledge.yaml` exists and the task requires Dart API context.

---

## [7.11.0] — 2026-05-19

### Added
- `qa` persona — new QA engineer persona with two workflows: test case generation and UI automation script generation.
  - `qa-testcase-worker` — generates and maintains mobile UI test cases (create + regenerate modes); outputs `.csv` to `/test-cases/`; posts Jira comments.
  - `qa-automation-worker` — translates test case CSVs into Maestro YAML scripts; writes to `/test-automation/maestro/`; one file per feature area.
  - `qa-generate-testcase` skill — W-skill entry point for test case workflow; resume routing detects existing CSVs.
  - `qa-generate-automation` skill — W-skill entry point for automation script workflow; passes CSV path (not contents) to worker.

---

## [7.10.0] — 2026-05-19

### Added
- `flutter-mobile-jurnal` platform — 8 reference impl files and 18 contract skills generated from `mobile-jurnal` repo scan; covers domain, data, presentation, navigation, DI, testing, error handling, and utilities layers.

---

## [7.9.2] — 2026-05-19

### Changed
- `installer-setup` skill — platforms are now discovered dynamically via `ls software-dev-agentic/lib/platforms/` instead of being hardcoded; added `Bash` to `allowed-tools`.

---

## [7.9.1] — 2026-05-19

### Changed
- `builder-test-worker` — slimmed to a thin layer router; delegates all test creation to `builder-test-procedure` via layer routing table. Removed inline test strategy, coverage targets, and skill-selection logic.

### Added
- `builder-plan-feature` Step 6 — after feature execution, prompts user to run unit tests for created domain/data/presentation artifacts via `builder-test-worker`; surfaces artifact paths on skip.

---

## [7.9.0] — 2026-05-19

### Added
- `builder-test-procedure` skill — internal 4-step unit test procedure: resolve test file, determine mock need, resolve/generate mocks, verify test cases. Reads platform-specific `testing-procedure-impl.md` for variable details.
- `ios-talenta/reference/testing-procedure-impl.md` — XCTest + hand-written mocks, `TalentaTests/` path structure, `[safe:]` subscript pattern
- `android-talenta/reference/testing-procedure-impl.md` — Mockito-Kotlin inline mocks, MVP presenter/view pattern, RxJava3 scheduler trigger
- `flutter-mobile-talenta/reference/testing-procedure-impl.md` — `@GenerateNiceMocks` per test file, `build_runner`, monorepo `talenta/` package structure
- `flutter-qontak-crm/reference/testing-procedure-impl.md` — `@GenerateMocks` in central `test_helper.dart` per feature package
- `flutter-qontak-chat/reference/testing-procedure-impl.md` — `@GenerateNiceMocks` in central `mock_helper.dart` per feature package

---

## [7.8.8] — 2026-05-19

### Added
- `flutter-qontak-crm` platform: `CLAUDE-template.md` — covers Melos monorepo structure, manual GetIt DI, BLoC instantiation rules, and module dependency constraints

---

## [7.8.7] — 2026-05-19

### Removed
- `builder-test-worker` — dead fallback reference to non-existent `reference/index.md`
- `detective-debug-worker` — dead fallback reference to non-existent `reference/debugging.md`

---

## [7.8.6] — 2026-05-19

### Fixed
- `builder-feature-worker`, `builder-backend-orchestrator`, `builder-test-worker` — corrected `related_skills:` entries to use full `builder-` prefixed skill names matching actual contract skill directories
- Added missing `builder-pres-create-component` contract skill for `flutter-qontak-chat` and `android-talenta` platforms
- `pr-review-worker` (ios-talenta) — replaced hardcoded absolute path `/Users/mekari/...` with project-root-relative `.claude/agent-memory/pr-review-worker/`

---

## [7.8.5] — 2026-05-19

### Fixed
- `builder-pres-planner` Step 0 now conditionally loads `ui-theory.md` and `navigation-impl.md` only when scope includes `screen`, `component`, or `navigator` — stateholder-only runs no longer pull in UI reference files

---

## [7.8.4] — 2026-05-18

### Fixed
- `setup-symlinks.sh` CLAUDE.md sync appended duplicate blocks on every run when the template's marker tag (e.g. `ios`) differed from the platform directory name (e.g. `ios-talenta`) — markers are now read directly from the template instead of constructed from `$PLATFORM`

---

## [7.8.3] — 2026-05-18

### Fixed
- `sda.sh` interactive platform menu had stale short names (`ios`, `flutter`, `flutter-qontak`); updated to full names matching `lib/platforms/`
- `setup-ai.sh` error message listed old short platform names
- `sync.sh` missing `flutter-qontak-crm` in header, auto-detect case, and error message

---

## [7.8.2] — 2026-05-18

### Fixed
- `flutter-qontak-chat` and `flutter-qontak-crm` reference impl files — corrected line counts across 25 files in `reference/code-architecture/` and `reference/project.md`

---

## [7.8.1] — 2026-05-18

### Fixed
- `generate-platform` and `sync-platform` skills — Step 4 now reads `agent-generate-platform-worker.md` and spawns a `general-purpose` agent with the worker's instructions, instead of naming the worker directly (which had no valid `subagent_type` route and caused fallback to `agent-scaffold-worker` with a wrong monolithic output structure)

---

## [7.8.0] — 2026-05-18

### Added
- `lib/platforms/flutter-qontak-crm/` — new platform onboarded from `mobile-qontak-crm` monorepo
- `lib/platforms/flutter-qontak-crm/reference/code-architecture/` — 13 impl files: `domain-impl.md`, `data-impl.md`, `presentation-impl.md`, `di-impl.md`, `error-handling-impl.md`, `testing-impl.md`, `syntax-conventions-impl.md`, `utilities-impl.md`, `navigation-impl.md`, `app-layer-impl.md`, `ui-impl.md`, `tech-stack-impl.md`, `modular-structure-impl.md`
- `lib/platforms/flutter-qontak-crm/reference/project.md` and `index.md`
- `lib/platforms/flutter-qontak-crm/skills/contract/` — 17 contract skills: `auditor-arch-check`, `builder-domain-create-entity/repository/usecase/service`, `builder-data-create-mapper/datasource/repository-impl`, `builder-pres-create-stateholder/screen`, `builder-test-create-domain/data/presentation/mock`, `detective-debug-add-logs/remove-logs`, `installer-setup-project`

---

## [7.7.0] — 2026-05-18

### Changed
- `lib/platforms/ios/` → `lib/platforms/ios-talenta/`
- `lib/platforms/android/` → `lib/platforms/android-talenta/`
- `lib/platforms/flutter/` → `lib/platforms/flutter-mobile-talenta/`
- `lib/platforms/flutter-qontak/` → `lib/platforms/flutter-qontak-chat/`
- `scripts/setup-symlinks.sh` — updated `--platform=` usage examples and error message to new names
- `scripts/sync.sh` — updated auto-detect case patterns and usage comments to new names
- `scripts/check-skill-contracts.sh` — updated usage example
- `scripts/sda.sh`, `scripts/setup-ai.sh`, `scripts/clean-ai.sh` — updated platform name references in comments
- All internal skill and reference files — updated `lib/platforms/<old>/` path references to new names
- All docs, agents, and core skills — updated `--platform=` and `platforms/` references throughout

---

## [7.6.0] — 2026-05-18

### Added
- `lib/platforms/flutter-qontak-chat/skills/contract/` — 17 contract skills scaffolded: `auditor-arch-check`, all `builder-domain-*`, `builder-data-*`, `builder-pres-*`, `builder-test-*`, `detective-debug-add-logs`, `detective-debug-remove-logs`, `installer-setup-project`
- `app-layer-impl.md` — `AppInitializationBloc` orchestrator pattern (sibling BLoC stream subscriptions, internal `_` events, `close()` cleanup)
- `app-layer-impl.md` — Firebase background message handling pattern (`@pragma('vm:entry-point')`, top-level handler, iOS-only registration, isolate `Firebase.initializeApp()`)
- `ui-impl.md` — `BlocProvider.value` pattern for route-scoped BLoC reuse (long-lived BLoCs spanning multiple routes)

### Changed
- `lib/platforms/flutter-qontak-chat/reference/` — 11 reference files synced against `mobile-qontak-chat`: `project.md`, `app-layer-impl.md`, `navigation-impl.md`, `di-impl.md`, `flavor-impl.md`, `presentation-impl.md`, `ui-impl.md`, `error-handling-impl.md`, `localization-impl.md`, `tech-stack-impl.md`, `module-communication-impl.md`
- `lib/platforms/flutter-qontak-chat/CLAUDE-template.md` — corrected architecture description, removed stale melos/go_router/injectable references, added `ViewDataState` API note

---

## [7.5.0] — 2026-05-18

### Added
- `docs/contract/builder-skill-contract.md` — canonical required contract skills for the builder persona (feature-worker + test-worker)
- `docs/contract/detective-skill-contract.md` — canonical required contract skills for the detective persona
- `docs/contract/auditor-skill-contract.md` — canonical required contract skills for the auditor persona
- `docs/contract/installer-skill-contract.md` — canonical required contract skills for the installer persona
- `scripts/check-skill-contracts.sh` — validates platform skill contract compliance against `docs/contract/*-skill-contract.md`; exits non-zero on gaps; safe for CI
- `.claude/agents/agent-generate-platform-worker.md` — shared internal worker for generate and sync platform workflows
- `.claude/skills/generate-platform/SKILL.md` — Type W skill: scans a downstream repo and generates platform reference impl files + contract skills for a new platform
- `.claude/skills/sync-platform/SKILL.md` — Type W skill: diffs existing platform implementation against a real codebase and syncs reference files + contract skills

### Changed
- `scripts/setup-symlinks.sh` — runs `check-skill-contracts.sh` automatically as a post-setup compliance check
- `docs/contract/README.md` — registered all four new skill contract files; added skill validation section with script usage
- `docs/principles/submodule-repo-structure.md` — added pointer to `docs/contract/` for skill contract reference
- Multiple `*-impl.md` reference files across all platforms — `<!-- N -->` line count annotations corrected

### Removed
- `lib/platforms/ios-talenta/packages/ios.pkg` — obsolete; iOS platform agents no longer rely on a `.pkg` manifest

---

## [7.4.1] — 2026-05-18

### Fixed
- `ios/di-impl.md` — corrected framing: constructor injection is the current pattern; DIContainer is aspirational/target; renamed "Fallback Pattern" to "Current Pattern"
- `ios/ui-impl.md` — DI Wiring section: replaced DIContainer factory claim with actual Coordinator-owned constructor injection
- `ios/domain-impl.md` — added Legacy UseCase Pattern (Current) documenting the 3-param `UseCase<Query, Path, Result>` + `call(queryParams:pathParams:expected:)` signature; V2 UseCaseProtocol marked as target
- `android/presentation-impl.md` — fixed `BaseMvpVbActivity` type param order to `<Presenter, View, Binding>` (was `<Binding, Presenter>`); fixed error handler call to `errorHandler.proceed(error)` (was `errorHandler.handle(error) { ... }`)
- `flutter-qontak/ui-impl.md` — BlocProvider placement corrected to app-level `route_manager.dart` (was per-module `BaseModule.routes()`)
- `flutter-qontak/modular-structure-impl.md` — added note that current codebase uses centralized route manager; BaseModule pattern is the target architecture
- `flutter-qontak/di-impl.md` — Registration Order renamed to layer-based convention matching actual code: `_registerData → _registerRepository → _registerDomain → _registerPresentation`
- `flutter/ui-impl.md` — Screen section: added `StatefulWidget` lifecycle pattern and feature-scoped DI accessor (`[feature]Dependency<Bloc>()`)
- `flutter/domain-impl.md` — entity `@freezed` rule softened to "recommended"; plain Dart classes documented as acceptable

## [7.4.0] — 2026-05-18

### Added
- `navigation-theory.md` — new canonical theory file with 6 Terms extracted from all platform navigation-impl files
- `ui-impl.md` for all 5 platforms (ios, flutter, web, android, flutter-qontak) — previously missing entirely; 8 Terms each
- `## Dependency Rule` and `## Creation Order` to all `domain-impl.md` (5 platforms)
- `## Dependency Rule`, `## Creation Order`, `## Layer Invariants` to all `data-impl.md` (5 platforms)
- `## Layer Invariants` to all `error-handling-impl.md` (5 platforms)
- `## Helper Extensions` to `utilities-impl.md` (flutter, web, android, flutter-qontak)
- `## What to Test Per Layer`, `## Mock vs Real`, `## Test Naming Convention` to all `testing-impl.md` (5 platforms)
- `## Registration Order`, `## Scope Rules`, `## Testing with DI` to all `di-impl.md` (5 platforms)
- 8 canonical Terms (`Dependency Rule`, `StateHolder`, `State`, `Events / Input`, `Actions / Output`, `StateHolder Contract`, `Creation Order`, `Layer Invariants`) to all `presentation-impl.md` (5 platforms) — existing framework sections untouched

---

## [7.3.0] — 2026-05-18

### Changed
- Skill taxonomy refactored from A/T/U to P/W — Procedure (worker-called) and Workflow (user-invocable, model-run); Type B (bash-only) removed in favor of hooks; T and U merged since both are the same workflow at different complexity levels
- `/audit`, `/migrate`, `/scaffold` trigger skills now own their full runtime — routing, agent spawning, validation, and reporting inline; no longer hollow passthroughs
- `reference/builder/` renamed to `reference/code-architecture/` across all 6 platforms and core — knowledge grouped by domain, not by persona
- `agent-consult-worker` handoff for convention review updated from `arch-review-orchestrator` to `/audit`

### Removed
- `arch-review-orchestrator` — redundant now that each trigger skill owns its workflow directly

---

## [7.2.3] — 2026-05-18

### Changed
- `builder-rfc` skill owns `agentic-state/rfc/` directory creation (Step 8) — removed from setup script and writer
- `builder-rfc-writer`: output directory is guaranteed by the calling skill

### Reverted
- `setup-symlinks.sh`: removed `agentic-state/rfc/` pre-creation (not setup script's responsibility)

---

## [7.2.2] — 2026-05-18

### Fixed
- `setup-symlinks.sh`: pre-creates `.claude/agentic-state/rfc/` alongside `runs/`
- `builder-rfc-writer`: removed self-`mkdir` — output directory is guaranteed by setup

---

## [7.2.1] — 2026-05-18

### Fixed
- `setup-symlinks.sh`: added `flutter-qontak` to usage comment and error string
- `sda.sh`: added `flutter-qontak` as option 4 in `ask_platform` interactive menu

---

## [7.2.0] — 2026-05-18

### Added
- `builder-rfc` skill — generates an RFC and ticket breakdown from a Jira Epic + PRD + optional Figma design; drives the full Clean Architecture convergence planning loop interactively
- `builder-rfc-writer` agent — pure writer; receives converged plan context inline and writes `<epic-slug>-rfc.md` + `<epic-slug>-breakdown.md` to `.claude/agentic-state/rfc/`

---

## [7.1.0] — 2026-05-18

### Changed
- Theory reference files moved from `lib/platforms/<platform>/reference/code-architecture/` to `lib/core/reference/code-architecture/` — single source of truth, no duplication
- Setup script: core reference linking restored (`link_reference` call re-added for `lib/core/reference/`)
- Principles docs updated to reflect core-theory + platform-impl split

### Removed
- 30 duplicate `*-theory.md` files across ios, web, android platforms (flutter's copy promoted to canonical in core)

---

## [7.0.0] — 2026-05-18

### Changed
- Reference docs restructured: theory and impl files co-located per platform as `<topic>-theory.md` / `<topic>-impl.md` under `lib/platforms/<platform>/reference/code-architecture/`
- `lib/core/reference/code-architecture/` eliminated — theory content duplicated into each platform's `reference/code-architecture/` directory (accepted tradeoff for single base path)
- All `reference/contract/builder/<topic>.md` paths renamed to `reference/code-architecture/<topic>-impl.md` across all agents, skills, and templates
- Setup script: removed core reference linking step (no longer a separate source)
- Principles docs updated: Section 4 rewritten, all reference path examples updated
- Deck (`docs/deck/agentic-deck.html`): MCP added as 4th building block on Anatomy slide; new Foundation MCP slide (s11); Collaboration, Distribution, Expansion slides added (s12–s14); official Claude docs definitions added to all four anatomy cards

### Removed
- `lib/core/reference/code-architecture/` — 10 theory files (content moved to each platform's `reference/code-architecture/<topic>-theory.md`)
- `lib/platforms/*/reference/contract/` — 40 impl files across iOS, Flutter, Web, Android (renamed to `reference/code-architecture/<topic>-impl.md`)

### Migration
Downstream projects must re-run `setup-symlinks.sh` to get the new symlink layout. Agent and skill files that hardcode old paths (`reference/code-architecture/<topic>.md` or `reference/contract/builder/<topic>.md`) must be updated to the new `-theory.md` / `-impl.md` suffixes.

---

## [6.4.4] — 2026-05-16

### Changed
- `ios/contract/builder/utilities.md`: added `## Null Safety Extensions` section (folded from `reference/error-utilities.md`)
- `android/contract/builder/error-handling.md`: added `## Error Response Models`, `## Error Interceptor`, `## ErrorHandler` sections (folded from `reference/error-handling.md`); updated `builder-pres-create-screen` skill pointer to `contract/builder/error-handling.md`

### Removed
- `lib/platforms/android-talenta/reference/error-handling.md` — misplaced pre-contract era file; content folded into `contract/builder/error-handling.md`
- `lib/platforms/ios-talenta/reference/core-services.md` — zero external consumers; content already covered by `contract/builder/utilities.md`
- `lib/platforms/ios-talenta/reference/error-utilities.md` — zero external consumers; error handling covered by `contract/builder/error-handling.md`, utilities (incl. Null Safety Extensions) folded into `contract/builder/utilities.md`

---

## [6.4.3] — 2026-05-16

### Fixed
- Correct `<!-- N -->` line count annotations in platform `app-layer.md` files (Android, Flutter, iOS) — `Hybrid Embedding` and `Planner Search Patterns` section counts were off after content edits
- Add canonical pointer (`reference/code-architecture/ui.md — ## Navigator / Coordinator`) to all four platform `navigation.md` files — the back-reference was missing

---

## [6.4.2] — 2026-05-16

### Changed
- `builder-feature-orchestrator`: inlined `layer-contracts.md` as a two-table summary (artifacts + inter-layer imports) — eliminates Grep+Read tool call per run; single consumer, always loaded
- `builder-app-planner`: removed `di-containers.md` from reference list; `di` scope now points to platform `contract/builder/di.md` for container detail

### Removed
- `lib/core/reference/code-architecture/di-containers.md` — web-specific (Next.js server/client containers), redundant with `web/reference/contract/builder/di.md`, no other consumers
- `lib/core/reference/code-architecture/domain-purity.md` — web-specific import rules, zero agent/skill consumers, covered by `domain.md` `## Dependency Rule` and `## Entities`
- `lib/core/reference/code-architecture/layer-contracts.md` — inlined into `builder-feature-orchestrator`; single consumer, always loaded

## [6.4.1] — 2026-05-16

### Changed
- `lib/platforms/flutter-mobile-talenta/reference/contract/builder/app-layer.md`, `ios`, `android`: folded `## Hybrid Embedding` content into each platform's `contract/builder/app-layer.md` as a section; removed standalone `contract/builder/hybrid-embedding.md` files — hybrid embedding is an app-layer concern, not a separate contract layer
- `## Planner Search Patterns` `hybrid_embedding` row: updated Grep hint from stale file-load instruction to `## Hybrid Embedding section below`

### Removed
- `lib/platforms/flutter-mobile-talenta/reference/contract/builder/hybrid-embedding.md`
- `lib/platforms/ios-talenta/reference/contract/builder/hybrid-embedding.md`
- `lib/platforms/android-talenta/reference/contract/builder/hybrid-embedding.md`

## [6.4.0] — 2026-05-16

### Added
- `lib/core/reference/code-architecture/app-layer.md`: `## Hybrid Embedding` section — canonical terms, communication directions (Host→Guest navigation, headless execution, Guest→Host response/action), and module registration pattern; grep-first selectable via `<!-- 64 -->` annotation
- `lib/platforms/ios-talenta/reference/contract/builder/hybrid-embedding.md`: iOS-specific hybrid embedding patterns (BrickWrap, ModuleFactory, engine lifecycle)
- `lib/platforms/android-talenta/reference/contract/builder/hybrid-embedding.md`: Android-specific hybrid embedding patterns (bricks-talenta, BrickHelper, ActionListener)
- `lib/platforms/flutter-mobile-talenta/reference/contract/builder/hybrid-embedding.md`: Flutter guest-side patterns (brick_way, HostParams decoding, ExternalDataSourceHelper)

### Changed
- `lib/platforms/flutter-mobile-talenta/reference/contract/builder/app-layer.md`, `ios`, `android`: added `hybrid_embedding` scope row to `## Planner Search Patterns`
- `docs/persona/builder.md`: moved `domain-worker`, `data-worker`, `presentation-worker`, `builder-ui-worker` from active to Removed table with version and reason
- `docs/deck/workflow-deck.html`: fixed domain-planner step numbering (Step 4 → Step 3, Step 4a → Step 3a); added Step 0 reference load annotation

## [6.3.0] — 2026-05-15

### Added
- `builder-domain-planner`, `builder-data-planner`, `builder-pres-planner`: Step 0 (Load reference) — was entirely missing; now greps `^## ` in both core + contract reference files and reads scope-matching sections using `<!-- N -->` as exact line limit
- Survey+load pattern across all builder agents: Step 0 greps headings first, reads only matching sections immediately — no full-file reads, no guessed limits

### Changed
- All builder agent reference paths now use `.claude/reference/...` format (no downstream mentions)
- `builder-domain-planner` Step 0 scope table: prerequisite chains for `usecase` (needs `Repository Interfaces`, `Entit`) and `repository` (needs `Entit`) made explicit
- `builder-data-planner` Step 0 scope table: prerequisite chains for `mapper` (needs `DTO`, `Entit`) and `repository_impl` (needs `Data Source`, `Mapper`) made explicit
- `builder-feature-worker` pre-flight: switched from "read all sections" to survey+load pattern across 6 reference files (core + contract: syntax-conventions, utilities, error-handling)
- `builder-test-worker`: added explicit survey step after layer identification
- `builder-feature-orchestrator`: fixed bare path `reference/code-architecture/layer-contracts.md` → `.claude/reference/code-architecture/layer-contracts.md`
- `lib/core/reference/code-architecture/domain.md`: `## Repository` → `## Repository Interfaces` (canonical heading alignment)
- Platform contract `domain.md` files (web, ios, android): `## Services` → `## Domain Services`
- `lib/platforms/web/reference/contract/builder/data.md`: `## DTOs (Data Transfer Objects)` → `## DTOs`
- `lib/platforms/android-talenta/reference/contract/builder/data.md` and `flutter`: `## Repository Implementations` → `## Repository Implementation`
- `lib/platforms/flutter-mobile-talenta/reference/contract/builder/error-handling.md`: `## Widget Error UI` → `## Error UI`
- `lib/platforms/ios-talenta/reference/contract/builder/utilities.md`: `## Helper Extensions Index` → `## Helper Extensions`

## [6.2.1] — 2026-05-15

### Changed
- `workflow-deck.html`: added slide 14 "What's Next" — multi-platform AI (ongoing), one-shot ticket-to-build, testing gap (planner + UI test agent + QA persona), and persona orchestration vision

## [6.2.0] — 2026-05-15

### Changed
- `builder-app-planner` Steps 2–6 no longer hardcode platform-specific glob patterns — each step now reads the `## Planner Search Patterns` table from the platform contract loaded in Step 1
- `ios`, `flutter`, `android` `app-layer.md` contracts: added `## Planner Search Patterns` section with scope-keyed glob patterns and grep hints per concern (`di`, `route`, `module`, `analytics`, `feature_flag`)
- `web/app-layer.md`: stubbed `## Planner Search Patterns` section (no convention established yet)
- `workflow-deck.html`: added 5 architecture slides (Skills as Runtime, Orchestrator, Planners + Convergence Loop, Knowledge Structure, Search Protocol); removed results slide

## [6.1.0] — 2026-05-15

### Changed
- Builder planners (`domain`, `data`, `pres`, `app`) now accept an optional `scope` parameter — only globs for artifact types listed in scope, skipping the rest
- Each planner adds demand-driven reference expansion (Step 4a / Step 6a): after reading primary artifact symbols, fetches referenced types only if their shape is structurally required or they will be modified as a consequence of the change
- `builder-feature-orchestrator` `spawn-planners` decision block now carries a `scope` map per planner so the orchestrator narrows each planner's entry point based on stated intent

## [6.0.0] — 2026-05-15

### Changed
- Submodule is now installed at the project root (`software-dev-agentic/`) instead of inside `.claude/software-dev-agentic/` — makes the toolkit platform-neutral for Claude Code, Gemini CLI, and GitHub Copilot
- `scripts/setup-symlinks.sh`: `PROJECT_ROOT` depth corrected; `REL_CORE`/`REL_PLATFORM` symlink prefixes updated from `../` to `../../` to account for the extra level from `.claude/agents/`
- `scripts/sync.sh`, `scripts/setup-ai.sh`, `scripts/clean-ai.sh`: `PROJECT_ROOT` depth corrected
- `scripts/sync.sh`: hardcoded submodule path in `git submodule update` and commit hint updated
- All installer agents/skills, `perf-worker`, and `agentic-perf-review` shell snippets updated

### Migration

Downstream projects must relocate the submodule:

```bash
git mv .claude/software-dev-agentic software-dev-agentic
# update .gitmodules: path = software-dev-agentic
git add .gitmodules software-dev-agentic
git commit -m "chore: migrate software-dev-agentic to project root"
software-dev-agentic/scripts/setup-symlinks.sh --platform=<platform>
```

---

## [5.6.0] — 2026-05-14

### Added
- `lib/core/reference/code-architecture/syntax-conventions.md` — platform-agnostic Null Safety invariants (rules only; implementation code lives in platform contracts)
- `lib/core/reference/code-architecture/utilities.md` — platform-agnostic definitions for StorageService, DateService, Logger, and Helper Extensions
- `lib/platforms/{ios,android,flutter,web}/reference/contract/builder/syntax-conventions.md` — per-platform Null Safety extension implementation code (Swift, Kotlin, Dart, TypeScript)
- `lib/platforms/web/reference/contract/builder/app-layer.md` — new file; all 7 app-layer sections present (most as stubs pending convention adoption)
- iOS app-layer contract: Push Notification Registration — documents unified FCM + DeeplinkStream architecture; all notification sources converge on `DeeplinkStreamImpl.shared`
- iOS app-layer contract: Deeplink Registration — full entry-point table (PN tap → FCMManager, URL scheme/universal link/quick action → DeeplinkManager), 3-step registration convention
- Android app-layer contract: Push Notification Registration — documents `TalentaNotificationManagerImpl`, token lifecycle via `PostFcmTokenUseCase`/`DeleteFcmTokenUseCase`, `NotificationNavigationType` routing
- Android app-layer contract: Deeplink Registration — documents `RedirectionActivity` as single entry point, `UrlHelper` pattern matching, 4-step registration convention
- Flutter/Web app-layer contracts: stub sections for Push Notification and Deeplink (no convention established yet)
- Core app-layer reference: Push Notification Registration and Deeplink Registration sections with platform-agnostic invariants

### Changed
- `builder-feature-worker`: pre-flight now loads both `syntax-conventions.md` and `utilities.md` before writing any code
- `builder-feature-worker`: merged Component Reuse Check from deleted `builder-ui-worker`
- `builder-app-planner`: replaced stale web skip note with stub-aware instruction; fixed iOS feature flag grep target from deprecated `FeatureFlagKey`/`FeatureFlagCollection` to active `FeatureIdentity` in `MekariFlagCustomProvider`
- iOS app-layer contract: Feature Flag Registration updated — active system is `FeatureIdentity` enum in `MekariFlagCustomProvider.swift`; `FeatureFlagKey`/`FeatureFlagCollection` marked as V2/not in use
- Android app-layer contract: Feature Flag Registration updated — documents three-enum system (`LocalFeatureFlag`, `RemoteConfigFeatureFlag`, `FlagsmithFeatureFlag`) with code examples
- All platform utilities.md files: Null Safety Extensions section removed (content moved to `syntax-conventions.md` per platform)
- All platforms now have all 7 app-layer sections present (stub or documented)
- Fixed downstream-resolved path references in `builder-test-worker`, `builder-groom-orchestrator`, `installer-setup-worker`, and `perf-worker`

### Removed
- `builder-ui-worker` — deleted; no valid spawn path (violated Skill-First Entry principle); Component Reuse Check merged into `builder-feature-worker`

---

## [5.5.0] — 2026-05-13

### Changed
- `builder-feature-orchestrator`: removed `execute-approved-plan` and `resume` modes — both were pass-through calls (read files, return `Decision: spawn-worker`) with no reasoning value, causing unnecessary cold boots.
- `builder-plan-feature`: Step 5 now updates `plan.md` status to `approved` and spawns `builder-feature-worker` directly, without going through the orchestrator.
- `builder-build-feature`: resume path now spawns `builder-feature-worker` directly with pre-loaded context; build-directly path no longer expects `Decision: spawn-worker` from orchestrator.
- `builder-build-from-ticket`: Step 8 now updates `plan.md` status to `approved` and spawns `builder-feature-worker` directly.

### Removed
- `Decision: spawn-worker` structured output block from `builder-feature-orchestrator` — no longer returned by any remaining mode.

---

## [5.4.2] — 2026-05-12

### Removed
- `builder-feature-planner` and `builder-auto-feature-planner` — deleted (were already marked DEPRECATED; responsibilities fully absorbed into `builder-feature-orchestrator` and the entry skills).

## [5.4.1] — 2026-05-12

### Fixed
- `sda.sh` sync menu option: prompt for platform when `--platform` is not passed, instead of failing with "could not detect platform".

## [5.4.0] — 2026-05-12

### Added
- `builder-feature-orchestrator`: new brain-only architecture — returns structured Decision blocks (`spawn-planners`, `converged`, `spawn-worker`, `blocked`) to the calling entry skill. Modes: `gather-intent`, `gather-intent-prefilled`, `process-findings`, `synthesize`, `execute-approved-plan`, `resume`. Never spawns agents or writes source files directly.
- All four layer planners (`builder-domain-planner`, `builder-data-planner`, `builder-pres-planner`, `builder-app-planner`): new `### Impact Recommendations` section in output contract — reports which other layers are affected and at what urgency (`required` / `optional`).

### Changed
- `builder-plan-feature`: rewritten as convergence loop executor — calls orchestrator for intent and per-round decisions, spawns only the needed layer planners in parallel, tracks visited set, accumulates findings across rounds (max 3), synthesizes plan then gates on user approval, spawns `builder-feature-worker` with plan + context injected inline.
- `builder-build-from-ticket`: rewritten to use the same convergence loop non-interactively — uses `gather-intent-prefilled` mode, auto-approves, writes `error.md` on block or round-cap instead of asking the user.
- `builder-build-feature`: updated — resume path uses orchestrator `resume` mode; build-directly uses orchestrator fast path.
- `builder-groom-ticket` + `builder-groom-orchestrator`: aligned to new pattern — orchestrator returns `Decision: spawn-planners` for scope detection; skill spawns planners in grooming-only mode (single round, no loop); orchestrator synthesizes and chains to `tracker-adjust-ticket`.
- `docs/principles/core-design-principles.md`: updated orchestrator definition (brain-only, Decision blocks), planner definition (layer explorer with impact recommendations), skill size rule (Type T scales with routing complexity — no line limit), anatomy diagram, handoff contracts, layer isolation section.
- `docs/persona/builder.md`: full anatomy rewrite — convergence loop diagram, orchestrator modes table, planners table with impact recommendations column, deprecated agents section.
- `docs/deck/agentic-deck.html`: all affected slides updated — role cards, anatomy diagrams, taxonomy table, builder example cards, maturity ladder.
- `README.md`: agent table updated (descriptions); skill descriptions updated; workflow step updated.

### Deprecated
- `builder-feature-planner`: responsibilities absorbed into `builder-feature-orchestrator` (synthesize mode) and `builder-plan-feature` skill (convergence loop).
- `builder-auto-feature-planner`: responsibilities absorbed into `builder-feature-orchestrator` (`gather-intent-prefilled` mode) and `builder-build-from-ticket` skill.

---

## [5.3.1] — 2026-05-12

### Changed
- `tracker-adjust-ticket` skill: upgraded `## Session Adjustment` heading to `#`, and subsection headings from `###` to `##`

---

## [5.3.0] — 2026-05-11

### Added
- `tracker-jira-ticket-worker`: generic worker that creates Jira tickets under an epic from a platform breakdown list — parses platform/scope/duration, fetches PRD from Confluence, optional Figma context for UI tickets, generates requirement-focused descriptions (Context · Scope of Work · Design · Acceptance Criteria), previews before creating, and creates via Atlassian MCP. Codebase exploration deferred to `/builder-groom-ticket`.
- `tracker-jira-ticket` skill: entry point for `tracker-jira-ticket-worker`

### Changed
- `README.md`: fixed stale agents and skills tables (v3.15.0 → v5.2.0 header, added Android platform, corrected builder persona table, added tracker-jira-ticket-worker, removed non-existent prompt-debug-worker, expanded skills from 4 to 17 entries by persona)
- `README.md`: added Recommended Workflows section — Workflow 1 (Tracker Persona: 1a create tickets, 1b update progress) and Workflow 2 (Builder Persona: groom → build → adjust) with prompt examples and first-time tutorial framing

---

## [5.2.0] — 2026-05-10

### Added
- `auditor-arch-check` contract skill — all 4 platforms (iOS + web moved from flat, Flutter + Android stubs)
- `installer-setup-project` contract skill — all 4 platforms (iOS + web moved from flat, Flutter + Android stubs)
- `builder-test-create-mock` contract skill — all 4 platforms (web moved from flat, iOS + Flutter + Android stubs)

### Fixed
- `auditor-arch-review-worker`, `installer-setup-worker`, `builder-test-worker`: replaced flat platform skill references with contract skill names — fixes P6 platform-agnosticism violations

---

## [5.1.0] — 2026-05-10

### Added
- `detective-debug-add-logs` and `detective-debug-remove-logs` promoted to detective persona contract skills across all 4 platforms — iOS and web implementations moved from flat to `contract/`, Flutter and Android stubs created

### Changed
- `detective-debug-log-worker`: adds `related_skills` pointing to both contract skills; drops inline platform conventions table and `LOG_PREFIX` input — log format knowledge now lives in each platform's skill

---

## [5.0.1] — 2026-05-10

### Fixed
- Reverted persona prefix from flat platform-specific skills (non-contract). Only contract skills under `/contract/` keep `builder-*` prefix. Flat platform skills (`arch-check-ios`, `debug-add-logs`, `setup-ios-project`, `pres-ssr-check`, etc.) are single-platform by definition — no cross-platform ambiguity, so the prefix added noise without benefit.

---

## [5.0.0] — 2026-05-10

### Changed
- **BREAKING** — All platform skills renamed with persona-name prefix (`<persona>-<layer>-<action>-<target>`):
  - Contract skills (all 4 platforms): `domain-create-*` → `builder-domain-create-*`, `data-create-*` → `builder-data-create-*`, `pres-create-*` → `builder-pres-create-*`, `test-create-*` → `builder-test-create-*`
  - iOS flat skills: `arch-check-ios` → `auditor-arch-check-ios`, `review-pr` → `auditor-review-pr`, `sonar-check` → `auditor-sonar-check`, `debug-*-logs` → `detective-debug-*-logs`, `setup-ios-project` → `installer-setup-ios-project`, `generate-changelog` → `tracker-generate-changelog`, `migrate-*` → `builder-migrate-*`, `audit-presentation-test` → `builder-audit-presentation-test`, etc.
  - Web flat skills: `arch-check-web` → `auditor-arch-check-web`, `debug-*-logs` → `detective-debug-*-logs`, `setup-nextjs-project` → `installer-setup-nextjs-project`, `pres-*` → `builder-pres-*`, etc.
- **BREAKING** — Removed 13 duplicate flat iOS skills that were silently shadowing their `contract/` counterparts in `setup-symlinks.sh` link ordering. `contract/` is now the authoritative source for iOS.

### Migration

Downstream projects must re-run setup-symlinks.sh to get new skill names in `.claude/skills/`:
```bash
.claude/software-dev-agentic/scripts/setup-symlinks.sh --platform=<platform>
```
Any `skills.local/` overrides must be renamed to match the new `builder-`/`auditor-`/`detective-`/`installer-`/`tracker-` prefixed names.

---

## [4.1.1] — 2026-05-10

### Changed
- `docs/principles/core-design-principles.md`: replaced blanket 30-line skill limit with a type-based size rule (Type A short, Type T medium, Type U as long as needed); removed stale 500-line SKILL.md cap

---

## [4.1.0] — 2026-05-10

### Added
- `lib/core/skills/installer-update/SKILL.md`: new Type U runbook skill — detects platform, runs `sync.sh`, then verifies submodule state, agent/skill symlinks, CLAUDE.md markers, settings, and gh auth. Prints a combined ✓/⚠/✗ report

### Changed
- `docs/principles/core-design-principles.md`: added Type U runbook exception to the 30-line skill limit — all-Bash diagnostic skills are exempt

---

## [4.0.0] — 2026-05-10

### Changed
- **BREAKING** — All 18 persona agent files renamed to carry the persona name as prefix (`<persona>-<domain>-<role>`):
  `feature-orchestrator` → `builder-feature-orchestrator`, `feature-worker` → `builder-feature-worker`, `feature-planner` → `builder-feature-planner`, `backend-orchestrator` → `builder-backend-orchestrator`, `app-planner` → `builder-app-planner`, `auto-feature-planner` → `builder-auto-feature-planner`, `data-planner` → `builder-data-planner`, `domain-planner` → `builder-domain-planner`, `pres-planner` → `builder-pres-planner`, `groom-orchestrator` → `builder-groom-orchestrator`, `test-worker` → `builder-test-worker`, `ui-worker` → `builder-ui-worker`, `debug-orchestrator` → `detective-debug-orchestrator`, `debug-worker` → `detective-debug-worker`, `debug-log-worker` → `detective-debug-log-worker`, `arch-review-worker` → `auditor-arch-review-worker`, `setup-worker` → `installer-setup-worker`, `issue-worker` → `tracker-issue-worker`
- `docs/principles/core-design-principles.md`: Agent Naming Convention updated to `<persona>-<domain>-<role>` format
- All spawn prompts, `agents:` frontmatter, skill descriptions, README, `docs/persona/`, and `CLAUDE.md` updated to new names

### Migration

Downstream projects with extension files must rename them to match:

```bash
# Example renames in .claude/agents.local/extensions/
mv feature-orchestrator.md builder-feature-orchestrator.md
mv feature-worker.md        builder-feature-worker.md
mv arch-review-worker.md    auditor-arch-review-worker.md
mv setup-worker.md          installer-setup-worker.md
mv issue-worker.md          tracker-issue-worker.md
# ... etc for any other extensions you have
```

---

## [3.67.0] — 2026-05-10

### Changed
- All core trigger skills renamed to carry their persona name as prefix — consistent with existing `builder-*` convention:
  `build-from-ticket` → `builder-build-from-ticket`, `clear-runs` → `builder-clear-runs`, `backend-orchestrator` → `builder-backend`, `debug-orchestrator` → `detective-debug`, `arch-review` → `auditor-arch-review`, `issue-worker` → `tracker-issue`, `doctor` → `installer-doctor`, `setup-worker` → `installer-setup`, `sync` → `installer-sync`
- All slash-command references updated across agent descriptions, CLAUDE-templates (web/ios/flutter/android), platform setup skills, README, and CLAUDE.md
- `agentic-perf-review` and `release` unchanged — `perf-worker` is ungrouped (no persona folder yet); `release` is a repo utility

---

## [3.66.0] — 2026-05-10

### Added
- `scripts/setup-ai.sh`: Phase 2 skill compilation — compiles `lib/` skills into Gemini CLI (`.agents/skills/` symlinks + `.gemini/commands/*.toml`) and Copilot (`.github/agents/*.agent.md` + `.github/instructions/*.instructions.md`) formats after Phase 1 config generation
- `scripts/clean-ai.sh`: Phase 2 cleanup — removes compiled skill artifacts; surgical for Copilot (`.github/` may have user files), aggressive for Gemini-owned dirs

### Changed
- `scripts/clean-ai.sh`: `--platform=` flag added (now required, symmetric with `setup-ai.sh`)
- `docs/multi-ai-platform-initiative.md`: moved to `docs/initiatives/multi-ai-platform-initiative.md`

---

## [3.65.4] — 2026-05-10

### Added
- `lib/platforms/android-talenta/reference/contract/builder/app-layer.md`: Android app-layer reference doc
- `lib/core/agents/builder/app-planner.md`: Android glob patterns

### Changed
- `lib/core/skills/builder-plan-feature/SKILL.md`, `lib/core/skills/builder-build-feature/SKILL.md`: renamed from `plan-feature` / `feature-orchestrator`

### Fixed
- `lib/core/skills/builder-build-feature/SKILL.md`: name collision resolved, `user-invocable` added, app-planner web path corrected
- `lib/core/agents/builder/feature-orchestrator.md`: extension point path restored after sed rename corruption

---

## [3.65.0] — 2026-05-10

### Added
- `lib/core/reference/code-architecture/app-layer.md`: two new canonical headings — `## Analytics Constants` and `## Feature Flag Registration` (platform-agnostic theory)
- `lib/platforms/ios-talenta/reference/contract/builder/app-layer.md`: iOS implementations — `{Feature}FirebaseName.swift` struct pattern for analytics; `FeatureFlagKey` + `FeatureFlagCollection` registration steps in `Shared/Infrastructure/FeatureFlag/FeatureFlag.swift`
- `lib/platforms/flutter-mobile-talenta/reference/contract/builder/app-layer.md`: Flutter stubs for Analytics Constants and Feature Flag Registration (discovery-oriented — pattern varies by project)

### Changed
- `lib/core/agents/builder/app-planner.md`: added Steps 5–6 (locate analytics constants files; locate feature flag registration files); Output block gains `### Analytics Constants` and `### Feature Flag Registration` sections; Naming Conventions gains `analytics_pattern` and `feature_flag_pattern`
- `lib/core/agents/builder/feature-planner.md`: `## App Layer` plan.md table gains Analytics Constants and Feature Flag Registration rows
- `lib/core/agents/builder/feature-worker.md`: App Layer execution section gains special-case handling for Analytics Constants (create) and Feature Flag Registration (update/skip)
- `lib/core/reference/code-architecture/app-layer.md`, `lib/platforms/ios-talenta/reference/contract/builder/app-layer.md`, `lib/platforms/flutter-mobile-talenta/reference/contract/builder/app-layer.md`: corrected `<!-- N -->` line counts on `## Module Registration` sections

## [3.64.0] — 2026-05-10

### Added
- `lib/core/agents/builder/app-planner.md`: new planner agent — explores DI registration, route registration, and module registration patterns for a feature; returns structured `## App Findings` block; no writes
- `lib/core/reference/code-architecture/app-layer.md`: platform-agnostic theory for Dependency Registration, Route Registration, and Module Registration concepts
- `lib/platforms/ios-talenta/reference/contract/builder/app-layer.md`: iOS/Needle/Coordinator patterns for all three app-layer concerns
- `lib/platforms/flutter-mobile-talenta/reference/contract/builder/app-layer.md`: Flutter/get_it/BaseModule patterns for all three app-layer concerns

### Changed
- `lib/core/agents/builder/feature-planner.md`: Phase 2 spawns `app-planner` in parallel alongside the three layer planners; Phase 3 aggregates `## App Findings`; `context.md` format gains `### App` discovered-artifacts table; `plan.md` format gains `## App Layer` table after `## UI Layer`
- `lib/core/agents/builder/feature-worker.md`: execution order extended with App Layer (order 5); per-artifact workflow section adds App Layer direct-edit procedure (no skill — always `Read` + `Edit`); `state.json` schema gains `"app"` key; Output block gains `### App` section
- `docs/principles/core-design-principles.md`: Layer Isolation section updated — references all four planners (`app-planner` added); `feature-planner` description corrected to "four planners in parallel"

## [3.63.0] — 2026-05-09

### Changed
- `docs/principles/core-design-principles.md`: restructured into 5 Core Design Principles + separate Reference, Taxonomy, and Anatomy top-level sections; Context Isolation and Fail-Fast folded as subsections under Agents = Brain; corrected context relay framing (disk reads + trigger skill as bridge, not cache TTL); confirmed `agents:` frontmatter field as undocumented (verified 2026-05-09); Agents and Skills taxonomy entries grouped under parent sections with subsections
- `docs/multi-ai-platform-initiative.md`: extended platform equivalence tables — Copilot prose-delegation workaround for orchestrator/worker and planner patterns; layer isolation and DI at skill level Copilot/Gemini notes; fixed Gemini isolated context inconsistency; added Gemini context relay partial workaround via `@{file}` injection; updated Grep-first and resume routing portability; corrected Architecture Reference section framing; hooks Convention column updated to reflect actual shell hook categories
- `docs/deck/agentic-deck.html`: corrected context relay bullet (removed cache pricing, added `plan.md`); updated trigger skill card and anatomy handoff table to include `plan.md`

## [3.62.0] — 2026-05-09

### Changed
- `docs/multi-ai-platform-initiative.md`: full rewrite — Principles × Platform Equivalence tables with Official/Convention split per platform (Claude Code, Gemini CLI, GitHub Copilot); phases derived from principles; verified Gemini CLI subagent system, custom commands, skill frontmatter; verified Copilot agent system
- `docs/principles/core-design-principles.md`: natural language routing removed — trigger skills are the only supported entry path; Type B (destructive) skill type retired — automated bash belongs in hooks, not skills; taxonomy updated to A/T/U only
- `docs/deck/agentic-deck.html`: Type B row removed from skills taxonomy table; caption updated to reference hooks for bash execution
- `lib/core/agents/builder/feature-orchestrator.md`: direct invocation now hard-stops instead of warn-and-proceed

### Fixed
- `lib/platforms/ios-talenta/skills/`: 5 skills misclassified as Type B (`disable-model-invocation: true`) — all migrated to Type U (`user-invocable: true`): `generate-changelog`, `audit-presentation-test`, `migrate-presentation`, `migrate-usecase`, `sonar-check`

## [3.61.0] — 2026-05-09

### Changed
- `docs/multi-ai-platform-initiative.md`: Copilot section rewritten — no skill invocation primitive, Phase 2 does not apply; expanded platform equivalence tables
- `docs/`: reorganized root files into semantic subdirectories — `core-design-principles.md` + `submodule-repo-structure.md` → `principles/`; `stakeholder-brief.md` → `deck/`; `contract-schema-improvement-backlog.md` → `initiatives/`; all inbound references updated

### Removed
- `docs/collaboration.md`: obsolete PM–engineer workflow referencing `/pickup-issue` and `/create-issue` skills
- `docs/changelog-core-design-principles.md`: stale since v3.21.0; superseded by `CHANGELOG.md`
- `docs/changelog-submodule-repo-structure.md`: stale since v3.21.0; superseded by `CHANGELOG.md`
- `docs/detective-agent-design.md`: draft superseded by `docs/persona/detective.md`
- `docs/deck-plan.md`: planning doc superseded by `docs/deck/agentic-deck.html`
- `docs/plugin-vs-submodule.md`: one-time architectural decision doc, no inbound references
- `docs/agentic-performance-report-apr-2026.md`: narrative summary, no inbound references
- `docs/ai-fluency-test-study.md`: study doc, no inbound references

## [3.60.0] — 2026-05-08

### Added
- `scripts/setup-symlinks.sh`: `reference.local/` support — created at setup time, linked with highest priority (local > platform > core); override-only, no extension mechanism
- `docs/deck/agentic-deck.html`: new slide s9a — "Override without forking. Extend without copying." — local directories table, priority order, reference override-only rationale
- `docs/core-design-principles.md`: reference docs taxonomy section (Core / Platform / Project by scope); expanded consumer modes table to include `reference.local/`; local directories table with override/extend support per directory

## [3.59.0] — 2026-05-08

### Added
- `scripts/setup-ai.sh`: generates AI assistant config file from template — `--ai=copilot|gemini`, `--platform=<platform>`, `--app-name=<name>`; writes `.github/copilot-instructions.md` or `GEMINI.md`; prompts before overwriting
- `scripts/clean-ai.sh`: removes AI assistant config file — `--ai=copilot|gemini`; prompts before deleting
- `lib/ai-platforms/copilot/template.md`: Copilot instructions template — Clean Architecture layers, creation order, naming conventions, hard rules; placeholders for `[APP_NAME]` and `[PLATFORM]`
- `lib/ai-platforms/gemini/template.md`: Gemini instructions template — same content as Copilot template plus `@import` directives for `.claude/reference/` docs
- `docs/multi-ai-platform-initiative.md`: planning doc for multi-AI platform support — Phase 1 (context files), Phase 2 (native skills), Phase 3 (hooks); capability gap table per platform

### Changed
- `scripts/sda.sh`: extended interactive menu with `Add AI` (option 3) and `Remove AI` (option 4); wires to `setup-ai.sh` and `clean-ai.sh`; Claude setup and sync unchanged

## [3.58.0] — 2026-05-08

### Added
- `scripts/sda.sh`: new CLI entry point — interactive menu for `setup` (first-time wiring) and `sync` (pull latest + re-wire); prompts for platform when not passed; delegates to `setup-symlinks.sh` and `sync.sh`
- `lib/platforms/ios-talenta/skills/`: promoted 13 skills from `talenta-ios/.claude/skills.local/` — `data-create-datasource`, `data-create-mapper`, `data-create-repository-impl`, `domain-create-entity`, `domain-create-repository`, `domain-create-service`, `domain-create-usecase`, `pres-create-component`, `pres-create-screen`, `pres-create-stateholder`, `test-create-data`, `test-create-domain`, `test-create-presentation`
- `lib/core/agents/builder/backend-orchestrator.md`: rebuilt — calls skills directly in layer order (no sub-agents); handles Domain + Data layers for a feature
- `lib/core/skills/backend-orchestrator/SKILL.md`: entry trigger for the rebuilt `backend-orchestrator`

### Changed
- `scripts/sync.sh`: explicit `git pull origin main` for plain-clone path

### Removed
- `lib/core/agents/builder/domain-worker.md`: dead weight — superseded by `feature-worker` and `backend-orchestrator`
- `lib/core/agents/builder/data-worker.md`: dead weight — superseded by `feature-worker` and `backend-orchestrator`
- `lib/core/agents/builder/presentation-worker.md`: dead weight — superseded by `feature-worker`
- `lib/core/agents/builder/pres-orchestrator.md`: dead weight — no active skill entry point

## [3.57.0] — 2026-05-07

### Added
- `lib/core/skills/builder-groom-ticket/SKILL.md`: new user-invocable skill — entry trigger for the ticket grooming workflow; accepts optional ticket path, reads ticket content, spawns `groom-orchestrator`
- `lib/core/agents/builder/groom-orchestrator.md`: new orchestrator — maps ticket acceptance criteria to CLEAN layers, spawns only in-scope layer planners (domain/data/pres) in parallel using grooming-only mode, aggregates a compact grooming summary, then auto-chains to `tracker-adjust-ticket`; sits between ticket fetch and `/plan-feature` in the pre-build workflow

---

## [3.56.0] — 2026-05-07

### Added
- `docs/core-design-principles.md §6`: ubiquitous language authoring rule — H2 headings in cross-platform reference docs must be identical for the same concept (horizontal contract); documents vertical vs horizontal contract distinction
- `docs/deck/agentic-deck.html`: new slide s9c — canonical headings and Ubiquitous Language (DDD); bad/good code panels, vertical vs horizontal contract table; deck is now 20 slides

### Fixed
- All cross-platform `reference/contract/builder/` H2 headings standardized to canonical terms: `## Repository Interfaces` (was `## Repository Protocols` on iOS), `## State Management` (was `## State` / `## QueryState` / `## ViewModel State Management` / `## ViewDataState`), `## Null Safety Extensions` (was `## Null Safety Utilities` on web/flutter), `## Presenter Tests` (was `## ViewModel Tests` / `## ViewModel Hook Tests` / `## BLoC Tests`), `## HTTP Client` (was `## Networking (Moya)` on iOS), `## HTTP Error Interceptor` (was `## Dio Error Interceptor` on flutter/error-handling)
- iOS `domain-create-repository` skill: grep target `## Repository Protocols` → `## Repository Interfaces`
- iOS `pres-create-stateholder` skill: grep target `## ViewModel State Management` → `## State Management`
- iOS `test-create-presentation` skill: grep target `## ViewModel Tests` → `## Presenter Tests`
- Web `test-create-presentation` skill: grep target `## ViewModel Hook Tests` → `## Presenter Tests`
- Web `test-create-mock` skill: grep target `## ViewModel Hook Tests` → `## Presenter Tests`
- Flutter `test-create-presentation` skill: grep target `## BLoC Tests` → `## Presenter Tests`
- Flutter `reference/index.md`: section description updated to `Presenter Tests`
- Flutter `error-handling.md`: cross-reference updated to `## HTTP Error Interceptor`
- Line counts refreshed across all affected reference files via `update-ref-counts.sh`

## [3.55.0] — 2026-05-06

### Added
- `lib/platforms/android-talenta/reference/contract/builder/error-handling.md`: new — `## Error Flow`, `## Error Types`, `## Error Mapping`, `## Error UI` covering `DomainException`, `ErrorHandler`, and `onErrorResumeNext` patterns
- `lib/platforms/android-talenta/reference/contract/builder/navigation.md`: new — `## Navigator` (custom `NavigationImpl` pattern) and `## Route Constants` stub
- `lib/platforms/android-talenta/reference/contract/builder/domain.md`: added `## Services` and `## Domain Errors` sections
- `lib/platforms/android-talenta/reference/contract/builder/presentation.md`: added `## State` (MVP View interface as state surface) and `## Shared Component Paths`
- `lib/platforms/android-talenta/reference/contract/builder/testing.md`: added `## Test Pyramid` and `## Repository Tests` with full Mockito example
- `lib/platforms/android-talenta/reference/contract/builder/utilities.md`: added `## StorageService`, `## DateService`, `## Logger` stubs
- `arch-check-conventions`: new `## Reference Doc Section Line-Count Check` — every `##` heading must carry `<!-- N -->` integer; missing or non-integer is a Warning violation
- `docs/core-design-principles.md §6`: authoring rule for `<!-- N -->` line-count convention (writer-side documentation)

### Changed
- `lib/platforms/ios-talenta/reference/contract/builder/data.md`: `## Response Models (DTOs)` → `## DTOs`; iOS naming explained in section body
- `lib/platforms/android-talenta/reference/contract/builder/data.md`: `## Response Models` → `## DTOs`; `## API Service` → `## Data Sources`; platform naming explained in body
- `arch-review-worker`: platform scope now includes `reference/contract/**/*.md`; adds `reference-doc` as third file classification routing to Contract Schema + Line-Count checks
- `docs/deck/agentic-deck.html`: corrected `feature-orchestrator` flow (spawns `feature-worker`, not individual layer workers); Android promoted from "coming soon" to active; removed false pre-commit hook claim

### Fixed
- All Android reference contract files now satisfy `builder-auditor-schema.md` keyword requirements — schema check passes for all 8 required files

---

## [3.54.0] — 2026-05-04

### Added
- `lib/platforms/android-talenta/`: new Android platform for Kotlin/MVP (Dagger 2 + RxJava 3) projects
- `lib/platforms/android-talenta/skills/contract/` (12 skills): full builder persona contract skill set — `domain-create-entity`, `domain-create-repository`, `domain-create-usecase`, `domain-create-service`, `data-create-datasource`, `data-create-mapper`, `data-create-repository-impl`, `pres-create-stateholder`, `pres-create-screen`, `test-create-domain`, `test-create-data`, `test-create-presentation`
- `lib/platforms/android-talenta/reference/contract/builder/` (6 files): `domain.md`, `data.md`, `presentation.md`, `di.md`, `utilities.md`, `testing.md` — all reflecting real Talenta Android patterns (`BaseMvpVbActivity`, `BaseMvpPresenter`, `doOnSubscribe`/`doFinally`, `addToDisposables()`, `given/when/then` test naming)
- `lib/platforms/android-talenta/reference/error-handling.md`: `ErrorHandler`, `ApiException`, `ErrorInterceptor` — platform-specific, not a contract file
- `lib/platforms/android-talenta/reference/network.md`: Retrofit/OkHttp setup, `AuthInterceptor` — platform-specific
- `lib/platforms/android-talenta/reference/project.md`: module structure, naming conventions, build commands
- `lib/platforms/android-talenta/CLAUDE-template.md` and `settings-template.jsonc`

### Changed
- `scripts/setup-symlinks.sh`: added `android` to supported platforms list and usage/validation message
- `docs/persona/builder.md`: updated Android implementation reference row to reflect new platform stub

---

## [3.53.0] — 2026-05-03

### Added
- `lib/platforms/flutter-mobile-talenta/reference/index.md`: new index listing all 6 contract reference files with sections and Grep pattern — enables workers to satisfy the P6 Grep-first rule when uncertain which file covers a topic
- `agent-audit-worker`: Check 7 — platform skill parity via Glob comparison; audits a platform's `skills/contract/` dir against sibling platforms and reports gaps based on actual file presence, not assumed names

### Changed
- `docs/core-design-principles.md`: P1 Skill-First Entry — `build-from-ticket` added as third builder entry skill (CI/remote non-interactive path); P2 DI at Skill Level — skills-are-create-only rule added; P3 skill naming note — stale `update-*` reference removed
- `docs/persona/builder.md`: Skill Roster — create-only callout added above table
- `docs/submodule-repo-structure.md`: Decision 1 naming pattern and "What Goes Where" Platform-contract skills row both state create-only constraint
- `docs/deck/agentic-deck.html`: Type A skill description updated from "Standard build / update procedures" to reflect create-only nature
- `agent-audit-worker`: hard constraint added at top of Checks section — every "missing" finding must be grounded in a Glob result, never inferred from framework or domain knowledge

### Fixed
- `lib/platforms/flutter-mobile-talenta/skills/contract/` (all 9 skills): removed Fix G `Rules:` prose blocks; non-obvious constraints inlined as code comments in templates; reference docs carry the full specification
- `data-create-repository-impl/SKILL.md`: corrected `reference/contract/builder/error-handling.md` → `.claude/reference/contract/builder/error-handling.md` (missing `.claude/` prefix)
- `arch-review-orchestrator`: Intent Routing table phase labels aligned with three-phase body structure — audit/review now explicitly show they skip Phase 2 and go to Phase 3 (report)

---

## [3.52.3] — 2026-04-29

### Fixed
- `feature-orchestrator` skill: moved "Plan first / Build directly" `AskUserQuestion` from the orchestrator agent into the skill (Step 4) — option menus only work in the main session
- `feature-orchestrator` agent: replaced `new` trigger with `build-directly`; agent no longer calls interactive option menus
- `plan-feature` skill: Step 1 now spawns `feature-orchestrator (Trigger: plan-first)` instead of `feature-planner` directly, keeping routing in the agent layer

## [3.52.2] — 2026-04-29

### Fixed
- `plan-feature` skill: moved plan approval `AskUserQuestion` (Approve / Discuss more / Discard) out of `feature-orchestrator` and into the skill itself — `AskUserQuestion` with options only works in the main session, not inside spawned sub-agents
- `feature-orchestrator`: added `execute-approved-plan` trigger for post-approval execution; removed approval loop that could never surface interactive options

## [3.52.1] — 2026-04-29

### Fixed
- `feature-orchestrator`: plan approval `AskUserQuestion` (Approve / Discuss more / Discard) moved from `feature-planner` to the orchestrator — sub-agents cannot surface interactive UI, causing the prompt to collapse to prose text

## [3.52.0] — 2026-04-28

### Added
- `build-from-ticket`: new one-shot skill for remote AI tools (CI jobs, API callers) — fetches a Jira ticket via `getJiraIssue` or `mmpa_get_jira`, derives planning inputs inline, runs `auto-feature-planner`, then `feature-worker`, and cleans up run state on exit. Fail-fast `error.md` writes surface failures in PR diffs rather than hung jobs.
- `auto-feature-planner`: non-interactive fork of `feature-planner` — accepts pre-filled intent block, never calls `AskUserQuestion`, auto-approves plan after writing `plan.md` + `context.md`. Designed for `build-from-ticket` and future CI callers.

### Changed
- `feature-worker`: load platform `utilities.md` during pre-flight and enforce null safety extension methods (`.orZero()`, `.orEmpty()`, `.orFalse()`) over raw `??` and `!` across all artifacts and platforms
- `feature-worker`: added Run Directory Ownership guard — cleanup of `runs/<feature>/` is the calling skill's responsibility, not the agent's
- `feature-orchestrator` agent: refactored to mode-based routing (`plan-first` / `resume` / `new`); removed old `domain-worker`, `data-worker`, `pres-orchestrator` phase chain — replaced by single `feature-worker` spawn. Added hot/cold start guidance in Search Protocol.
- `plan-feature` skill: simplified to a single `feature-orchestrator` agent spawn with `Trigger: plan-first` — all orchestration logic now lives in the agent
- `feature-orchestrator` skill: resume path now routes through `feature-orchestrator` agent (previously spawned `feature-worker` directly, bypassing orchestrator)
- `debug-orchestrator` agent: scoping budget capped at 2 tool calls; intake assessment table added; `.pbxproj` and build-system metadata reads blocked

## [3.51.4] — 2026-04-28

### Changed
- `debug-orchestrator` skill: intake now collects `Target files` from context/ticket (skips the question if already named); spawn prompt includes `Target files` field so the agent never needs to discover what the caller already knows
- `debug-add-logs` iOS skill: added `## Inputs` section defining the expected contract (`Bug description`, `Entry point`, `Target files`, `Expected / Actual`) — aligns with what debug-orchestrator passes

## [3.51.3] — 2026-04-28

### Changed
- `debug-orchestrator`: Step 2 now includes an intake assessment table — classifies what is known before any tool call and maps directly to the required action (skip, one Grep, or route immediately with `layer: unknown`)
- `debug-orchestrator`: added 2-call exploration budget with explicit stopping condition; explicit ban on reading `.pbxproj`, `.xcworkspace`, and build-system metadata

## [3.51.2] — 2026-04-26

### Changed
- `agent-scaffold-worker`: Step 4 "Gather Details" now asks each detail one question at a time via `AskUserQuestion` — numbered sequence per type (Worker, Orchestrator, Skill, New Persona) with explicit "do not bundle" rule, matching the interactive pattern used in `tracker-adjust-ticket`

## [3.51.1] — 2026-04-26

### Changed
- `tracker-adjust-ticket`: split `### Decisions & Open Questions` into separate `### Decisions` (prose bullets with rationale) and `### Open Questions` (checklist) sections; both omitted when empty — aligns template to real ticket structure

## [3.51.0] — 2026-04-25

### Added
- `feature-worker`: Search Protocol section — Grep-first table, Read-once rule, explicit ban on bash grep as a substitute for the Grep tool
- `tracker-adjust-ticket`: Acceptance Criteria duplicate into Session Adjustment on every update; `### Work Items` checklist for per-session progress tracking

### Changed
- `debug-worker`: added bash-grep callout to existing Search Protocol — Bash grep does not reduce Read tool count and bypasses token-efficiency audit
- `tracker-adjust-ticket`: write boundary now strictly locked to `## Session Adjustment` section only; original ticket content is never touched

## [3.50.1] — 2026-04-25

### Fixed
- `feature-planner`: Phase 5 now shows plan path + numbered step list (`ArtifactName → short description`) before prompting for approval — previously showed nothing
- `feature-planner`: agent can no longer pre-announce "Plan approved" before the user selects Approve in AskUserQuestion

## [3.50.0] — 2026-04-25

### Added
- `/sync` toolkit skill (`lib/core/skills/sync/SKILL.md`): pull latest submodule + re-run setup-symlinks in one command; auto-detects platform from existing symlinks, falls back to asking user

### Changed
- `scripts/sync.sh`: `--platform` is now optional — auto-detected from `.claude/skills/domain-create-entity` symlink target when omitted; fails with a clear message only if detection fails and flag is absent

## [3.49.2] — 2026-04-25

### Added
- `docs/core-design-principles.md`: Anatomy of a Persona section — layer diagram, handoff contracts table, state files table
- `docs/persona/builder.md`: Anatomy section — dual entry skill diagram, planner phase breakdown, execution phase description, standalone paths
- `docs/persona/detective.md`: Anatomy section — investigation sequence diagram, tool isolation constraint, short-circuit path, handoff boundary

### Changed
- `docs/persona/builder.md`: Agent Roster updated — added `feature-worker`, `domain-planner`, `data-planner`, `pres-planner`; `feature-planner` reclassified as Planner; Layer-to-Agent Mapping adds Planner column; Skill Roster adds `domain-create-service`, removes stale update skills

## [3.49.1] — 2026-04-25

### Changed
- `docs/core-design-principles.md`: added Planner as a first-class taxonomy entry — `-planner` suffix in naming convention table, Planner row in Agents By Role table, Planners in DI at Skill Level analogy, and "Planner vs Worker" decision rule (complexity/scale determines which to use first)

## [3.49.0] — 2026-04-25

### Added
- `feature-worker`: plan-driven executor — reads approved plan.md, calls skills in layer order (domain → data → presentation → UI), validates each artifact inline via Glob+Grep, tracks per-artifact state.json, handles stateholder-contract handoff, and supports auth interruption recovery

### Changed
- `/plan-feature` skill: execution step now spawns `feature-worker` instead of `feature-orchestrator`; plan.md passed inline alongside context.md
- `/feature-orchestrator` skill: resume path now spawns `feature-worker` with plan+context inline; new-call path routes to `feature-planner` for plan-first flow
- `feature-orchestrator` agent: `agents:` list updated to include `feature-worker` and `feature-planner`

## [3.48.0] — 2026-04-25

### Added
- `domain-planner`: explore-only agent — discovers entities, use cases, repository interfaces, domain services; returns structured findings, no writes
- `data-planner`: explore-only agent — discovers DTOs, mappers, datasources, repository implementations; returns structured findings, no writes
- `pres-planner`: explore-only agent — discovers StateHolders, screens, components, navigators + key symbols (event cases, state fields, constructor params); no writes

### Changed
- `feature-planner`: Phase 2 now spawns domain-planner, data-planner, and pres-planner in parallel via Agent tool, replacing the single Explore agent; aggregates three structured findings blocks into context.md + plan.md; added `Agent` to tools and `agents:` frontmatter list

## [3.47.1] — 2026-04-25

### Changed
- `feature-planner`: enforce 60-line read budget on Explore agent — offset+limit required after Grep, never unbounded Read; Key Symbols extraction uses Grep line number + ±30 line window
- `feature-planner`: Search Protocol updated — all Reads capped at `limit=60`, unbounded Read on a large file is an explicit violation

## [3.47.0] — 2026-04-25

### Changed
- Skills are now create-only: workers handle artifact modifications via direct `Read` + `Edit` with reference docs — no skill wrapper needed for updates
- `extract-session.sh`: fix path slug encoding for dotted usernames — dots now encoded as dashes to match Claude's actual `~/.claude/projects/` folder format; added fuzzy basename fallback
- `docs/core-design-principles.md`: updated precondition rule to reflect direct-edit model for existing artifacts

### Removed
- All update and fix skills across iOS, Flutter, and Web (18 skill dirs): `data-update-mapper`, `domain-update-usecase`, `pres-update-screen`, `pres-update-stateholder`, `test-update`, `test-fix`
- Corresponding pointers removed from worker frontmatter (`related_skills`), routing tables, precondition rules, agent descriptions, `perf-worker`, `flutter/README`, `ios/test-orchestrator`, and `web/skills/README`

## [3.46.3] — 2026-04-24

### Changed
- `tracker-adjust-ticket`: update in place instead of appending — exactly one `## Session Adjustment` section, date reflects last update

## [3.46.2] — 2026-04-24

### Changed
- CLAUDE-template.md (ios, web, flutter): replaced agent list with skill-first entry rule; removed stale delegation guard hook line

## [3.46.1] — 2026-04-24

### Fixed
- `scripts/setup-symlinks.sh` prune loop: removed invalid `2>/dev/null` redirect from `for ... in` glob expansion (bash syntax error on line 167)

## [3.46.0] — 2026-04-24

### Removed
- `scripts/local-setup-symlinks.sh`, `scripts/local-sync.sh` — local (non-submodule) variants no longer needed
- `scripts/manage-packages.sh`, `scripts/local-manage-packages.sh` — package management scripts removed with packages
- `disabled-hooks` guard from all 3 web hooks (`check-use-server.sh`, `block-impl-import-in-presentation.sh`, `lint-on-edit.sh`) — skill-first entry replaces hook-level guards
- `feature-dirs` check from `doctor` skill — delegation hook retired, fragment config no longer relevant
- `config/` directory creation from `setup-symlinks.sh` — nothing writes there anymore

## [3.45.1] — 2026-04-24

### Changed
- `docs/deck/agentic-deck.html`: updated presentation deck to reflect Skill-First Entry architecture — added Trigger Skill as 4th role (slides 11, 12), updated entry flows to show slash commands (slides 14, 16), added trigger skill column to personas table (slide 15), added context relay bullet to caching slide (slide 8), fixed slide counter

## [3.45.0] — 2026-04-24

### Added
- `setup-symlinks.sh`: now does full managed-section sync on `CLAUDE.md` (replaces content between markers on re-run, not just skip)

### Changed
- `sync.sh`: simplified to pull + delegate to `setup-symlinks.sh` — all link/prune/CLAUDE.md logic is now in one place
- `CLAUDE.md`, `README.md`, `submodule-repo-structure.md`, `setup-nextjs-project/SKILL.md`, `setup-worker.md`, `agent-scaffold-worker.md`: updated all references from `setup-packages.sh` → `setup-symlinks.sh`

### Removed
- `scripts/setup-packages.sh` — selective persona installation no longer needed; all personas install by default
- `scripts/local-setup-packages.sh` — removed alongside `setup-packages.sh`
- `packages/*.pkg` — package definition files no longer needed
- Lockfile (`config/installed-packages`) — removed from `setup-symlinks.sh`; no package selection to track

## [3.44.4] — 2026-04-24

### Changed
- `core-design-principles.md`: reframed Principle 1 from "Natural Language as the Entry Point" to "Skill-First Entry" — skills are the preferred path; natural language routing is valid but secondary; updated the intro tagline to match

## [3.44.3] — 2026-04-24

### Added
- `arch-review` skill: Type T trigger skill for the auditor persona — presents scope options (file / feature folder / full codebase) then spawns `arch-review-worker`

### Changed
- `arch-review-worker.md`: description updated to "skill-only — invoked only by `/arch-review` skill"

## [3.44.2] — 2026-04-24

### Fixed
- `feature-orchestrator` skill: made AskUserQuestion explicit with `question/header/options` format matching the established pattern
- `plan-feature` skill: added `AskUserQuestion` gate after planner returns — user now picks "Build now" or "Review first" before orchestrator spawns; also stops cleanly if plan was discarded (no context.md found)

## [3.44.1] — 2026-04-24

### Changed
- `core-design-principles.md`: clarified Skill-First Entry — multiple workflow skills per persona are allowed when they converge on the same primary entry agent; sub-agents used only as workflow steps do not need standalone trigger skills

## [3.44.0] — 2026-04-24

### Added
- `backend-orchestrator` skill: Type T trigger skill — owns routing (resume/new), context pre-loading from runs directory, and spawn prompt construction
- `setup-worker` skill: Type T trigger skill — asks platform if not provided, then spawns `setup-worker` agent
- `issue-worker` skill: Type T trigger skill — spawns `issue-worker` agent with `$ARGUMENTS`
- `core-design-principles.md`: Skill-First Entry for Personas principle — every persona's primary entry agent requires a trigger skill; workers remain orchestrator-spawned

### Changed
- `backend-orchestrator.md`: description updated to "skill-only" and added `Pre-flight — Context Check` (same context relay pattern as `feature-orchestrator`)
- `setup-worker.md`, `issue-worker.md`: descriptions updated to "skill-only — invoked only by trigger skill"

## [3.43.3] — 2026-04-24

### Fixed
- `feature-orchestrator` skill: made Agent tool usage explicit in spawn steps (Resume and New call) — same class of fix as `plan-feature` v3.43.2

## [3.43.2] — 2026-04-24

### Fixed
- `plan-feature` skill: changed "Invoke" to "Spawn using the Agent tool" for both `feature-planner` and `feature-orchestrator` — prevents model from calling them as skills (which fails) instead of agents

## [3.43.1] — 2026-04-24

### Fixed
- `core.pkg`: added `tracker-adjust-ticket` to skills list so downstream sync picks it up

## [3.43.0] — 2026-04-24

### Added
- `tracker-adjust-ticket` skill: appends a new `## Session Adjustment` section to a locally fetched Jira ticket `.md` file based on session discussion — captures progress, decisions/blockers, and development status; never modifies existing content

## [3.42.0] — 2026-04-24

### Added
- `plan-feature` skill: after `feature-planner` completes, reads `context.md` + `state.json` from the runs directory (cache hits in active session) and passes them inline to `feature-orchestrator` spawn — orchestrator starts with context pre-loaded, no cold pre-flight reads
- `feature-orchestrator` skill: owns resume selection via `AskUserQuestion` (one option per existing run + "Start new"); reads selected run's `context.md` + `state.json` and passes inline; new-call path spawns lean and lets orchestrator collect intent
- `feature-orchestrator` agent: `Pre-flight — Context Check` — detects pre-loaded context block in prompt, extracts all needed values, jumps directly to `next_phase`; direct invocation (no skill) warns user and falls back to approved-plan check

### Changed
- `feature-orchestrator` skill: `allowed-tools` expanded to `Bash, Read, AskUserQuestion, Agent`
- `plan-feature` skill: `allowed-tools` expanded to `Bash, Read, Agent`
- `feature-planner` agent: `context.md` added to allowed writes in Constraints
- `clear-runs` skill: note updated to remove `delegation.json` reference

### Removed
- `feature-orchestrator` agent: `Pre-flight — Resume Check` (moved to skill), `Pre-flight — Set Delegation Flag`, and `delegation.json` clear in Phase 4 — delegation mechanism retired in favour of skill-enforced entry point
- `lib/core/hooks/require-feature-orchestrator.sh` — delegation guard hook removed; skill is the enforced entry point, user accepts workflow boundary consciously
- `scripts/setup-symlinks.sh`, `sync.sh`, `local-setup-symlinks.sh`, `local-sync.sh`, `local-setup-packages.sh`: hook wiring and `feature-dirs` creation removed; scripts now remove the hook from `settings.json`/`settings.local.json` if present (migration path for existing downstream projects)

## [3.41.0] — 2026-04-24

### Added
- `feature-planner`: enrich Explore agent to return artifact paths, naming conventions, and key symbols (emitEvent cases, MARK sections, constructor params); write `context.md` alongside `plan.md` so codebase discovery is done once and cached as a file
- `feature-orchestrator`: Correction Mode — trivial single-layer fixes surface to the user for inline edit; complex fixes spawn the layer worker directly, both bypassing full orchestration re-entry and delegation flag re-write
- `feature-orchestrator`: early `state.json` write — initial state written before `domain-worker` spawns so sessions are resumable even if they exit mid-Phase 1
- `feature-orchestrator`: pass `context-path` to `domain-worker`, `data-worker`, and `pres-orchestrator` spawns
- `domain-worker`, `data-worker`, `presentation-worker`, `pres-orchestrator`: Context Shortcut — read `context.md` first when provided and skip Glob+Grep discovery; fall back to standard flow for artifacts not in context

### Changed
- `feature-orchestrator`: Phase 1 state write changed from post-worker to pre-worker (early write)

### Fixed
- `docs/perf-report`: revise TE-14689 D3 findings — ViewModel direct edit was correct per `presentation-worker` judgment rule; feature flag files are outside Clean Architecture layers; raise D3 6→8, Overall 7.6→7.9

## [3.40.10] — 2026-04-23

### Fixed
- `sync.sh`: add `link_reference` function and re-link `reference/` after every prune step — the lockfile path only linked agents and skills, leaving `reference/` empty after dangling symlinks were pruned
- `setup-packages.sh`: same fix — add `link_reference` and call it after the prune step so reference files are always present

## [3.40.9] — 2026-04-23

### Fixed
- `setup-symlinks.sh`, `sync.sh`, `setup-packages.sh`: prune dangling `reference/` symlinks recursively — all three scripts previously skipped `reference/` in their prune step, causing broken nested symlinks (e.g. `reference/code-architecture/`, `reference/contract/builder/`) to survive re-runs because `link_if_absent` skips existing symlinks even when dangling

## [3.40.8] — 2026-04-23

### Fixed
- `setup-symlinks.sh`: correct relative path depth in recursive `link_reference` — symlinks inside subdirectories (e.g. `reference/code-architecture/`, `reference/contract/builder/`) were one `../` too shallow, causing broken symlinks in downstream projects
- `data-worker`, `presentation-worker`: enforce skill-before-write precondition — new artifact creation must invoke the corresponding skill before any Write/Edit call to prevent pattern-error rework loops
- `data-worker`, `presentation-worker`: prohibit Bash `cat` reads in Search Protocol — workers must use `Grep` or `Read` tools only
- `feature-orchestrator`: add pre-flight test intent check — pure test-creation requests (matching "create tests", "write tests", etc.) are now routed to `test-worker` instead of self-executing
- `feature-orchestrator`: add auth interruption recovery — orchestrator saves state and surfaces a clear resume message on session expiry rather than stalling silently

## [3.40.7] — 2026-04-23

### Fixed
- `setup-symlinks.sh`: prune dangling symlinks in `agents/`, `skills/`, and `hooks/` after the linking step — re-running the script no longer leaves stale symlinks from deleted skills/agents

## [3.40.6] — 2026-04-23

### Fixed
- `sync.sh`: prune dangling `.claude/hooks/*.sh` symlinks during the stale symlink cleaning step
- `sync.sh`: migrate stale `PROJECT_ROOT/hooks/` placeholder in `settings.local.json` to `.claude/hooks/` on every run (matches fix already in `setup-packages.sh` and `setup-symlinks.sh`)

## [3.40.5] — 2026-04-23

### Fixed
- All builder agents (`feature-orchestrator`, `feature-planner`, `domain-worker`, `data-worker`, `presentation-worker`): added **Write Path Rule** — `$(...)` expressions in `file_path` arguments are not evaluated by Write/Edit and produce a literal `__CMDSUB_OUTPUT__` directory; agents must resolve project root via Bash first
- `presentation-worker` step 6: explicit instruction to run `git rev-parse --show-toplevel` before writing `stateholder-contract.md`

## [3.40.4] — 2026-04-23

### Fixed
- `feature-planner`: Phase 5 and Resume path now explicitly prohibit prose option presentation — `AskUserQuestion` is called immediately with no fallback text
- `feature-planner`: "Edit" option renamed to "Discuss more"; agent stays in conversation and re-presents options instead of dropping out
- `setup-packages.sh` / `setup-symlinks.sh`: detect and migrate stale `PROJECT_ROOT/hooks/` placeholder (from v3.4.0 template) to correct `.claude/hooks/` relative path on every run
- `setup-packages.sh`: prune broken symlinks in `agents/`, `skills/`, and `hooks/` during every install run, removing stale links to deleted skills (e.g. `plan`)

## [3.40.3] — 2026-04-23

### Added
- `feature-orchestrator` skill: directory-based (`SKILL.md`), replaces flat file; agent now asks "plan first or build directly?" when no approved plan exists
- `debug-orchestrator` skill: converted from flat file to directory-based (`SKILL.md`)
- `detective.pkg`: added `debug-orchestrator` to skills
- `feature-orchestrator` agent: new decision step — prompts user to invoke `feature-planner` or proceed inline when no approved plan is found

### Removed
- `lib/core/skills/feature-orchestrator.md` — replaced by `feature-orchestrator/SKILL.md`
- `lib/core/skills/debug-orchestrator.md` — replaced by `debug-orchestrator/SKILL.md`

---

## [3.40.2] — 2026-04-23

### Removed
- `lib/core/skills/plan/` — replaced by `plan-feature`

---

## [3.40.1] — 2026-04-23

### Fixed
- `sync.sh`: strip trailing slash before `[ -L ]` check so stale skill symlinks are correctly detected and removed
- `builder.pkg`: add `plan-feature` and `feature-orchestrator` to skills so sync links them in downstream projects

---

## [3.40.0] — 2026-04-23

### Added
- `plan-feature` skill: chains `feature-planner` → `feature-orchestrator` as a single trigger

---

## [3.39.1] — 2026-04-22

### Fixed
- `test-worker`, `debug-worker`, `debug-log-worker`, `arch-review-worker` (lib/core), `pr-review-worker`, `issue-worker`, `perf-worker`: added Read-once rule and/or full Search Protocol block — these workers had the lookup table but no re-read enforcement
- `backend-orchestrator`, `feature-orchestrator`, `feature-planner`, `pres-orchestrator`, `debug-orchestrator`: added coordinator-scoped Search Protocol (state/run files only, delegate source reads to workers) and Read-once rule

---

## [3.39.0] — 2026-04-22

### Added
- `lib/core/skills/debug-orchestrator.md`: Type T trigger skill — collects missing intake then spawns `debug-orchestrator` agent
- `lib/core/skills/feature-orchestrator.md`: Type T trigger skill — passes optional description and hands off to `feature-orchestrator` agent for Phase 0 intake

### Fixed
- `arch-review-orchestrator`: added `Agent` to `tools` — without it the orchestrator could not spawn any sub-agents and collapsed all work inline
- `arch-review-orchestrator`, `agent-scaffold-worker`, `agent-migrate-worker`, `agent-audit-worker`, `agent-consult-worker`, `arch-review-worker`: upgraded Search Rules to `## Search Rules — Never Violate` with full 4-row table including `^## SectionName → <!-- N --> → Read(offset, limit=N)` bounded-read row and explicit Read-once rule
- `.claude/reference/agent-conventions.md`: added `<!-- N -->` section annotations via `update-ref-counts.sh` — enables bounded Read for all `.claude/agents/` tooling

---

## [3.38.0] — 2026-04-22

### Added
- `scripts/update-ref-counts.sh`: rewrites `## Section` headings in all `lib/*/reference/*.md` files with `<!-- N -->` line count annotations — agents use N as the `Read` limit for targeted section reads; runs standalone (all docs) or per-file
- `scripts/hooks/pre-commit`: auto-runs `update-ref-counts.sh` on staged reference docs only (path-constrained to `lib/*/reference/**/*.md`); silent on all other files
- `docs/deck/agentic-deck.html`: 18-slide HTML presentation deck — covers problems, solutions, architecture, personas, Leave Request walkthrough, results; keyboard + touch swipe navigation
- `docs/deck-plan.md`: planning doc for the deck

### Changed
- All 52 reference docs under `lib/*/reference/`: initial `<!-- N -->` section count annotations applied
- Search Protocol in 8 agents (`domain-worker`, `data-worker`, `ui-worker`, `presentation-worker`, `test-worker`, `arch-review-worker`, `debug-worker`, `pr-review-worker`): updated to `Grep "^## SectionName"` → read `<!-- N -->` from heading → `Read(file, offset=line, limit=N)` — replaces imprecise "Grep for the section heading" instruction
- `lib/core/reference/README.md` "How Agents Use This Directory": updated with same two-step Grep + targeted Read pattern as canonical reference

---

## [3.37.0] — 2026-04-22

### Changed
- `lib/core/reference/clean-arch/` → `lib/core/reference/code-architecture/`: renamed to align reference dir naming with the persona taxonomy — all files in this dir are owned and consumed by the builder persona
- `lib/platforms/{ios,web,flutter}/reference/contract/*.md` → `reference/contract/builder/*.md`: contract reference docs grouped under a persona subdir to make room for future personas (e.g. `contract/detective/`) without restructuring
- `scripts/setup-symlinks.sh`: `link_reference` made fully recursive — handles any depth of subdir nesting; `contract/builder/` and future persona subdirs land downstream automatically with no further script changes
- `scripts/local-sync.sh`: `copy_reference` made fully recursive to match; core reference call updated to pass `lib/core/reference/` root so `builder/` is preserved as a subdir rather than copied flat
- All builder agents (`domain-worker`, `data-worker`, `presentation-worker`, `ui-worker`, `test-worker`, `feature-planner`): Grep paths updated to `reference/code-architecture/` and `reference/contract/builder/`
- All platform contract skills (ios/web/flutter): `reference/contract/` paths updated to `reference/contract/builder/`
- `docs/submodule-repo-structure.md`, `docs/core-design-principles.md`, `docs/contract/README.md`: updated to document `contract/<persona>/` grouping pattern

### Fixed
- `scripts/setup-symlinks.sh`: `link_skills()` now filters `extensions/` in addition to `contract/` — prevents `skills.local/extensions/` from being incorrectly symlinked as a skill downstream

---

## [3.36.0] — 2026-04-22

### Changed
- `lib/core/agents/detective/debug-worker.md`: always reports static analysis findings and ranked hypotheses before any instrumentation — asks the user explicitly before spawning `debug-log-worker`, preventing noisy log runs when static analysis already reveals the root cause
- `lib/core/agents/detective/debug-orchestrator.md`: stripped to a thin router — removed duplicated static analysis and hypothesis formation; orchestrator now only scopes the failure to a CLEAN layer/module and routes to the right worker(s), with a consolidation step for multi-worker runs

---

## [3.35.0] — 2026-04-22

### Added
- `lib/platforms/web/CLAUDE-template.md`: `## Stack` section with placeholder comments for backend-type, ORM, auth, styling, testing, and deployment — agents read CLAUDE.md every session so filling this in once propagates choices automatically
- `lib/platforms/web/skills/setup-nextjs-project/SKILL.md`: Step 5 updated to show the Stack table and prompt engineers to fill it in during initial setup

### Changed
- `scripts/setup-packages.sh`: post-install next steps now lists the six specific stack decisions engineers must fill in, replacing the vague "Fill in CLAUDE.md placeholders" message

---

## [3.34.0] — 2026-04-22

### Changed
- `scripts/setup-symlinks.sh`: writes `.claude/config/installed-packages` lockfile on first run, recording all available packages for the platform — ensures subsequent syncs are package-aware without requiring a re-run of `setup-packages.sh`

---

## [3.33.0] — 2026-04-22

### Added
- `lib/platforms/ios-talenta/packages/ios.pkg`: iOS platform package — declares `test-orchestrator` and `pr-review-worker` so package-aware sync manages them correctly
- `scripts/setup-packages.sh`: writes `.claude/config/installed-packages` lockfile after installation — records platform and selected package names for use by sync

### Changed
- `scripts/sync.sh`: package-aware sync — reads lockfile, links only installed packages, removes stale submodule-pointing symlinks automatically; falls back to `setup-symlinks.sh` if no lockfile found
- `packages/builder.pkg`: added `feature-planner` to agents list

---

## [3.32.0] — 2026-04-22

### Added
- `agents/detective/debug-log-worker.md`: new worker — the only detective agent with `Edit` access; supports `MODE=add` (hypothesis-tagged log insertion) and `MODE=remove` (cleanup before commit); enforces a structural tool boundary where orchestrator and debug-worker remain read-only
- `docs/persona/detective.md`: detective persona doc — governing theory (Zeller's Scientific Debugging), step-to-agent mapping, tool boundary rule, handoff contract, CLEAN/SOLID/DRY mapping, and future scaling direction
- `docs/detective-agent-design.md`: design rationale doc — captures decisions on detective persona direction, platform workers vs feature-specific workers approach, and token-efficient feature reference doc structure

### Removed
- `agents/detective/prompt-debug-worker.md`: moved out of detective persona — prompt/agent debugging belongs with the perf evaluation workflow; `perf-worker` callout updated with inline guidance

### Changed
- `agents/detective/debug-worker.md`: updated to spawn `debug-log-worker` instead of referencing removed `debug-add-logs` / `debug-remove-logs` skills
- `docs/persona/`: persona docs moved from `docs/` root into `docs/persona/` folder (`persona-builder.md` → `persona/builder.md`, `persona-detective.md` → `persona/detective.md`)
- `docs/core-design-principles.md`: updated internal links to reflect `docs/persona/` move

---

## [3.31.0] — 2026-04-22

### Added
- `agents/agent-audit-worker.md`: new worker audits structural integrity of a persona, agent, or skill — verifies `related_skills`, orchestrator `agents:` field, `.pkg` agent lists, hook scripts, and reference doc paths resolve to real files on disk
- `agents/agent-migrate-worker.md`: new worker migrates an existing agent or skill file to convention compliance — audits against `reference/agent-conventions.md`, confirms fix plan with user, applies in a single pass, verifies each fix
- `agents/agent-scaffold-worker.md`: new worker (renamed from `scaffold-worker`) for designing and scaffolding new agentic components; gathers four signals before classifying
- `reference/agent-conventions.md`: new internal greppable convention reference — component types, skill types/scopes, valid type×scope combinations, required frontmatter, required sections, model selection, naming, platform-agnosticism rules, Extension Point standard
- `skills/audit/SKILL.md`: `/audit` Type T trigger skill — routes to `arch-review-orchestrator` with `audit` intent
- `skills/migrate/SKILL.md`: `/migrate` Type T trigger skill — routes to `arch-review-orchestrator` with `migrate` intent
- `skills/scaffold/SKILL.md`: `/scaffold` Type T trigger skill — routes to `arch-review-orchestrator` with `scaffold` intent

### Changed
- `agents/arch-review-orchestrator.md`: expanded to coordinate all four specialist workers (`agent-audit-worker`, `arch-review-worker`, `agent-migrate-worker`, `agent-scaffold-worker`) with intent-based routing — spawns only workers the intent requires; adds verification pass after migrate/scaffold scoped to the affected file only
- `agents/agent-scaffold-worker.md`: Step 2 (Classify) now Greps `reference/agent-conventions.md` instead of embedding the decision tree inline; added `user-invocable: false`, `## Search Rules` section, and output verification in Step 7
- `agents/arch-review-worker.md`: added `user-invocable: false`, normalized `## Search Rules` heading, fixed Extension Point path (removed `.claude/` prefix for repo agent)
- `docs/core-design-principles.md`: removed Delivery Mechanism and Folder Design Rationale sections (repo structure content, moved to submodule-repo-structure.md)
- `docs/submodule-repo-structure.md`: added Delivery Mechanism section and Folder Design Rationale (moved from principles); removed D8 Token Efficiency (agent design principle, covered in principles P5); removed dangling Doc Sync System heading; updated stale What Goes Where table rows
- `docs/evaluation/` and `docs/perf-report/`: consolidated from root-level `evaluation/` and `perf-report/` into `docs/` — all active pointers updated across agents, skills, and lib files

### Removed
- `agents/docs-sync-worker.md`: Confluence sync no longer needed as a dedicated internal agent
- `skills/docs-identify-changes/SKILL.md`: companion skill to docs-sync-worker; removed as orphaned

---

## [3.30.0] — 2026-04-21

### Added
- `skills/scaffold.md`: new `/scaffold` trigger skill — entry point that invokes `agent-scaffold-worker` to generate CLEAN layer scaffolding
- `agents/agent-scaffold-worker.md` (renamed from `scaffold-worker.md`): aligned naming with agent-prefixed convention

### Changed
- `packages/*/package.json`: `hooks` field now supported — builder package declares `require-feature-orchestrator` hook
- `scripts/register-hooks.sh` (and related setup scripts): hooks registered in `settings.json` using relative paths instead of absolute paths
- `scripts/setup-packages.sh`, `scripts/setup-symlinks.sh`: settings template renamed from `settings-template.json` to `settings-template.jsonc`

### Fixed
- `scripts/sync.sh`: falls back to `git pull` when `.claude/software-dev-agentic` is a plain clone (not a submodule), preventing sync failures in flat-clone setups

---

## [3.29.0] — 2026-04-21

### Changed
- `scripts/setup-symlinks.sh`, `scripts/setup-packages.sh`, `scripts/local-setup-symlinks.sh`, `scripts/local-setup-packages.sh`: CLAUDE.md handling changed from skip-if-exists to append-if-absent — when a `CLAUDE.md` already exists, the platform-specific `<!-- BEGIN software-dev-agentic:<platform> -->` / `<!-- END software-dev-agentic:<platform> -->` block is appended instead of skipped; re-running is idempotent (skips if marker already present); works for all platforms via the `$PLATFORM` variable

---

## [3.28.0] — 2026-04-20

### Changed
- `docs/core-design-principles.md`: extracted Goals, Core Design Decision, Three Consumer Modes, Context Cost Analysis, DI at Skill Level, and Layer Isolation into the principles doc as the single source of truth; removed `isolation: worktree` references
- `docs/submodule-repo-structure.md` (renamed from `shared-submodule-arch.md`): now a pure structural reference — all principles moved to core doc; agent/skill names genericized; setup section merged back in
- `docs/changelog-submodule-repo-structure.md` (renamed from `changelog-shared-submodule-arch.md`)

### Added
- **Layer Isolation** principle (P2): workers have bounded knowledge and write authority — each worker knows only its CLEAN layer's rules and writes only to that layer's files

### Removed
- `isolation: worktree` removed from all orchestrators (`arch-review-orchestrator`, `scaffold-worker`, `debug-orchestrator`, `test-orchestrator`) and from the `arch-check-conventions` checklist — layer isolation in this system means knowledge/authority boundaries, not git worktree isolation

---

## [3.27.0] — 2026-04-20

### Changed
- `docs/core-design-principles.md`: restructured for clarity — down from 652 to ~420 lines, 16 principles consolidated to 9; taxonomy promoted to P4 with `####` subsections; orchestrators/memory/naming folded into P2; skills preloading/types folded into P3; delegation rule folded into P1; trigger skill added as second valid entry point; P2 orchestrator section trimmed from 10-step spec to 5 rules; P6 folder structure details moved to arch doc
- `docs/shared-submodule-arch.md`: removed Examples and Open Items sections; principle reference table synced with renumbering

### Added
- `docs/changelog-core-design-principles.md`: version history extracted from core-design-principles.md
- `docs/changelog-shared-submodule-arch.md`: version history extracted from shared-submodule-arch.md
- `docs/persona-builder.md`: new doc consolidating all builder-specific content — agent/skill rosters, layer mapping, execution examples, CLEAN/SOLID/DRY, delegation threshold, implementation reference, open items

---

## [3.26.0] — 2026-04-20

### Fixed
- `lib/core/agents/detective/debug-worker.md`: added "Third-Party Library Investigation" rule to Search Protocol — use `Grep -rn` before any `find`/`ls` in node_modules or vendor directories; Grep for a related symbol from the error message when the target pattern is unknown; never navigate a vendor directory speculatively with directory listings
- `lib/core/agents/builder/feature-orchestrator.md`: extended Explore Agent Grep-First Rule with a dynamic pattern exception — Tailwind template strings and runtime-assembled identifiers cannot be matched by literal Grep; in those cases use Glob + targeted Read and require the exploration prompt to document the reason for skipping Grep

### Changed
- `perf-report/xpnsio-2026-04-19-305f9697-split-bill-dropdown-bg-fix.md`: D5 6→8, D6 4→5, Overall 6.7→7.1 — branch routing revised; user-initiated "create issue and pick up" from `main` is intentional; missing PR remains the sole D6 finding
- `perf-report/xpnsio-2026-04-19-e6748dd1-fix-skeleton-height-classes.md`: D5 4→8, D6 3→7, Overall 6.1→7.3 — starting on `main` was correct for the workflow; mid-session branch switch + PR creation was the right sequence

### Added
- `evaluation/11-d5-workflow-intent-and-vendor-grep-first.md`: documents three observations from xpnsio sessions #97 and #99 — D5/D6 false penalisation for user-initiated main-branch workflow, node_modules `find`/`ls` token overhead (~31% of session), and the dynamic class name gap in the Grep-first rule

---

## [3.25.1] — 2026-04-19

### Fixed
- `lib/core/hooks/require-feature-orchestrator.sh`: redirect all block output to stderr (`>&2`) — Claude Code reads stderr for hook messages; stdout is silently discarded, which caused "No stderr output" and Claude falling back to plain-text instead of invoking `AskUserQuestion`

---

## [3.25.0] — 2026-04-19

### Fixed
- `lib/core/hooks/require-feature-orchestrator.sh`: replaced fragmented `echo` block with a `cat <<'EOF'` heredoc that opens with an imperative mandate ("You MUST call the AskUserQuestion tool RIGHT NOW — do not respond in plain text") followed by the exact JSON input; previous format caused Claude to paraphrase the options as prose instead of invoking the tool

### Changed
- `lib/core/agents/builder/feature-planner.md`: both `AskUserQuestion` call sites (pre-flight resume check and Phase 5 confirm) now specify the full call structure — `question`, `header`, `multiSelect`, `options[].label`, `options[].description` — instead of vague "Present using AskUserQuestion" prose
- `lib/core/agents/builder/feature-orchestrator.md`: pre-flight resume check `AskUserQuestion` call now specifies full call structure consistently with feature-planner

---

## [3.24.2] — 2026-04-19

### Added
- `docs/contract/README.md`: index and structural rules for `docs/contract/` — heading format, validation snippet, adding a new platform; extracted from `builder-auditor-schema.md`

### Changed
- `docs/contract/arch-check.md` → `docs/contract/builder-auditor-schema.md`: renamed to reflect dual ownership (builder greps, auditor enforces); keyword tables only — structural rules moved to README
- `skills/arch-check-conventions/SKILL.md`: schema path updated to `docs/contract/builder-auditor-schema.md`
- `docs/contract-schema-improvement-backlog.md`: path references updated

---

## [3.24.1] — 2026-04-19

### Changed
- `docs/contract/schema.md` → `docs/contract/arch-check.md`: renamed to reflect owning persona (`arch-check-conventions` / auditor); `docs/contract/` preserved as home for future persona contracts
- `docs/contract/improvement-backlog.md` → `docs/contract-schema-improvement-backlog.md`: moved to flat `docs/` — backlog doc, not a contract spec
- `skills/arch-check-conventions/SKILL.md`: schema path updated to `docs/contract/arch-check.md`

---

## [3.24.0] — 2026-04-19

### Added
- `docs/contract/schema.md`: contract keyword registry relocated here from `lib/core/reference/clean-arch/` — internal-only spec; no longer ships to downstream projects via symlink
- `docs/contract/improvement-backlog.md`: documents 4 schema gaps confirmed not yet safe to register (pending platform `##` heading alignment): `presentation.md` Events/Input + Actions/Output, `testing.md` Use Case Tests naming reconciliation, `di.md` Scope Rules + Registration Order

### Changed
- `docs/contract/schema.md`: `Services` keyword added to `domain.md` table — substring of `## Services` (web/iOS) and `## Domain Services` (flutter); `arch-check-conventions` now enforces this on all platforms
- `skills/arch-check-conventions/SKILL.md`: schema reference path updated to `docs/contract/schema.md`
- `docs/core-design-principles.md`: `contract-schema.md` removed from P7 "universal theory" list — spec docs are not architecture theory
- `docs/shared-submodule-arch.md`: same — removed from Decision 4 universal theory list

### Removed
- `lib/core/reference/clean-arch/contract-schema.md`: misplaced as architecture reference theory; superseded by `docs/contract/schema.md`

---

## [3.23.1] — 2026-04-19

### Fixed
- `lib/platforms/web/skills/contract/data-create-mapper`, `data-create-datasource`, `data-create-repository-impl`, `data-update-mapper`: replaced legacy `§ N.N` section references with canonical `## Heading` Grep pointers
- `lib/platforms/web/skills/contract/pres-create-stateholder`, `pres-create-screen`: replaced `§ 5.x` and `§ 6.2`, `§ 15.6` with canonical `## Heading` Grep pointers across `presentation.md`, `navigation.md`, and `ssr.md`
- `lib/platforms/web/skills/contract/test-create-domain`, `test-create-data`, `test-create-presentation`, `test-update`: replaced `§ 10.x` references with canonical `## Heading` Grep pointers
- `lib/platforms/web/skills/test-create-mock`, `pres-wire-di`, `pres-create-server-action`, `data-create-db-datasource`, `data-create-db-repository`: replaced `§ N.N` references across `testing.md`, `di.md`, `server-actions.md`, and `database.md`

Zero `§` section references remain anywhere in `lib/` — all 29 web skills now use canonical `## Heading` Grep pointers, consistent with iOS and Flutter (fixed in v3.21.0)

---

## [3.23.0] — 2026-04-19

### Added
- `lib/core/reference/clean-arch/data.md`: canonical template for the Data layer — platform-agnostic definitions for DTO, Mapper, DataSource, RepositoryImpl, creation order (remote + local), and layer invariants
- `lib/core/reference/clean-arch/presentation.md`: canonical template for the Presentation layer — StateHolder, State, Events/Input, Actions/Output, StateHolder contract shape, creation order, and layer invariants
- `lib/core/reference/clean-arch/ui.md`: canonical template for the UI layer — Screen, Component/Sub-view, Navigator/Coordinator, DI wiring, creation order, and layer invariants
- `lib/core/reference/clean-arch/di.md`: canonical template for Dependency Injection — five universal DI principles, registration order, scope rules (singleton/feature-scoped/transient), and testing with DI
- `lib/core/reference/clean-arch/testing.md`: canonical template for Testing — test pyramid, what to test per layer, Repository Tests, Mapper Tests, mock-vs-real decision rule, and test naming convention
- `lib/core/reference/clean-arch/error-handling.md`: canonical template for Error Handling — error flow diagram, error types per layer, error mapping table (HTTP → DomainError), error UI patterns, and layer invariants

### Changed
- `lib/core/agents/builder/data-worker.md`: "Data Layer Rules" now points to `reference/clean-arch/data.md` (concepts) and `reference/contract/data.md` (platform syntax); replaced stale `layer-contracts.md § Data Layer` reference
- `lib/core/agents/builder/presentation-worker.md`: removed inline StateHolder concept block (moved to `presentation.md`); "Presentation Layer Rules" now points to `reference/clean-arch/presentation.md` and `reference/contract/presentation.md`
- `lib/core/agents/builder/ui-worker.md`: "UI Layer Rules" now points to `reference/clean-arch/ui.md` and `reference/contract/presentation.md`; replaced stale `layer-contracts.md § UI Layer` reference
- `lib/core/reference/clean-arch/layer-contracts.md`: Data, Presentation, and UI Layer sections slimmed to pointer + summary table — full definitions now live in per-layer canonical templates
- `lib/core/reference/clean-arch/contract-schema.md`: "Currently available" list updated — `data.md`, `presentation.md`, `ui.md`, `di.md`, `testing.md`, `error-handling.md` added
- `lib/platforms/{web,ios,flutter}/reference/contract/data.md`: `> Concepts: reference/clean-arch/data.md` pointer header added to all three platforms
- `lib/platforms/{web,ios,flutter}/reference/contract/presentation.md`: `> Concepts: reference/clean-arch/presentation.md` pointer header added to all three platforms
- `lib/platforms/{web,ios,flutter}/reference/contract/di.md`: `> Concepts: reference/clean-arch/di.md` pointer header added to all three platforms
- `lib/platforms/{web,ios,flutter}/reference/contract/testing.md`: `> Concepts: reference/clean-arch/testing.md` pointer header added to all three platforms
- `lib/platforms/{web,ios,flutter}/reference/contract/error-handling.md`: `> Concepts: reference/clean-arch/error-handling.md` pointer header added to all three platforms

### Fixed
- `lib/platforms/web/skills/contract/domain-create-entity`, `domain-create-repository`, `domain-create-usecase`, `domain-create-service`, `domain-update-usecase`: replaced legacy `§ N.N` section references with canonical `## Heading` Grep pointers — aligns with v3.21.0 convention (iOS and Flutter were already clean)

---

## [3.22.0] — 2026-04-19

### Added
- `lib/core/reference/clean-arch/domain.md`: first per-layer canonical template — platform-agnostic concept definitions for Entity, Repository, UseCase, DomainService, DomainError, creation order, and dependency rule; workers reference this for the "what"; platform contract files implement the "how"

### Changed
- `lib/core/reference/clean-arch/contract-schema.md`: core templates note added — documents that each contract file has a platform-agnostic counterpart in `clean-arch/`; `domain.md` listed as first available
- `lib/core/reference/clean-arch/layer-contracts.md`: Domain Layer section slimmed to summary table + pointer to `clean-arch/domain.md`; full definitions now live in the canonical template
- `lib/platforms/{web,ios,flutter}/reference/contract/domain.md`: stripped to syntax and platform-specific patterns only; generic concept intros and duplicate rule paragraphs removed; `> Concepts: reference/clean-arch/domain.md` header added to each file; canonical `##` headings preserved
- `lib/core/agents/builder/domain-worker.md`: "Domain Layer Rules" now points to `reference/clean-arch/domain.md` (concepts) and `reference/contract/domain.md` (platform syntax); source paths replaced with downstream paths
- `lib/core/agents/builder/{data-worker,presentation-worker,ui-worker,feature-planner}.md`: `lib/core/reference/clean-arch/layer-contracts.md` source paths replaced with `reference/clean-arch/layer-contracts.md` downstream paths
- **`scripts/setup-symlinks.sh`, `scripts/local-setup-symlinks.sh`**: `link_reference` / `copy_reference` generalized — now loop all subdirs and preserve each as a subdir in `.claude/reference/`; previously only `contract/` was handled explicitly; core call updated from `lib/core/reference/clean-arch` to `lib/core/reference` so `clean-arch/` lands at `.claude/reference/clean-arch/` downstream
- `docs/core-design-principles.md` v39, `docs/shared-submodule-arch.md` v18: reference knowledge tier structure documented — `clean-arch/` two-kind distinction (universal theory + layer templates), reference subdir rule, downstream path convention

---

## [3.21.0] — 2026-04-19

### Added
- `lib/core/reference/clean-arch/contract-schema.md`: canonical keyword registry for all 8 contract reference files — defines required `##` headings per file; enforced by `arch-check-conventions`
- `error-handling.md` and `utilities.md` added to `lib/platforms/{flutter,ios,web}/reference/contract/` — contract now has 8 mandatory files on every platform

### Changed
- **Contract heading structure normalized** across all 24 contract files (8 files × 3 platforms): `#` platform+topic title, `##` canonical keyword sections (agent-greppable), `###` subsections — agents grep with `^## Keyword` for deterministic lookup without depth guessing
- **`§N` section references removed** from all 37 skills (iOS + Flutter) — replaced with canonical `## Heading` names; agents no longer grep for numbered anchors that don't exist in the files
- **Numbered headings stripped** from all non-contract reference files: web (modular, ssr, server-actions, api-routes, database, project, project-setup, overview) and iOS (project, migration, error-utilities, core-services) and Flutter (project) — `## 12. Project Structure` → `## Project Structure`
- iOS `domain.md`: removed 113-line Overview + Architecture Layers intro sections (moved concept to `project.md`); file now opens directly with `## Entities`
- iOS reference file H1 titles normalized: `# Talenta iOS — Architecture V2: N. Topic` → `# iOS — Topic`; web files (non-contract) gain `# Web — Topic` H1 where missing
- `arch-check-conventions` SKILL: contract schema check updated to grep `^## .*keyword` — `###` depth no longer satisfies the canonical keyword requirement
- `docs/core-design-principles.md` v38, `docs/shared-submodule-arch.md` v17: contract file count updated (6 → 8), heading structure rule documented

## [3.20.0] — 2026-04-18

### Added
- `lib/core/skills/plan/SKILL.md`: new `/plan` user-invocable skill — direct entry point to `feature-planner` agent; closes the gap where the planner was only reachable via hook and never actually invoked
- All workers (`domain-worker`, `data-worker`, `presentation-worker`, `ui-worker`, `test-worker`): `## Input` section — required parameter table with `MISSING INPUT` STOP condition on entry
- All workers: `## Scope Boundary` section — declares owned layer and delegation table for out-of-scope tasks; workers STOP and name the correct worker rather than crossing layer boundaries
- All workers: `## Task Assessment` section — standardised skill-vs-direct-edit decision gate; workers default to direct `Read`+`Edit` for scoped changes and only invoke skills for new artifacts or contract changes
- All workers: `## Skill Execution` section — explicit platform path resolution (`lib/platforms/<platform>/skills/<skill>/SKILL.md`), Read SKILL.md, follow as authoritative procedure
- All workers: `## Output` verification — Glob + Grep each artifact before listing path; workers never return paths that don't exist on disk
- All orchestrators (`feature-orchestrator`, `backend-orchestrator`, `pres-orchestrator`): explicit output validation after each worker spawn — STOP if `## Output` section missing or any listed path does not exist on disk

### Changed
- `lib/core/agents/builder/domain-worker.md`, `data-worker.md`, `test-worker.md`: model upgraded from `haiku` to `sonnet` — skill execution requires architectural judgment (path resolution, multi-step instruction following, output verification), not purely mechanical template filling
- `lib/core/agents/builder/feature-orchestrator.md`, `backend-orchestrator.md`, `pres-orchestrator.md`: `platform` parameter added to Phase 0 intake and all worker spawn calls — workers now resolve skill paths deterministically at runtime
- `lib/core/agents/builder/pres-orchestrator.md`, `backend-orchestrator.md`: removed `isolation: worktree` — both orchestrators need shared working tree so uncommitted artifacts (contract file, domain artifacts) are readable across phases
- `lib/core/agents/builder/pres-orchestrator.md`: Phase 3 "Verify Wiring" removed — presentation-layer wiring knowledge moved to `ui-worker` Workflow step 6 where it belongs
- `lib/core/hooks/require-feature-orchestrator.sh`: added post-selection dispatch instructions — hook now tells the agent exactly which agent to invoke per option (`feature-planner`, `feature-orchestrator`, or inline bypass)
- `docs/core-design-principles.md`: v36 — P8 orchestrator contract updated (platform param, output validation gate, worktree exception); P10 fail-fast restructured into four explicit gates; P15 convention table updated (sonnet default, new required worker sections)
- `docs/shared-submodule-arch.md`: v15 — Decision 3 runtime platform param; Decision 8a sonnet for all workers; Decision 8b worktree isolation conditional; Convention Compliance table updated

## [3.19.0] — 2026-04-18

### Fixed
- `lib/core/agents/perf-worker.md` D6: split rules into always-required and conditional — issue tracking and PR creation checks are only applied when the project's CLAUDE.md references an issue workflow; projects without issue tracking are not penalised
- `lib/core/agents/builder/feature-orchestrator.md`: added Path Verification rule — paths must be taken verbatim from Grep output, never inferred from naming conventions
- `lib/core/agents/builder/feature-orchestrator.md`: added Callsite Analysis rule — use `Grep --context=5` for symbol/flag impact discovery instead of per-file Read calls; reduces read:grep ratio and token overhead

---

## [3.18.0] — 2026-04-17

### Fixed
- `lib/core/hooks/require-feature-orchestrator.sh`: block message now outputs the exact `AskUserQuestion` parameter structure (with `questions`, `header`, `options[].label`, `options[].description`) — prose-only instructions caused Claude to fall back to free-text instead of a structured choice dialog
- `lib/core/agents/perf-worker.md` D3: added work-nature classification step before skill-to-artifact alignment — flag/dead-code removal and file deletion now score N/A (8/10) automatically; skill requirements apply only to creation, restoration, and update work; mixed sessions evaluated per-portion

### Added
- `evaluation/09-d3-skill-scoring-and-hook-ask-user-question.md`: documents both fixes — root cause, changes made, and open questions for follow-up

---

## [3.17.0] — 2026-04-17

### Added
- `lib/core/agents/builder/feature-planner.md`: New read-only planning agent — produces a reviewable `plan.md` per layer before any code is written; reads `layer-contracts.md` + Explore agent for existing conventions; does not set `delegation.json`; consumed by `feature-orchestrator` pre-flight on approval
- `lib/core/reference/clean-arch/layer-contracts.md`: Single source of truth for all four Clean Architecture layers — artifact types, creation order, inter-layer dependencies, and invariants; replaces inline rule lists in workers
- `lib/core/reference/README.md`: Grep-optimized taxonomy doc for agents — placement rules for reference vs agent body vs skills, directory map, access rules

### Changed
- `lib/core/agents/builder/feature-orchestrator`: Added Approved Plan Check pre-flight — detects `status: approved` in `plan.md` and skips Phase 0 if found
- `lib/core/hooks/require-feature-orchestrator.sh`: Block now surfaces three options — "Plan first with feature-planner", "Delegate to feature-orchestrator", "Proceed inline"
- `lib/core/agents/builder/domain-worker`, `data-worker`, `presentation-worker`, `ui-worker`: Layer rules sections replaced with pointer lines to `layer-contracts.md`
- `docs/core-design-principles.md`: P7 placement decision rule added (reference vs agent body vs skills); `feature-planner` added to Combined Matrix; builder orchestrator count updated to 5; version v35
- `docs/shared-submodule-arch.md`: `reference/README.md` and `layer-contracts.md` added to reference docs section
- `docs/stakeholder-brief.md`: New "How the Team Is Built" section — personas, orchestrators, workers, skills, and three-tier knowledge taxonomy with placement column

---

## [3.16.0] — 2026-04-17

### Added
- `agents/scaffold-worker`: Consultant-first internal agent — gathers 4 signals (trigger, scope, platform, branching) before classifying and scaffolding any component type (skill, worker, orchestrator, new persona)
- `docs/stakeholder-brief.md`: Non-technical stakeholder brief for software-dev-agentic — mobile-first framing (iOS, Flutter, Android), includes Leave Request walkthrough and real performance data

### Changed
- `lib/core/agents/builder/feature-orchestrator`: Phase 3 now spawns `pres-orchestrator` as sub-orchestrator instead of calling `presentation-worker` and `ui-worker` directly
- `lib/core/agents/builder/pres-orchestrator`: Promoted to sub-orchestrator of `feature-orchestrator`; dual-mode (standalone vs sub-orchestrator), path-only handoff to `ui-worker`, state file writes, Search Protocol section added
- `lib/core/agents/builder/backend-orchestrator`: State file writes added after Phase 1 and Phase 2
- `lib/core/agents/detective/prompt-debug-worker`: `## Output` section added
- `docs/core-design-principles.md`: Full taxonomy section added — Agents by Role/Scope, Persona definition, Skills by Type (A/B/T/U) and Scope (Toolkit/Platform-contract/Platform-only/Project/Repo), Type × Scope intersection matrix; pres-orchestrator hierarchy reflected in Combined Matrix

---

## [3.15.0] — 2026-04-17

### Added
- `lib/core/agents/detective/prompt-debug-worker`: New worker that diagnoses why an agent underperformed — feeds its system prompt and perf-worker trajectory back to Claude to surface ambiguous instructions, missing context, and contradicting rules
- `docs/core-design-principles.md`: Full Core Design Principles doc (v31) — local source of truth, replaces agent-architecture.md; Confluence is now the published view
- `docs/shared-submodule-arch.md`: Full Shared Submodule Architecture doc (v14) — local source of truth
- `docs/README.md`: Index of docs/ with Confluence links and edit workflow

### Changed
- `lib/core/agents/perf-worker`: New Step 5 — when any D1–D7 dimension scores below 7, report flags the underperforming agent file and points to `prompt-debug-worker`
- `skills/arch-check-conventions`: Prompt Clarity Check category added (Warning) — flags ambiguous scope, missing stop conditions, contradicting rules, undefined failure paths
- `CLAUDE.md`: Trimmed from 1.1k to ~550 tokens — structure tree replaced with pointer to docs/; frontmatter examples condensed to prose

### Removed
- `docs/agent-architecture.md`: Superseded by `docs/core-design-principles.md`

---

## [3.14.0] — 2026-04-16

### Fixed
- `require-feature-orchestrator.sh`: Branch guard widened from `feat/*`/`feature/*` allowlist to "not main or develop" blocklist — `fix/*` and all other work branches now correctly require feature-orchestrator delegation before editing feature directories

### Added
- `evaluation/08-fix-branch-delegation-guard-gap.md`: Documents the fix branch delegation gap found in xpnsio sessions #91 and #93 (both scored Fair due to inline edits on `fix/*` branches)
- `evaluation/README.md`: Backfilled entries 07 and 08 in the log table

---

## [3.13.0] — 2026-04-15

### Added
- `ui-worker`: Component Reuse Check protocol — Grep existing shared components before creating new ones; gates create vs. reuse vs. extend decision
- `reference/presentation.md` (iOS, web, Flutter): `Shared Component Paths` section with platform-specific search paths for component reuse discovery
- `feature-orchestrator`: Explore Agent Grep-first rule — when spawning Explore agents, must include explicit Grep-first instructions and return structured path list
- `CLAUDE-template.md` (web): Agent Spawning Rules section with Explore Grep-first guidance
- `CLAUDE-template.md` (web): Known Configurations section documenting Tailwind v4 `@source` directive fix

### Changed
- `feature-orchestrator`: Replaced single-line inline-write constraint with prominent `ZERO INLINE WORK` block — no Edit, Write, or file-writing Bash calls, regardless of scope
- `domain-worker`, `data-worker`, `presentation-worker`, `ui-worker`: Added read-once rule to Search Protocol — read a file once, form a complete edit plan, apply in a single Edit call

---

## [3.12.0] — 2026-04-16

### Added
- `lib/platforms/flutter-mobile-talenta/`: full Flutter platform implementation — Clean Architecture + BLoC
  - `reference/`: 8 project-agnostic knowledge docs (domain, data, presentation, di, testing, navigation, project, error-handling)
  - `skills/`: 19 platform skills for core workers (domain, data, presentation, test layers)
  - `CLAUDE-template.md`: downstream CLAUDE.md snippet
- `docs/agent-architecture.md`: three-layer model doc (orchestrators → workers → skills) explaining when to use core vs platform workers

### Changed
- `CLAUDE.md`: added `## Agent Architecture` pointer to `docs/agent-architecture.md`; fixed misleading `web/agents/` comment; marked flutter as active

---

## [3.11.0] — 2026-04-16

### Added
- `scripts/manage-packages.sh`: interactive package and hook manager for submodule projects — shows ✓/✗ state for all packages and hooks, toggle by number mid-run
- `scripts/local-manage-packages.sh`: same interactive manager for non-submodule (local copy) projects — takes `--project=` arg, uses `cp` instead of symlinks

### Changed
- `scripts/setup-packages.sh`: hooks now installed as symlinks (previously copied) — hook updates in the submodule propagate automatically; re-running migrates stale copies to symlinks with `migrate` label
- `scripts/local-setup-packages.sh`: hooks always overwritten on re-run (previously skipped) — re-running is now the upgrade path for hook changes
- All hooks (`require-feature-orchestrator.sh`, `block-impl-import-in-presentation.sh`, `lint-on-edit.sh`, `check-use-server.sh`): added disable guard — exits 0 immediately if the hook name is listed in `.claude/config/disabled-hooks`, enabling per-hook toggle without modifying `settings.local.json`

---

## [3.10.1] — 2026-04-16

### Changed
- `lib/core/agents/builder/feature-orchestrator.md`: added `AskUserQuestion` to tools; added "Pre-flight — Resume Check" section — detects existing `state.json` runs and presents a `AskUserQuestion` dialog (Resume / Start new feature) before gathering intent
- `lib/core/hooks/require-feature-orchestrator.sh`: updated block output to instruct Claude to use `AskUserQuestion` for the delegation choice dialog instead of rendering a plain text menu

---

## [3.10.0] — 2026-04-16

### Changed
- `.claude/config/feature-dirs` — `feature-dirs` moved from `.claude/` root into `.claude/config/` to establish a dedicated directory for committed, machine-readable orchestrator config (separate from asset dirs and gitignored `agentic-state/`)
- `lib/core/hooks/require-feature-orchestrator.sh`: updated config path to `.claude/config/feature-dirs`
- All setup/sync scripts (`setup-symlinks.sh`, `setup-packages.sh`, `sync.sh`, `local-sync.sh`, `local-setup-symlinks.sh`, `local-setup-packages.sh`): updated to create `$CLAUDE_DIR/config/`, write/read `config/feature-dirs`, and auto-migrate from `.claude/feature-dirs` if found (smooth v3.9.x → v3.10.x upgrade)
- `lib/core/skills/doctor/SKILL.md`: updated check 6 path to `.claude/config/feature-dirs`

---

## [3.9.0] — 2026-04-16

### Added
- `.claude/feature-dirs` — new plain-text config file (one path fragment per line, `#` comments) that replaces the `## Feature Directories` fenced block in `CLAUDE.md` as the authoritative config for the delegation guard hook
- `scripts/local-setup-symlinks.sh` — non-submodule counterpart to `setup-symlinks.sh`; copies all agents/skills/reference/hooks into a local project, accepts `--platform` and `--project` args, re-running is safe
- `scripts/local-setup-packages.sh` — non-submodule counterpart to `setup-packages.sh`; interactive package picker with copy semantics, accepts `--platform` and `--project` args

### Changed
- `lib/core/hooks/require-feature-orchestrator.sh`: reads feature directories from `.claude/feature-dirs` instead of parsing `## Feature Directories` fenced block in `CLAUDE.md` — simpler grep, no Python regex on markdown
- `lib/core/hooks/require-feature-orchestrator.sh`: added session boundary detection (session_id tracking) previously only present in the iOS hook — new sessions now wipe stale delegation entries immediately rather than waiting for the 4h TTL
- `lib/platforms/ios-talenta/hooks/require-feature-orchestrator.sh`: removed — now identical to core hook after session boundary and `delegation.json` changes; iOS projects fall through to core hook automatically
- `agentic-state/.delegated-<branch-slug>` files replaced by a single `agentic-state/delegation.json` — branch-slug → Unix timestamp entries, atomic writes via `os.replace`; session boundary cleanup clears the JSON object instead of globbing flag files
- Block message in `require-feature-orchestrator.sh` restructured to present numbered choices `[1] Delegate` / `[2] Proceed inline` so Claude surfaces a menu to the user instead of a free-form ask
- `scripts/setup-symlinks.sh`, `scripts/setup-packages.sh`: `settings.local.json` now patched (add `require-feature-orchestrator` hook) when file already exists, instead of skipping — mirrors `sync.sh` behaviour
- `scripts/setup-symlinks.sh`, `scripts/setup-packages.sh`, `scripts/sync.sh`, `scripts/local-sync.sh`: create/migrate `.claude/feature-dirs` during setup; migrate from `## Feature Directories` in `CLAUDE.md` if present, else write platform default (`src` for web, `[AppName]/*` for iOS)
- `lib/platforms/web/CLAUDE-template.md`, `lib/platforms/ios-talenta/CLAUDE-template.md`: `## Feature Directories` section removed — configuration now lives in `.claude/feature-dirs`
- `lib/core/skills/doctor/SKILL.md`: added check 6 — validates `.claude/feature-dirs` exists, has at least one active fragment, and has no unfilled `[AppName]` placeholder

### Fixed
- `scripts/local-sync.sh`: feature-dirs migration now runs before the CLAUDE.md managed-block sync step, which removes `## Feature Directories` from the block; previously migration always missed it
- `scripts/local-sync.sh`: `copy_agents`, `copy_skills`, `copy_reference` now unlink broken or stale symlinks before copying — `cp -f` fails silently when the destination is a broken symlink (e.g. old submodule path that no longer resolves)

---

## [3.8.2] — 2026-04-15

### Changed
- Consolidated agentic runtime state into `.claude/agentic-state/` — delegation flags (`.delegated-*`), session file (`.session-id`), and run artifacts (`runs/`) moved from `.claude/` root into a single subdirectory
- All scripts (`setup-packages.sh`, `setup-symlinks.sh`, `sync.sh`, `local-sync.sh`): mkdir now creates `agentic-state/runs/`; gitignore patch now adds `.claude/agentic-state/` as a single entry
- `lib/core/hooks/require-feature-orchestrator.sh`, `lib/platforms/ios-talenta/hooks/require-feature-orchestrator.sh`: updated FLAG_FILE and SESSION_FILE paths to `agentic-state/`
- `lib/core/agents/builder/feature-orchestrator.md`: delegation flag and run state paths updated to `agentic-state/`
- `lib/core/agents/builder/presentation-worker.md`: stateholder contract path updated to `agentic-state/runs/`
- `lib/core/skills/clear-runs/SKILL.md`: all paths updated to `agentic-state/runs/`
- `README.md`: gitignore recommendation simplified to single `.claude/agentic-state/` entry

---

## [3.8.1] — 2026-04-15

### Fixed
- `scripts/local-sync.sh`, `sync.sh`, `setup-symlinks.sh`: gitignore patch now includes `.claude/.session-id` and `.claude/runs/` alongside `.delegated-*`, matching `setup-packages.sh`

---

## [3.8.0] — 2026-04-14

### Added
- `scripts/local-sync.sh`: new internal script to sync agents/skills/reference/hooks into projects that do not use the submodule pattern — copies files instead of symlinking, accepts `--platform` and `--project` args, all other behaviour identical to `sync.sh`

### Changed
- `perf-worker.md` D2 (Worker Invocation): added layer-to-worker mapping table, cross-layer ordering checks (domain → data → presentation → UI), and input quality check (orchestrator must pass file paths, not contents)
- `perf-worker.md` D3 (Skill Execution): added skill-to-artifact alignment tables for domain/data/presentation layers, direct-write detection (worker bypassing skills), and intra-layer skill sequencing checks

### Removed
- `isolation: worktree` from `feature-orchestrator` worker spawns and CLAUDE-template delegation rule — worktrees required a manual `git pull` after every run and `.claude/worktrees` cleanup; changes now land directly in the current branch

---

## [3.7.0] — 2026-04-14

### Added
- `lib/core/skills/clear-runs/`: new core skill for clearing `.claude/runs/` artifacts
- `lib/platforms/ios-talenta/hooks/`: platform-specific iOS delegation guard hook

### Changed
- `feature-orchestrator`: added Search Protocol — forbids direct `Read` on production source files; orchestrator must remain a pure coordinator and delegate all source investigation to workers
- `CLAUDE-template` (ios + web): delegation rule now requires `isolation: worktree` when invoking `feature-orchestrator`, preventing partial edits from polluting the working tree on failure
- `setup-packages.sh`: improved hook installation (copy with chmod) and extended `.gitignore` patching to include `.session-id` and `runs/`
- `packages/core.pkg`: added `clear-runs` to the default core skill set

---

## [3.6.0] — 2026-04-14

### Added
- `lib/core/agents/perf-worker.md`: standardized `## Effort vs Billing` section in every report — token cost breakdown (USD), per-task token distribution with ✅/❌/⚠️ productivity flags, effort-to-value ratio per deliverable, and key insight paragraph
- `perf-report/talenta-2026-04-14-att-offline-disabled-refactor.md`: agentic performance report for TE-14350 att offline disabled refactor session

---

## [3.5.1] — 2026-04-14

### Fixed
- `lib/core/hooks/require-feature-orchestrator.sh`: branch check now matches both `feat/*` and `feature/*` — iOS projects using `feature/` prefix were silently bypassing the delegation guard
- `lib/core/agents/tracker/issue-worker.md`: feature branch prefix documented as `feat/` or `feature/` — agent now checks existing branches to follow the project convention

---

## [3.5.0] — 2026-04-14

### Added
- Candidate file uploads now organized into nested Google Drive folders using the pattern `{Job Title}/{timestamp} {Candidate Name}/` for easier browsing and per-applicant isolation

---

## [3.4.7] — 2026-04-14

### Fixed
- `lib/core/hooks/require-feature-orchestrator.sh`: block message now explicitly instructs the agent to stop and surface to the user — removes the two-option menu that agents could self-resolve autonomously
- `lib/core/agents/builder/feature-orchestrator.md`: `isolation: worktree` moved inline with each `Spawn <worker>` directive (Phases 1–4) so it cannot be overlooked
- `lib/core/agents/builder/feature-orchestrator.md`: added constraint prohibiting direct `Edit`/`Write` calls from the parent session after the delegation flag is set

---

## [3.4.6] — 2026-04-13

### Changed
- `lib/core/hooks/require-feature-orchestrator.sh`: delegation flag now expires after 4h — stale flags are treated as missing, preventing indefinite hook bypass on interrupted orchestrator sessions
- `lib/core/agents/builder/feature-orchestrator.md`: write epoch timestamp into delegation flag (`date +%s`) instead of empty `touch` to support TTL check
- `lib/core/agents/builder/pres-orchestrator.md`: replace full-file Read of UseCase files with targeted Grep for class/struct definitions and `execute` signatures; only Read if Grep returns no results

---

## [3.4.5] — 2026-04-13

### Changed
- `lib/platforms/ios-talenta/CLAUDE-template.md`: add same delegation guard rule as web — if hook blocks an edit, ask the user inline vs `feature-orchestrator`, never resolve autonomously

---

## [3.4.4] — 2026-04-13

### Changed
- `lib/platforms/web/CLAUDE-template.md`: add session-start rule — if delegation guard hook blocks an edit, always ask the user inline vs `feature-orchestrator`, never resolve autonomously

---

## [3.4.3] — 2026-04-13

### Changed
- `lib/core/hooks/require-feature-orchestrator.sh`: on block, instruct Claude to ask the user whether to proceed inline (create delegation flag) or invoke `feature-orchestrator` — replaces the static "invoke feature-orchestrator" message

---

## [3.4.2] — 2026-04-13

### Fixed
- `lib/core/hooks/require-feature-orchestrator.sh`: actually set executable bit on disk before staging — v3.4.1 release commit used `git add` after `git update-index --chmod=+x`, which overwrote the mode back to `100644` from disk; fix re-applies `chmod +x` on the file itself

---

## [3.4.1] — 2026-04-13

### Fixed
- `lib/core/hooks/require-feature-orchestrator.sh`: set executable bit (`100755`) — was committed as `100644`, causing `Permission denied` on all downstream hook invocations

---

## [3.4.0] — 2026-04-13

### Added
- `lib/core/hooks/require-feature-orchestrator.sh`: new `PreToolUse` hook — blocks inline `Edit`/`Write` on `feat/*` branches when the target file is in a feature directory and no branch-scoped delegation flag exists
- `lib/platforms/ios-talenta/settings-template.json`: new file wiring the delegation guard hook for iOS projects
- `lib/platforms/web/CLAUDE-template.md`, `lib/platforms/ios-talenta/CLAUDE-template.md`: `## Feature Directories` section — hook reads path fragments from here; iOS template uses `[AppName]` placeholder
- `setup-packages.sh`, `setup-symlinks.sh`: `--app-name=` flag + interactive prompt to replace `[AppName]` in CLAUDE.md at setup time
- `setup-symlinks.sh`: core hooks (`lib/core/hooks/`) now linked alongside platform hooks
- `README.md`: `.gitignore` recommendations section — documents `.claude/.delegated-*` pattern

### Changed
- `lib/platforms/web/settings-template.json`: `require-feature-orchestrator.sh` added as first `PreToolUse` hook
- `lib/core/agents/builder/feature-orchestrator.md`: added `Bash` to tools; Pre-flight phase sets branch-scoped delegation flag (`.claude/.delegated-<branch>`); Phase 5 clears it
- Delegation flag is now branch-scoped (`.claude/.delegated-<branch>`) — persists across sessions on the same branch, eliminating false blocks on continuation sessions

---

## [3.3.0] — 2026-04-13

### Changed
- `README.md`: rewritten for two setup personas (new project vs. existing project) — removed AI agent setup instructions, seed file manifest, and stack tables that belong in reference docs
- `web/CLAUDE-template.md`: added mandatory feature routing rule — feature work (create or update, any scope) must always delegate to `feature-orchestrator`, never inline
- `ios/CLAUDE-template.md`: same mandatory routing rule added for iOS platform

---

## [3.2.0] — 2026-04-13

### Changed
- `feature-orchestrator`: description now includes `update`, `modify`, `extend` — routes correctly when updating an existing feature (D2 fix)
- `feature-orchestrator`: Phase 0 adds "New or update?" question — update sessions only run workers for changed layers
- `feature-orchestrator`: Phase 5 renamed to "Wrap Up" — now runs `gh pr create` if no open PR exists (D6 fix)
- `perf-worker`: filename convention now includes first 8 chars of `session_id` between date and description — prevents collisions when project, date, and description are identical

### Added
- All builder workers (`domain-worker`, `data-worker`, `presentation-worker`): `## Validation Protocol` — run type checker once, fix in one pass, confirm clean, never loop more than twice (D7 fix)
- `evaluation/03-worker-routing-and-validation.md` — documents findings and fixes from the 2026-04-13 xpnsio session

---

## [3.1.0] — 2026-04-13

### Changed
- All workers: `## Search Rules` replaced with `## Search Protocol` decision gate table — agents must answer "full file or symbol?" before any Read call (P7 enforcement)
- All builder workers: `## Output` section added as a required contract — one path per line, no prose
- `feature-orchestrator`: writes `.claude/runs/<feature>/state.json` after each phase for mid-run resumability (P4)
- `presentation-worker`: writes StateHolder contract to `.claude/runs/<feature>/stateholder-contract.md`; returns only the path (P8 fix)
- `feature-orchestrator`: passes only the contract file path to `ui-worker` — not content (P8 fix)

### Added
- `evaluation/02-context-efficiency-round-2.md` — investigation documenting xpnsio session findings and the four fixes applied

---

## [3.0.2] — 2026-04-12

### Fixed
- `scripts/setup-symlinks.sh` — hooks were never symlinked into `.claude/hooks/`; script now creates the directory and links each `.sh` file

---

## [3.0.1] — 2026-04-12

### Fixed
- `lib/platforms/ios-talenta/skills/test-fix/` — stale reference `testing-patterns.md` → `testing-patterns-advanced.md`
- `lib/platforms/ios-talenta/skills/migrate-usecase/` — stale reference `domain-layer.md` → `domain.md`

---

## [3.0.0] — 2026-04-12

### Changed
- **`core/` and `platforms/` moved into `lib/`** — all distributable content now lives under `lib/core/` and `lib/platforms/`. **Breaking**: downstream projects must re-run `setup-symlinks.sh` or `setup-packages.sh` after updating the submodule pointer.
- `scripts/setup-symlinks.sh`, `setup-packages.sh`, `sync.sh` — all path references updated to `lib/core/` and `lib/platforms/`
- All agents and skills with path references updated (`arch-review-orchestrator`, `arch-review-worker`, `setup-worker`, `setup-nextjs-project`, `setup-ios-project`, `arch-check-conventions`, `docs-identify-changes`)
- `CLAUDE.md` structure updated to reflect `lib/` layout

---

## [2.1.0] — 2026-04-12

### Added
- `core/agents/installer/` — installer persona group: `setup-worker` (platform-agnostic project setup + onboarding)
- `platforms/ios/skills/setup-ios-project/` — iOS project setup skill (copies CLAUDE-template, prompts for placeholders, creates agents.local stub)

### Changed
- `platforms/web/skills/setup-nextjs-project/` — now `user-invocable: false`; called by `setup-worker`; orientation content removed (worker handles that); step numbering fixed; agents.local reference updated to `arch-review-worker`
- `packages/core.pkg` — `setup-worker` added to always-installed agents
- `platforms/web/CLAUDE-template.md` — `setup-worker` added to agents list
- `platforms/ios/CLAUDE-template.md` — `setup-worker` added to agents list

### Removed
- `HINTS.md` — replaced by `setup-worker` orientation output and `CLAUDE-template.md` agents list

---

## [2.0.0] — 2026-04-12

### Added
- `core/agents/builder/` — builder persona group: `feature-orchestrator`, `backend-orchestrator`, `pres-orchestrator`, `domain-worker`, `data-worker`, `presentation-worker`, `ui-worker`, `test-worker`
- `core/agents/detective/` — detective persona group: `debug-orchestrator`, `debug-worker`
- `core/agents/tracker/` — tracker persona group: `issue-worker`
- `core/agents/auditor/` — auditor persona group: `arch-review-worker` (platform-agnostic)
- `packages/builder.pkg`, `packages/detective.pkg`, `packages/auditor.pkg` — selective installation via `setup-packages.sh`
- `platforms/web/skills/arch-check-web/` — web-specific CLEAN rules (W1–W6: import direction, hook exposure, ViewModel patterns, directive placement, Server Actions, Atomic Design)
- `platforms/ios/skills/arch-check-ios/` — iOS-specific CLEAN rules (I1–I4: layer imports, legacy folder violations, UseCase bypass, RepositoryImpl placement)
- `agents/arch-review-orchestrator.md` — internal convention review orchestrator (not symlinked to downstream projects)
- `agents/arch-review-worker.md` — internal convention review worker; runs `arch-check-conventions` per file
- `skills/arch-check-conventions/` — full convention checklist: frontmatter, Grep-first, isolation, model selection, platform-agnosticism, Fix F, Fix G, naming
- `skills/arch-generate-report/` — formats raw convention findings into severity-grouped report
- `agents/docs-sync-worker.md` — manual Confluence sync worker; applies targeted section updates after sessions that change structure or conventions
- `skills/docs-identify-changes/` — maps session delta descriptions to stale Confluence doc sections

### Changed
- `core/agents/` restructured from flat to persona subdirectories — **breaking**: downstream projects must re-run `setup-symlinks.sh` or `setup-packages.sh` to pick up the new paths
- `setup-packages.sh` — new Step 2: core agent group selection (builder / detective / auditor) before platform packages
- `setup-symlinks.sh` — `link_agents()` now recurses into persona subdirectories; all agents still land flat in `.claude/agents/`
- `core/agents/auditor/arch-review-worker.md` — rewritten as platform-agnostic; universal CLEAN rules U1–U5 in body; platform rules delegated to `arch-check-web` and `arch-check-ios` skills
- iOS platform skills (20 files) — corrected broken reference filenames (`domain-layer.md` → `domain.md`, `data-layer.md` → `data.md`, `testing-patterns.md` → `testing-patterns-advanced.md`); Grep-first added to all reference reads
- `platforms/ios/agents/test-orchestrator.md` — added `isolation: worktree` and `## Search Rules` section
- `platforms/ios/agents/pr-review-worker.md` — added `## Search Rules` section
- `core/agents/builder/pres-orchestrator.md` — added `isolation: worktree` to Constraints
- `core/agents/detective/debug-orchestrator.md` — added `isolation: worktree` to Constraints

---

## [1.2.1] — 2026-04-11

### Fixed
- `perf-worker` — reports now write to `web-agentic/perf-report/` (submodule) instead of downstream project's `journey/`; worker commits and pushes from inside `.claude/web-agentic/`
- `perf-worker` — report filename now follows `[project]-[YYYY-MM-DD]-[short-session-description].md` pattern for cross-project readability in git log

---

## [1.2.0] — 2026-04-11

### Added
- `agents/perf-worker.md` — agentic performance analyst; reads extracted session JSON, scores 7 dimensions (orchestration, worker invocation, skill execution, token efficiency, routing accuracy, workflow compliance, one-shot rate) with numeric scores, writes report to `journey/` and commits it
- `skills/agentic-perf-review/SKILL.md` — user-invocable `/agentic-perf-review <issue> [session_id]` slash command; extracts session data then spawns perf-worker for isolated analysis
- `scripts/extract-session.sh` — parses a Claude Code session JSONL into structured JSON (token totals, tool call frequencies, agent spawns, skill calls, duplicate reads, read:grep ratio); auto-detects current session or accepts explicit session ID
- `journey/` — serialized log of agentic design observations and improvements; entry 01 documents token optimization investigation against Core Design Principles

---

## [1.1.0] — 2026-04-10

### Added
- `/doctor` skill — flutter-doctor-style setup audit: checks submodule staleness, agent/skill symlinks (including broken links), CLAUDE.md managed markers, settings.local.json placeholder, and GitHub CLI auth
- `setup-packages.sh` — interactive package installer; presents a menu of packages, always installs core, lets user select orchestrator bundles (feature, backend, debug, arch-review)
- `packages/` directory with `.pkg` manifests defining agent + skill dependencies per package; orchestrator packages automatically include all dependent workers and skills

### Changed
- `CLAUDE-template.md` — added `<!-- BEGIN web-agentic -->` / `<!-- END web-agentic -->` managed section markers
- `setup-symlinks.sh` — copies `CLAUDE-template.md` → `CLAUDE.md` on first run if no CLAUDE.md exists
- `sync.sh` — replaces only the managed section in downstream `CLAUDE.md` on each sync, leaving platform-specific content untouched
- `CLAUDE.md` workflow instructions — replaced `@issue-worker` with plain `issue-worker` to avoid spurious Skill tool lookup errors

---

## [1.0.0] — 2026-04-10

### Changed
- **Agent architecture**: Refactored from 5 flat agents to 2 orchestrators + 6 workers following Core Design Principles
  - `feature-scaffolder` → `feature-orchestrator` (coordinates domain/data/presentation workers)
  - `backend-scaffolder` → `backend-orchestrator` (coordinates domain/data workers for full-stack)
  - `arch-reviewer` → `arch-review-worker`
  - `test-writer` → `test-worker`
  - `debug-agent` → `debug-worker`
  - NEW: `domain-worker`, `data-worker`, `presentation-worker` (split from feature-scaffolder)
- **Skill classification**: All skills now typed as Type A (`user-invocable: false`) or Type B (`disable-model-invocation: true`) — no Type C
- **Skill naming**: Layer-prefixed convention (`domain-*`, `data-*`, `pres-*`, `test-*`)
- **Skill content**: Bodies slimmed to ~30 lines; code templates extracted to `template.md` files
- **Natural language routing**: Skills are agent-only (Type A) — users describe intent, Claude routes to the right agent
- **Extension hooks**: Every agent ends with an extension point for `.claude/agents.local/extensions/`

### Added
- `domain-create-entity`, `domain-create-usecase`, `domain-create-repository`, `domain-create-service` skills
- `data-create-mapper`, `data-create-datasource`, `data-create-repository-impl`, `data-create-db-datasource`, `data-create-db-repository` skills
- `pres-create-viewmodel`, `pres-create-view`, `pres-create-server-action`, `pres-wire-di`, `pres-ssr-check` skills
- `test-create-mock`, `test-create-domain`, `test-create-data`, `test-create-presentation` skills

### Removed
- Old flat agent files: `feature-scaffolder`, `backend-scaffolder`, `arch-reviewer`, `test-writer`, `debug-agent`
- Old skill directories: `new-entity`, `new-usecase`, `new-feature`, `new-viewmodel`, `new-server-action`, `new-db-repository`, `scaffold-repository`, `scaffold-service`, `create-mock`, `write-tests`, `integration-test`, `ssr-check`, `wire-di`

---

## [0.1.0] — 2026-04-10

### Added
- Initial release of the Next.js Clean Architecture starter kit
- Architecture reference docs (`reference/`) covering domain, data, presentation, DI, testing, SSR, server actions, database, API routes, error handling, navigation, utilities, and modular structure
- Agent definitions: `feature-scaffolder`, `arch-reviewer`, `test-writer`, `debug-agent`, `backend-scaffolder`
- Skills: `new-feature`, `new-entity`, `new-usecase`, `new-viewmodel`, `write-tests`, `ssr-check`, `wire-di`, `create-mock`, `scaffold-service`, `scaffold-repository`, `integration-test`, `create-issue`, `pickup-issue`, `new-server-action`, `new-db-repository`, `setup-nextjs-project`
- Hooks: `block-impl-import-in-presentation.sh`, `lint-on-edit.sh`, `check-use-server.sh`
- `CLAUDE-template.md` for project-level Claude instructions
- `settings-template.json` with hooks pre-wired
- `README.md` with AI Project Setup flow
- `HINTS.md` quick reference guide
