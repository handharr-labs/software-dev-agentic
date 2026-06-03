---
platform: android
project: android-talenta
discipline: engineering
topic: error_handling
pattern: error_mapping
---

## Theory

Repository implementations own the mapping from transport errors to domain errors:

- HTTP 404 → `DomainError.notFound`
- HTTP 401/403 → `DomainError.unauthorized`
- HTTP 422 / validation response → `DomainError.validationFailed`
- Network timeout / no connection → `DomainError.networkUnavailable`
- HTTP 5xx / unexpected → `DomainError.serverError`
- Parse failure → `DomainError.serverError` (malformed response is a server problem)

---

## Definition

RepositoryImpl maps transport errors to `DomainException` via `onErrorResumeNext`. Presenter delegates to `ErrorHandler` — never inspect the error directly in the Presenter.

## Code Pattern

```kotlin
// RepositoryImpl error mapping
.onErrorResumeNext { throwable ->
    when (throwable) {
        is ApiException -> when (throwable.code) {
            401 -> Single.error(DomainException.Unauthorized())
            404 -> Single.error(DomainException.NotFound())
            else -> Single.error(throwable)
        }
        is IOException -> Single.error(DomainException.NetworkError())
        else -> Single.error(throwable)
    }
}

// Presenter delegates to ErrorHandler
errorHandler.handle(error) { message -> view?.showError(message) }
```
