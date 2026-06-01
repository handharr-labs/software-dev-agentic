> Related: Core Design Principles · Shared Agentic Submodule Architecture

## What is the Builder Persona?

The **developer** persona is the primary feature-building workflow. It handles the full CLEAN Architecture build cycle — from domain layer through presentation — across all platforms.

Location: `lib/core/agents/developer/`

---

## Anatomy

The developer persona has three entry skills. All use the same strategist brain and the same convergence planning loop — they differ only in how intent is gathered and how blocking decisions are handled.

```
User
 │
 ├─ /developer-plan-feature          — interactive; convergence loop + user approval + worker
 ├─ /developer-build-feature         — direct entry; routes resume vs new, or build-directly
 └─ /developer-build-from-ticket     — non-interactive; derives intent from Jira ticket, auto-approves
          │
          │  Step 1: gather-intent (or gather-intent-prefilled for ticket path)
          ▼
    developer-feature-strategist   — brain only; returns Decision blocks; never spawns or writes
          │
          │  Decision: spawn-planners (which layers, why)
          ▼
    Entry skill spawns planners in parallel (only those decided by strategist)
          │
          ├─ developer-domain-planner    — Domain: entities, use cases, repository interfaces
          ├─ developer-data-planner      — Data: DTOs, mappers, datasources, repo implementations
          ├─ developer-pres-planner      — Presentation: StateHolders, screens, key symbols
          └─ developer-app-planner       — App: DI registration, routing, module registration
          │
          │  Planners return findings + Impact Recommendations
          ▼
    Entry skill sends accumulated findings to strategist
          │
          │  Decision: converged / spawn-planners (next round) / blocked
          ▼
    Loop continues until converged (max 3 rounds)
          │
          │  Decision: converged → strategist synthesizes plan.md + context.md
          │
          │  [interactive path: user reviews and approves plan.md]
          │  [ticket path: auto-approved]
          │
          │  Decision: spawn-worker
          ▼
    developer-feature-worker         — reads approved plan; executes skills in layer order
          │
          ▼
    platform-contract skills       — concrete artifact creation per platform and layer
```

---

## Entry Skills

| Skill | When to use | Difference |
|---|---|---|
| `/developer-plan-feature` | Complex or cross-layer features; uncertain existing state | Interactive convergence loop; user reviews plan before execution |
| `/developer-build-feature` | Known scope; resuming an existing run; or build-directly opt-out | Routes resume vs new; build-directly skips the loop |
| `/developer-build-from-ticket` | CI job, API caller, automated pipeline | Non-interactive; intent derived from Jira ticket; auto-approves |

---

## Planning Convergence Loop

The entry skill (not the strategist) owns the loop. Each round:

1. Strategist decides which planners are needed based on intent and prior findings
2. Entry skill spawns only those planners in parallel
3. Planners return findings + `### Impact Recommendations` (which other layers are affected)
4. Entry skill sends accumulated findings to strategist
5. Strategist checks: are all required recommendations covered by the visited set?
   - No → `Decision: spawn-planners` for the next round (unvisited layers only)
   - Yes → `Decision: converged`

**Guards:**
- Visited set prevents re-spawning already-explored layers
- Hard cap at 3 rounds → `Decision: blocked` surfaces to user (or `error.md` for ticket path)

---

## Strategist Modes

`developer-feature-strategist` is called multiple times per feature build, each time in a different mode:

| Mode | Called when | Returns |
|---|---|---|
| `gather-intent` | New interactive feature | `Decision: spawn-planners` (round 1) |
| `gather-intent-prefilled` | Ticket path; intent pre-derived | `Decision: spawn-planners` (round 1) |
| `process-findings` | After each planner round | `Decision: spawn-planners` / `Decision: converged` / `Decision: blocked` |
| `synthesize` | After convergence; skill passes all findings | Writes `plan.md` + `context.md`; returns summary |

---

## Sub-Planners

Each planner explores one layer, reports findings, and returns. Spawned by the entry skill in parallel per round.

| Planner | Explores | Impact Recommendations |
|---|---|---|
| `developer-domain-planner` | Entities, use cases, repository interfaces, domain services | → data (new entity needs DTO), → app (new use case needs DI) |
| `developer-data-planner` | DTOs, mappers, datasources, repository implementations | → domain (contract gap), → app (new impl needs DI binding) |
| `developer-pres-planner` | StateHolders, screens, components, navigators, key symbols | → domain (missing use case), → app (new screen needs route) |
| `developer-app-planner` | DI registration, routing, module registration, analytics, feature flags | → domain / presentation (flag or route impacts) |

