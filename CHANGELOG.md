# Changelog

All notable changes to this starter kit will be documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

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
- `setup-symlinks.sh`, `sync.sh`, `setup-packages.sh`: prune dangling `reference/` symlinks recursively — all three scripts previously skipped `reference/` in their prune step, causing broken nested symlinks (e.g. `reference/builder/`, `reference/contract/builder/`) to survive re-runs because `link_if_absent` skips existing symlinks even when dangling

## [3.40.8] — 2026-04-23

### Fixed
- `setup-symlinks.sh`: correct relative path depth in recursive `link_reference` — symlinks inside subdirectories (e.g. `reference/builder/`, `reference/contract/builder/`) were one `../` too shallow, causing broken symlinks in downstream projects
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
- `lib/core/reference/clean-arch/` → `lib/core/reference/builder/`: renamed to align reference dir naming with the persona taxonomy — all files in this dir are owned and consumed by the builder persona
- `lib/platforms/{ios,web,flutter}/reference/contract/*.md` → `reference/contract/builder/*.md`: contract reference docs grouped under a persona subdir to make room for future personas (e.g. `contract/detective/`) without restructuring
- `scripts/setup-symlinks.sh`: `link_reference` made fully recursive — handles any depth of subdir nesting; `contract/builder/` and future persona subdirs land downstream automatically with no further script changes
- `scripts/local-sync.sh`: `copy_reference` made fully recursive to match; core reference call updated to pass `lib/core/reference/` root so `builder/` is preserved as a subdir rather than copied flat
- All builder agents (`domain-worker`, `data-worker`, `presentation-worker`, `ui-worker`, `test-worker`, `feature-planner`): Grep paths updated to `reference/builder/` and `reference/contract/builder/`
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
- `lib/platforms/ios/packages/ios.pkg`: iOS platform package — declares `test-orchestrator` and `pr-review-worker` so package-aware sync manages them correctly
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
- `lib/platforms/flutter/`: full Flutter platform implementation — Clean Architecture + BLoC
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
- `lib/platforms/ios/hooks/require-feature-orchestrator.sh`: removed — now identical to core hook after session boundary and `delegation.json` changes; iOS projects fall through to core hook automatically
- `agentic-state/.delegated-<branch-slug>` files replaced by a single `agentic-state/delegation.json` — branch-slug → Unix timestamp entries, atomic writes via `os.replace`; session boundary cleanup clears the JSON object instead of globbing flag files
- Block message in `require-feature-orchestrator.sh` restructured to present numbered choices `[1] Delegate` / `[2] Proceed inline` so Claude surfaces a menu to the user instead of a free-form ask
- `scripts/setup-symlinks.sh`, `scripts/setup-packages.sh`: `settings.local.json` now patched (add `require-feature-orchestrator` hook) when file already exists, instead of skipping — mirrors `sync.sh` behaviour
- `scripts/setup-symlinks.sh`, `scripts/setup-packages.sh`, `scripts/sync.sh`, `scripts/local-sync.sh`: create/migrate `.claude/feature-dirs` during setup; migrate from `## Feature Directories` in `CLAUDE.md` if present, else write platform default (`src` for web, `[AppName]/*` for iOS)
- `lib/platforms/web/CLAUDE-template.md`, `lib/platforms/ios/CLAUDE-template.md`: `## Feature Directories` section removed — configuration now lives in `.claude/feature-dirs`
- `lib/core/skills/doctor/SKILL.md`: added check 6 — validates `.claude/feature-dirs` exists, has at least one active fragment, and has no unfilled `[AppName]` placeholder

### Fixed
- `scripts/local-sync.sh`: feature-dirs migration now runs before the CLAUDE.md managed-block sync step, which removes `## Feature Directories` from the block; previously migration always missed it
- `scripts/local-sync.sh`: `copy_agents`, `copy_skills`, `copy_reference` now unlink broken or stale symlinks before copying — `cp -f` fails silently when the destination is a broken symlink (e.g. old submodule path that no longer resolves)

---

## [3.8.2] — 2026-04-15

### Changed
- Consolidated agentic runtime state into `.claude/agentic-state/` — delegation flags (`.delegated-*`), session file (`.session-id`), and run artifacts (`runs/`) moved from `.claude/` root into a single subdirectory
- All scripts (`setup-packages.sh`, `setup-symlinks.sh`, `sync.sh`, `local-sync.sh`): mkdir now creates `agentic-state/runs/`; gitignore patch now adds `.claude/agentic-state/` as a single entry
- `lib/core/hooks/require-feature-orchestrator.sh`, `lib/platforms/ios/hooks/require-feature-orchestrator.sh`: updated FLAG_FILE and SESSION_FILE paths to `agentic-state/`
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
- `lib/platforms/ios/hooks/`: platform-specific iOS delegation guard hook

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
- `lib/platforms/ios/CLAUDE-template.md`: add same delegation guard rule as web — if hook blocks an edit, ask the user inline vs `feature-orchestrator`, never resolve autonomously

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
- `lib/platforms/ios/settings-template.json`: new file wiring the delegation guard hook for iOS projects
- `lib/platforms/web/CLAUDE-template.md`, `lib/platforms/ios/CLAUDE-template.md`: `## Feature Directories` section — hook reads path fragments from here; iOS template uses `[AppName]` placeholder
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
- `lib/platforms/ios/skills/test-fix/` — stale reference `testing-patterns.md` → `testing-patterns-advanced.md`
- `lib/platforms/ios/skills/migrate-usecase/` — stale reference `domain-layer.md` → `domain.md`

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
