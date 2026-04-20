# Changelog — Shared Agentic Submodule Architecture

**v18 — 2026-04-19 · software-dev-agentic v3.21.0**
- Decision 4: `lib/core/reference/clean-arch/` now holds two kinds of files — universal theory (existing) and per-layer canonical templates (new, starting with `domain.md`). Both preserved as `clean-arch/` subdir downstream. Platform `contract/` files retain syntax only; conceptual definitions moved to core templates.
- Decision 4: "Reference subdir rule" added — all reference source subdirs preserved downstream; any new subdir automatically preserved; agents use downstream paths (`reference/clean-arch/`, `reference/contract/`)
- Decision 6: Symlink table updated — new row for `lib/core/reference/clean-arch/<name>.md` → `.claude/reference/clean-arch/<name>.md` (preserved); note added explaining why reference preserves subdirs while agents/skills do not
- Setup scripts: `link_reference` / `copy_reference` generalized — loop all subdirs (previously hardcoded `contract/` only); core call changed from `lib/core/reference/clean-arch` to `lib/core/reference` so `clean-arch/` is treated as a preserved subdir

**v16 — 2026-04-19 · software-dev-agentic v3.21.0**
- Decision 1: Core-dependency skills now in `lib/platforms/<platform>/skills/contract/` subfolder — makes the mandatory cross-platform contract explicit; platform-only skills remain flat; setup scripts handle both transparently
- Decision 3: Worker skill resolution updated — workers resolve via `.claude/skills/<name>/SKILL.md` (downstream symlink), not `lib/platforms/<platform>/skills/<name>/SKILL.md` source path; runtime platform param still passed for workers needing platform context
- Decision 4: Reference docs split into three tiers — `lib/core/reference/clean-arch/`, `lib/platforms/<platform>/reference/contract/` (six cross-platform files, preserved as `contract/` subdir downstream), flat platform-specific refs; downstream behavior difference from skills documented
- Decision 6: Added table documenting different downstream symlink behavior — skills land flat regardless of `contract/` source grouping; references preserve `contract/` subdir because skill files hard-code that path
- "What Goes Where" table: Platform-contract skill and Platform-only skill rows split; cross-platform contract reference and platform-specific reference rows split
- Examples: Flutter entity creation updated to show both source path (`lib/platforms/flutter/skills/contract/...`) and downstream resolution (`.claude/skills/.../SKILL.md`)
- Principle modifications table: P5 and P7 rows updated with `contract/` subfolder and downstream behavior

**v15 — 2026-04-18 · software-dev-agentic v3.20.0**
- Decision 3: Updated — platform now passed at runtime in every worker spawn prompt, not just resolved via setup-time symlinks; rationale updated to explain dual safety net
- Decision 8a: Updated — all workers now use `model: sonnet`; haiku reserved only for truly mechanical leaf tasks; rationale: skill execution requires architectural judgment (path resolution, SKILL.md reading, output verification)
- Decision 8b: Updated — `isolation: worktree` is conditional, not universal; `pres-orchestrator` and `backend-orchestrator` omit isolation to allow contract file sharing between phases; blackboard violation note added
- Convention Compliance table: Workers row expanded — `## Input`, `## Scope Boundary`, `## Task Assessment`, `## Skill Execution` added as required sections; `## Output` Glob+Grep verification promoted to Critical; Orchestrators row — output validation after each spawn added (Critical); model row updated to sonnet default

**v14 — 2026-04-17 · software-dev-agentic v3.14.0**
- `prompt-debug-worker` added to `lib/core/agents/detective/` — diagnoses why an agent underperformed by analyzing its system prompt against the trajectory from a perf-worker report
- "What Goes Where" table updated: `prompt-debug-worker` listed under detective persona alongside `debug-worker`; `perf-worker` moved from "Meta/observability flat" entry to detective group entry
- Convention Compliance table: Prompt Clarity Check row added (🟡 Warning severity) — flags ambiguous scope, missing stop conditions, contradicting rules, undefined failure paths; points to `prompt-debug-worker` for deeper analysis
- Decision 8a updated: `prompt-debug-worker` listed alongside other `sonnet` reasoning-heavy workers

**v13 — 2026-04-16 · software-dev-agentic v3.4.6**
- Decision 1: Core-dependency skill table added — maps each skill to its calling worker and required platform coverage; Platform-specific skills category defined
- Examples section added: Flutter entity creation (core-dependency skill flow) and iOS PR review (platform-specific skill flow)

**v12 — 2026-04-14 · software-dev-agentic v3.4.6**
- Convention Compliance Internal Reviewer table — Orchestrators row updated: `isolation: worktree` now described as inline with each Spawn directive (not a trailing Constraints entry); new rule added: after delegation flag is set, no direct Edit or Write — file changes through workers only

**v11 — 2026-04-13 · software-dev-agentic v3.0.1**
- Decision 8c: Added orchestrator state file pattern (`.claude/runs/<run-id>/state.json` written after each phase); added stateholder handoff file pattern (`presentation-worker` writes contract to disk, orchestrator passes path only to `ui-worker`)
- Convention Compliance Internal Reviewer table: Workers row updated
- Context Cost Analysis: orchestrator row updated to mention state file

**v10 — 2026-04-12 · software-dev-agentic v3.0.0**
- `lib/` boundary introduced; all paths updated
- Decision 5 added: "`lib/` Boundary — Distributable vs Internal Content"

**v9 — 2026-04-12 · software-dev-agentic v2.1.0**
- `installer/` persona group added; `setup-worker` added to core.pkg

**v8 — 2026-04-12 · software-dev-agentic v2.0.0**
- Added `docs-sync-worker` + `docs-identify-changes` to internal tooling

**v7 — 2026-04-12 · software-dev-agentic v2.0.0**
- Convention Compliance System section added; `arch-review-worker` rewritten as platform-agnostic

**v6 — 2026-04-12 · software-dev-agentic v1.2.x**
- `core/agents/` grouped by persona subdirectories; `.pkg` files added

**v5 and earlier** — See git history in the software-dev-agentic repository.