### Scope-Aware Entry

The strategist passes a `scope` map in every `spawn-planners` decision block. Each planner uses its scope to skip glob steps for artifact types not relevant to the stated intent — so a "update use case" task causes the domain planner to only search for use cases, not entities, repository interfaces, or services.

### Demand-Driven Reference Expansion

After reading primary artifact symbols, each planner checks its referenced types and expands **only if**:

- **(a) Structural need** — the referenced type's shape is required to describe the new/modified artifact (e.g. a use case returns `UserEntity` and its fields must be listed in the findings), **or**
- **(b) Modification need** — the referenced type itself will be modified as a consequence of the change (e.g. adding a use case output field requires a new entity property)

All other referenced types — injected dependencies, pass-throughs, unrelated artifacts — are skipped. The decision stays inside the planner; the strategist only controls the entry point via `scope`.

---

## Execution Phase — `developer-feature-worker`

`developer-feature-worker` is the only agent that writes source files. It reads the approved `plan.md` and calls skills in CLEAN layer order — domain → data → presentation → UI. Each artifact is validated via `Glob` + `Grep` before moving to the next. `state.json` is updated after each artifact so the run is resumable.

---

## Agent Roster

### Core agents (`lib/core/agents/developer/`)

| Role | Agent | Responsibility |
|---|---|---|
| Strategist | `developer-feature-strategist` | Brain of the developer persona — decides which planners, synthesizes plan, instructs skill to spawn worker |
| Strategist | `developer-groom-strategist` | Grooming brain — detects scope from AC, decides which planners, synthesizes grooming summary |
| Strategist | `developer-backend-strategist` | Backend API + data layer coordination |
| Planner | `developer-domain-planner` | Domain layer exploration — entities, use cases, repository interfaces |
| Planner | `developer-data-planner` | Data layer exploration — DTOs, mappers, datasources, repo implementations |
| Planner | `developer-pres-planner` | Presentation layer exploration — StateHolders, screens, key symbols |
| Planner | `developer-app-planner` | App layer exploration — DI, routing, module registration, analytics, feature flags |
| Worker | `developer-feature-worker` | Plan-driven executor — reads plan.md, calls skills in layer order, validates each artifact |
| Worker | `developer-test-worker` | Test generation across all layers |
| Worker | `developer-rfc-writer` | RFC document generation from feature intent or existing plan |
| Worker | `auditor-arch-review-worker` | CLEAN Architecture violation review (downstream projects) |

**Deprecated (absorbed into strategist + entry skills):**

| Agent | Replaced by |
|---|---|
| `developer-feature-planner` | `developer-feature-strategist` (synthesize mode) + entry skill (convergence loop) |
| `developer-auto-feature-planner` | `developer-feature-strategist` (gather-intent-prefilled mode) + `developer-build-from-ticket` skill |

**Removed:**

| Agent | Removed in | Reason |
|---|---|---|
| `domain-worker` | v3.58.0 | Superseded by `developer-feature-worker` and `developer-backend-strategist` |
| `data-worker` | v3.58.0 | Superseded by `developer-feature-worker` and `developer-backend-strategist` |
| `presentation-worker` | v3.58.0 | Superseded by `developer-feature-worker` |
| `developer-ui-worker` | v5.6.0 | No valid spawn path — violated Skill-First Entry; Component Reuse Check merged into `developer-feature-worker` |

### Platform agents

| Platform | Agent | Why platform-specific |
|---|---|---|
| iOS | `test-strategist` | Knows `xcodebuild`, XCTest flow |
| iOS | `pr-review-worker` | Knows Swift/UIKit conventions |

### Internal tooling (NOT symlinked downstream)

| Component | Location | Purpose |
|---|---|---|
| `arch-review-strategist`, `arch-review-worker` | `.claude/agents/` | Convention review |
| `arch-check-conventions`, `arch-generate-report` | `.claude/skills/` | Convention checklist, report formatter |

---

## Layer-to-Agent Mapping

