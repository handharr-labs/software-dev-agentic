---
platform: flutter
discipline: engineering
topic: data
pattern: data_source
---

## Theory

A **DataSource** is an abstract interface for raw data access — remote (HTTP) or local (DB, cache).

**Invariants:**
- Interface only in the data layer — implementation is injected, never instantiated directly
- Methods return raw data (DTOs or primitives) — never domain entities
- One DataSource per data origin (remote API, local DB, cache) — do not mix sources in one interface
- Throws or returns transport-layer errors — the repository implementation maps these to domain errors

**When to create:** One DataSource interface per data origin per feature. Created after the DTO and mapper, before the repository implementation.

---

Separate remote and local data sources via abstract interface + implementation. DataSources only throw — they never return `Either`. The repository catches and converts.

## Code Pattern

```dart
// data/datasources/employee_remote_data_source.dart
abstract class EmployeeRemoteDataSource {
  Future<EmployeeModel> getEmployee(String id);
  Future<List<EmployeeModel>> getEmployees({int page = 1, int limit = 20, String? departmentId});
  Future<EmployeeModel> updateEmployee(String id, UpdateEmployeePayload payload);
  Future<void> deleteEmployee(String id);
}
```

```dart
// data/datasources/employee_remote_data_source_impl.dart
@LazySingleton(as: EmployeeRemoteDataSource)
class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  EmployeeRemoteDataSourceImpl({required this.dio});
  final Dio dio;

  @override
  Future<EmployeeModel> getEmployee(String id) async {
    final response = await dio.get('/api/v1/employees/$id');
    final base = BaseResponse<EmployeeModel>.fromJson(
      response.data as Map<String, dynamic>,
      fromJsonT: EmployeeModel.fromJson,
    );
    return base.data!;
  }

  @override
  Future<List<EmployeeModel>> getEmployees({int page = 1, int limit = 20, String? departmentId}) async {
    final response = await dio.get(
      '/api/v1/employees',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (departmentId != null) 'department_id': departmentId,
      },
    );
    final base = BaseResponse<List<dynamic>>.fromJson(
      response.data as Map<String, dynamic>,
      fromJsonT: (data) => data as List<dynamic>,
    );
    return (base.data ?? [])
        .map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
```

```dart
// data/models/base_response.dart
class BaseResponse<T> {
  const BaseResponse({this.status, this.message, this.data});
  final int? status;
  final String? message;
  final T? data;

  factory BaseResponse.fromJson(
    Map<String, dynamic> json, {
    required T Function(dynamic) fromJsonT,
  }) =>
      BaseResponse<T>(
        status: json['status'] as int?,
        message: json['message'] as String?,
        data: json['data'] != null ? fromJsonT(json['data']) : null,
      );
}
```
