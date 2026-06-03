---
name: debugger-add-logs
description: Add strategic debug logs to trace execution flow or diagnose a bug.
user-invocable: false
allowed-tools: Read, Edit, Glob, Grep
knowledge_scope: engineering/presentation
---

Add debug instrumentation logs following `lib/core/knowledge/{platform}/engineering/presentation/logging.md` for format and prefix rules.

## Steps

Follow the `INSTRUMENTATION_BRIEF` provided by the caller:

1. **Read** `lib/core/knowledge/{platform}/engineering/presentation/logging.md` for the platform's log format and prefix. Check `lib/core/knowledge/{project}/engineering/presentation/logging.md` first (project-specific override), fall back to `lib/core/knowledge/{platform}/engineering/presentation/logging.md` (platform-base).
2. `Grep` each target method name to locate the exact line
3. `Read` only the method body — not the full file
4. Insert logs at entry, exit, branch points, and error handlers as specified in the brief

## Rules

- Log only at locations specified in the brief
- Never modify logic
- Never log passwords or tokens — log `.length` / `.count` instead
- Never commit debug logs

## Output

List each file and line where a log was inserted.
