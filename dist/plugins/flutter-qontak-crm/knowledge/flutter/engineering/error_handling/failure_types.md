---
platform: flutter
discipline: engineering
topic: error_handling
pattern: failure_types
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

Error flow: HTTP → `AppException` → `Failure` → `ViewDataState.error`. Each layer converts, never forwards raw exceptions.

```
HTTP / Storage / Parse error
        ↓
Data layer throws AppException
        ↓
Repository catches → returns Left(Failure)
        ↓
UseCase passes through Either
        ↓
BLoC calls result.fold() → emits ViewDataState.error
        ↓
Widget reads state.hasError → shows UI
```

**Rules:**
1. DataSources throw, Repositories return Either — never mix
2. Never throw in domain or presentation
3. Always handle both fold arms
4. Keep user messages short — technical details in `developerMessage`
5. Field validation errors use `ValidationFailure`

## Code Pattern

```dart
// Accessing failure in a BLoC
result.fold(
  (failure) {
    final message = failure.when(
      serverFailure: (msg, _, __, ___) => msg,
      validationFailure: (msg, __, ___) => msg,
      networkFailure: (msg) => msg,
      unknownFailure: (msg) => msg,
      localFailure: (msg) => msg,
    );
    emit(state.copyWith(
      dataState: ViewDataState.error(message: message, failure: failure),
    ));
  },
  (data) => emit(state.copyWith(dataState: ViewDataState.loaded(data: data))),
);
```
