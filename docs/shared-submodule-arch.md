> Author: Puras Handharmahua · 2026-04-09
> Updated: 2026-04-18 — v15: Decision 3 runtime platform param; Decision 8a sonnet for all workers; Decision 8b worktree isolation conditional; Convention Compliance table updated with new required worker sections and output validation
> Synced with: software-dev-agentic v3.20.0
> Related: Agentic Coding Assistant — Core Design Principles

## Relationship to Core Design Principles

This document extends the Core Design Principles — it does not replace them. All 15 principles remain in effect. This doc specifically modifies how certain principles are applied in a cross-platform shared submodule:

| Principle | What Changes |
|---|---|
| 5 — Preloaded Skills | Shared skills remain preloaded. Platform-specific skills live in `lib/platforms/<platform>/skills/` — linked at setup time, not loaded on-demand at runtime. |
| 7 — Three-Tier Knowledge | Tier 3 reference docs now live in the shared submodule: `lib/core/reference/clean-arch/` for universal CLEAN principles; `lib/platforms/<platform>/reference/` for platform-specific code patterns. Accessed via Grep-first, never Read in full unless necessary. |
| 8 — Orchestrators Coordinate | Orchestrators AND workers live in `lib/core/agents/` — both platform-agnostic. Platform knowledge lives exclusively in `lib/platforms/<platform>/skills/`. Platform-specific agents (e.g., iOS `test-orchestrator`) live in `lib/platforms/<platform>/agents/` only when the agent itself is inherently platform-specific. |
| 9 — Delegation Threshold | Tasks touching >3 architectural layers must delegate to `feature-orchestrator` with `isolation: worktree`. Inline execution at that scope is a P9 violation. |
| 13 — Naming Convention | Flutter and Android must adopt the `-orchestrator` / `-worker` suffix convention as a prerequisite for migration into the shared submodule. |
| 15 — Convention Enforcement | The repo enforces its own conventions through automated review. Running `arch-review-orchestrator` audits all agents and skills in this repo against the full convention checklist. |

---

## Problem Statement

The Agentic Coding Assistant is currently implemented independently in talenta-ios, mobile-talenta (Flutter), and talenta-mobile-android. All three projects share the same CLEAN architecture, the same layer structure (Domain → Data → Presentation), and the same orchestrator/worker/skill patterns. Maintaining three separate copies means:

- Updates to shared logic must be applied three times
- Improvements discovered in one project don't propagate to others
- Engineers contributing to one project can't leverage work done in another
- The "persona" concept (crash-fixer, PR reviewer, feature builder) has to be rebuilt per-project

web-agentic was the Next.js 15 reference implementation. It has since been restructured and renamed to software-dev-agentic — a multi-platform toolkit now serving as the single shared submodule for all platforms.

---

## Goals

1. **Consistent Agentics across platforms** — same agents, same principles, one source of truth
2. **Easy to maintain** — update once, all projects get it
3. **Open contribution model** — all engineers can explore, create, and PR new agents/skills
4. **Context efficiency** — no wasted tokens on irrelevant content
5. **Encouraging initiatives** — low barrier to propose new "personas" (orchestrators)

---

## Core Design Decision: Shared Submodule

A git repository — software-dev-agentic — serves as the shared submodule. It lives inside each project's `.claude/` directory:

```
/
  .claude/
    software-dev-agentic/    ← submodule
      agents/                ← symlinks only
      skills/                ← symlinks only
```

> **Why inside `.claude/`:** Consistent with existing personal project pattern (`.claude/starter-kit`). All Claude-related content under one boundary. Clean symlink paths: `../software-dev-agentic/` from within `.claude/agents/`. Doesn't pollute project root (iOS/Android roots are already dense).

---

## Key Design Decisions

### 1. DI at Skill Level — All Workers in Core, Platform Knowledge in Skills

**Decision:** All core workers (`domain-worker`, `data-worker`, `presentation-worker`, `ui-worker`, `test-worker`, `debug-worker`, `prompt-debug-worker`) live in `lib/core/agents/` — fully platform-agnostic. Platform knowledge lives exclusively in skills (`lib/platforms/<platform>/skills/`). Platform-specific agents (e.g., iOS `test-orchestrator`, iOS `pr-review-worker`) live in `lib/platforms/<platform>/agents/` only when the agent itself is inherently platform-specific.

**Rationale:** This pushes Dependency Inversion one level deeper — to the skill level:
- Workers define the *protocol* (what CLEAN layer needs building, in what order, with what checks)
- Skills are the *implementations* of that protocol for a specific platform (file paths, templates, framework patterns)

