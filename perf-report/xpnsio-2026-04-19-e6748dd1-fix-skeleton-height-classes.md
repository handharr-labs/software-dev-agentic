# Agentic Performance Report — Issue #97

> Date: 2026-04-19
> Session: e6748dd1-51f6-49ef-a2cc-4b5b6d3de22b
> Branch: main
> Duration: ~57 min (2026-04-19T16:15:44Z → 2026-04-19T17:12:25Z)

## Summary Scores

| Dimension | Score | Rating | Key Signal |
|---|---|---|---|
| D1 · Orchestration Quality | 8/10 | Good | feature-orchestrator correctly delegated to; no inline file edits by orchestrator |
| D2 · Worker Invocation | 7/10 | Good | issue-worker + feature-orchestrator appropriate; no domain/data workers needed for a CSS fix |
| D3 · Skill Execution | 8/10 | Good | N/A — artifact update to an existing view with no new file creation; inline fix appropriate |
| D4 · Token Efficiency | 6/10 | Fair | cache_hit_ratio 0.85 (Good), but read_grep_ratio 4 (Fair) and avg billed/turn ~5002 (borderline Poor) |
| D5 · Routing Accuracy | 4/10 | Poor | Work executed on `main` branch instead of `fix/` branch; branch mismatch is a clear routing failure |
| D6 · Workflow Compliance | 3/10 | Poor | Work committed directly to `main` — violates the feature-branch rule; `git checkout fix/skeleton-detail-screens` appeared after the work was done |
| D7 · One-Shot Rate | 7/10 | Good | 0 rejected tools, 0 duplicate reads; user/assistant turn ratio 0.775 is slightly high but within range |
| **Overall** | **6.1/10** | **Fair** | |

## Token Breakdown

| Metric | Value |
|---|---|
| Input tokens | 263 |
| Cache creation | 188,889 |
| Cache reads | 1,071,746 |
| Output tokens | 10,909 |
| **Billed approx** | **200,061** |
| Cache hit ratio | 85% |
| Avg billed / turn | ~5,002 |

## Tool Usage

| Tool | Calls |
|---|---|
| Bash | 11 |
| Read | 4 |
| Glob | 2 |
| Agent | 2 |
| Edit | 1 |

Read:Grep ratio: 4 (target < 3 — high ratio signals full-file reads over targeted search; no Grep calls were made, 4 Reads used instead)

## Agent & Skill Invocations

| Component | Args / Description | Outcome |
|---|---|---|
| Agent: issue-worker | Create GitHub issue for skeleton purge bug | ✓ Issue #97 created correctly |
| Agent: feature-orchestrator | Fix skeleton height classes in detail screens | ✓ Fix applied to SplitBillManageView.tsx and TripDetailView.tsx |

## Findings

### What went well
- The orchestration pattern was correct: `issue-worker` was spawned first to create the issue, then `feature-orchestrator` was delegated to for the fix — matching the required workflow order.
- Zero rejected tool calls and zero duplicate reads indicate a clean, focused execution with no confusion or backtracking.
- Cache hit ratio of 85% is in the Good range, keeping costs low relative to the volume of context loaded.
- No skill calls were needed for this session. The work was a targeted update to an existing view file (replacing Tailwind height classes with inline styles) — not a new artifact creation — so skipping skills was correct.
- The `feature-orchestrator` was used rather than attempting inline edits, complying with CLAUDE.md's delegation rule.

### Issues found
- **[D5][D6]** Work was executed on `main` — the `git_branch` field records `main` as the active branch at session start. The bash command `git checkout fix/skeleton-detail-screens` appears in the log, but it runs mid-session after work had already been initiated. The PR was eventually created from `fix/skeleton-detail-screens`, but session routing began on the wrong branch, risking accidental commits to `main`. This violates the fundamental workflow rule requiring all feature/fix work to start on a dedicated branch.
- **[D4]** `read_grep_ratio` of 4 — `SplitBillManageView.tsx` and `TripDetailView.tsx` were Read in full rather than using Grep to locate the specific skeleton class patterns (`h-8`, `h-24`) first. Targeted Grep would have reduced token consumption and confirmed the right files before full reads.
- **[D4]** Average billed tokens per turn is ~5,002 — at the boundary of the Poor threshold (>5K). The large cache-creation cost (188,889 tokens) for a relatively small fix session suggests context was loaded that may not have been necessary.

