---
name: detective-debug-remove-logs
description: Remove all debug log statements previously added by detective-debug-add-logs from flutter-mobile-jurnal files.
user-invocable: false
---

Remove debug logging added during a debug session.

## Steps

1. **Grep** across the feature for `Log.d(` patterns added during the debug session
2. **Read** each file that contains debug logs
3. **Remove** only the `Log.d` lines added for debugging — do not remove `Log.e`, `Log.w`, or `Log.i` that were pre-existing production logs
4. **Verify** no stray import is left unused after removal

## Identification

Debug logs added by `detective-debug-add-logs` follow the pattern:
```
Log.d('[<Feature>Bloc]
Log.d('[<Feature>Repo]
Log.d('[<Feature>Mapper]
```

## Grep Command

```bash
grep -rn "Log\.d('\[<Feature>" features/<feature>/lib/
```

## Rules

- Remove `Log.d` lines only — preserve `Log.e` and `Log.w` (production error/warning logging)
- Remove the log line entirely (do not replace with comment)
- If the debug log was the only statement in an `if` block, remove the entire `if` block

## Output

List all files modified and all log statements removed.