A `domain-worker` is the same brain on iOS (Swift entities) and web (TypeScript interfaces). It calls `domain-create-entity` by name. On iOS, that skill creates a Swift struct at `Talenta/Domain/Entities/`. On web, it creates a TypeScript interface at `src/domain/entities/`. The worker never knows which platform it's on — and doesn't need to.

| Role | Analogy | Location |
|---|---|---|
| Orchestrators | CLEAN Repository Interface | `lib/core/agents/` |
| Workers | CLEAN UseCase | `lib/core/agents/` |
| Skills | CLEAN Repository Implementation | `lib/platforms/<platform>/skills/` |

**Core-dependency skills** — called by core workers. Must be implemented by every platform that wants core agent support. Same name across platforms, different syntax per platform:

| Skill name | Called by | Must exist in |
|---|---|---|
| `domain-create-entity` | `domain-worker` (core) | all platforms |
| `domain-create-repository` | `domain-worker` (core) | all platforms |
| `domain-create-usecase` | `domain-worker` (core) | all platforms |
| `data-create-mapper` | `data-worker` (core) | all platforms |
| `data-create-datasource` | `data-worker` (core) | all platforms |
| `data-create-repository-impl` | `data-worker` (core) | all platforms |
| `pres-create-stateholder` | `presentation-worker` (core) | all platforms |
| `pres-create-screen` | `ui-worker` (core) | all platforms |
| `test-create-domain` | `test-worker` (core) | all platforms |
| `test-create-data` | `test-worker` (core) | all platforms |
| `test-create-presentation` | `test-worker` (core) | all platforms |

**Platform-specific skills** — called by platform agents only. Implemented only by the platform that owns the calling agent. Examples: iOS `review-pr` (called by iOS `pr-review-worker`), iOS `arch-check-ios`.

> **New platform extensibility:** Adding a 4th platform (e.g., React Native, KMP) requires only `lib/platforms/<platform>/skills/` + `lib/platforms/<platform>/reference/` directories. No changes to any agents in `lib/core/agents/`.

---

### 2. Persona Grouping in `lib/core/agents/`

**Decision:** Agents in `lib/core/agents/` are grouped into persona subdirectories. Each persona represents a coherent workflow — agents within a group relate to and can depend on each other. Ungrouped agents (no peers yet) remain flat at `lib/core/agents/`.

Adding a new persona: Create `lib/core/agents/<persona>/`, add worker(s)/orchestrators, create `packages/<persona>.pkg`. The installer picks it up automatically — no script changes needed.

**Rationale:** Grouping by persona makes the directory self-documenting and enables selective installation. Engineers understand which agents serve their workflow before opening a single file.

---

### 3. Setup-Time Platform Resolution — No `.claude/platform` File

**Decision:** The correct platform skill files are linked at project setup time via the `--platform=` flag. There is no `.claude/platform` file — platform identity is baked into the symlinks themselves. At runtime, orchestrators also pass `platform` explicitly in every worker spawn prompt so workers can resolve skill paths without relying solely on symlink structure.

**Rationale:** With workers being platform-agnostic files in `lib/core/agents/`, and skills being the platform-specific layer, setup-time symlinks wire the right skill implementations into `.claude/skills/`. The runtime platform parameter (`web`/`ios`/`flutter`) lets workers resolve `lib/platforms/<platform>/skills/<skill>/SKILL.md` deterministically — a second safety net that works even in repos with non-standard symlink layouts.

Three-pass linking priority: `agents.local` > platform > core (first link wins)

**Result:** `.claude/skills/domain-create-entity/` points to the correct platform skill implementation. `.claude/agents/domain-worker.md` points to the single shared core worker. The worker calls `domain-create-entity` by name and gets the right implementation automatically.

---

### 4. Reference Docs Split by Scope

**Decision:** Reference docs live in two locations within the submodule:
- `lib/core/reference/README.md` — taxonomy doc: placement rules for reference vs agent body vs skills (agentic use)
- `lib/core/reference/clean-arch/` — conceptual, language-agnostic CLEAN Architecture principles (DI containers, domain purity, layer contracts)
- `lib/platforms/<platform>/reference/` — platform-specific patterns with code examples (TypeScript, Swift, Dart)

