# Token Optimization — Journey Observation

> Date: 2026-04-10
> Context: web-agentic is productive enough to close 3–5 issues per 5-hour Claude Code session, but that productivity is accelerating token consumption to unsustainable levels. This doc investigates where tokens drain and maps findings against the [Core Design Principles](https://jurnal.atlassian.net/wiki/spaces/~611df3da650a26006e44928d/pages/51126370416).

## Design Principles Alignment Check

Before fixing anything, map findings against the principles to understand whether this is a _violation_ or a _gap in the current implementation_.

| Principle | What It Says | Current State | Gap? |
|-----------|-------------|---------------|------|
| **P4 — Context Isolation** | Workers run in isolated context windows. Main session only sees the result. | ✅ Workers do run isolated | Isolation is correct but each worker still pays the full reference doc cost independently |
| **P5 — Preloaded Skills** | Monitor total preloaded size — if it exceeds ~500 lines, split the agent | ✅ Skills not overloaded | Reference docs (not skills) are the bloat — separate problem |
| **P7 — Three-Tier Knowledge** | Skills reference Tier 3 files with _precise section pointers_, never embed content | ❌ Workers load full reference files | Should `Grep` for specific sections, not `Read` entire files |
| **P9 — Delegation Threshold** | If it takes fewer tokens to DO than to DELEGATE, do it directly | ❌ Orchestrators do context reads they shouldn't | Orchestrator's Phase 2 reads are wasted — workers already do their own |
| **P8 — Orchestrators Coordinate, Not Execute** | Orchestrators gather input, spawn workers — workers execute | ❌ Orchestrators currently read codebase files | Violates the intent: orchestrators should pass _intent_, not accumulated file content |

**Summary:** The main issues are P7 and P8 violations — reference docs loaded in full, and orchestrators doing redundant codebase reads that workers repeat.

---

## Identified Drains

## Identified Drains

### 1. Reference Docs — Biggest Culprit (4,523 lines total)

| File | Lines |
|------|-------|
| `reference/data.md` | 529 |
| `reference/utilities.md` | 487 |
| `reference/presentation.md` | 405 |
| `reference/project.md` | 391 |
| `reference/domain.md` | 349 |
| `reference/database.md` | 343 |
| `reference/modular.md` | 260 |
| `reference/testing.md` | 232 |
| `reference/server-actions.md` | 227 |

Workers read from `reference/` before writing code. When 3 workers run sequentially inside one orchestrator, the same docs are potentially loaded 3× into separate contexts.

### 2. Orchestrator Accumulates Everything

`feature-orchestrator` spawns domain → data → presentation workers sequentially. The orchestrator receives each worker's output and passes it to the next — so by Phase 4 its context holds all three workers' outputs.

### 3. Duplicate File Reads — Orchestrator AND Workers Read the Same Files

This is the most concrete redundancy found. Files are read twice: once by the orchestrator in Phase 2, then again by the worker in its own workflow step.

**`feature-orchestrator` Phase 2 reads:**
| File | Also read by |
|------|-------------|
| `Glob: src/domain/entities/*.ts` | `domain-worker` step 3 |
| `Read: src/di/container.client.ts` | `presentation-worker` step 3 |
| `Read: src/presentation/navigation/routes.ts` | `presentation-worker` step 3 |
| `Glob: src/data/dtos/*.ts` | _(only orchestrator — orphaned read)_ |

**`backend-orchestrator` Phase 2 reads:**
| File | Also read by |
|------|-------------|
| `Glob: src/data/repositories/*DbRepositoryImpl.ts` | `data-worker` step 3 (`Glob: src/data/repositories/*.ts`) |
| `Glob: src/data/mappers/db/DbErrorMapper.ts` | `data-worker` step 3 (`Glob: src/data/mappers/*.ts`) |

The orchestrator's Phase 2 reads serve as "style matching" — but the workers already do their own style matching. The orchestrator reads are redundant and stay in the orchestrator's context for the entire multi-phase run.

### 4. Reference Doc Load per Worker

Workers reference large docs via a `Reference:` pointer at the bottom of each agent file. When invoked, agents will read these docs in full.

| Worker | Reference docs loaded | Total lines |
|--------|----------------------|-------------|
| `domain-worker` | `reference/domain.md` | 349 |
| `data-worker` | `reference/data.md` + `reference/database.md` | 872 |
| `presentation-worker` | `reference/presentation.md` + `reference/server-actions.md` + `reference/di.md` + `reference/navigation.md` | 632+ |
| `test-worker` | `reference/testing.md` | 232 |

A full `feature-orchestrator` run (domain → data → presentation) loads ~1,853 lines of reference docs across three sub-agent contexts. These are fresh contexts, so the docs aren't shared — each worker pays the full cost independently.

### 5. All Workers Default to Sonnet

Code-generation workers that fill templates don't need Sonnet-class reasoning, but all workers currently use `model: sonnet`.

---

## Recommended Fixes

### High Impact

**A. Move context reads into workers, not orchestrators**

Orchestrators should pass _intent_ (feature name, fields, operations) — not file contents. Each worker should read only what it needs for its own layer. This significantly reduces the orchestrator's context growth per phase.

**B. Downgrade mechanical workers to Haiku**

Change `model:` frontmatter in template-filling workers:

```yaml
model: haiku   # data-worker, test-worker, domain-worker
```

Keep `sonnet` for orchestrators and reasoning-heavy workers (`feature-orchestrator`, `backend-orchestrator`, `arch-review-worker`, `debug-worker`).

> Note: Haiku is ~5–8× cheaper per token than Sonnet. Workers that follow a deterministic skill procedure (no architectural judgment needed) are safe candidates.

**C. Split and trim large reference docs**

`data.md` (529 lines) and `utilities.md` (487 lines) are too large to load wholesale. Options:
- Split by operation type (read vs. mutation patterns)
- Workers doing GET-only features shouldn't load mutation sections
- Workers should `Grep` for specific patterns rather than `Read` entire files

**D. Pass file paths between workers, not content**

In orchestrator delegation instructions, be explicit that workers receive only the _list of created file paths_, not file contents. This prevents previous workers' outputs from being re-embedded in orchestrator turns.

### Medium Impact

**E. Use the reference index for selective loading**

`reference/index.md` exists. Workers should read that first, then fetch only the relevant section via targeted `Grep` rather than reading a whole reference file.

**F. Strip explanatory comments from skill templates**

Templates like `pres-create-viewmodel/template.md` (73 lines) may include inline comments explaining the pattern. Those are redundant — the worker already has the SKILL.md. Remove them to reduce template load size.

---

## Quick Wins (Immediate)

1. Add `model: haiku` to `data-worker.md`, `test-worker.md`, `domain-worker.md`
2. Remove Phase 2 file reads from both orchestrators — move those instructions into each worker's own section
3. In `feature-orchestrator`, change "Pass the output of each worker as input context" → "Pass only the list of created file paths"

---

## Connection to Shared Submodule Architecture

The [Shared Submodule doc](https://jurnal.atlassian.net/wiki/spaces/~611df3da650a26006e44928d/pages/51129909710) explicitly solves the platform-skills problem via on-demand `Read` instead of preloading. The same principle applies here to reference docs:

> "On-demand cost: one Read call at the start of execution — negligible compared to preloading 3 skill files permanently."

The web-agentic reference docs should adopt the same pattern: workers `Grep` for the specific section they need rather than loading the full file. This aligns with the shared submodule's context efficiency model and is consistent across all platforms.

---

## Notes

- Session IDs cannot be used to pull Anthropic usage analytics externally
- Token counts per turn are visible in the Claude Code terminal output — watch for spikes after each `Agent()` spawn; orchestrator turns are typically the spike points
- Orchestrators are the highest-leverage place to optimize — they hold the longest-lived context windows
- This observation directly supports decisions for migrating web-agentic into the shared submodule model
