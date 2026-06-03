---
platform: android
project: android-talenta
discipline: engineering
topic: presentation
pattern: presenter
---

## Theory

A **StateHolder** is the single source of truth for a screen's UI state. Use cases are injected via DI — never instantiated directly inside the StateHolder.

---

## Definition

Extends `BasePresenter<View>` — injects use case and `ErrorHandler` via Dagger.
Uses `doOnSubscribe`/`doFinally` for loading state, `addToDisposables()` for cleanup.

Rules:
- `@Inject constructor` — Dagger provides use cases, SchedulerTransformers, ErrorHandler
- `doOnSubscribe { view?.showLoading() }` / `doFinally { view?.hideLoading() }` — loading state always managed this way
- `errorHandler.proceed(error)` — delegates error display to the ErrorHandler; never call `view?.showError(error.message.orEmpty())` directly
- `addToDisposables()` — disposes on `detachView()`; never call `dispose()` manually
- `view?.` guard on all view calls — view may be null after `detachView()`
- One presenter per screen

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
