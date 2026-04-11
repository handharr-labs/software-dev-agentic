# Agentic Performance Report — Issue #26

> Date: 2026-04-10
> Session: ee9f752f-50f1-4594-96e0-8cb2219cbbaf
> Branch: main (feature work on feat/issue-026-add-basic-rule-based-applicant-scoring)
> Duration: ~15 hr 15 min (2026-04-10T16:24:44Z → 2026-04-11T07:39:37Z)

## Summary Scores

| Dimension | Score | Rating | Key Signal |
|---|---|---|---|
| D1 · Orchestration Quality | 7/10 | Good | issue-worker + feature-orchestrator spawned correctly; no isolation set |
| D2 · Worker Invocation | 7/10 | Good | correct subagent types in sequence; isolation field empty for feature-orchestrator |
| D3 · Skill Execution | 6/10 | Fair | `release minor` fired correctly post-merge on main; pickup handled via agent not skill |
| D4 · Token Efficiency | 8/10 | Good | cache_hit_ratio 97.2% excellent; read_grep_ratio 37.0 is a critical P7 violation |
| D5 · Routing Accuracy | 7/10 | Good | feat/ branch prefix matches new feature work; feature-orchestrator appropriate |
| D6 · Workflow Compliance | 7/10 | Good | specific git add, no --no-verify, PR with Closes #; closed unrelated issues 42+44 |
| D7 · One-Shot Rate | 7/10 | Good | zero rejections, zero duplicate reads; 5x test reruns + 2x build reruns signal iteration |
| **Overall** | **7.0/10** | **Good** | |

## Token Breakdown

| Metric | Value |
|---|---|
| Input tokens | 1,861 |
| Cache creation | 536,267 |
| Cache reads | 18,555,856 |
| Output tokens | 106,098 |
| **Billed approx** | **644,226** |
| Cache hit ratio | 97.2% |
| Avg billed / turn | ~2,863 (225 turns) |

## Tool Usage

| Tool | Calls |
|---|---|
| Edit | 43 |
| Read | 37 |
| Bash | 31 |
| Glob | 10 |
| Write | 4 |
| Agent | 2 |
| Grep | 1 |
| Skill | 1 |

Read:Grep ratio: 37.0 (target < 3 — high ratio signals full-file reads over targeted search)

## Agent & Skill Invocations

| Component | Args / Description | Outcome |
|---|---|---|
| Agent: issue-worker | Pick up issue #26 | Correct — invoked first before any implementation work |
| Agent: feature-orchestrator | Implement applicant scoring feature | Correct agent type; no worktree isolation specified |
| Skill: release | minor | Correctly called on main after PR merge for a new feature version bump |

## Findings

### What went well
- Cache efficiency was excellent at 97.2%, indicating effective prompt caching across the long session
- Zero rejected tool calls and zero duplicate file reads across a 225-turn session
- `git add` used explicit file paths in all commits, not `-A` or `.`
- `issue-worker` was invoked before any implementation work began — correct CLAUDE.md workflow
- `release minor` was correctly chosen for a new feature addition
- Feature branch naming (`feat/issue-026-add-basic-rule-based-applicant-scoring`) correctly follows convention

### Issues found
- **[D4]** `read_grep_ratio` of 37.0 — 37 Read calls vs 1 Grep call. Files such as `Code.gs`, `CompanySettingsRepositoryImpl.ts`, `useCompanySettingsViewModel.ts`, and multiple test files were fully read when targeted Grep searches for specific symbols or patterns would have been sufficient
- **[D2]** `feature-orchestrator` spawned with `isolation: ""` — for a session spanning 15+ hours touching 30 write paths across domain, data, and presentation layers, worktree isolation would have prevented context bleed and allowed parallel worker execution
- **[D6]** `gh issue close 42 && gh issue close 44` executed during the session — closing issues outside the scope of issue #26 suggests scope creep or cleanup work that should have been a separate session or explicitly tracked
- **[D7]** `npm run test -- --run` executed 5 times and `npm run build` twice — multiple reruns indicate iterative test-fix cycles rather than writing correct tests first time; raises question of whether test-worker was underused
- **[D3]** The `pickup-issue` skill was not called directly; instead an `issue-worker` agent handled it. This is consistent with CLAUDE.md but the `skill_calls` array only shows `release` — no issue creation skill invocation appears in the skill log, which may mean issue pickup was done via agent tool rather than dedicated skill path

## Recommendations

1. **Highest impact fix — use Grep over Read for symbol lookup** — the read_grep_ratio of 37.0 is the single largest inefficiency. When exploring existing code to understand a type, method, or pattern, use Grep to locate the relevant lines rather than reading entire files. This alone can reduce billed tokens significantly on future sessions of similar scope.
2. **Enable worktree isolation for feature-orchestrator** — set `isolation: worktree` when spawning feature-orchestrator on tasks that touch more than 5 files across multiple layers. This prevents context contamination and enables the orchestrator to run domain, data, and presentation workers in parallel.
3. **Invoke test-worker earlier in the TDD cycle** — 5 test reruns suggest the implementation outpaced test validation. Invoking `test-worker` after each layer (domain → data → presentation) rather than at the end reduces rework and makes failures easier to isolate.
4. **Scope issue closures to the current issue** — closing issues #42 and #44 during an issue #26 session creates an implicit dependency that is hard to audit. Separate cleanup sessions or at minimum a comment on #26 linking the closures would improve traceability.
