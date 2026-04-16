# Changelog

All notable changes to this starter kit will be documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
