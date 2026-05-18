# Orchestrator Read Discipline and Worktree Isolation at Invocation

> Date: 2026-04-14
> Type: Improvement
> Related: [06-delegation-guard-autonomous-resolution.md](./06-delegation-guard-autonomous-resolution.md)
> Sessions analysed: talenta-ios cico-no-location-hint (2026-04-14, session 05eb621f)
> Perf reports: [talenta-2026-04-14-cico-no-location-hint](../perf-report/talenta-2026-04-14-cico-no-location-hint.md)

## Trigger

The cico-no-location-hint session (6.6/10 — Fair) surfaced two distinct gaps not previously addressed:

- **[D1/D4]** `feature-orchestrator` performed 9 direct `Read` calls and 2 direct `Edit` calls on production source files before delegating to workers. The orchestrator has no enforcement against reading source files — it had `Read` in its tool list with no guidance on when to use it. This produced a `read:grep` ratio of 4.0 (target < 3) and caused `AttendanceCoordinator.swift` to be read 3 times and `AttendanceScheduleViewModel.swift` twice.

- **[D2]** The outer agent spawned `feature-orchestrator` without `isolation: worktree`. Entry 06 fixed `isolation: worktree` for worker spawns (inside the orchestrator), but the orchestrator itself was never required to run in isolation. The CLAUDE.md delegation rule said "always delegate to `feature-orchestrator`" — with no mention of isolation.

---

## Root Cause Analysis

### No Search Protocol in feature-orchestrator

Workers (`domain-worker`, `data-worker`, `presentation-worker`, `ui-worker`) all carry a "Search Protocol — Never Violate" table that mandates `Grep` over `Read` for symbol lookups. The `feature-orchestrator` had no equivalent — it only had a constraint saying "Workers own their own context reads — do not pre-read files on their behalf," which is about not doing workers' reads, not about the orchestrator's own investigation reads.

In practice, the orchestrator was doing source file investigation on behalf of itself (to build the delegation prompt), which is also a violation. The coordinator role does not require reading any production source file — all source context should come from the Explore agent output passed in by the user or outer agent.

### Delegation rule missing `isolation: worktree`

The CLAUDE-template delegation line for both `ios` and `web` platforms read:

```
Feature work → always delegate to `feature-orchestrator`, never inline.
```

This correctly mandates delegation but says nothing about how the orchestrator should be invoked. Without `isolation: worktree`, a mid-run failure leaves partial state (uncommitted edits, `.claude/runs/` artifacts) in the main working tree. For multi-file changes spanning protocol + implementation + ViewModels + tests, this is a meaningful risk.

---

## Changes Made

### Updated: `lib/core/agents/builder/feature-orchestrator.md`

Added "Search Protocol — Never Violate" section above the Constraints block:

```markdown
## Search Protocol — Never Violate

You are a pure coordinator. You never investigate source files.

| What you need | Tool |
|---|---|
| Whether a state/run file exists | `Glob` |
| A value inside a state/run file | `Read` — permitted |
| Anything in a production source file | **Delegate to a worker — never Read directly** |

If you find yourself about to `Read` a `.swift`, `.ts`, `.kt`, or other source file, stop.
Pass the intent to the appropriate worker instead.
```

### Updated: `lib/platforms/ios-talenta/CLAUDE-template.md` and `lib/platforms/web/CLAUDE-template.md`

Delegation rule updated to include `isolation: worktree`:

```markdown
# Before
**Feature work (create or update, any scope) → always delegate to `feature-orchestrator`, never inline.**

# After
**Feature work (create or update, any scope) → always delegate to `feature-orchestrator` with `isolation: worktree`, never inline.**
```

---

## Downstream Impact

| Project | Method | Changes synced |
|---------|--------|----------------|
| wehire | `sync.sh --platform=web` | v3.7.0 — feature-orchestrator + CLAUDE.md managed section |
| xpnsio | `sync.sh --platform=web` | v3.7.0 — feature-orchestrator + CLAUDE.md managed section |
| talenta-ios | Manual copy | feature-orchestrator.md + CLAUDE.md managed section updated directly |

---

## Resolved Open Questions from Entry 06

1. **iOS branch pattern** — Resolved in v3.5.0 (commit `9c8c998`). `require-feature-orchestrator.sh` now matches both `feat/*` and `feature/*` branch prefixes, covering the Bitbucket naming convention used by iOS projects.

---

## Open Questions

1. **Worker identity in hook** (carried from Entry 06) — the hook cannot distinguish a worker `Edit` (legitimate, inside worktree) from a root-agent `Edit` (violation). Worktree isolation reduces the risk since workers operate on a separate branch, but this is not verified by the hook. A future improvement could check whether the current working directory differs from the main project root as a proxy for "inside worker context."

2. **Orchestrator tool list still includes `Read`** — the Search Protocol forbids reading production source files, but `Read` remains in the frontmatter tool list. A future improvement could narrow the tool list to `Glob, Grep, Bash` only, making the constraint structural rather than instructional.
