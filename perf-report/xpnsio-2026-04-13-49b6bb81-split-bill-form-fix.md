# Agentic Performance Report — split-bill-form-fix

> Date: 2026-04-13
> Session: 49b6bb81-6ed6-46a7-9e0f-c6a1409d2b3d
> Branch: feat/issue-073-split-bill-mvp
> Duration: ~3 min (2026-04-13T08:50:19Z → 2026-04-13T08:53:14Z)
> Evaluation: [04-delegation-guard-hook](../evaluation/04-delegation-guard-hook.md)

## Summary Scores

| Dimension | Score | Rating | Key Signal |
|---|---|---|---|
| D1 · Orchestration Quality | 8/10 | Good | N/A — no orchestrators spawned; inline work performed |
| D2 · Worker Invocation | 2/10 | Critical | Feature edit done inline; feature-orchestrator never delegated to |
| D3 · Skill Execution | 5/10 | Fair | No skill calls; issue-worker not required (already on branch from prior session) |
| D4 · Token Efficiency | 7/10 | Good | cache_hit_ratio 79.1% (Fair), read_grep_ratio 2 (Good), billed/turn ~8,385 (>5K) |
| D5 · Routing Accuracy | 4/10 | Poor | Branch prefix correct (feat/) but work was routed inline instead of to feature-orchestrator |
| D6 · Workflow Compliance | 5/10 | Fair | One CLAUDE.md rule violated: no feature-orchestrator delegation (issue-worker N/A — already on branch) |
| D7 · One-Shot Rate | 9/10 | Excellent | 0 rejected tools, 0 duplicate reads, single clean Edit, user/assistant ratio 0.73 |
| **Overall** | **5.9/10** | **Fair** | |

## Token Breakdown

| Metric | Value |
|---|---|
| Input tokens | 21 |
| Cache creation | 73,696 |
| Cache reads | 279,671 |
| Output tokens | 18,516 |
| **Billed approx** | **92,233** |
| Cache hit ratio | 79.1% |
| Avg billed / turn | ~8,385 |

## Tool Usage

| Tool | Calls |
|---|---|
| Read | 2 |
| Glob | 1 |
| Edit | 1 |
| Bash | 1 |

Read:Grep ratio: 2 (target < 3 — high ratio signals full-file reads over targeted search)

## Agent & Skill Invocations

| Component | Args / Description | Outcome |
|---|---|---|
| _(none)_ | No agents or skills were invoked | — |

## Findings

### What went well
- Zero rejected tool calls indicates clean, confident execution within the chosen (incorrect) approach.
- No duplicate file reads — each file read exactly once.
- Read:Grep ratio of 2 is below the target of 3, showing good use of targeted reads over broad file scanning.
- Single targeted Edit to the relevant file with no rework.
- Branch naming follows the `feat/` convention matching the task type.

### Issues found
- **[D2]** Feature work (editing `SplitBillFormView.tsx`) was performed inline. CLAUDE.md states explicitly: "Feature work (create or update, any scope) → always delegate to `feature-orchestrator`, never inline." This is a direct violation of the workflow mandate. **Recurring pattern** — delegation to feature-orchestrator continues to be skipped across sessions; this is not an isolated miss.
- **[D3]** N/A — session started on an existing branch (`feat/issue-073-split-bill-mvp`) from a prior session. Issue-worker had already been invoked; no re-invocation required.
- **[D4]** Average billed tokens per turn is ~8,385, exceeding the 5K/turn threshold. The cache_hit_ratio of 79.1% is in the Fair band (below the >90% target), suggesting opportunity for better cache reuse across this short session.
- **[D5]** Despite the correct branch prefix, the routing decision to work inline instead of delegating to `feature-orchestrator` means the task was misrouted at the execution level, even if branch classification was accurate.
- **[D6]** One core workflow rule from CLAUDE.md was bypassed: feature-orchestrator not delegated to for the presentation layer edit. Issue-worker is not a violation — branch was already established from a prior session.

## Recommendations

1. **Delegate all feature edits to `feature-orchestrator`** — even a single-file presentation fix qualifies as "feature work (create or update, any scope)" per CLAUDE.md. The orchestrator handles coordination, arch alignment, and correct worker dispatch that inline edits bypass entirely. This is a recurring failure across sessions and needs to be the default reflex, not an afterthought.
2. **Improve cache warm-up** — at 79.1% cache hit ratio, there is ~21% of tokens being re-processed. For short sessions on an established branch, ensuring CLAUDE.md and key context files are in the cache preamble would push this above 90%.
