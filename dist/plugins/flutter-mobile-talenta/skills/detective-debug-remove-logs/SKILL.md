---
name: detective-debug-remove-logs
description: Remove all [DebugTest] debugPrint debug statements from a Flutter/Dart codebase before committing.
user-invocable: false
tools: Grep, Edit, Glob
---

Remove all `debugPrint('[DebugTest]...)` statements added during debugging.

## Steps

1. `Grep` for `\[DebugTest\]` across all `.dart` files
2. For each match: remove the `debugPrint(...)` line entirely
3. Verify: run `Grep` again — result must be zero matches

## Rules

- Never remove non-`[DebugTest]` logging (print statements, Logger, etc.)
- Never remove adjacent code
