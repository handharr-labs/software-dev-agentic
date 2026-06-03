---
name: debugger-remove-logs
description: Remove all debug logs added by debugger-add-logs.
user-invocable: false
allowed-tools: Read, Edit, Glob, Grep
knowledge_scope: engineering/presentation
---

Remove all debug instrumentation logs using the platform's log prefix from `lib/core/knowledge/{platform}/engineering/presentation/logging.md`.

## Steps

1. **Read** `lib/core/knowledge/{platform}/engineering/presentation/logging.md` for the platform's debug log prefix (e.g. `[DebugTest]`). Check `lib/core/knowledge/{project}/engineering/presentation/logging.md` first (project-specific override), fall back to `lib/core/knowledge/{platform}/engineering/presentation/logging.md` (platform-base).
2. `Grep` the codebase for the debug prefix to find all instrumented files
3. For each file: `Read` the file, then `Edit` to remove every debug log line
4. Confirm no debug logs remain

## Rules

- Remove only debug log lines — never touch other logic
- Verify removal with a final grep for the prefix

## Output

List each file where logs were removed and confirm final grep shows zero matches.
