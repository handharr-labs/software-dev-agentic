---
platform: android
project: android-talenta
discipline: engineering
topic: domain
pattern: domain_error
---

## Theory

A **Domain Error** is the unified error type returned from all repository and use case operations. It decouples the domain from transport-layer error types (HTTP status codes, network errors).

**Invariants:**
- Domain operations return a Result/Either typed with the domain error — they never propagate raw network errors upward
- Repositories map transport errors to domain errors before returning
- Error codes are business-meaningful (`notFound`, `validationFailed`, `unauthorized`) — not HTTP status codes

---

## Definition

Typed exceptions thrown from the domain boundary. Repository implementations map transport errors to these before returning.

Rules:
- Sealed class — exhaustive `when` in presenter error handling
- No transport types leak out — `ApiException`, `IOException` are mapped in `RepositoryImpl`
- Presenters catch `DomainException` subtypes via `ErrorHandler`

## Code Pattern

```kotlin
// domain/exception/DomainException.kt
sealed class DomainException(message: String) : Exception(message) {
    class Unauthorized(message: String = "Unauthorized") : DomainException(message)
    class NotFound(message: String = "Resource not found") : DomainException(message)
    class NetworkError(message: String = "Network unavailable") : DomainException(message)
    class Unknown(message: String = "Unknown error") : DomainException(message)
}
```
