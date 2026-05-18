---
name: detective-debug-add-logs
description: Add strategic debug logs to a Flutter/Dart codebase using debugPrint with [DebugTest] prefix.
user-invocable: false
tools: Read, Edit, Glob, Grep
---

Add debug instrumentation logs using `debugPrint` with `[DebugTest]` prefix.

## Log Format

```dart
debugPrint('[DebugTest][MethodName] entry — param: $param');
debugPrint('[DebugTest][MethodName] state — before: $before, after: $after');
debugPrint('[DebugTest][MethodName] error — $error');
```

## Steps

Follow the `INSTRUMENTATION_BRIEF` provided by the caller:

1. `Grep` each target method name to locate the exact line
2. `Read` only the method body — not the full file
3. Insert `debugPrint('[DebugTest]...')` at entry, exit, branch points, and error handlers as specified
4. Confirm each insertion

## Rules

- Log only at locations specified in the brief
- Never modify logic
- Never commit `[DebugTest]` logs
