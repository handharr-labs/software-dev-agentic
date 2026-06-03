---
platform: android
project: android-talenta
discipline: engineering
topic: utilities
pattern: logger
---

## Theory

**Logger** is the centralized logging abstraction with severity levels. All log output goes through this interface.

**Invariants:**
- Severity levels: `debug`, `info`, `warning`, `error` — each with distinct routing (debug stripped in production)
- No `print` / `console.log` / `Log.d` calls at call sites — always use the Logger interface
- Sensitive data (tokens, PII) must never appear in log output
- The implementation routes to Crashlytics or the platform crash reporter for `error`-level events

**When to use:** Any layer that needs diagnostic output. Inject `Logger` — never call the platform logging API directly.

---

## Definition

> Android Logger patterns not yet catalogued. Add structured logging utility here (e.g. Timber wrapper) when established.

## Code Pattern

```kotlin
// Placeholder — add Timber-based structured logger here
// Injected as Logger interface; implementation uses Timber.d/e/w
// Never use Log.d directly at call sites — use the injected Logger
```