**Rationale:** Previously all reference docs lived flat in `reference/`. Some (like `di-containers.md`) describe pure CLEAN theory with no code. Others (like `domain.md`, `data.md`) contain TypeScript-specific examples that would confuse an iOS worker. Splitting by scope ensures each platform's skills only load reference docs relevant to their language.

From the downstream project's perspective, all reference docs are accessible as `.claude/reference/<name>.md` — the split is internal to the submodule.

**Grep-first rule (P7 enforcement):** Workers Grep reference files by section keyword before reading in full. If uncertain which file covers a topic, check `reference/index.md` first.

---

### 5. `lib/` Boundary — Distributable vs Internal Content

**Decision:** All content that gets symlinked into downstream projects lives under `lib/`. Internal tooling stays at the repo root.

**Rationale:** The boundary is explicit and self-documenting. `lib/` = the library surface. Everything outside `lib/` is build/repo tooling. Engineers contributing a new agent know exactly which folder it belongs in without needing to know the implicit contract.

---

### 6. Symlink Architecture

**Decision:** `.claude/agents/` and `.claude/skills/` contain only symlinks — never real files. Real files live in `agents.local/` and `skills.local/`.

> The setup scripts recurse into persona subdirectories when linking agents — all agents land flat in `.claude/agents/` regardless of their subdir in the submodule.

---

### 7. Three Modes: Use, Extend, Override

Both agents and skills support three modes:

| Mode | Mechanism | When to use |
|---|---|---|
| Use | shared symlink → submodule agent/skill | works as-is — standard workflow |
| Extend | shared symlink + `*.local/extensions/{name}.md` | need additions without losing submodule updates |
| Override | real file in `*.local/` | fundamentally different behavior needed |

**Agent extension pattern** — every shared agent ends with a standard hook:

```
After completing, check for `.claude/agents.local/extensions/<name>.md` — if it exists, read and follow its additional instructions.
```

Extension files contain only the delta — not a full copy. Updates to the submodule are inherited automatically; extensions just layer on top.

**Override** — create a real file in `agents.local/` (or `skills.local/`) with the same name as a shared agent/skill. The setup script's `link_if_absent` guard skips symlinking the shared version.

---

### 8. Token Efficiency — Mechanical Worker Model, Isolation, and File Path Passing

