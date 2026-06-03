---
platform: ios
project: ios-talenta
discipline: engineering
topic: presentation
pattern: logging
---

## Logging

Log format: `print("[DebugTest][ClassName.methodName] <event> — <value>")`.

```swift
print("[DebugTest][methodName] entry — param: \(param)")
print("[DebugTest][methodName] state — before: \(before), after: \(after)")
print("[DebugTest][methodName] error — \(error)")
```

Rules:
- Use `[DebugTest]` prefix on every log — filter in Xcode console with `Cmd+K` then search `[DebugTest]`
- Never log passwords or tokens — log `.count` instead
- Never commit `[DebugTest]` logs
