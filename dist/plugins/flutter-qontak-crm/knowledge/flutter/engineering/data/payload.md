---
platform: flutter
discipline: engineering
topic: data
pattern: payload
---

## Theory

Separate class for write request bodies. Keeps read DTOs clean. Domain Params → Data Payload conversion happens in the repository impl.

**Domain Params → Data Payload flow:**
```
Domain Params (pure Dart)
      ↓
Repository Impl converts
      ↓
Data Payload (@JsonKey, freezed, .toJson())
      ↓
DataSource sends to API
```

Simple conversions happen inline in the repository. Complex conversions warrant a `PayloadMapper`.

## Code Pattern

```dart
// data/models/update_employee_payload.dart
@freezed
class UpdateEmployeePayload with _$UpdateEmployeePayload {
  const factory UpdateEmployeePayload({
    @JsonKey(name: 'full_name') required String name,
    required String email,
    @JsonKey(name: 'department_id') String? departmentId,
  }) = _UpdateEmployeePayload;

  factory UpdateEmployeePayload.fromJson(Map<String, dynamic> json) =>
      _$UpdateEmployeePayloadFromJson(json);
}
```

```dart
// data/mappers/update_employee_payload_mapper.dart (complex case)
@lazySingleton
class UpdateEmployeePayloadMapper {
  UpdateEmployeePayload fromParams(UpdateEmployeeParams params) =>
      UpdateEmployeePayload(
        name: params.name,
        email: params.email,
        departmentId: params.departmentId,
      );
}
```
