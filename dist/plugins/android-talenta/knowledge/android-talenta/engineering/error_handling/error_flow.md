---
platform: android
project: android-talenta
discipline: engineering
topic: error_handling
pattern: error_flow
---

## Theory

Errors travel inward-to-outward, mapped at each layer boundary:

```
DataSource throws transport error (NetworkError, HTTP 4xx/5xx, DB exception)
    ↓ caught and mapped by
Repository Implementation → DomainError
    ↓ returned to
Use Case → propagates DomainError unchanged
    ↓ received by
StateHolder → maps to UI error State
    ↓ observed by
Screen → renders error UI
```

**Rule:** Each layer catches the error type from the layer below it and converts it to the type its consumers expect. No raw transport errors escape the Data layer. No domain errors escape the Presentation layer uncaught.

---

## Definition

```
DataSource (ApiException / IOException)
      ↓
RepositoryImpl  →  maps to DomainException
      ↓
UseCase         →  propagates via RxJava onError
      ↓
Presenter       →  ErrorHandler.handle() → view?.showError()
      ↓
View (Activity/Fragment)  →  shows Toast / inline error UI
```

## Code Pattern

```kotlin
// Full error flow:

// 1. DataSource throws ApiException
interface TimeOffApi {
    @GET("v1/time-off/requests")
    fun getTimeOffRequests(...): Single<TimeOffRequestListResponse>
    // ApiException thrown by ErrorInterceptor on non-2xx response
}

// 2. RepositoryImpl maps to DomainException
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

// 3. Presenter delegates to ErrorHandler
{ error -> errorHandler.handle(error) { view?.showError(it) } }

// 4. View renders error
override fun showError(error: Throwable) {
    showToast(error.message.orEmpty())
}
```
