---
name: detective-debug-remove-logs
description: Remove all [DebugTest] debug print statements from the codebase before committing.
user-invocable: false
tools: Grep, Edit, Glob
---

# Debug: Remove Logs (iOS / Swift)

Remove all `print("[DebugTest]...)` and `.do(onNext:)` debug instrumentation added during debugging.

## Step 1 — Find All Debug Logs

```bash
grep -rn '\[DebugTest\]' Talenta/ --include="*.swift"
```

Or `Grep` with pattern `\[DebugTest\]` across all Swift files.

## Step 2 — Remove Each Log

For each file with matches:
- Remove standalone `print("[DebugTest]...)` lines entirely
- For `.do(onNext:)` blocks added purely for debugging — remove the entire `.do(onNext:)` operator
- Preserve any `.do(onNext:)` that existed before debugging (check git diff if uncertain)

## Step 3 — Verify

Run `Grep` again for `[DebugTest]` — result must be zero matches.

## Rules

- Never commit `[DebugTest]` logs — they are temporary instrumentation only
- If a log reveals a real issue, fix the issue, then still remove the log
- Do not remove non-`[DebugTest]` logging (production Logger calls, OSLog, etc.)

## Extension Point

Check for `.claude/skills.local/extensions/debug-remove-logs.md` — if it exists, follow its additional instructions.
