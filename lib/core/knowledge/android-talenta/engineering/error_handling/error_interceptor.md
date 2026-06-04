---
platform: android
project: android-talenta
discipline: engineering
topic: error_handling
pattern: error_interceptor
---

## Theory

The DataSource layer throws transport errors — it never returns null to signal failure. The repository implementation maps these to domain errors.

---

## Definition

OkHttp interceptor that converts non-2xx HTTP responses into `ApiException` before they reach the Retrofit interface.

## Code Pattern

```kotlin
class ErrorInterceptor @Inject constructor(private val gson: Gson) : Interceptor {

    override fun intercept(chain: Interceptor.Chain): Response {
        val response = chain.proceed(chain.request())
        if (!response.isSuccessful) {
            val errorBody = response.body?.string()
            val errorResponse = try { gson.fromJson(errorBody, ErrorResponse::class.java) } catch (e: Exception) { null }
            throw ApiException(
                code = response.code,
                errorResponse = errorResponse,
                message = errorResponse?.error?.message ?: "Unknown error"
            )
        }
        return response
    }
}
```
