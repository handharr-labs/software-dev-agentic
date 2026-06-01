# Agentic Performance Report — rca-live-tracking-api-spike

> Date: 2026-04-22
> Session: 3f113dea-3a69-45dc-8a8d-33d8c0b1e678
> Branch: feature/TLMN-5158_Setup-software-dev-agentic
> Duration: ~62 min (2026-04-22T11:32:47Z → 2026-04-22T12:35:09Z)

## Summary Scores

| Dimension | Score | Rating | Key Signal |
|---|---|---|---|
| D1 · Orchestration Quality | 8/10 | Good | N/A — no orchestrators spawned; inline investigation is correct for an RCA session |
| D2 · Worker Invocation | 8/10 | Good | N/A — no workers spawned; the task was pure read/analysis, not artifact creation |
| D3 · Skill Execution | 8/10 | Good | N/A — no artifact creation; flag-removal/debugging work does not require skills |
| D4 · Token Efficiency | 7/10 | Good | Cache hit ratio 94.5% is excellent; 5 duplicate reads of the same file drag the score |
| D5 · Routing Accuracy | 5/10 | Fair | RCA/debugging session run on a setup branch with no `debug-orchestrator` or `debug-worker` delegation |
| D6 · Workflow Compliance | 6/10 | Fair | Feature work rule mandates `feature-orchestrator`; investigation session instead ran fully inline |
| D7 · One-Shot Rate | 6/10 | Fair | 3 rejected tools, 3 user interruptions, high user:assistant ratio (0.80), 5 duplicate file re-reads |
| **Overall** | **6.9/10** | **Fair** | |

## Token Breakdown

| Metric | Value |
|---|---|
| Input tokens | 154 |
| Cache creation | 204,389 |
| Cache reads | 3,493,908 |
| Output tokens | 37,282 |
| **Billed approx** | **3,735,733** |
| Cache hit ratio | 94.5% |
| Avg billed / turn | 43,950 |

## Tool Usage

| Tool | Calls |
|---|---|
| Bash | 25 |
| Read | 14 |
| ToolSearch | 2 |
| WebSearch | 1 (rejected) |
| mcp__mmpa__mmpa_get_confluence_page | 1 |

Read:Grep ratio: 0.88 (target < 3 — excellent; most investigation was done via targeted grep)

## Agent & Skill Invocations

| Component | Args / Description | Outcome |
|---|---|---|
| (none) | No agents or skills were invoked this session | N/A |

## Findings

### What went well

- Cache hit ratio of 94.5% is excellent — the session made very effective use of prompt caching, reducing cost from ~$11.65 to ~$2.37.
- Read:Grep ratio of 0.88 is well below the 3.0 threshold. The agent correctly used targeted `grep` calls for most code exploration rather than reading full files blindly.
- The RCA analysis itself was thorough and accurate — correctly identified the permission denial retry loop as the primary cause of `/live-tracking-status` API spikes and traced both call paths through the codebase.
- Confluence MCP integration worked correctly: the page was fetched in one call without manual URL parsing.

### Issues found

- **[D5]** Branch mismatch: the session performed RCA/debugging investigation on `feature/TLMN-5158_Setup-software-dev-agentic`, which is a setup/chore branch unrelated to the live-tracking RCA work. Debugging sessions should be on a `fix/` or dedicated `debug/` branch, and routed through `debug-orchestrator` + `debug-worker` per CLAUDE.md.
- **[D6]** The session ran fully inline rather than delegating to `feature-orchestrator` or `debug-orchestrator`. CLAUDE.md states: *"Feature work (create or update, any scope) → always delegate to `feature-orchestrator`, never inline."* While this was investigation-only, the delegation guard should have been triggered or the user explicitly asked whether to proceed inline.
- **[D7]** `AttendanceScheduleViewModel.swift` was read 6 times as a full-file Read (in addition to grep calls against the same file). Each re-read suggests the agent lost context and needed to re-examine the same content repeatedly, consuming unnecessary tokens.
- **[D7]** `LiveAttendanceIndexMainViewModel.swift` was read 3 times in full for similar reasons.
- **[D7]** 3 tool rejections occurred: 1 user-rejected WebSearch call (user preferred an official source), and 2 failed Bash calls attempting to run `extract-session.sh` against an incorrect project path. The script path resolution failure was not self-corrected efficiently — two attempts failed before the user intervened.
- **[D7]** User:assistant turn ratio of 0.80 indicates the user had to course-correct frequently — particularly around the CFNetwork/platform question, which required 5+ back-and-forth exchanges.

