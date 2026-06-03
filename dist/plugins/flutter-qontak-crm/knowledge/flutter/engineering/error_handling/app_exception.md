---
platform: flutter
discipline: engineering
topic: error_handling
pattern: app_exception
---

## Theory

Repository implementations own the mapping from transport errors to domain errors:

- HTTP 404 → `DomainError.notFound`
- HTTP 401/403 → `DomainError.unauthorized`
- HTTP 422 / validation response → `DomainError.validationFailed`
- Network timeout / no connection → `DomainError.networkUnavailable`
- HTTP 5xx / unexpected → `DomainError.serverError`
- Parse failure → `DomainError.serverError` (malformed response is a server problem)

Mappers never throw — they handle null/missing fields defensively and return safe defaults.

---

Typed exceptions thrown inside datasources. Lives in `data/exceptions/app_exception.dart`. DataSources only throw — they never return `Either`. The repository catches and converts to `Failure`.

**Boundary rule:**
- HTTP → DataSource: `ErrorInterceptor` catches `DioException`, attaches `AppException`
- DataSource → Repository: `catch (e on AppException)` → `Left(e.toFailure())`

## Code Pattern

```dart
// Throwing in a datasource
Future<EmployeeModel> getEmployee(String id) async {
  final response = await dio.get('/api/v1/employees/$id');
  final data = response.data as Map<String, dynamic>?;
  if (data == null || data['data'] == null) {
    throw AppException.server(
      message: 'Employee not found',
      statusCode: 404,
    );
  }
  return EmployeeModel.fromJson(data['data'] as Map<String, dynamic>);
}
```

```dart
// Catching in a repository
try {
  final model = await remoteDataSource.getEmployee(id);
  return Right(mapper.toEntity(model));
} on AppException catch (e) {
  return Left(e.toFailure());   // typed conversion
} catch (e, stackTrace) {
  debugPrint('Unexpected: $e\n$stackTrace');
  return Left(Failure.unknownFailure(message: e.toString()));
}
```

```dart
// HTTP 422 validation in the error interceptor
if (statusCode == 422) {
  final errors = (responseData?['errors'] as Map<String, dynamic>?);
  throw AppException.validation(
    message: responseData?['message'] as String? ?? 'Validation failed',
    errors: errors,
    statusCode: 422,
  );
}
```

Register `ErrorInterceptor` when creating Dio:

```dart
Dio(BaseOptions(baseUrl: '...'))
  ..interceptors.add(ErrorInterceptor());
```
