# Agentic Performance Report — Issue #TE-14689

> Date: 2026-04-23
> Session: 5f83f9b0-1e65-4b17-8c0b-a7faa0a635f1
> Branch: feature/TE-14689_Show-Location-marker-and-perimeter-based-on-API-list-location
> Duration: ~19 min (2026-04-23T17:19:27Z → 2026-04-23T17:38:57Z)

## Summary Scores

| Dimension | Score | Rating | Key Signal |
|---|---|---|---|
| D1 · Orchestration Quality | 8/10 | Good | feature-orchestrator delegated correctly; no direct file reads by orchestrator |
| D2 · Worker Invocation | 7/10 | Good | feature-planner + feature-orchestrator used appropriately; second orchestrator spawn for a 1-line fix added overhead |
| D3 · Skill Execution | 6/10 | Fair | plan-feature skill used; no domain/data/presentation skills invoked despite modifying presentation-layer ViewModel |
| D4 · Token Efficiency | 8/10 | Good | 95% cache hit ratio; read:grep ratio of 0.4 (excellent); no duplicate reads |
| D5 · Routing Accuracy | 9/10 | Excellent | feat/ branch, correct worker types, task classified accurately from the start |
| D6 · Workflow Compliance | 9/10 | Excellent | feature branch, specific git add, no --no-verify, commits include issue prefix |
| D7 · One-Shot Rate | 6/10 | Fair | 1 error tool result; second orchestrator spawn was a correction; delegation guard triggered mid-session requiring user input |
| **Overall** | **7.6/10** | **Good** | |

## Token Breakdown

| Metric | Value |
|---|---|
| Input tokens | 90 |
| Cache creation | 151,602 |
| Cache reads | 2,918,211 |
| Output tokens | 16,151 |
| **Billed approx** | **3,086,054** |
| Cache hit ratio | 95.1% |
| Avg billed / turn | 77,151 (per user turn) |

## Tool Usage

| Tool | Calls |
|---|---|
| Bash | 15 |
| Agent | 3 |
| Read | 3 |
| Edit | 3 |
| ToolSearch | 1 |
| SendMessage | 1 |

Read:Grep ratio: 0.4 (target < 3 — excellent; Grep-first discipline well applied)

## Agent & Skill Invocations

| Component | Args / Description | Outcome |
|---|---|---|
| Skill: plan-feature | plan-feature (ticket TE-14689) | ✓ Correct skill for pre-execution planning |
| Agent: feature-planner | Feature planning for TE-14689 feature flag + API call | ✓ Produced a focused, accurate plan |
| Agent: feature-orchestrator | Execute TE-14689 feature flag + use case wiring | ✓ Delivered all 3 file changes correctly |
| Agent: feature-orchestrator | Move fetchAllLocation call to viewDidLoad event | ✓ Corrected placement; used feature-orchestrator as required but added cost for a 1-line fix |

## Findings

### What went well

- Grep-first discipline was excellent — 8 grep calls vs 3 reads gives a 0.4 ratio, well below the target of < 3.
- Cache performance was strong at 95.1%, cutting the session cost from ~$9.45 to ~$1.69.
- The agent correctly consulted the feature-planner before execution and validated the strict-location guard condition (`isFlexibleLocation`) against real code before committing it to the plan — this prevented a wrong-field bug from reaching execution.
- Git hygiene was excellent: specific file paths in `git add`, issue prefix on both commits, no hook bypasses, work on the correct feature branch.
- The agent correctly stopped and asked the user for routing preference when the delegation guard triggered mid-session, rather than resolving it autonomously — this is the correct CLAUDE.md-mandated behaviour.
- Plan.md was iteratively refined (3 edits) before handing off to feature-orchestrator, resulting in a clean first execution pass.

### Issues found

- **[D3]** No `pres-update-stateholder` skill was invoked despite `CICOLocationViewModel.swift` receiving substantial changes: use case injection (constructor + property + init wiring), a new private helper method, and event-handler modification. Skills exist precisely to govern these writes; bypassing them means the worker wrote directly without skill scaffolding.
- **[D3]** Similarly, changes to `MekariFlagResponse.swift` and `MekariFlagCustomProvider.swift` (data-layer feature flag machinery) were done without a corresponding `data-update-*` skill call. This is a partial bypass of the skills layer.
- **[D7]** The second `feature-orchestrator` spawn (moving the call from `handlePostCICOValidateLocationSuccess` to `.viewDidLoadEvent`) was a rework spawn — the first execution placed the call in the wrong location. This added ~2 minutes of orchestration overhead for a single-line relocation. The planning step did not specify where in `CICOLocationViewModel` the call should land, allowing the misplacement.
- **[D7]** The delegation guard fired mid-session, requiring user intervention. While the agent handled it correctly (stopped and asked), the guard triggering at all indicates the second spawn was attempting a direct edit rather than routing through the skill layer properly.

