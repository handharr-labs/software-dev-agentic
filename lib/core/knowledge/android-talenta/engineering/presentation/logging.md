---
platform: android
project: android-talenta
discipline: engineering
topic: presentation
pattern: logging
---

## Theory

**Logger** is the centralized logging abstraction with severity levels. All log output goes through this interface.

---

## Definition

Log format: `Log.d("DebugTest", "[MethodName] <event> — <value>")`.

Rules:
- Use `"DebugTest"` tag on every log — filter in Logcat with tag `DebugTest`
- Never log passwords or tokens — log `.length` instead
- Never commit `[DebugTest]` logs

## Code Pattern

```kotlin
Log.d("DebugTest", "[methodName] entry — param: $param")
Log.d("DebugTest", "[methodName] state — before: $before, after: $after")
Log.d("DebugTest", "[methodName] error — $error")
```
