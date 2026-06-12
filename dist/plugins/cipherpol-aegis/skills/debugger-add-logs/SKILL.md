---
name: debugger-add-logs
description: Add strategic debug logs to trace execution flow or diagnose a bug.
user-invocable: false
allowed-tools: Read, Edit, Glob, Grep, mcp__cp8__kms_list, mcp__cp8__kms_fetch
knowledge_scope: engineering
---

Add debug instrumentation logs following the {platform} standard architecture (loaded from the KMS) for format and prefix rules.

## Steps

Follow the `INSTRUMENTATION_BRIEF` provided by the caller:

1. **Load pattern** (fetch-by-topic — see `kms-conventions.md §Retrieval Protocol`). Logging lives under a platform-specific topic (flutter → `utilities`/`logger`; android → `presentation`/`logging`):
   - `kms_list(discipline="engineering", artifact="standard-architecture", platform={platform})` — scan the TOC for the logger/logging pattern slug.
   - `kms_fetch(discipline="engineering", artifact="standard-architecture", topic="<logging topic>", pattern="<logger slug from list>", platform={platform})` — full content: log format and prefix.
   - If the TOC has no logger pattern, STOP and report a KMS seed gap for `{platform}/engineering/standard-architecture` (logging) — do not guess.
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
