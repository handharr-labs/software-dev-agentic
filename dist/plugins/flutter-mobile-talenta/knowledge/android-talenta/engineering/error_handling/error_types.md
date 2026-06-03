---
platform: android
project: android-talenta
discipline: engineering
topic: error_handling
pattern: error_types
---

## Theory

| Layer | Error type owned | Purpose |
|---|---|---|
| Data (transport) | Platform HTTP/network error | Represents wire failures — HTTP status, timeout, parse failure |
| Domain | `DomainError` | Business-meaningful error codes (`notFound`, `validationFailed`, `unauthorized`) |
| Presentation | UI error State | What the screen renders — message, retry action, recovery path |

**Domain error codes are business vocabulary** — `notFound`, `validationFailed`, `unauthorized`, `networkUnavailable`, `serverError`. Never use HTTP status codes as domain error codes.

---

## Definition

| Type | Layer | Description |
|---|---|---|
| `ApiException` | Data | HTTP error from Retrofit; carries status code |
| `IOException` | Data | Network failure (no connectivity, timeout) |
| `DomainException` | Domain | Sealed class; subtypes: `Unauthorized`, `NotFound`, `NetworkError`, `Unknown` |
| `BaseErrorModel` | Presentation | UI-facing error with user-readable message |

## Code Pattern

```kotlin
// Data layer error types
class ApiException(
    val code: Int,
    val errorResponse: ErrorResponse?,
    override val message: String
) : Exception(message)

// Domain layer error type
sealed class DomainException(message: String) : Exception(message) {
    class Unauthorized(message: String = "Unauthorized") : DomainException(message)
    class NotFound(message: String = "Resource not found") : DomainException(message)
    class NetworkError(message: String = "Network unavailable") : DomainException(message)
    class Unknown(message: String = "Unknown error") : DomainException(message)
}
```
