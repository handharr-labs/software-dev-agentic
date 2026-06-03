---
platform: android
project: android-talenta
discipline: engineering
topic: ui
pattern: di_wiring
---

## Theory

**DI wiring** registers the StateHolder and its dependencies in the project's DI container for a given screen.

**Invariants:**
- StateHolder registered with the correct scope (feature-scoped, not singleton unless explicitly shared)
- Use cases injected into the StateHolder — never instantiated inside the StateHolder
- DI factory or binding key matches the StateHolder contract exactly

**When to create:** After the Screen and StateHolder exist. Required before the feature is navigable.

---

## Definition

**DI wiring** registers the Presenter and its dependencies in a Hilt module.

**Invariants:**
- Presenter provided via `@Provides` or `@Binds` in a Hilt `@Module` — scope matches Activity/Fragment lifetime
- Use cases injected into the Presenter constructor — never instantiated inside the Presenter
- Navigation implementation bound to its interface in the Hilt module

**When to create:** After the Screen and Presenter exist. Required before the feature is navigable.

## Code Pattern

See `dependency_injection/di_module.md` and `dependency_injection/activity_binding.md` for full wiring patterns.
