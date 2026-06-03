---
platform: flutter
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

The unified error type returned from all repository and use case calls. All failures are typed variants of `Failure<T>` — no raw exceptions leak into domain or presentation.

## Code Pattern

```dart
// domain/errors/failure.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
abstract class Failure<T> with _$Failure<T> {
  /// API returned an error status.
  factory Failure.serverFailure({
    required String message,
    required String developerMessage,
    int? statusCode,
    String? errorCode,
  }) = ServerFailure;

  /// API returned validation errors keyed by field.
  factory Failure.validationFailure({
    required String message,
    T? errors,
    int? statusCode,
  }) = ValidationFailure<T>;

  /// No internet connection or DNS failure.
  factory Failure.networkFailure({
    required String message,
  }) = NetworkFailure;

  /// Unexpected error (bug, null response, parse error).
  factory Failure.unknownFailure({
    required String message,
  }) = UnknownFailure;

  /// Local storage read/write failure.
  factory Failure.localFailure({
    required String message,
  }) = LocalFailure;
}
```
