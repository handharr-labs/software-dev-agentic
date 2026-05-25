---
name: detective-debug-remove-logs
description: Remove all DebugTest Log.d debug statements from a Kotlin/Android codebase before committing.
user-invocable: false
tools: Grep, Edit, Glob
---

Remove all `Log.d("DebugTest", ...)` statements added during debugging.

## Steps

1. `Grep` for `Log.d("DebugTest"` across all `.kt` files
2. For each match: remove the `Log.d(...)` line entirely
3. Verify: run `Grep` again — result must be zero matches

## Rules

- Never remove non-`DebugTest` Log.d calls
- Never remove adjacent code
