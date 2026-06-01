# Agentic Performance Report — Issue #TE-14689

> Date: 2026-04-23
> Session: 3f869f29-9a8a-4e92-b25f-400287bb757f
> Branch: feature/TE-14689_Show-Location-marker-and-perimeter-based-on-API-list-location
> Duration: ~340 min (2026-04-23T09:17:38Z → 2026-04-23T14:57:48Z)

## Summary Scores

| Dimension | Score | Rating | Key Signal |
|---|---|---|---|
| D1 · Orchestration Quality | 6/10 | Fair | Orchestrator performed direct file reads (plan.md, errors.md, RepositoryImpl, ViewModel) instead of coordinating only |
| D2 · Worker Invocation | 5/10 | Fair | Second feature-orchestrator used for test creation instead of test-worker; no domain-worker spawned; orchestrator blocked from spawning workers and handled work inline |
| D3 · Skill Execution | 4/10 | Poor | Only routing skill (feature-orchestrator) called — no data-create-datasource, data-create-repository-impl, or pres-create-stateholder invoked; workers wrote files bypassing skills |
| D4 · Token Efficiency | 6/10 | Fair | 93.2% cache hit ratio (Excellent) but avg 60,440 billed/turn exceeds threshold; 2 duplicate reads; 10 full-file Bash cat reads |
| D5 · Routing Accuracy | 7/10 | Good | Correct feature branch prefix; feature-orchestrator routing correct; minor: test work routed to feature-orchestrator instead of test-worker |
| D6 · Workflow Compliance | 7/10 | Good | Correct feature branch; no git add -A or --no-verify; feature-orchestrator delegation followed per CLAUDE.md; two auth interruptions required manual resume |
| D7 · One-Shot Rate | 6/10 | Fair | Error loop required second /feature-orchestrator invocation; login expired twice; ViewModel written then edited (rework); user had to manually prompt test creation |
| **Overall** | **5.9/10** | **Fair** | |

## Token Breakdown

| Metric | Value |
|---|---|
| Input tokens | 6,910 |
| Cache creation | 532,073 |
| Cache reads | 7,436,048 |
| Output tokens | 63,528 |
| **Billed approx** | **8,038,559** |
| Cache hit ratio | 93.2% |
| Avg billed / turn | 60,440 |

## Tool Usage

| Tool | Calls |
|---|---|
| Bash | 43 |
| Read | 8 |
| Agent | 6 |
| Edit | 4 |
| ToolSearch | 2 |
| Write | 2 |
| SendMessage | 2 |
| Skill | 2 |
| mcp__mmpa__mmpa_get_jira | 1 |

Read:Grep ratio: 8:0 (no Grep tool used — target < 3; grep was performed via Bash grep commands, but 10 full-file `cat` reads via Bash indicate further over-reading)

## Agent & Skill Invocations

| Component | Args / Description | Outcome |
|---|---|---|
| Skill: feature-orchestrator | (routing invocation via /plan-feature) | ✓ Triggered feature-planner + feature-orchestrator sequence |
| Skill: feature-orchestrator | Create tests for the getAllLocationLiveAttendance migration — covers DataSource, RepositoryImpl, ViewModel, and UseCase layers added for TE-14689 | ✓ Tests created but wrong skill — should be test-worker |
| Agent: feature-planner | Plan getAllLocationLiveAttendance migration to LiveAttendanceRemoteDataSource | ✓ Plan produced and approved |
| Agent: feature-orchestrator | Execute getAllLocationLiveAttendance migration plan | Partial ✗ — blocked by permission denials when spawning data/pres workers; required user intervention to resume |
| Agent: data-worker | Data layer: add getAllLocationLiveAttendance to DataSource + RepositoryImpl | ✓ DataSource and RepositoryImpl updated |
| Agent: Explore | Read LiveAttendanceLocationViewController for pres context | ✓ Appropriate read-only exploration |
| Agent: presentation-worker | Presentation layer: create ViewModel + update ViewController | Partial ✗ — ViewModel had compilation errors requiring a second fix cycle |
| Agent: feature-orchestrator | Feature orchestrator: create tests for getAllLocationLiveAttendance migration | ✓ 26 test cases created across 5 files — but wrong agent type |

