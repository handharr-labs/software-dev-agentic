> Related: Core Design Principles · Shared Agentic Submodule Architecture

## What is the Builder Persona?

The **builder** persona is the primary feature-building workflow. It handles the full CLEAN Architecture build cycle — from domain layer through presentation — across all platforms.

Location: `lib/core/agents/builder/`

---

## Agent Roster

### Core agents (`lib/core/agents/builder/`)

| Role | Agent | Responsibility |
|---|---|---|
| Orchestrator | `feature-orchestrator` | Full feature build — coordinates all layers |
| Orchestrator | `pres-orchestrator` | Presentation + UI phase (standalone or sub-orchestrator) |
| Orchestrator | `backend-orchestrator` | Backend API + data layer coordination |
| Orchestrator | `debug-orchestrator` | Debug session coordination |
| Orchestrator | `feature-planner` | Pre-build planning and scope definition |
| Worker | `domain-worker` | Domain layer: entities, use cases, repository interfaces |
| Worker | `data-worker` | Data layer: mappers, datasources, repository implementations |
| Worker | `presentation-worker` | Presentation layer: StateHolder, state management |
| Worker | `ui-worker` | UI layer: screens, components, navigation |
| Worker | `test-worker` | Test generation across all layers |
| Worker | `debug-worker` | Root cause analysis and fix execution |
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
| `arch-review-orchestrator`, `arch-review-worker`, `docs-sync-worker` | `agents/` (root) | Convention review + design doc sync |
| `arch-check-conventions`, `arch-generate-report`, `docs-identify-changes` | `skills/` (root) | Convention checklist, report formatter, delta mapper |

---

## Layer-to-Agent Mapping

| Layer | Worker | Skills |
|---|---|---|
| Domain | `domain-worker` | `domain-create-entity`, `domain-create-usecase`, `domain-create-repository`, `domain-create-service`, `domain-update-usecase` |
| Data | `data-worker` | `data-create-datasource`, `data-create-mapper`, `data-create-response`, `data-create-repository-impl`, `data-update-mapper` |
| Presentation | `presentation-worker`, `ui-worker` | `pres-create-stateholder`, `pres-update-stateholder`, `pres-create-screen`, `pres-create-component`, `pres-create-navigator`, `pres-update-screen` |
| Test | `test-worker` | `test-create-domain`, `test-create-data`, `test-create-presentation`, `test-update`, `test-fix` |

---

## Skill Roster (Platform-Contract — all platforms must implement)

| Skill | Called by | Layer |
|---|---|---|
| `domain-create-entity` | `domain-worker` | Domain |
| `domain-create-repository` | `domain-worker` | Domain |
| `domain-create-usecase` | `domain-worker` | Domain |
| `data-create-mapper` | `data-worker` | Data |
| `data-create-datasource` | `data-worker` | Data |
| `data-create-repository-impl` | `data-worker` | Data |
| `pres-create-stateholder` | `presentation-worker` | Presentation |
| `pres-create-screen` | `ui-worker` | Presentation/UI |
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

**Doc sync** *(internal)* — "Sync the docs — we added X and Y this session"
→ `docs-sync-worker` fetches current pages, runs `docs-identify-changes`, applies targeted updates

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
| 4 | Reference doc splitting | Structural split of `lib/platforms/web/reference/contract/data.md` and `lib/platforms/web/reference/utilities.md` by operation type |
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
