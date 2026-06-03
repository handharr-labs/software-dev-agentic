---
platform: web
project: web
discipline: engineering
topic: presentation
pattern: logging
---

## Logging

Log format: `console.log('[DebugTest][ClassName.methodName] <event> —', value)`.

```typescript
console.log('[DebugTest][methodName] entry —', { param })
console.log('[DebugTest][methodName] state —', { before, after })
console.error('[DebugTest][methodName] error —', error)
```

Filter in browser devtools Console tab with `[DebugTest]`, or server terminal with `| grep '\[DebugTest\]'`.

Rules:
- Use `[DebugTest]` prefix on every log
- Never log passwords or tokens — log `.length` instead
- Never commit `[DebugTest]` logs
