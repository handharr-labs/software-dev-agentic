---
platform: android
project: android-talenta
discipline: engineering
topic: app
pattern: dependency_registration
---

## Theory

**Dependency Registration** is the act of binding concrete implementations to their interfaces in the app's DI container so that the runtime can inject them into use cases, repositories, and state holders.

**Invariants:**
- Bindings live at the app shell — never inside a CLEAN layer
- Each feature owns its own registration unit (component, module, or file) — one file per feature
- Use cases and repositories are registered, not constructed inline at call sites
- Registration order follows the dependency graph: data sources → repositories → use cases

**When to add:** Any time a new use case, repository implementation, or data source is introduced. Skipping registration causes runtime crashes — this step is mandatory, not optional.

---

## Definition

Android uses **Dagger 2** with `@Module` + `@Binds` + `@ContributesAndroidInjector` per feature.

Rules:
- ✅ One `@Module` per feature under `feature_{feature}/di/`
- ✅ `@Binds` for interface-to-implementation binding — never `@Provides` for simple bindings
- ✅ `@ContributesAndroidInjector` scopes injection to the Activity/Fragment
- ❌ Never inject `Context` directly — use `@ApplicationContext` or `@ActivityContext`

## Code Pattern

```kotlin
// feature_{feature}/di/Feature{Feature}Module.kt

@Module
abstract class Feature{Feature}Module {

    @Binds
    abstract fun bind{Feature}Repository(
        impl: {Feature}RepositoryImpl
    ): {Feature}Repository

    @Binds
    abstract fun bind{Feature}RemoteDataSource(
        impl: {Feature}RemoteDataSourceImpl
    ): {Feature}RemoteDataSource

    @ContributesAndroidInjector(modules = [Feature{Feature}Module::class])
    abstract fun contribute{Feature}Activity(): {Feature}Activity
}

// app/di/{Feature}ActivityBindingModule.kt

@Module
abstract class {Feature}ActivityBindingModule {

    @ContributesAndroidInjector(modules = [Feature{Feature}Module::class])
    abstract fun contribute{Feature}Activity(): {Feature}Activity
}

// app/di/MainComponent.kt
@Singleton
@Component(
    modules = [
        // ... existing modules
        {Feature}ActivityBindingModule::class,  // ← add here
    ]
)
interface MainComponent : AndroidInjector<App>
```
