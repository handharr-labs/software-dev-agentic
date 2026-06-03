---
platform: android
project: android-talenta
discipline: engineering
topic: dependency_injection
pattern: activity_binding
---

## Theory

`@ContributesAndroidInjector` scopes injection to the Activity/Fragment lifetime.

---

## Definition

Activity binding module wires Dagger injection for an Activity and its associated feature module.

Rules:
- Register `TimeOffActivityModule` in the app-level `ActivityModule` or equivalent binding module
- Presenter is injected by Dagger via `@Inject` — declare it as `@Inject lateinit var presenter` in the activity
- Do not instantiate any injectable class with `MyClass()`; always let Dagger provide it

## Code Pattern

```kotlin
// di/TimeOffActivityModule.kt
@Module
abstract class TimeOffActivityModule {

    @ContributesAndroidInjector(modules = [TimeOffModule::class])
    abstract fun contributeTimeOffRequestActivity(): TimeOffRequestActivity
}
```
