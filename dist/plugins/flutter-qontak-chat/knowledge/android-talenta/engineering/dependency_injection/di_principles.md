---
platform: android
project: android-talenta
discipline: engineering
topic: dependency_injection
pattern: di_principles
---

## Theory

These rules apply regardless of framework (Next.js React Context, Swinject, get_it):

1. **Constructor injection** — dependencies are declared as constructor parameters, never fetched inside a class body
2. **Depend on interfaces, not implementations** — callers reference abstract types; the container resolves the concrete class
3. **No `new` inside business logic** — use cases, StateHolders, and repository implementations never instantiate their own dependencies
4. **Container owns lifecycle** — the DI container decides whether a dependency is a singleton, feature-scoped, or transient; callers never manage this
5. **One container per runtime boundary** — if your platform has multiple runtimes (e.g. server + client), each runtime gets its own container; never share a container across boundaries

---

## Definition

- Prefer constructor injection (`@Inject constructor`) — avoid field injection except in Activities/Fragments
- Dagger modules live in each feature's `di/` package
- `app/` composes the top-level component graph
- Use `@ContributesAndroidInjector` for activities and fragments

## Code Pattern

```kotlin
// ✅ Constructor injection (use cases, presenters, repositories)
class TimeOffRequestPresenter @Inject constructor(
    private val useCase: GetTimeOffRequestsUseCase,
    private val errorHandler: ErrorHandler
) : BasePresenter<TimeOffRequestContract.View>()

// ✅ Field injection (Activities/Fragments only)
class TimeOffRequestActivity : BaseMvpVbActivity<...>() {
    @Inject
    override lateinit var presenter: TimeOffRequestPresenter
}

// ❌ Never instantiate directly
// val presenter = TimeOffRequestPresenter(useCase, errorHandler)
```
