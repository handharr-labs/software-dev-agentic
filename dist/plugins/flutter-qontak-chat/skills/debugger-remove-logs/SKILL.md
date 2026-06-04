---
name: debugger-remove-logs
description: Remove all debug logs added by debugger-add-logs.
user-invocable: false
allowed-tools: Read, Edit, Glob, Grep
knowledge_scope: engineering
---

Remove all debug instrumentation logs using the platform's log prefix from `kms/knowledge-sources/engineering/{platform}-standard-architecture.md`.

## Steps

1. **Fetch pattern** — `kms_fetch(discipline="engineering", topic="presentation", pattern="logging", platform={platform}, project={project})` for the platform's debug log prefix (e.g. `[DebugTest]`). **Fallback** if KMS unavailable: `Read kms/knowledge-sources/engineering/{platform}-standard-architecture.md and locate the relevant section).
2. `Grep` the codebase for the debug prefix to find all instrumented files
3. For each file: `Read` the file, then `Edit` to remove every debug log line
4. Confirm no debug logs remain

## Rules

- Remove only debug log lines — never touch other logic
- Verify removal with a final grep for the prefix

## Output

List each file where logs were removed and confirm final grep shows zero matches.
