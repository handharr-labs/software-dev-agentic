# 11 — D5 Workflow Intent & Vendor Library Grep-First

**Date:** 2026-04-20
**Triggered by:** perf-reports `xpnsio-2026-04-19-305f9697-split-bill-dropdown-bg-fix.md`, `xpnsio-2026-04-19-e6748dd1-fix-skeleton-height-classes.md`

---

## Observations

### O1 — D5/D6 penalised intentional main-branch workflow

Both sessions started on `main` and were scored Poor/Fair on D5 (Routing Accuracy) and D6 (Workflow Compliance). On review, the user explicitly initiated both sessions via "create issue and pick up" — a workflow where starting on `main` before branching is the intended sequence.

The perf-worker had no concept of user-initiated workflow context. It applied the fix-branch rule unconditionally, treating a deliberate choice as a routing failure.

**Impact:** Issue #99 D5 over-penalised by 2 points (6→8), D6 by 1 point (4→5). Issue #97 D5 over-penalised by 4 points (4→8), D6 by 4 points (3→7). Overall scores revised from 6.7→7.1 and 6.1→7.3 respectively.

### O2 — debug-worker used find/ls to explore node_modules instead of Grep

In the Issue #99 session, the debug phase executed 15 Bash `find`/`ls` commands to navigate `node_modules/@base-ui/react` looking for the CSS class responsible for the dropdown background. A single `Grep -rn "background" node_modules/@base-ui/react/select/popup/` would have surfaced the relevant file in one pass.

**Impact:** ~55K tokens (~31% of session) spent on the investigation phase, predominantly on directory listings that generated high-volume output flowing through context. A targeted Grep would have reduced this by an estimated 40%.

### O3 — Grep-first rule in feature-orchestrator had no exception for dynamic patterns

The Explore Agent Grep-First rule in `feature-orchestrator.md` instructed agents to always Grep for class names before reading files. This is correct for static string literals, but would fail silently for dynamically-constructed patterns — e.g. Tailwind classes built via template strings (`` `h-${size}` ``). A literal Grep for `h-8` would miss any file using dynamic construction, leading the Explore agent to the wrong target.

**Impact:** No observed failure yet, but the rule as written was a latent bug for any project using programmatic Tailwind class generation.

---

## Changes Made

### `lib/core/agents/detective/debug-worker.md` — Third-Party Library Investigation rule

Added a dedicated subsection under the Search Protocol for vendor/node_modules investigation:

- Prefer `Grep -rn "pattern" node_modules/@vendor/package/` over `find`/`ls` directory navigation
- If the pattern is unknown, Grep for a related symbol from the error message first to narrow the target directory
- Never navigate a vendor directory speculatively with directory listings

### `lib/core/agents/builder/feature-orchestrator.md` — Dynamic pattern exception

Extended the Explore Agent Grep-First Rule with an explicit exception:

- If the target pattern may be constructed at runtime (Tailwind template strings, feature-flag-assembled identifiers), Grep for the literal will miss matches
- In that case: use Glob to list candidate files, Read only the files most likely to contain the pattern based on naming conventions
- Require the agent to document the reason for skipping Grep in the exploration prompt

### Perf reports revised

Both perf reports updated to reflect corrected D5/D6 scores and revised findings:
- D5/D6 branch routing findings replaced with accurate workflow-intent context
- Recommendations that assumed branch routing was wrong removed or reframed

---

## Open Questions

- Should `perf-worker.md` detect user workflow intent automatically — e.g. by checking whether the session's first agent call was `issue-worker` and treating that as a signal that main-branch initiation was expected? This would make the correction automatic rather than requiring manual score revision.
- The 15-Bash-call node_modules pattern in Issue #99 suggests debug-worker's existing Search Protocol (which does say "Grep first") wasn't being applied to the vendor-exploration context. Worth checking whether the protocol needs a more explicit trigger: "when the error implicates a third-party package" as a step in the call-chain trace, not just as a general principle.
