---
platform: android
project: android-talenta
discipline: engineering
topic: error_handling
pattern: layer_invariants
---

## Theory

- DataSources throw — they never return null to signal failure
- Repository implementations always catch and map — never let transport errors propagate to use cases
- Use cases propagate `DomainError` unchanged — they do not re-map errors
- StateHolders catch all errors from use cases — no unhandled promise rejections or uncaught exceptions reach the UI
- Screens never inspect error codes directly — they render the error State the StateHolder produces

---

## Definition

Enforced constraints for error handling across all layers.

## Code Pattern

- DataSources throw `ApiException` or `IOException` — they never return `null` or a partial model to signal failure
- Repository implementations always catch and map to `DomainException` via `onErrorResumeNext` — no transport error propagates to use cases
- Use cases propagate `DomainException` via RxJava `onError` unchanged — they do not re-map errors
- Presenters delegate all error handling to `ErrorHandler` — never call `view?.showError(error.message)` directly
- Views never inspect `DomainException` subtypes — they render the error message `ErrorHandler` produces
