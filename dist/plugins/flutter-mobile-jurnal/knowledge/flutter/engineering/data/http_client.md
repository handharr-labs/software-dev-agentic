---
platform: flutter
discipline: engineering
topic: data
pattern: http_client
---

## Theory

`ErrorInterceptor` translates Dio errors → `AppException` before they reach the repository. Registered on Dio creation.

## Code Pattern

```dart
// data/network/error_interceptor.dart
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = switch (err.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout =>
        AppException.network(message: 'No internet connection'),
      DioExceptionType.badResponse => _mapStatusCode(err),
      _ => AppException.unknown(message: err.message ?? 'Unknown error'),
    };
    handler.reject(
      DioException(requestOptions: err.requestOptions, error: exception),
    );
  }

  AppException _mapStatusCode(DioException err) {
    final statusCode = err.response?.statusCode ?? 0;
    final message =
        (err.response?.data as Map<String, dynamic>?)?['message'] as String? ??
        err.message ??
        'Server error';
    return statusCode == 422
        ? AppException.validation(message: message, statusCode: statusCode)
        : AppException.server(message: message, statusCode: statusCode);
  }
}
```
