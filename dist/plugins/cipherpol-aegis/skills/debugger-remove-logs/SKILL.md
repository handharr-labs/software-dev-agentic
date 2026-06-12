---
name: debugger-remove-logs
description: Remove all debug logs added by debugger-add-logs.
user-invocable: false
allowed-tools: Read, Edit, Glob, Grep, mcp__cp8__kms_list, mcp__cp8__kms_fetch
knowledge_scope: engineering
---

Remove all debug instrumentation logs using the platform's log prefix, loaded from the KMS.

## Steps

1. **Load pattern** (fetch-by-topic — see `kms-conventions.md §Retrieval Protocol`). Logging lives under a platform-specific topic (flutter → `utilities`/`logger`; android → `presentation`/`logging`):
   - `kms_list(discipline="engineering", artifact="standard-architecture", platform={platform})` — scan the TOC for the logger/logging pattern slug.
   - `kms_fetch(discipline="engineering", artifact="standard-architecture", topic="<logging topic>", pattern="<logger slug from list>", platform={platform})` — full content: the debug log prefix (e.g. `[DebugTest]`).
   - If the TOC has no logger pattern, STOP and report a KMS seed gap for `{platform}/engineering/standard-architecture` (logging) — do not guess.
2. `Grep` the codebase for the debug prefix to find all instrumented files
3. For each file: `Read` the file, then `Edit` to remove every debug log line
4. Confirm no debug logs remain

## Rules

- Remove only debug log lines — never touch other logic
- Verify removal with a final grep for the prefix

## Output

List each file where logs were removed and confirm final grep shows zero matches.