| Layer | Planner | Worker | Skills |
|---|---|---|---|
| Domain | `developer-domain-planner` | `developer-feature-worker` | `developer-domain-create-entity`, `developer-domain-create-usecase`, `developer-domain-create-repository`, `developer-domain-create-service` |
| Data | `developer-data-planner` | `developer-feature-worker` | `developer-data-create-datasource`, `developer-data-create-mapper`, `developer-data-create-repository-impl` |
| Presentation | `developer-pres-planner` | `developer-feature-worker` | `developer-pres-create-stateholder`, `developer-pres-create-screen`, `developer-pres-create-component` |
| App | `developer-app-planner` | `developer-feature-worker` (inline) | — |
| Test | — | `developer-test-worker` | `developer-test-create-domain`, `developer-test-create-data`, `developer-test-create-presentation` |

---

## Skill Roster (Platform-Contract — all platforms must implement)

These skills cover **artifact creation only**. Workers handle modifications to existing artifacts via direct `Read` + `Edit` with reference docs — there are no `update-*` or `fix-*` skills.

| Skill | Called by | Layer |
|---|---|---|
| `developer-domain-create-entity` | `developer-feature-worker` | Domain |
| `developer-domain-create-repository` | `developer-feature-worker` | Domain |
| `developer-domain-create-usecase` | `developer-feature-worker` | Domain |
| `developer-domain-create-service` | `developer-feature-worker` | Domain |
| `developer-data-create-mapper` | `developer-feature-worker` | Data |
| `developer-data-create-datasource` | `developer-feature-worker` | Data |
| `developer-data-create-repository-impl` | `developer-feature-worker` | Data |
| `developer-pres-create-stateholder` | `developer-feature-worker` | Presentation |
| `developer-pres-create-screen` | `developer-feature-worker` | Presentation/UI |
| `developer-test-create-domain` | `developer-test-worker` | Test |
| `developer-test-create-data` | `developer-test-worker` | Test |
| `developer-test-create-presentation` | `developer-test-worker` | Test |

---

## Standalone Paths (no convergence loop needed)

| Task | Path |
|---|---|
| Single known artifact | Entry skill (`/developer-build-feature`) with narrow intent → strategist scopes to one layer → `developer-feature-worker` |
| Test generation | `developer-test-worker` directly |
| Targeted edit to existing artifact | Worker with `context.md` Key Symbols if available |

---

## Agent Count Snapshot

| Category | `lib/core/agents/` | `lib/platforms/ios-talenta/agents/` | `lib/platforms/web/agents/` |
|---|---|---|---|
| Strategists | 3 in `builder/` + 1 in `debugger/` | 1 (`test-strategist`) | — |
| Workers | 3 in `builder/` + 2 in `debugger/` + 2 in `tracker/` + 1 in `auditor/` + 1 in `installer/` + 1 flat (`perf-worker`) | 1 (`pr-review-worker`) | — |
| Skills (Type A / contract) | — | 18 | 18 |
| Skills (Type B / platform-only) | — | 4 (`migrate-presentation`, `migrate-usecase`, `review-pr`, `sonar-check`) | 0 |

Platform skill counts: Flutter 18 · Android 17 · flutter-qontak 0 (uses flutter platform)

> This is a point-in-time snapshot. Check `lib/core/agents/` and `lib/platforms/` for the current roster.

---

## Execution Examples

### Builder flows

**Direct action** — "Add import RxSwift to this file" → single-line edit, no agent needed

**Single-layer task** — "Create GetLeaveRequestListUseCase"
→ `/developer-build-feature` with narrow intent; strategist scopes to domain only; `developer-feature-worker` calls `developer-domain-create-usecase`

**Multi-layer task** — "Build the leave request feature"
→ `/developer-plan-feature` skill: strategist decides which planners, skill runs convergence loop, plan approved, `developer-feature-worker` executes

**Partial update** — "Add a new screen, domain/data already exist"
→ strategist decides: spawn only `pres-planner` + `app-planner` (domain and data have no impact)

**Cross-layer impact discovered** — pres-planner reports "new screen needs a use case that doesn't exist"
→ strategist spawns domain-planner in round 2 to explore; skill adds `domain` to visited set

**Type B skill** — `/migrate-presentation CustomFormScreen`
→ explicit user trigger; prevents accidental migration

**Ticket-driven build** — `/developer-build-from-ticket PROJ-123`
→ skill derives intent from ticket, runs convergence loop automatically, auto-approves, executes worker

