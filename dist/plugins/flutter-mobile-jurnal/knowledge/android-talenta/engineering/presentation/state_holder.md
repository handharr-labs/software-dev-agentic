---
platform: android
project: android-talenta
discipline: engineering
topic: presentation
pattern: state_holder
---

## Theory

A **StateHolder** is the single source of truth for a screen's UI state. Platform names vary (ViewModel, BLoC, Presenter) but the contract is identical across platforms.

**Invariants:**
- Owns no view imports — no UI framework, no widget, no component type
- Depends on use case interfaces only — never calls repositories or data sources directly
- Use cases are injected via DI — never instantiated directly inside the StateHolder
- Exposes state as a read-only stream or observable — UI observes, never mutates
- One StateHolder per screen — never shared across screens unless explicitly scoped

**When to create:** One StateHolder per screen. Created before the screen that observes it.

---

## Definition

In Android (MVP), the StateHolder is the **Presenter** extending `BasePresenter<View>`.

Invariants:
- Receives use cases via `@Inject constructor` — Dagger provides all dependencies; never instantiate use cases directly
- Drives the View interface imperatively via `view?.show*` / `view?.hide*` calls — Activity/Fragment never mutates presenter state
- Calls navigation via an injected `Navigation` interface — never starts Activities directly from the Presenter
- One Presenter per screen — scoped to the Activity/Fragment lifecycle via `attachView`/`detachView`

## Code Pattern

```kotlin
// presentation/[feature]/TimeOffRequestPresenter.kt
class TimeOffRequestPresenter @Inject constructor(
    private val getTimeOffRequestsUseCase: GetTimeOffRequestsUseCase,
    private val schedulerTransformers: SchedulerTransformers?,
    private val errorHandler: ErrorHandler
) : BasePresenter<TimeOffRequestContract.View>(), TimeOffRequestContract.Presenter {

    override fun loadTimeOffRequests(id: String) {
        val params = GetTimeOffRequestsUseCase.Params(id)
        getTimeOffRequestsUseCase.execute(params)
            .doOnSubscribe { view?.showLoading() }
            .doFinally { view?.hideLoading() }
            .subscribe(
                { requests -> view?.showTimeOffRequests(requests) },
                { error -> errorHandler.proceed(error) }
            )
            .addToDisposables()
    }

    override fun refreshData() {
        // re-invoke loadTimeOffRequests
    }
}
```
