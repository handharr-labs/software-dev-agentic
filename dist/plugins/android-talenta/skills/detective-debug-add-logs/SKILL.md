---
name: detective-debug-add-logs
description: Add strategic debug logs to a Kotlin/Android codebase using Log.d with [DebugTest] tag.
user-invocable: false
tools: Read, Edit, Glob, Grep
---

Add debug instrumentation logs using `Log.d` with `[DebugTest]` tag.

## Log Format

```kotlin
Log.d("DebugTest", "[MethodName] entry — param: $param")
Log.d("DebugTest", "[MethodName] state — before: $before, after: $after")
Log.d("DebugTest", "[MethodName] error — $error")
```

## Steps

Follow the `INSTRUMENTATION_BRIEF` provided by the caller:

1. `Grep` each target method name to locate the exact line
2. `Read` only the method body — not the full file
3. Insert `Log.d("DebugTest", "...")` at entry, exit, branch points, and error handlers as specified
4. Confirm each insertion

## Rules

- Log only at locations specified in the brief
- Never modify logic
- Never commit `[DebugTest]` logs
