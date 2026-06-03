---
platform: android
project: android-talenta
discipline: engineering
topic: error_handling
pattern: error_response_models
---

## Theory

DTOs mirror the raw API error shape exactly. All fields are nullable — server may omit any field.

---

## Definition

Error response data classes used to deserialize API error bodies from Retrofit.

## Code Pattern

```kotlin
data class ErrorResponse(
    @SerializedName("error") val error: ErrorDetail?
)

data class ErrorDetail(
    @SerializedName("code") val code: String?,
    @SerializedName("message") val message: String?,
    @SerializedName("errors") val errors: List<FieldError>?
)

data class FieldError(
    @SerializedName("field") val field: String?,
    @SerializedName("message") val message: String?
)

class ApiException(
    val code: Int,
    val errorResponse: ErrorResponse?,
    override val message: String
) : Exception(message)
```
