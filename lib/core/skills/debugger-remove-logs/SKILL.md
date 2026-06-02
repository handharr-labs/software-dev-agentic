---
name: debugger-remove-logs
description: Remove all debug logs added by debugger-add-logs.
user-invocable: false
allowed-tools: Read, Edit, Glob, Grep
---

Remove all debug instrumentation logs using the platform's log prefix from `.claude/reference/code-architecture/presentation-impl.md ## Logging`.

## Steps

1. **Read** `.claude/reference/code-architecture/presentation-impl.md` — locate `## Logging` for the platform's debug log prefix (e.g. `[DebugTest]`)
2. `Grep` the codebase for the debug prefix to find all instrumented files
3. For each file: `Read` the file, then `Edit` to remove every debug log line
4. Confirm no debug logs remain

## Rules

- Remove only debug log lines — never touch other logic
- Verify removal with a final grep for the prefix

## Output

List each file where logs were removed and confirm final grep shows zero matches.
