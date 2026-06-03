---
platform: flutter
discipline: engineering
topic: data
pattern: exception
---

## Theory

Typed exceptions thrown by DataSources. Converted to `Failure` in the repository via `toFailure()`. Never propagated to domain or presentation.

## Code Pattern

```dart
// data/exceptions/app_exception.dart
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  factory AppException.server({required String message, int? statusCode, String? errorCode}) = ServerException;
  factory AppException.validation<T>({required String message, T? errors, int? statusCode}) = ValidationException<T>;
  factory AppException.network({required String message}) = NetworkException;
  factory AppException.unknown({required String message}) = UnknownAppException;
}

final class ServerException extends AppException {
  const ServerException({required super.message, this.statusCode, this.errorCode});
  final int? statusCode;
  final String? errorCode;
}

final class ValidationException<T> extends AppException {
  const ValidationException({required super.message, this.errors, this.statusCode});
  final T? errors;
  final int? statusCode;
}

final class NetworkException extends AppException {
  const NetworkException({required super.message});
}

final class UnknownAppException extends AppException {
  const UnknownAppException({required super.message});
}

extension AppExceptionX on AppException {
  Failure toFailure() => switch (this) {
        ServerException e => Failure.serverFailure(
            message: e.message,
            developerMessage: 'HTTP ${e.statusCode}',
            statusCode: e.statusCode,
            errorCode: e.errorCode,
          ),
        ValidationException e => Failure.validationFailure(
            message: e.message,
            errors: e.errors,
            statusCode: e.statusCode,
          ),
        NetworkException e => Failure.networkFailure(message: e.message),
        UnknownAppException e => Failure.unknownFailure(message: e.message),
      };
}
```
