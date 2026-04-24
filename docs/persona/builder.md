> Related: Core Design Principles · Shared Agentic Submodule Architecture

## What is the Builder Persona?

The **builder** persona is the primary feature-building workflow. It handles the full CLEAN Architecture build cycle — from domain layer through presentation — across all platforms.

Location: `lib/core/agents/builder/`

---

## Anatomy

The builder persona has two entry skills that both converge on `feature-orchestrator`:

```
User
 │
 ├─ /plan-feature skill (Type T)         — plan-first; sequences planner → approval → worker
 │
 └─ /feature-orchestrator skill (Type T) — direct entry; routes resume vs new, or build-directly
          │
          ▼
    feature-orchestrator                 — coordinates phases; never writes source files
          │
          ▼  (plan-first path)
    feature-planner                      — scopes build; produces plan.md + context.md
      │           │           │
      ▼           ▼           ▼
 domain-       data-       pres-
 planner       planner     planner       — explore each layer in parallel; no source writes
          │
          │  [user reviews and approves plan.md]
          │
          ▼
    feature-worker                       — reads approved plan; executes skills in layer order
          │
          ▼
    platform-contract skills             — concrete artifact creation per platform and layer
```

**Two entry paths — same executor:**

| Entry skill | When to use | Difference |
|---|---|---|
| `/plan-feature` | Complex or cross-layer features; uncertain existing state | Runs `feature-planner` first; user reviews plan before execution begins |
| `/feature-orchestrator` | Known scope; resuming an existing run | Routes directly to `feature-worker`, or lets orchestrator decide |

**Planner phase — parallel sub-planners:**

`feature-planner` spawns all three layer planners simultaneously. Each explores its layer independently and returns a structured findings block. `feature-planner` aggregates the findings into `plan.md` and `context.md`, then stops for human approval.

| Sub-planner | Explores |
|---|---|
| `domain-planner` | Entities, use cases, repository interfaces, domain services |
| `data-planner` | DTOs, mappers, datasources, repository implementations |
| `pres-planner` | StateHolders, screens, components, navigators, key symbols |

**Execution phase — `feature-worker`:**

`feature-worker` is the only agent that writes source files. It reads the approved `plan.md` and calls skills in CLEAN layer order — domain → data → presentation → UI. Each artifact is validated via `Glob` + `Grep` before moving to the next. `state.json` is updated after each artifact so the run is resumable.

**Standalone paths (no orchestrator or planner needed):**

| Task | Path |
|---|---|
| Single known artifact | Worker directly (`domain-worker`, `data-worker`, `presentation-worker`, `ui-worker`) |
| Test generation | `test-worker` directly |
| Targeted edit to existing artifact | Worker with `context.md` Key Symbols if available |

---

## Agent Roster

### Core agents (`lib/core/agents/builder/`)

| Role | Agent | Responsibility |
|---|---|---|
| Orchestrator | `feature-orchestrator` | Full feature build — coordinates planner + feature-worker phases |
| Orchestrator | `pres-orchestrator` | Presentation + UI phase — standalone entry for pres-only tasks |
| Orchestrator | `backend-orchestrator` | Backend API + data layer coordination |
| Planner | `feature-planner` | Pre-build planning — spawns layer planners in parallel, produces plan.md |
| Planner | `domain-planner` | Domain layer exploration — entities, use cases, repository interfaces |
| Planner | `data-planner` | Data layer exploration — DTOs, mappers, datasources, repo implementations |
| Planner | `pres-planner` | Presentation layer exploration — StateHolders, screens, key symbols |
| Worker | `feature-worker` | Plan-driven executor — reads plan.md, calls skills in layer order, validates each artifact |
| Worker | `domain-worker` | Domain layer direct creation — for single known artifacts |
| Worker | `data-worker` | Data layer direct creation — for single known artifacts |
| Worker | `presentation-worker` | Presentation layer creation — StateHolder, state management |
| Worker | `ui-worker` | UI layer creation — screens, components, navigation |
| Worker | `test-worker` | Test generation across all layers |
| Worker | `prompt-debug-worker` | Agent prompt diagnosis from perf reports |
| Worker | `arch-review-worker` | CLEAN Architecture violation review (downstream projects) |

