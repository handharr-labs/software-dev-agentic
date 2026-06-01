# 10 — D6 Conditional Rules & Grep-First Callsite Analysis

**Date:** 2026-04-18
**Triggered by:** perf-report `perf-report-TLMN-5129.md` (session TLMN-5129, flag removal on iOS Talenta)

---

## Observations

### O1 — D6 penalised projects without issue tracking

`perf-worker.md` D6 scored a session down for not calling `pickup-issue` and not opening a PR, even though the downstream project (`talenta` iOS) does not use GitHub Issues as a workflow gate. The CLAUDE.md for that project has no `issue-worker` or `pickup-issue` reference.

**Impact:** D6 score of 7/10 instead of a fair 9/10 — recommendations #3 and #4 were noise for this project type.

### O2 — Impact analysis used 7 Read calls instead of 1 Grep

Before delegating to `feature-orchestrator`, the outer session opened each `isEnableLiveTracking` call site individually via `Read` to understand the surrounding semantics (guard-else vs always-true if-block). A single `Grep --context=5 isEnableLiveTracking **/*.swift` would have returned all call sites with context in one tool call.

**Impact:** read:grep ratio 4.5 (target <3); ~15% of session tokens (~115K) spent on the analysis phase when 1-2 tool calls would have sufficed.

### O3 — Wrong path inferred from module naming convention

The session attempted `Read` on `TalentaTM/Presentation/ViewModel/Dashboard/DashboardViewModel.swift`. The Grep output earlier in the session had already shown the correct path (`TalentaDashboard/Presentation/ViewModel/DashboardViewModel.swift`). The model inferred the path from module naming rather than re-reading the Grep result.

**Impact:** 1 rejected tool call, ~30K tokens wasted on retry (~4% of session).

---

## Changes Made

### `lib/core/agents/perf-worker.md` — D6 Conditional Rules

Split D6 checks into two tiers:

- **Always required:** feature branch (not main), `git add` with specific files, no `--no-verify`
- **Conditional** (only if project CLAUDE.md references issue tracking): `issue-worker`/`pickup-issue` called early, PR with `Closes #N`

Scorer must read the project's CLAUDE.md before applying any D6 check. If no issue workflow is mentioned, skip both conditional checks entirely — do not penalise.

### `lib/core/agents/developer/feature-orchestrator.md` — Path Verification Rule

Added to Search Protocol: before any `Read` call, verify the exact path from the most recent Grep output — never infer a path from module naming conventions or directory structure guesses. The rule includes a concrete counter-example (TalentaTM vs TalentaDashboard) to make the failure mode unambiguous.

### `lib/core/agents/developer/feature-orchestrator.md` — Callsite Analysis Rule

Added to Search Protocol: for symbol/flag impact analysis, use `Grep --context=N <symbol> **/*.<ext>` as a single discovery call. Only escalate to `Read` if the Grep context is genuinely insufficient for a specific line — and only after re-confirming the path from that Grep output. This directly addresses the 7-Read loop pattern observed in this session.

---

## Open Questions

- Should `perf-worker.md` auto-detect issue tracking from `CLAUDE.md` content (e.g. Grep for `issue-worker|pickup-issue|Jira|Linear`) rather than requiring the scorer to read the whole file? A Grep-based detection rule would be more robust and faster.
- The `--context=5` default in the Callsite Analysis rule is a reasonable starting point, but some flag removals (deeply nested conditionals) may need more lines. Should the rule specify a range (5–10) or leave it to judgment?