## Findings

### What went well
- Cache hit ratio of 93.2% was excellent — the prompt cache was well utilised across the long session.
- Domain layer was already complete from a prior session; the plan correctly identified this and scoped work to data and presentation layers only.
- The `feature-planner` → `feature-orchestrator` flow via `/plan-feature` skill was correctly invoked.
- Plan scope was clear and accurate: API plumbing only with no UI scope creep.
- `data-worker` correctly handled both `LiveAttendanceRemoteDataSource.swift` and `LiveAttendanceRepositoryImpl.swift`.
- 26 test cases were ultimately produced across 5 files covering all touched layers.
- The `Explore` subagent was appropriately used for read-only context gathering.

### Issues found
- **[D3]** No artifact-level skills invoked — `data-create-datasource`, `data-create-repository-impl`, and `pres-create-stateholder` were all skipped. The `feature-orchestrator` skill is a routing construct, not a creation skill. Workers wrote `LiveAttendanceRepositoryImpl.swift` and `LiveAttendanceLocationViewModel.swift` directly without skill scaffolding.
- **[D2]** Test creation delegated to `feature-orchestrator` instead of `test-worker`. The `feature-orchestrator` is a build orchestrator — it should not be used as a substitute for `test-worker` when the sole intent is test authoring.
- **[D1]** The orchestrator directly read files (`plan.md` twice, `errors.md` twice, `BaseViewModelV2.swift`, `LiveAttendanceLocationViewModel.swift`, `LiveAttendanceRepositoryImpl.swift`) — orchestrators should pass intents to workers, not perform file reads themselves.
- **[D4]** Ten `cat` calls via Bash read entire Swift files when targeted `grep` on specific symbols (e.g. `ViewModelState`, `InitializableDefault`, `init(`) would have sufficed. Five files in particular — `DashboardViewModelState.swift`, `DashboardUIModel.swift`, `AllLocationLiveAttendanceResponse.swift`, `InboxApprovalBulkViewModelState.swift`, `InboxApprovalBulkViewModelEvent.swift` — were full-file reads used purely to infer a protocol conformance pattern.
- **[D7]** The `LiveAttendanceLocationViewModel.swift` required Write then Edit (rework) due to compilation errors: `ViewModelState` non-conformance, `UserViewModel.sharedInstance` not existing, and `updateState` signature mismatch. These were architectural pattern errors that a skill-guided scaffold would have prevented.
- **[D7]** Login expired twice mid-session, requiring 2 manual `SendMessage` resumes. The orchestrator was interrupted once by the user ("Request interrupted by user") and once by a permission denial loop — both broke the automation flow.
- **[D6]** No `git commit` or `git push` calls were found in the session. It is unclear whether changes were committed to the feature branch.

> **Low score on D3?** Review `lib/core/agents/developer/data-worker.md` and `lib/core/agents/developer/presentation-worker.md` — look for missing precondition checks requiring skill invocation before file writes. The workers may lack explicit enforcement that `data-create-datasource` / `pres-create-stateholder` skills must be called before any Write/Edit to those artifact types.

> **Low score on D2?** Review `lib/core/agents/developer/feature-orchestrator.md` — check whether the routing rules distinguish between build work (delegate to domain/data/pres workers) and test work (must delegate to test-worker). The current agent description for test creation used `feature-orchestrator` incorrectly.

## Recommendations

1. **Highest impact fix — enforce skill invocation in data-worker and presentation-worker** — both workers should call `data-create-datasource`, `data-create-repository-impl`, and `pres-create-stateholder` before any Write. Without skills, pattern errors (ViewModelState conformance, singleton usage) are caught only at compile time, creating a costly fix loop.
2. **Add test-worker routing rule to feature-orchestrator.md** — when the feature-orchestrator receives a description that begins with "create tests" or "covers tests", it should immediately delegate to `test-worker`, not self-execute or spawn another `feature-orchestrator`.
3. **Prohibit full-file cat reads in workers** — presentation-worker used `cat -n` on 5+ reference files to infer one protocol. Add a rule to worker prompts: use `grep -n "ProtocolName"` to locate the definition, then `sed -n 'N,Mp'` for the relevant range. This would have eliminated ~3,000 tokens of overhead reads.
4. **Address auth/login interruption resilience** — the session required two manual `SendMessage` resumes after login expiry. If background agents are long-running, consider adding a pre-flight auth check in the orchestrator's worker-spawn loop.