### Platform agents

| Platform | Agent | Why platform-specific |
|---|---|---|
| iOS | `test-orchestrator` | Knows `xcodebuild`, XCTest flow |
| iOS | `pr-review-worker` | Knows Swift/UIKit conventions |

### Internal tooling (NOT symlinked downstream)

| Component | Location | Purpose |
|---|---|---|
| `arch-review-orchestrator`, `arch-review-worker` | `.claude/agents/` | Convention review |
| `arch-check-conventions`, `arch-generate-report` | `.claude/skills/` | Convention checklist, report formatter |

---

## Layer-to-Agent Mapping

| Layer | Planner | Worker | Skills |
|---|---|---|---|
| Domain | `domain-planner` | `domain-worker` | `domain-create-entity`, `domain-create-usecase`, `domain-create-repository`, `domain-create-service` |
| Data | `data-planner` | `data-worker` | `data-create-datasource`, `data-create-mapper`, `data-create-response`, `data-create-repository-impl` |
| Presentation | `pres-planner` | `presentation-worker`, `ui-worker` | `pres-create-stateholder`, `pres-create-screen`, `pres-create-component`, `pres-create-navigator` |
| Test | — | `test-worker` | `test-create-domain`, `test-create-data`, `test-create-presentation` |

---

## Skill Roster (Platform-Contract — all platforms must implement)

| Skill | Called by | Layer |
|---|---|---|
| `domain-create-entity` | `domain-worker`, `feature-worker` | Domain |
| `domain-create-repository` | `domain-worker`, `feature-worker` | Domain |
| `domain-create-usecase` | `domain-worker`, `feature-worker` | Domain |
| `domain-create-service` | `domain-worker`, `feature-worker` | Domain |
| `data-create-mapper` | `data-worker`, `feature-worker` | Data |
| `data-create-datasource` | `data-worker`, `feature-worker` | Data |
| `data-create-repository-impl` | `data-worker`, `feature-worker` | Data |
| `pres-create-stateholder` | `presentation-worker`, `feature-worker` | Presentation |
| `pres-create-screen` | `ui-worker`, `feature-worker` | Presentation/UI |
| `test-create-domain` | `test-worker` | Test |
| `test-create-data` | `test-worker` | Test |
| `test-create-presentation` | `test-worker` | Test |

---

## Agent Count Snapshot

| Category | `lib/core/agents/` | `lib/platforms/ios/agents/` | `lib/platforms/web/agents/` |
|---|---|---|---|
| Orchestrators | 5 in `builder/` + 1 in `detective/` | 1 (`test-orchestrator`) | — |
| Workers | 8 in `builder/` + 2 in `detective/` + 1 in `tracker/` + 1 in `auditor/` + 1 in `installer/` + 1 flat | 1 (`pr-review-worker`) | — |
| Skills (Type A) | — | 29 | 29 |
| Skills (Type B) | — | 2 | 0 |

> This is a point-in-time snapshot. Check `lib/core/agents/` and `lib/platforms/` for the current roster.

---

## Execution Examples

### Builder flows

**Direct action** — "Add import RxSwift to this file" → single-line edit, no agent needed

**Single-layer task** — "Create GetLeaveRequestListUseCase"
→ `domain-worker` spawned directly, assesses preconditions, sequences skills

**Multi-layer task** — "Build the leave request feature"
→ `feature-orchestrator` coordinates 4 workers; passes file paths only; writes state file after each phase

**Intelligent selection** — "Create StateHolder, the UseCase already exists"
→ orchestrator spawns only `presentation-worker`

**Type B skill** — `/migrate-presentation CustomFormScreen`
→ explicit user trigger; prevents accidental migration

**Cross-platform feature** — same CLEAN pattern, each codebase's `domain-worker` applies platform-specific skill

**Standalone worker** — "Review my branch before PR"
→ `pr-review-worker` directly, no orchestrator

**Flutter domain entity creation** — "Create a LeaveRequest entity for Flutter"

