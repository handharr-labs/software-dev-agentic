---
platform: android
project: android-talenta
discipline: engineering
topic: error_handling
pattern: error_handler
---

## Theory

The StateHolder maps `DomainError` to an error State that the screen renders. Never show raw error messages or stack traces to users.

---

## Definition

Central error handler injected into presenters. Never call `view?.showError(error.message)` directly.

## Code Pattern

```kotlin
class FeaturePresenter @Inject constructor(
    private val useCase: GetFeatureUseCase,
    private val errorHandler: ErrorHandler
) : BasePresenter<FeatureContract.View>(), FeatureContract.Presenter {

    override fun loadData(id: String) {
        useCase.execute(GetFeatureUseCase.Params(id))
            .doOnSubscribe { view?.showLoading() }
            .doFinally { view?.hideLoading() }
            .subscribe(
                { view?.showData(it) },
                { error -> errorHandler.handle(error) { view?.showError(it) } }
            )
            .addToDisposables()
    }
}
```
