---
platform: android
project: android-talenta
discipline: engineering
topic: utilities
pattern: storage_service
---

## Theory

**StorageService** is an interface-based key-value store for persisting tokens, user preferences, and cached data across app sessions.

**Invariants:**
- The interface lives in the infrastructure layer — never in domain or data
- All keys are typed constants (enum or sealed class) — never raw strings at call sites
- Implementations are swappable per environment (e.g. in-memory for tests, secure storage for production)
- `clearAll()` is only called on logout — never on individual feature teardown

**When to use:** Any layer that needs to read or write persistent state. Inject the interface — never access the concrete implementation directly.

---

## Definition

> Android StorageService patterns not yet catalogued. Add `SharedPreferences`/`EncryptedSharedPreferences` abstraction here when established.

## Code Pattern

```kotlin
// Placeholder — add SharedPreferences/EncryptedSharedPreferences abstraction here
// Pattern: interface SessionPreference with typed keys, injected via Dagger
```