```
feature-orchestrator   (core orchestrator)
  └─ domain-worker     (core worker)         ← knows the rules
        └─ domain-create-entity              ← flutter skill, knows the syntax
             source:     lib/platforms/flutter/skills/contract/domain-create-entity/SKILL.md
             downstream: .claude/skills/domain-create-entity/SKILL.md
```

The worker knows the rules (no framework imports, single responsibility). The skill knows the syntax (Dart, `@freezed`, file naming).

**iOS PR review** — "Review my PR before merging"

```
pr-review-worker       (iOS platform worker)   ← iOS-specific workflow
  └─ review-pr         (iOS platform skill)    ← Swift/UIKit conventions
       lib/platforms/ios/skills/review-pr/SKILL.md
```

`review-pr` is a platform-specific skill — only the iOS platform worker calls it, so it only needs to exist for iOS.

### Other persona flows

**Debug flow** *(detective)* — "Why is form submission silently failing?"
→ `debug-orchestrator` gathers context, spawns `debug-worker`

**Agent prompt debugging** *(detective)* — "Why did domain-worker create an implementation instead of an interface?"

```
perf-worker           ← scores session D1–D7
  D2: 5/10            ← worker invocation anomaly flagged
prompt-debug-worker   ← reads perf-report + domain-worker.md
  → surfaces ambiguous "create the repository" instruction
  → suggests rewrite with explicit scope
```

**Convention audit** *(auditor)* — "Run arch-review-orchestrator for lib/core"
→ spawns workers per scope; `arch-generate-report` formats findings

**Project setup** *(installer)* — "Set up this project with the starter kit"
→ `setup-worker` detects platform, runs `setup-nextjs-project` or `setup-ios-project` skill, provides orientation

---

## Implementation Reference

| Project | Stack | Status |
|---|---|---|
| talenta-ios | Swift/UIKit, 4 orchestrators, 7 workers, 27 skills | Content mirrored in `lib/platforms/ios/`. Still uses its own copy — submodule wiring pending. |
| mobile-talenta (Flutter) | Dart/BLoC, get_it + injectable DI, 7 agents, 9 skills | `lib/platforms/flutter/` is a stub — needs agents, skills, reference docs |
| talenta-mobile-android | MVP, Dagger 2, RxJava 3, 7 agents, 7 skills | Naming alignment required before migration (`-orchestrator`/`-worker` suffix) |
| wehire, xpnsio | Next.js 15, 29 Type A skills, 0 Type B | Active — consuming submodule via web platform |

> **Breaking:** downstream projects must re-run setup scripts after updating the submodule pointer.

---

## Open Items

| # | Topic | Status |
|---|---|---|
| 1 | Migration: talenta-ios | Agents/skills/reference content copied to `lib/platforms/ios/`. Full submodule wiring = separate session. |
| 2 | Versioning | ✅ Resolved — semantic versioning established: v2.0.0 tagged. |
| 3 | Naming alignment | Flutter/Android adopt `-orchestrator` / `-worker` suffix — required before migration |
| 4 | Reference doc splitting | Structural split of `lib/platforms/web/reference/contract/builder/data.md` and `lib/platforms/web/reference/utilities.md` by operation type |
| 5 | Flutter implementation | `lib/platforms/flutter/` is a stub — needs agents, skills, reference docs |
---

## CLEAN Architecture, SOLID, and DRY

> Layer-to-agent mapping: see [Layer-to-Agent Mapping](#layer-to-agent-mapping) above.

**SOLID via Agent Design:**
- **SRP:** Each worker handles exactly one layer; each skill does exactly one task
- **OCP:** New features add new agents/skills without modifying existing ones
- **DIP:** Workers define the protocol; platform skills are the implementations
- **DRY via Architecture:** Reference docs are the single source of truth — skills Grep section pointers, never embed content.
---

## Delegation Threshold

Always delegate to `feature-orchestrator` when a task touches more than 3 architectural layers — inline execution at that scope produces inconsistent results.

> Rule: if the task takes fewer tokens to DO than to DELEGATE, do it directly. Otherwise, delegate.
