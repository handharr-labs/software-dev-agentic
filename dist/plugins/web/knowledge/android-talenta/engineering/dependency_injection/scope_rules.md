---
platform: android
project: android-talenta
discipline: engineering
topic: dependency_injection
pattern: scope_rules
---

## Theory

| Scope | Use for | Lifetime |
|---|---|---|
| Singleton | Shared infrastructure — HTTP client, token store, logger | App lifetime |
| Feature-scoped | StateHolders and use cases for a single feature | Screen/route lifetime |
| Transient | Stateless helpers, mappers, pure services | Per-resolution |

**Never register a StateHolder as a singleton** — it holds mutable UI state that must be reset when the screen is destroyed.

---

## Definition

| Dagger scope | Use for | Lifetime |
|---|---|---|
| `@Singleton` | HTTP client (`Retrofit`), database, shared utilities | App lifetime |
| `@ActivityScoped` / feature scope | Presenters — one per Activity/Fragment | Screen lifetime |
| Unscoped (default) | Mappers, pure helpers — stateless, cheap | Per-resolution |

**Never scope a Presenter as `@Singleton`** — it holds a View reference that must be released when the Activity is destroyed. Use `@ActivityScoped` or inject via `@ContributesAndroidInjector`.

## Code Pattern

```kotlin
// ✅ Singleton — shared infrastructure
@Singleton
@Provides fun provideRetrofit(okHttpClient: OkHttpClient): Retrofit = Retrofit.Builder()
    .client(okHttpClient)
    .build()

// ✅ ActivityScoped — presenter
@ActivityScoped
@Provides fun provideTimeOffPresenter(
    useCase: GetTimeOffRequestsUseCase,
    errorHandler: ErrorHandler
): TimeOffRequestPresenter = TimeOffRequestPresenter(useCase, errorHandler)

// ✅ Unscoped (default) — mappers
@Provides fun provideTimeOffRequestMapper(): TimeOffRequestMapper = TimeOffRequestMapper()
```
