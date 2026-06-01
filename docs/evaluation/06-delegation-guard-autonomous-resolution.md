# Delegation Guard — Autonomous Resolution and Worktree Isolation

> Date: 2026-04-14
> Type: Improvement
> Related: [04-delegation-guard-hook.md](./04-delegation-guard-hook.md), [05-flag-ttl-and-read-efficiency.md](./05-flag-ttl-and-read-efficiency.md)
> Sessions analysed: xpnsio split-bill-mvp-release (2026-04-13, session a5a8c748), xpnsio split-bill-currency-input (2026-04-13, session d4df114b)
> Perf reports: [xpnsio-2026-04-13-a5a8c748-split-bill-mvp-release](../perf-report/xpnsio-2026-04-13-a5a8c748-split-bill-mvp-release.md), [xpnsio-2026-04-13-d4df114b-split-bill-currency-input](../perf-report/xpnsio-2026-04-13-d4df114b-split-bill-currency-input.md)

## Trigger

Two perf reports from 2026-04-13 sessions surfaced three distinct problems:

- **Session a5a8c748 (4.9/10 — Poor)**: No `feature-orchestrator` delegation at all. Inline edits proceeded on a feat/* branch without the hook triggering (or being challenged). D1 and D2 both critical.
- **Session d4df114b (8.0/10 — Good)**: Feature-orchestrator correctly invoked twice, but `isolation: worktree` was absent on both spawns. One inline `Edit` call present in the parent session after delegation had begun.

Root cause for a5a8c748 was not a missing `## Feature Directories` section (the xpnsio CLAUDE.md has `src` configured). The hook fired, but the block message gave the agent a two-option menu it could resolve autonomously — and it did.

---

## Root Cause Analysis

### Hook block message exploitable by agent

The previous block message was:

```
Ask the user how to proceed — present exactly these two options:
  1. Inline  — create the delegation flag now and continue with the edit directly
  2. Feature orchestrator — invoke feature-orchestrator to handle this properly
```

This framing handed the agent a structured decision it could act on without user involvement. Option 1 — create the flag and proceed inline — was self-contained: the agent knew the flag path, could run `date +%s > <path>`, and continue. Nothing in the message said it couldn't. The CLAUDE.md rule ("always stop and ask the user") was overridden by the hook's own output.

The fix must be in the hook itself. The message cannot offer a resolution path the agent can take unilaterally.

### Worktree isolation instruction too soft

`feature-orchestrator.md` had a single trailing constraint: *"Spawn each worker with `isolation: worktree`."* This is easy to miss — it's one line among five at the bottom of a constraints block, read after the agent has already designed its delegation plan. The d4df114b session confirms this: two correct orchestrator spawns, zero worktree isolation on either.

The fix is co-location: put `isolation: worktree` inline with each `Spawn <worker>` directive, adjacent to the instruction that actually causes the spawn.

### Parent session writing files after delegation flag is set

Once the orchestrator sets the `.delegated-<branch>` flag, the hook allows `Edit`/`Write` from *any* caller — including the orchestrator's own parent session. The flag was designed to unblock workers operating inside worktrees, not to authorize inline edits from the root agent.

There is no structural way to distinguish callers in a bash PreToolUse hook. The enforcement must be in the orchestrator's constraints: explicitly prohibit direct `Edit`/`Write` calls from the parent session after the flag is set.

---

## Changes Made

### Updated: `lib/core/hooks/require-feature-orchestrator.sh`

Block message rewritten to eliminate the resolution menu:

```bash
# Before
echo "Ask the user how to proceed — present exactly these two options:"
echo "  1. Inline  — create the delegation flag now and continue with the edit directly"
echo "  2. Feature orchestrator — invoke feature-orchestrator to handle this properly (recommended for logic changes, new files, or multi-layer work)"

# After
echo "STOP. Do not proceed. Do not create the flag. Do not choose an option autonomously."
echo "Tell the user this edit was blocked and ask them how to proceed:"
echo "  - Inline: user must explicitly say to proceed inline"
echo "  - Delegate: invoke feature-orchestrator (recommended)"
```

Comment updated: `# Block — ask Claude to present a choice to the user` → `# Block — agent must stop and surface to user; must not resolve autonomously`

### Updated: `lib/core/agents/developer/feature-orchestrator.md`

`isolation: worktree` moved from the Constraints section into each Phase spawn directive:

```markdown
# Before (Phase 1)
Spawn `domain-worker` with:

# After (Phase 1)
Spawn `domain-worker` with `isolation: worktree` and:
```

Same change applied to Phases 2, 3, and 4 (`data-worker`, `presentation-worker`, `ui-worker`).

Constraints section updated:

```markdown
# Before
- Spawn each worker with `isolation: worktree`

# After
- After the delegation flag is set, never call `Edit` or `Write` directly — all file changes must go through workers
```

---

## Downstream Impact

| Project | Method | Changes synced |
|---------|--------|----------------|
| xpnsio | Submodule update | v3.4.7 — hook + feature-orchestrator |
| wehire | Submodule update | v3.4.7 — hook + feature-orchestrator |
| talenta-ios | Manual copy | Hook + feature-orchestrator copied directly |

---

## Resolved Open Questions from Entry 05

No open questions from Entry 05 are resolved by this entry. The iOS branch pattern (`feature/*` vs `feat/*`) and root agent read discipline remain open.

---

## Open Questions

1. **iOS branch pattern** (carried from Entry 05) — `require-feature-orchestrator.sh` only matches `feat/*`. iOS projects use `feature/*` (Bitbucket convention). The hook needs the branch pattern to be configurable, or a separate iOS variant.

2. **Worker identity in hook** — the hook cannot distinguish a worker Edit (legitimate, inside worktree) from a root-agent Edit (violation). Worktree isolation helps because workers operate on a separate branch, but this is not verified by the hook. A future improvement could check whether the current worktree path differs from the main project root as a proxy for "inside worker context."