**Flutter domain entity creation** — "Create a LeaveRequest entity for Flutter"

```
/developer-plan-feature skill
  └─ developer-feature-strategist   (decides: spawn domain-planner only)
  └─ developer-domain-planner         (explores domain layer)
  └─ developer-feature-strategist   (converged; synthesizes plan.md)
  └─ developer-feature-worker         (reads plan; calls skill)
        └─ developer-domain-create-entity   ← flutter skill, knows the syntax
```

**iOS PR review** — "Review my PR before merging"

```
pr-review-worker       (iOS platform worker)   ← iOS-specific workflow
  └─ review-pr         (iOS platform skill)    ← Swift/UIKit conventions
       lib/platforms/ios-talenta/skills/review-pr/SKILL.md
```

### Other persona flows

**Debug flow** *(detective)* — "Why is form submission silently failing?"
→ `debugger-strategist` gathers context, spawns `debugger-worker`

**Agent prompt debugging** *(detective)* — "Why did the worker create an implementation instead of an interface?"

```
perf-worker           ← scores session D1–D7
  D2: 5/10            ← worker invocation anomaly flagged
  → surfaces ambiguous "create the repository" instruction
  → suggests rewrite with explicit scope
```

**Convention audit** *(auditor)* — "Run arch-review-strategist for lib/core"
→ spawns workers per scope; `arch-generate-report` formats findings

**Project setup** *(installer)* — "Set up this project with the starter kit"
→ `installer-setup-worker` detects platform, runs `setup-nextjs-project` or `setup-ios-project` skill, provides orientation

---

## Implementation Reference

| Project | Stack | Status |
|---|---|---|
| talenta-ios | Swift/UIKit | `lib/platforms/ios-talenta/` — 18 contract skills, 4 platform-only skills, 11 reference docs. Submodule wiring pending. |
| mobile-talenta (Flutter) | Dart/BLoC, get_it + injectable | `lib/platforms/flutter-mobile-talenta/` — 18 contract skills, 11 reference docs, no platform agents. |
| talenta-mobile-android | Kotlin MVP, Dagger 2, RxJava 3 | `lib/platforms/android-talenta/` — 17 contract skills, 11 reference docs. Wire submodule with `setup-symlinks.sh --platform=android-talenta`. |
| mobile-qontak-chat | Flutter/BLoC, modular, get_it + injectable | `lib/platforms/flutter-qontak-chat/` — 16 reference docs (modular-structure, module-communication, flavor extras). No separate contract skills — shares flutter platform skills. |
| wehire, xpnsio | Next.js 15 | `lib/platforms/web/` — 18 contract skills. Active — consuming submodule via web platform. |

> **Breaking:** downstream projects must re-run setup scripts after updating the submodule pointer.

---

## Open Items

| # | Topic | Status |
|---|---|---|
| 1 | Migration: talenta-ios | Agents/skills/reference content copied to `lib/platforms/ios-talenta/`. Full submodule wiring = separate session. |
| 2 | Versioning | ✅ Resolved — semantic versioning established: v2.0.0 tagged. |
| 3 | Naming alignment | Flutter/Android adopt `-strategist` / `-worker` suffix — required before migration |
| 4 | Reference doc splitting | Structural split of `lib/platforms/web/reference/code-architecture/data.md` and `lib/platforms/web/reference/utilities.md` by operation type |
| 5 | Flutter implementation | ✅ Resolved — `lib/platforms/flutter-mobile-talenta/` has 18 contract skills + 11 reference docs. No platform agents yet (none needed). |

---

## CLEAN Architecture, SOLID, and DRY

> Layer-to-agent mapping: see [Layer-to-Agent Mapping](#layer-to-agent-mapping) above.

**SOLID via Agent Design:**
- **SRP:** Each worker handles exactly one layer; each skill does exactly one task; strategist only reasons and decides
- **OCP:** New features add new agents/skills without modifying existing ones
- **DIP:** Workers define the protocol; platform skills are the implementations
- **DRY via Architecture:** Reference docs are the single source of truth — skills Grep section pointers, never embed content.

---

## Delegation Threshold

Always use the convergence planning loop when a task touches more than 3 architectural layers — inline execution at that scope produces inconsistent results.

> Rule: if the task takes fewer tokens to DO than to DELEGATE, do it directly. Otherwise, delegate.