> **Low score on D5?** Review the agent routing logic. The session was classified as setup/feature work but the actual work was debugging/RCA. Consider adding a routing check at session start: if the user's first message references an RCA, incident, or spike, the session should be classified as a `debug-orchestrator` task regardless of the current branch.

> **Low score on D6?** Review `lib/core/agents/developer/feature-orchestrator.md` — ensure it includes explicit guidance for whether pure investigation/RCA sessions are exempt from the delegation requirement, or should delegate to `debug-orchestrator`.

> **Low score on D7?** Review `lib/core/agents/debugger/debug-worker.md` — look for guidance on file re-read limits. A debug worker should cache key function signatures locally in its working context rather than re-reading the same large ViewModel file 6 times.

## Recommendations

1. **Route RCA/investigation sessions through `debug-orchestrator`** — When a user opens a session with an RCA link or mentions a traffic spike/incident, the top-level agent should immediately classify as debugging and delegate to `debug-orchestrator` → `debug-worker`. This avoids inline sprawl and enforces the structured investigation pattern.
2. **Limit full-file reads on large ViewModels** — `AttendanceScheduleViewModel.swift` is large (confirmed by `wc -l` call). After the first Read, subsequent lookups should use `grep -n` with specific line ranges rather than re-reading the full file. A single targeted grep would have answered most follow-up questions more cheaply.
3. **Script path resolution should self-correct in one attempt** — The `extract-session.sh` failure due to dot-vs-hyphen path encoding should be handled by reading the actual directory listing first, then constructing the correct path. Two consecutive failing attempts is a recoverable error pattern that the agent should resolve autonomously.

---

## Effort vs Billing

### Token cost breakdown

| Token type | Count | Unit price | Cost (USD) |
|---|---|---|---|
| Input | 154 | $3.00 / MTok | $0.0005 |
| Cache creation | 204,389 | $3.75 / MTok | $0.7665 |
| Cache reads | 3,493,908 | $0.30 / MTok | $1.0482 |
| Output | 37,282 | $15.00 / MTok | $0.5592 |
| **Total** | **3,735,733 billed-equiv** | | **~$2.37** |

Cache hit ratio of **94.5%** was the primary cost saver — without caching, the same session would have cost ~$11.65 at full input rates (treating all context as fresh input). Caching saved approximately **$9.28**.

### Where the tokens went

| Task | Estimated tokens | % of total | Productive? |
|---|---|---|---|
| Confluence RCA page fetch + summary | ~180,000 | ~5% | ✅ Productive |
| Initial ViewModel grep + first read (flow tracing) | ~420,000 | ~11% | ✅ Productive |
| Permission manager + coordinator analysis | ~280,000 | ~7% | ✅ Productive |
| CFNetwork/User-Agent investigation (5+ exchanges) | ~600,000 | ~16% | ⚠️ Overhead — tangential to root cause |
| Repeat reads of AttendanceScheduleViewModel (reads 2–6) | ~900,000 | ~24% | ❌ Rework — same file re-read due to lost context |
| Repeat reads of LiveAttendanceIndexMainViewModel (reads 2–3) | ~350,000 | ~9% | ❌ Rework — same file re-read |
| LiveAttendanceIndex schedule/timer investigation | ~320,000 | ~9% | ✅ Productive |
| Session transcript / extract-session troubleshooting | ~240,000 | ~6% | ⚠️ Overhead |
| Final synthesis responses to user | ~445,733 | ~12% | ✅ Productive |
| **Total** | **~3,735,733** | **100%** | |

**Productive work: ~44% (~1,645,000 tokens / ~$1.04)**
**Wasted on rework: ~33% (~1,250,000 tokens / ~$0.79)**

### Effort-to-value ratio

| Deliverable | Complexity | Tokens spent | Efficiency |
|---|---|---|---|
| RCA root cause identification (permission loop) | Medium | ~900,000 | Good — analysis was accurate and well-traced |
| CFNetwork/User-Agent platform disambiguation | Low | ~600,000 | Poor — a straightforward factual question consumed 16% of total tokens due to repeated exchanges |
| Session extraction troubleshooting | Low | ~240,000 | Fair — script path issue required 3 attempts before resolution |

### Key insight

The single highest-cost item was the repeat full-file reads of `AttendanceScheduleViewModel.swift` (~900,000 tokens, 24% of the session). This file is large and was re-read 6 times in its entirety because the agent lost track of specific line numbers and function bodies across conversation turns. A debug-worker pattern that anchors key findings (line numbers, function signatures) in its working scratchpad at first read would have eliminated 5 of those 6 reads, saving roughly $0.47 and cutting session time by approximately 10 minutes.