---

## Effort vs Billing

### Token cost breakdown

| Token type | Count | Unit price | Cost (USD) |
|---|---|---|---|
| Input | 6,910 | $3.00 / MTok | $0.02 |
| Cache creation | 532,073 | $3.75 / MTok | $2.00 |
| Cache reads | 7,436,048 | $0.30 / MTok | $2.23 |
| Output | 63,528 | $15.00 / MTok | $0.95 |
| **Total** | **8,038,559 billed-equiv** | | **~$5.20** |

Cache hit ratio of **93.2%** was the primary cost saver — without it, the same session would have cost ~$24.88 at full input rates, a saving of ~$19.68 (79% reduction).

### Where the tokens went

| Task | Estimated tokens | % of total | Productive? |
|---|---|---|---|
| Feature planning (feature-planner spawn + plan.md creation) | ~800,000 | 10% | ✅ Productive |
| Data layer work — DataSource + RepositoryImpl (data-worker) | ~1,600,000 | 20% | ✅ Productive |
| Presentation layer work — ViewModel + ViewController (presentation-worker) | ~1,200,000 | 15% | ✅ Productive |
| ViewModel error fix cycle (errors.md → second feature-orchestrator) | ~900,000 | 11% | ❌ Rework |
| Test creation (second feature-orchestrator spawn) | ~1,600,000 | 20% | ✅ Productive |
| Orchestrator file reads (plan.md x2, errors.md x2, reference files) | ~600,000 | 7% | ⚠️ Overhead |
| Full-file cat reads for pattern inference (10 Bash cat calls) | ~500,000 | 6% | ⚠️ Overhead |
| Jira fetch + initial context (MMPA, temp-dir write) | ~200,000 | 3% | ⚠️ Overhead |
| Auth interruptions + SendMessage resumes | ~200,000 | 3% | ❌ Rework |
| Session start / system prompts / misc | ~438,559 | 5% | ⚠️ Overhead |
| **Total** | **~8,038,559** | **100%** | |

**Productive work: ~65% (~5,200,000 tokens / ~$3.38)**
**Wasted on rework: ~14% (~1,100,000 tokens / ~$0.73)**

### Effort-to-value ratio

| Deliverable | Complexity | Tokens spent | Efficiency |
|---|---|---|---|
| Feature plan (plan.md) | Low | ~800,000 | Fair — plan creation consumed 10% of total budget; planner explored more files than strictly needed for a focused migration |
| DataSource + RepositoryImpl update | Medium | ~1,600,000 | Good — two files with protocol conformance additions; proportionate |
| LiveAttendanceLocationViewModel (new file) | Medium | ~2,100,000 | Poor — new ViewModel required Write + Edit fix cycle due to ViewModelState/UserViewModel pattern errors; 31% over-budget for a medium-complexity artifact |
| 26 unit tests across 5 files | High | ~1,600,000 | Good — comprehensive test coverage at reasonable token cost |

### Key insight

The single highest-cost item was the `LiveAttendanceLocationViewModel.swift` creation and fix cycle (~2.1M tokens, ~$1.37), representing 26% of total session spend for what should be a medium-complexity artifact. The root cause was the `presentation-worker` writing the ViewModel without invoking `pres-create-stateholder` skill, which would have scaffolded the correct `ViewModelState` conformance, `InitializableDefault` protocol, and `UserViewModel` usage pattern. Instead the worker inferred patterns from 5 reference files via full `cat` reads, got 4 details wrong, and required a complete second fix pass. Enforcing skill-before-write discipline in `presentation-worker` would eliminate this class of rework entirely.
