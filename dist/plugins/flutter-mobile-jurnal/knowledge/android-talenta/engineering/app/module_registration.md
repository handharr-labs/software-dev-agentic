---
platform: android
project: android-talenta
discipline: engineering
topic: app
pattern: module_registration
---

## Theory

**Module Registration** is the act of plugging a feature module into the app's module manager so it participates in the app lifecycle (startup, teardown, deep link handling).

**When it applies:** Only on platforms that have an explicit module system (`BaseModule`, `AppModule`, etc.). Platforms that use implicit linking (e.g. file-based routing) skip this step.

**Invariants:**
- Module registration happens in one place — the app's module manager or root coordinator
- Each feature module is registered once — duplicates cause double initialization
- Module lifecycle hooks (`onStart`, `onStop`) must not duplicate logic already in use cases

**When to add:** Any time a new feature module is introduced. Required only on platforms with an explicit `ModuleManager` or equivalent.

---

## Definition

Android module registration has two parts: wiring Dagger (via `MainComponent`) and wiring Gradle (via `settings.gradle`).

Rules:
- ✅ Module name in `settings.gradle` must match the directory name exactly
- ✅ Both Gradle wiring and Dagger wiring are required — neither alone is sufficient
- ❌ Never add feature module code directly to the `app/` module — keep feature code in `feature_{feature}/`

## Code Pattern

```groovy
// settings.gradle
include ':feature_{feature}'   // ← add here

// app/build.gradle
dependencies {
    // ... existing
    implementation project(':feature_{feature}')   // ← add here
}
```

Dagger wiring is handled in Dependency Registration — `{Feature}ActivityBindingModule` added to `MainComponent`.
