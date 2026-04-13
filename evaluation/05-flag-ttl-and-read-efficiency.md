# Delegation Flag TTL and Orchestrator Read Efficiency

> Date: 2026-04-13
> Type: Improvement
> Related: [04-delegation-guard-hook.md](./04-delegation-guard-hook.md)
> Sessions analysed: xpnsio split-bill-ux-update (2026-04-13, session 5b24aae9)
> Perf reports: [xpnsio-2026-04-13-5b24aae9-split-bill-ux-update](../perf-report/xpnsio-2026-04-13-5b24aae9-split-bill-ux-update.md)

## Trigger

Perf report for xpnsio split-bill-ux-update (session 5b24aae9) scored 8.0/10 (Good). Two findings drove changes:

- **D4 (Token Efficiency, 8/10)**: `read_grep_ratio` at exactly 3.0 — the upper boundary of the Good/Fair threshold. `pres-orchestrator` was reading full UseCase files to confirm signatures before spawning workers, where targeted Grep would suffice.
- **D1 (Orchestration Quality, 8/10)**: root agent read 3 source files before delegating to `feature-orchestrator`. Noted for context — see Root Cause Analysis below.

The session also surfaced Open Question #2 from Entry 04: if the orchestrator is interrupted before Phase 5, the delegation flag is never cleared, leaving the hook permanently disarmed on that branch.

---

## Root Cause Analysis

### Interrupted orchestrator — orphaned flag

The `.delegated-<branch>` flag is created at Pre-flight and removed at Phase 5. If the orchestrator crashes, is interrupted, or the user ends the session mid-way, the `rm -f` in Phase 5 never runs. The flag sits on disk indefinitely. The hook stays disarmed. Subsequent sessions on the same branch bypass the delegation guard entirely — defeating the purpose of the hook.

There is no external signal (session end, process termination) available to a PreToolUse bash hook to detect this condition. The only reliable recovery mechanism is time-based: treat the flag as stale after a fixed TTL.

**TTL choice — 4 hours:** A complex multi-layer feature orchestration (all four layers + tests) takes roughly 30–90 minutes in practice. 4 hours gives enough headroom for the longest realistic session while being short enough to auto-recover within a working day if something goes wrong.

### pres-orchestrator reading full UseCase files

`pres-orchestrator` Phase 0 said: *"Read the existing UseCase files to confirm their signatures before proceeding."* This was intentionally conservative — UseCase signatures are load-bearing inputs to `presentation-worker`, and guessing them produces broken StateHolder contracts.

However, what the orchestrator actually needs is narrow: the class/struct name, parameter types, and return type of `execute`. These are always in the first 10–20 lines of a UseCase file. Reading the full file to get this is wasteful, and it drives the `read_grep_ratio` upward across the session.

### Root agent reading files before delegating (D1)

The `require-feature-orchestrator` hook blocks **Write/Edit** without delegation — it does not and should not block **Read/Grep/Glob**. The root agent reading PRD or config files before delegating is fine. The specific issue is reading *source files* (ViewModels, Views) at the root level before the orchestrator has been invoked — this is a token efficiency problem, not a correctness problem.

This is a downstream CLAUDE.md concern (guidance to the root agent), not something enforceable from this repo without over-reaching into the host project's instructions. Not fixed at the tooling level.

---

## Changes Made

### Updated: `lib/core/hooks/require-feature-orchestrator.sh`

Flag check upgraded from a simple `-f` existence test to a TTL-aware check:

```bash
# Before
if [[ -f "$FLAG_FILE" ]]; then
  exit 0
fi

# After
if [[ -f "$FLAG_FILE" ]]; then
  FLAG_TIME=$(cat "$FLAG_FILE" 2>/dev/null || echo 0)
  NOW=$(date +%s)
  AGE=$((NOW - FLAG_TIME))
  if [[ "$AGE" -lt 14400 ]]; then
    exit 0
  fi
  # Stale flag (> 4h) — fall through to block
fi
```

Block message updated: `(not found or stale > 4h)`.

### Updated: `lib/core/agents/builder/feature-orchestrator.md`

Pre-flight flag creation changed from `touch` (empty file) to writing the current epoch:

```bash
# Before
touch "$(git rev-parse --show-toplevel)/.claude/.delegated-$(git branch --show-current | tr '/' '-')"

# After
date +%s > "$(git rev-parse --show-toplevel)/.claude/.delegated-$(git branch --show-current | tr '/' '-')"
```

### Updated: `lib/core/agents/builder/pres-orchestrator.md`

Phase 0 guidance and Constraints updated to Grep-first:

- **Phase 0** (was): *"Read the existing UseCase files to confirm their signatures before proceeding."*
- **Phase 0** (now): *"Grep the existing UseCase files for class/struct definitions and `execute` method signatures. Only Read the full file if Grep returns no results."*
- **Constraints** (was): *"Always read existing UseCase files before spawning `presentation-worker` — never guess signatures"*
- **Constraints** (now): *"Always confirm UseCase signatures before spawning `presentation-worker` — Grep for class/struct definitions and `execute` signatures first; only Read the full file if Grep returns no results. Never guess signatures."*

---

## Downstream Impact

| Project | Method | Changes synced |
|---------|--------|----------------|
| xpnsio | Submodule update | v3.4.6 — all three files |
| wehire | Submodule update | v3.4.6 — all three files |
| talenta-ios | Manual copy | Hook + both agent files copied directly |

---

## Resolved Open Questions from Entry 04

**#2 — Flag cleanup on branch delete / interrupted session**: Resolved by the 4h TTL. The flag is now self-expiring. A periodic cleanup in `sync.sh` is no longer necessary.

---

## Open Questions

1. **Hook coverage for iOS** (carried from Entry 04) — `require-feature-orchestrator.sh` is platform-agnostic and works for iOS, but iOS branch convention is `feature/*` (Bitbucket), not `feat/*`. The hook currently only checks `feat/*`. iOS projects may need the hook extended or the branch pattern made configurable.

2. **Root agent read discipline** — D1 findings (root agent reading source files before delegating) are recurring but not enforced at tooling level. A downstream CLAUDE.md rule could address this: *"On feat/* branches, do not Read feature source files at the root level — pass intent only to feature-orchestrator."* Worth adding to the CLAUDE templates in a future entry.