> **Low score on D3?** Review `.claude/software-dev-agentic/lib/core/agents/builder/presentation-worker.md` — check whether the skill invocation requirement for ViewModel updates is clearly stated, and whether `pres-update-stateholder` is listed as mandatory for injecting use cases into an existing StateHolder/ViewModel.

> **Low score on D7?** Review `.claude/software-dev-agentic/lib/core/agents/builder/feature-orchestrator.md` — the plan spec passed to feature-orchestrator should include the target insertion point in the ViewModel (which `emitEvent` case, which MARK section). Ambiguous placement is a predictable misplacement vector.

## Recommendations

1. **Highest impact fix — Include call-site coordinates in plans.** The rework spawn happened because the plan said "call the use case" without specifying exactly where in `emitEvent(_:)` to place it. Plans for ViewModel wiring should include the target case name and the line-order relative to existing calls (e.g., "append after `actions.accept(.showLoading(false))` in `.viewDidLoadEvent`").

2. **Enforce skill calls for ViewModel updates.** `pres-update-stateholder` should be invoked before any write to an existing StateHolder/ViewModel. The feature-orchestrator's prompt should require a skill call per modified presentation-layer artifact, not just for new artifacts.

3. **Add `data-update-mapper` (or equivalent) for feature flag additions.** Additions to `MekariFlagResponse.swift` / `MekariFlagCustomProvider.swift` are data-layer artifact updates and should be governed by a skill call, even if small. This creates a traceable record in `skill_calls`.

---

## Effort vs Billing

### Token cost breakdown

| Token type | Count | Unit price | Cost (USD) |
|---|---|---|---|
| Input | 90 | $3.00 / MTok | $0.0003 |
| Cache creation | 151,602 | $3.75 / MTok | $0.5685 |
| Cache reads | 2,918,211 | $0.30 / MTok | $0.8755 |
| Output | 16,151 | $15.00 / MTok | $0.2423 |
| **Total** | **3,086,054 billed-equiv** | | **~$1.69** |

Cache hit ratio of **95.1%** was the primary cost saver — without it, the same session would have cost ~$9.45 at full input rates (savings of ~$7.77).

### Where the tokens went

| Task | Estimated tokens | % of total | Productive? |
|---|---|---|---|
| Plan-feature skill + feature-planner execution | ~620,000 | 20% | ✅ Productive |
| Research phase (grep-driven guard condition validation) | ~185,000 | 6% | ✅ Productive |
| Plan.md refinement (3 edit cycles + confirmations) | ~92,000 | 3% | ✅ Productive |
| feature-orchestrator execution (flag + ViewModel wiring) | ~1,240,000 | 40% | ✅ Productive |
| Rework: second feature-orchestrator spawn (viewDidLoad relocation) | ~620,000 | 20% | ❌ Rework |
| Commit staging + git operations | ~185,000 | 6% | ⚠️ Overhead |
| Perf-review script invocation (failed + retry) | ~154,000 | 5% | ⚠️ Overhead |
| **Total** | **~3,096,000** | **100%** | |

**Productive work: ~69% (~2,137,000 tokens / ~$1.17)**
**Wasted on rework: ~20% (~620,000 tokens / ~$0.34)**

### Effort-to-value ratio

| Deliverable | Complexity | Tokens spent | Efficiency |
|---|---|---|---|
| Feature flag in MekariFlagResponse + MekariFlagCustomProvider | Low | ~310,000 | Good — focused, no iteration |
| GetAllLocationLiveAttendanceUseCase injection into CICOLocationViewModel | Medium | ~930,000 | Fair — correct on first pass but placement required a second orchestrator run |
| viewDidLoad relocation correction | Low | ~620,000 | Poor — single-line move consumed ~20% of total tokens due to full orchestration overhead being applied to a trivial correction |

### Key insight

The single highest-cost inefficiency was applying full `feature-orchestrator` orchestration to a one-line call-site relocation. Moving `fetchAllLocationLiveAttendanceIfNeeded()` from one handler to another is a trivially small change, yet it consumed approximately 620,000 tokens (~$0.34) because it went through the full spawn-plan-execute-verify cycle. This was caused by the plan not specifying where the call should be placed initially — a missing coordinate in the plan led to a misplacement, which then required a costly correction pass. Tighter plan specifications (naming the exact `emitEvent` case and insertion order) would have prevented the misplacement entirely and eliminated the rework spawn.