These decisions were validated through empirical session analysis (wehire Issue #26 and #53, April 2026; xpnsio Issue #73, April 2026) and applied in April 2026.

**8a. Workers use `model: sonnet` by default**
All core workers now use `model: sonnet`. Skill execution requires reading SKILL.md, following multi-step platform-specific instructions, verifying output artifacts, and enforcing layer boundaries — none of which is purely mechanical. `model: haiku` is reserved only for truly mechanical leaf tasks with no architectural judgment. Orchestrators remain on `sonnet`.

**8b. `isolation: worktree` is conditional, not universal**
Orchestrators use `isolation: worktree` only when worker phases do not share uncommitted files. Exception: `pres-orchestrator` and `backend-orchestrator` omit isolation because `presentation-worker` writes the StateHolder contract to disk and `ui-worker` must read it in the same working tree. Applying worktree isolation here would silently break the contract file handoff.

**8c. Orchestrators pass only file paths, never file contents**
Between worker phases, orchestrators receive and forward only the list of created file paths — never file contents. This prevents orchestrator context from accumulating previous workers' outputs across phases.

Orchestrators also write a state file (`.claude/runs/<run-id>/state.json`) after each phase — if a long session loses context mid-run, the orchestrator reads the state file rather than re-reading source artifacts. This was validated by the xpnsio split-bill session (Issue #73) where a missing state file caused a PRD re-read in a 12-hour session.

For the presentation→UI handoff specifically: `presentation-worker` writes the StateHolder contract to `.claude/runs/<run-id>/stateholder-contract.md`. The orchestrator passes only this path to `ui-worker` — never the contract content. `ui-worker` reads the file directly. This closes the only remaining blackboard pattern violation.

**8d. Workers own their own context reads — no Phase 2 in orchestrators**
Orchestrators no longer perform Phase 2 codebase reads (style matching, DI pattern discovery, route structure). Workers do their own targeted reads as part of their workflow. Orchestrators pass only intent (feature name, fields, operations).

---

## Convention Compliance System

software-dev-agentic enforces its own conventions through an automated internal review system. This is separate from the downstream code reviewer (`lib/core/agents/auditor/arch-review-worker.md`) — the internal system reviews *agent and skill files in this repo*, not *application code in downstream projects*.

**Two Distinct Reviewers**

| Reviewer | Location | Audits |
|---|---|---|
| `arch-review-orchestrator` + `arch-review-worker` | `agents/` (repo root) | Agent `.md` files and `SKILL.md` files in this repo — convention compliance |
| `arch-review-worker` | `lib/core/agents/auditor/` | Application code in downstream projects — CLEAN Architecture violations |

> Why separate locations? Root `agents/` and `skills/` are this repo's internal tooling — they are NOT symlinked into downstream projects. `lib/core/agents/` and `lib/core/skills/` ARE symlinked. The distinction prevents internal review tooling from polluting downstream project contexts.

**What `arch-check-conventions` enforces:**

| Category | Rules | Severity |
|---|---|---|
| Frontmatter | `name`, `description`, `model`, `tools` required; `model: sonnet` for all workers (haiku only for truly mechanical leaf tasks) | 🔴 Critical / 🟡 Warning |
| Orchestrators | `agents:` lists only spawned workers; `isolation: worktree` inline with each Spawn directive (omit only when phases share uncommitted files); body passes only file paths between phases; writes state file after each phase; no Phase 2 codebase reads; after delegation flag is set, no direct Edit or Write — file changes through workers only; explicit output validation after each spawn — STOP if `## Output` missing or paths don't exist | 🔴 Critical |
| Workers | `## Input` section with required params table and `MISSING INPUT` STOP condition; `## Scope Boundary` section with owned-layer declaration and delegation table; `## Task Assessment` section — skill vs direct edit gate; `## Skill Execution` section — platform path resolution, Read SKILL.md, follow; `## Search Protocol` with decision gate table; `## Output` section with Glob + Grep verification before listing paths; `## Extension Point` at end; no "Read ... completely" on reference docs | 🔴 Critical / 🟡 Warning |
| Core agent platform-agnosticism | No hardcoded platform paths (`src/domain/`, `Talenta/Module/`, `lib/`, `app/`); no platform framework references as rules (`React`, `Next.js`, `RxSwift`, `UIKit`, `BLoC`, `axios`); no platform language syntax as rules (`'use client'`, `readonly`, `BehaviorRelay`); platform knowledge delegated to a skill | 🔴 Critical |
| Skill frontmatter | `name`, `description`, `user-invocable: false` present | 🔴 Critical |
| Reference reads in skills | Grep-first; no "Read completely"; all referenced paths match actual filenames | 🔴 Critical |
| Fix G | Template files contain only code generation hints — no explanatory/instructional comments | 🟡 Warning |
| Naming | `-orchestrator.md` / `-worker.md`; skill dirs follow `<layer>-<action>-<target>`; persona assignment correct | 🟢 Info |
| Prompt Clarity | No ambiguous scope ("create the X" without specifying interface vs implementation); no instructions spanning two CLEAN layers without a stop condition; no contradicting rules; failure paths specified. For deeper runtime reasoning analysis, run `prompt-debug-worker`. | 🟡 Warning |

**Severity levels:**
- 🔴 Critical — missing required frontmatter, broken reference path, "Read completely" violation, orchestrator missing `isolation: worktree`, platform-specific content in a `lib/core/agents/` file
- 🟡 Warning — wrong model, missing Search Protocol/Output/Extension Point, missing `reference/index.md` hint, explanatory template comments, prompt clarity issues
- 🟢 Info — naming deviation, description could be more specific

**Platform-Agnosticism Rule for `lib/core/agents/`**

> Any `lib/core/agents/` file body that contains hardcoded platform paths, framework references (as rules), or language-specific syntax is a Critical violation. Platform knowledge must be delegated to a skill in `related_skills`.

**Doc Sync System**

After sessions that change structure, conventions, or design decisions, the design docs are synced manually using:

```
"Sync the docs — we added X and Y this session"
```

Flow:
1. Engineer describes what changed in the session
2. `docs-sync-worker` fetches current Confluence pages, verifies repo state via Glob/Grep
3. `docs-identify-changes` maps the delta to specific stale sections
4. Worker applies targeted updates — no full rewrites
5. Version bumped, changelog entry prepended

> Why manual trigger? Doc sync requires judgment about what changed and why. The pattern isn't yet repetitive enough to automate. When it is, `docs-sync-worker` already has the structure to be hooked into `/release`.

---

## "What Goes Where" Decision Rule

| Content | Location | Reason |
|---|---|---|
| Orchestrators (feature-, backend-, pres-, debug-) | `software-dev-agentic/lib/core/agents/builder/` or `detective/` | Platform-agnostic coordination protocol, grouped by persona |
| Core workers (domain-, data-, presentation-, ui-, test-, debug-, prompt-debug-) | `software-dev-agentic/lib/core/agents/builder/` or `detective/` | Platform-agnostic CLEAN layer brains, grouped by persona |
| Tracker (`issue-worker`) | `software-dev-agentic/lib/core/agents/tracker/` | Issue lifecycle management |
| Auditor (`arch-review-worker`) | `software-dev-agentic/lib/core/agents/auditor/` | Architecture review — platform-agnostic CLEAN checker; delegates platform rules to skills |
| Installer (`setup-worker`) | `software-dev-agentic/lib/core/agents/installer/` | Platform-agnostic project setup + onboarding; delegates mechanical steps to platform setup skills |
| Meta/observability (`perf-worker`, `prompt-debug-worker`) | `software-dev-agentic/lib/core/agents/detective/` | Performance analysis + agent prompt debugging |
| Internal repo tooling | `software-dev-agentic/agents/` | Convention reviewer + doc sync worker — NOT symlinked to downstream projects |
| Platform-specific agents (`test-orchestrator`, `pr-review-worker`) | `software-dev-agentic/lib/platforms/<platform>/agents/` | Agent itself is inherently platform-specific |
| Core skills | `software-dev-agentic/lib/core/skills/` | Identical across platforms |
| Platform-specific skills | `software-dev-agentic/lib/platforms/<platform>/skills/` | Platform language/framework specific |
| Internal repo skills | `software-dev-agentic/skills/` | Convention checker, report formatter, doc sync skills — NOT symlinked to downstream projects |
| Universal reference docs | `software-dev-agentic/lib/core/reference/clean-arch/` | Language-agnostic CLEAN theory |
| Platform reference docs | `software-dev-agentic/lib/platforms/<platform>/reference/` | Platform-specific code patterns |
| Project-specific agents | `.claude/agents.local/` | Only relevant to one project |
| Agent/skill extensions | `.claude/*/extensions/` | Additive delta, project-scoped |
| Agent memory | `.claude/agent-memory/` | Project-scoped institutional knowledge |
| `CLAUDE.md` | project root | Project-specific universal rules |
| `settings.json` | `.claude/` | Project-specific Claude config |

> Rule of thumb: if it describes CLEAN architecture theory → `lib/core/`. If it's platform implementation details → `lib/platforms/<platform>/skills/`. If it's project-specific quirks → `.claude/agents.local/`. If it only applies to reviewing or maintaining this repo's own files → root `agents/` or `skills/`.

---

## Examples

**Flutter domain entity creation** — "Create a LeaveRequest entity for Flutter"

```
feature-orchestrator   (core orchestrator)
  └─ domain-worker     (core worker)       ← knows the rules
        └─ domain-create-entity            ← flutter skill, knows the syntax
             lib/platforms/flutter/skills/domain-create-entity/SKILL.md
```

The worker knows the rules (no framework imports, single responsibility). The skill knows the syntax (Dart, `@freezed`, file naming). `domain-create-entity` is a core-dependency skill — it must exist in every platform's `lib/platforms/<platform>/skills/`.

**iOS PR review** — "Review my PR before merging"

```
pr-review-worker       (iOS platform worker)   ← iOS-specific workflow
  └─ review-pr         (iOS platform skill)    ← Swift/UIKit conventions
       lib/platforms/ios/skills/review-pr/SKILL.md
```

`review-pr` is a platform-specific skill — only the iOS platform worker calls it, so it only needs to exist for iOS. No other platform needs to implement it.

---

## Setup & Installation

**Recommended: Interactive Package Installer**

```bash
.claude/software-dev-agentic/scripts/setup-packages.sh --platform=web
.claude/software-dev-agentic/scripts/setup-packages.sh --platform=ios
```

The interactive installer runs in three steps:
- **Step 1 — Always installed (core package):** `issue-worker`, `perf-worker`, `setup-worker`, core skills: `doctor`, `release`, `agentic-perf-review`
- **Step 2 — Core agent groups (your choice):** persona group selection menu
- **Step 3 — Platform packages (your choice):** platform-specific optional packages

**Alternative: Install Everything (no prompts)**

```bash
.claude/software-dev-agentic/scripts/setup-symlinks.sh --platform=web
```

Both scripts are idempotent — re-running never overwrites existing files (`link_if_absent` guard). `setup-symlinks.sh` links all core agents (all persona groups) without asking.

**What the setup scripts do:**
1. Convert any old-style directory symlinks to real directories
2. Create `.claude/agents/`, `.claude/skills/`, `.claude/reference/`, `.claude/agents.local/extensions/`, `.claude/skills.local/extensions/`
3. Pass 1: Link local overrides from `agents.local/` and `skills.local/`
4. Pass 2: Link platform agents, skills, and reference from `lib/platforms/<platform>/`
5. Pass 3: Link core agents, skills, and reference from `lib/core/` (recurse into persona subdirs; skip if name already linked)
6. Make hooks executable
7. Copy `settings-template.json` → `.claude/settings.local.json` if not present
8. Copy `CLAUDE-template.md` → `CLAUDE.md` if not present

> Note: Root `agents/` and `skills/` (internal tooling) are NOT linked to downstream projects. Only content under `lib/` is symlinked.

**`sync.sh` — Adopt Updates**

```bash
.claude/software-dev-agentic/scripts/sync.sh --platform=<platform>
```

1. `git pull` inside the submodule
2. Re-runs `setup-symlinks.sh` (idempotent — new agents/skills get linked, existing overrides preserved)
3. Syncs the managed section in `CLAUDE.md`
4. Prints the commit command to lock in the updated submodule pointer

**Post-setup checklist:**
1. Edit `CLAUDE.md` — fill in `[AppName]` and stack placeholders
2. Edit `.claude/settings.local.json` — replace `PROJECT_ROOT` with your project's `.claude/` absolute path
3. `git add .claude/ && git commit -m "chore: wire software-dev-agentic (<version>)"`

---

## Context Cost Analysis

| Component | Context cost | Mechanism |
|---|---|---|
| Core agents (descriptions) | ~3–5 lines each in main session | Agent tool definition |
| Platform-specific agents (descriptions) | ~3–5 lines each in main session | Agent tool definition |
| Preloaded skills | Loaded at worker startup | `related_skills` field |
| Reference docs | 1 Grep call per section needed | Grep-first in skill/worker body |
| `agents.local/extensions/` | 1 Read call (conditional) | Extension hook in shared agent |
| `skills.local/extensions/` | 1 Read call (conditional) | Extension hook in shared skill |
| Dead weight (unselected groups) | Zero | Persona groups not linked if not selected |
| Orchestrator context accumulation | Minimal — file paths only | Workers return paths, not content; state file prevents re-reads |

---

## Repository Structure

**Per-Project Layout (after `setup-packages.sh --platform=ios`)**

```
/
  .claude/
    software-dev-agentic/    ← submodule
    agents/                  ← symlinks: core + ios platform agents
    skills/                  ← symlinks: ios platform skills
    reference/               ← symlinks: clean-arch + ios reference
    agents.local/
      extensions/
    skills.local/
      extensions/
    settings.local.json
    CLAUDE.md
```

> Root `agents/` and `skills/` (internal tooling) are never symlinked here. Only content under `lib/` reaches downstream projects.

---

## Contribution Workflow

1. Engineer identifies a new agent/skill or improvement
2. PR to `software-dev-agentic` with the new/updated file (under `lib/core/` or `lib/platforms/<platform>/`)
3. Review by peers (same process as any code PR)
4. Merge to main
5. Each project adopts: `./scripts/sync.sh --platform=<platform>`
6. Commit the updated submodule pointer: `git add .claude/software-dev-agentic && git commit -m "chore: update agentic submodule"`

---

## Open Items

| # | Topic | Status |
|---|---|---|
| 1 | Migration: talenta-ios | Agents/skills/reference content copied to `lib/platforms/ios/`. talenta-ios still uses its own copy. Full submodule wiring = separate session. |
| 2 | Versioning | ✅ Resolved — semantic versioning established: v2.0.0 tagged. Confluence pages track `Synced with: software-dev-agentic vX.Y.Z` in header. |
| 3 | Naming alignment | Flutter/Android adopt `-orchestrator` / `-worker` suffix convention — Required before migration |
| 4 | Reference doc splitting | Structural split of `lib/platforms/web/reference/contract/data.md` and `lib/platforms/web/reference/utilities.md` by operation type |
| 5 | Flutter implementation | `lib/platforms/flutter/` is a stub — needs agents, skills, reference docs |

---

## Related Links

- [Agentic Coding Assistant — Core Design Principles](https://jurnal.atlassian.net/wiki/spaces/~611df3da650a26006e44928d/pages/51126370416)
- software-dev-agentic repository

---

## Changelog

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
