---
name: detective-debug-remove-logs
description: Remove all [DebugTest] console.log debug statements from the codebase before committing.
user-invocable: false
tools: Grep, Edit, Glob
---

# Debug: Remove Logs (Web / Next.js)

Remove all `console.log('[DebugTest]...)` and `console.error('[DebugTest]...)` statements added during debugging.

## Step 1 — Find All Debug Logs

`Grep` with pattern `\[DebugTest\]` across all `.ts` and `.tsx` files.

## Step 2 — Remove Each Log

For each file with matches:
- Remove standalone `console.log('[DebugTest]...)` lines entirely
- Remove standalone `console.error('[DebugTest]...)` lines entirely
- Preserve any non-`[DebugTest]` console statements that were pre-existing

## Step 3 — Verify

Run `Grep` again for `[DebugTest]` — result must be zero matches.

## Rules

- Never commit `[DebugTest]` logs — they are temporary instrumentation only
- Do not remove production logging (Logger, Sentry, analytics calls, etc.)
- If a log reveals a real issue, fix the issue, then still remove the log

## Extension Point

Check for `.claude/skills.local/extensions/debug-remove-logs.md` — if it exists, follow its additional instructions.
