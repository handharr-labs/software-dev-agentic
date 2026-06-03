---
platform: ios
project: ios-talenta
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

## Domain Errors

```swift
// Shared/Domain/Entities/BaseErrorModel.swift
struct BaseErrorModel: Error {
    let status: Int?
    let message: String
    let errors: [String: [String]]?
}
```

`BaseErrorModel` is the canonical error type for all UseCase and Repository completions (`Result<Model, BaseErrorModel>`). Repositories map `NetworkError` → `BaseErrorModel` before propagating upward. See `engineering/error_handling/` for full error flow and mapping patterns.
