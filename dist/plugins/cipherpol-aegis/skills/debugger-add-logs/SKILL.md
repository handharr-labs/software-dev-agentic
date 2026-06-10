---
name: debugger-add-logs
description: Add strategic debug logs to trace execution flow or diagnose a bug.
user-invocable: false
allowed-tools: Read, Edit, Glob, Grep
knowledge_scope: engineering
---

Add debug instrumentation logs following the {platform} standard architecture in `kms/knowledge-sources/engineering/{platform}-standard-architecture.md` for format and prefix rules.

## Steps

Follow the `INSTRUMENTATION_BRIEF` provided by the caller:

1. **Fetch pattern** — `kms_query(text="debug logging format prefix naming convention", platform={platform}, discipline="engineering", n_results=3)` for the platform's log format and prefix. **Fallback** if no results: Read `kms/knowledge-sources/engineering/{platform}-standard-architecture.md` and locate the relevant section.
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