> **Low score on D5?** Run `prompt-debug-worker` with this report + the agent's .md file to surface ambiguous instructions that caused this behavior.
> Agent file: `lib/core/agents/builder/feature-orchestrator.md`

> **Low score on D6?** Run `prompt-debug-worker` with this report + the agent's .md file to surface ambiguous instructions that caused this behavior.
> Agent file: `lib/core/agents/builder/feature-orchestrator.md`

## Recommendations

1. **Highest impact fix — enforce branch checkout before any work begins.** The feature-orchestrator (or the orchestrating agent) must verify the active branch is a `fix/` or `feat/` branch before spawning any workers or calling any tools. Add a pre-flight branch check as the first Bash step: `git branch --show-current` and abort with a user prompt if the result is `main`.
2. **Switch to Grep-first file discovery.** Before reading `SplitBillManageView.tsx` and `TripDetailView.tsx` in full, the Explore agent should Grep for `h-8\|h-24` across `src/features/` to confirm which files contain the problematic classes. This matches the CLAUDE.md "Explore agent — always Grep-first" rule and would reduce token spend per file discovery.
3. **Reduce cache-creation overhead for small bug fixes.** A fix touching a single view file produced 188K cache-creation tokens. Review whether the full project context is being loaded into cache for sessions that only need a narrow file scope.

---

## Effort vs Billing

### Token cost breakdown

| Token type | Count | Unit price | Cost (USD) |
|---|---|---|---|
| Input | 263 | $3.00 / MTok | $0.00 |
| Cache creation | 188,889 | $3.75 / MTok | $0.71 |
| Cache reads | 1,071,746 | $0.30 / MTok | $0.32 |
| Output | 10,909 | $15.00 / MTok | $0.16 |
| **Total** | **200,061 billed-equiv** | | **~$1.19** |

Cache hit ratio of **85%** was the primary cost saver — without it, the same session would have cost approximately $3.95 at full input rates (treating all cache reads as fresh input tokens), a saving of ~$2.76 (70% reduction).

### Where the tokens went

| Task | Estimated tokens | % of total | Productive? |
|---|---|---|---|
| Issue creation (issue-worker spawn + GitHub API) | ~15,000 | 7% | ✅ |
| Context loading / MEMORY.md + issue summary read | ~20,000 | 10% | ⚠️ |
| Explore: reading SplitBillManageView.tsx + TripDetailView.tsx | ~40,000 | 20% | ✅ |
| feature-orchestrator coordination + fix planning | ~60,000 | 30% | ✅ |
| Edit application + git operations | ~25,000 | 13% | ✅ |
| PR creation + branch management | ~20,000 | 10% | ✅ |
| Branch routing confusion (work on main before checkout) | ~20,000 | 10% | ❌ |
| **Total** | **~200,000** | **100%** | |

**Productive work: ~80% (~160,000 tokens / ~$0.95)**
**Wasted on rework: ~10% (~20,000 tokens / ~$0.12)**

### Effort-to-value ratio

| Deliverable | Complexity | Tokens spent | Efficiency |
|---|---|---|---|
| GitHub issue #97 created | Low | ~15,000 | Good — proportionate for issue creation with context |
| Skeleton height class fix in SplitBillManageView.tsx | Low | ~80,000 | Fair — a targeted CSS class replacement in one file; token spend is moderate for the simplicity of the change |
| Branch setup + PR creation | Low | ~40,000 | Fair — branch checkout appearing mid-session added unnecessary Bash overhead |

### Key insight

The single highest-cost item was the feature-orchestrator coordination and fix-planning phase (~60,000 tokens, 30% of total), which is disproportionate for a one-line CSS class replacement. A fix of this nature — swapping `h-8`/`h-24` Tailwind classes for inline styles in one or two view files — is a Low complexity change that should consume well under 50K tokens end-to-end. The elevated cost likely stems from two compounding factors: (1) the session started on `main` rather than the target branch, requiring additional branch management Bash calls mid-session, and (2) the full view files were read rather than using Grep to pinpoint the exact lines, causing the orchestrator to process more file content than necessary before delegating the edit. Together these inflated what should have been a ~$0.50 session to ~$1.19.
