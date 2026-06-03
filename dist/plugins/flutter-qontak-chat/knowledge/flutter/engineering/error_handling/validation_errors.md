---
platform: flutter
discipline: engineering
topic: error_handling
pattern: validation_errors
---

## Theory

| Layer | Error type owned | Purpose |
|---|---|---|
| Data (transport) | Platform HTTP/network error | Represents wire failures — HTTP status, timeout, parse failure |
| Domain | `DomainError` | Business-meaningful error codes (`notFound`, `validationFailed`, `unauthorized`) |
| Presentation | UI error State | What the screen renders — message, retry action, recovery path |

**Domain error codes are business vocabulary** — `notFound`, `validationFailed`, `unauthorized`, `networkUnavailable`, `serverError`. Never use HTTP status codes as domain error codes.

---

API validation errors (HTTP 422) carry structured field errors keyed by field name. Handled as `ValidationFailure` — never encoded in the generic `message` string.

## Code Pattern

```dart
// In error interceptor — detect 422
if (statusCode == 422) {
  final errors = (responseData?['errors'] as Map<String, dynamic>?);
  throw AppException.validation(
    message: responseData?['message'] as String? ?? 'Validation failed',
    errors: errors,
    statusCode: 422,
  );
}
```

```dart
// In BLoC — read field-level errors
result.fold(
  (failure) {
    if (failure is ValidationFailure) {
      final fieldErrors = failure.errors as Map<String, dynamic>?;
      emit(state.copyWith(
        submitState: ViewDataState.error(message: failure.message, failure: failure),
        fieldErrors: fieldErrors,
      ));
    } else {
      emit(state.copyWith(
        submitState: ViewDataState.error(message: failure.message ?? 'Failed', failure: failure),
      ));
    }
  },
  (_) => emit(state.copyWith(submitState: ViewDataState.loaded())),
);
```
