---
platform: flutter
discipline: engineering
topic: data
pattern: dto
---

## Theory

A **DTO (Data Transfer Object)** mirrors the raw API or database shape exactly.

**Invariants:**
- No domain logic — plain data container only
- No computed fields — no derived values, no formatting
- No domain entity types — DTOs use primitive types and nested DTOs
- Serialization annotations live here, not on domain entities (`@JsonKey`, `Codable`, `fromJson`)
- Field names match the API/DB schema — not the business domain vocabulary

**When to create:** One DTO per API response type or DB table row. Created before the mapper that consumes it.

---

DTO classes for API responses. Always have `fromJson` — entities never do. All fields nullable — API data is untrusted.

**Rules:**
- Both `.freezed.dart` and `.g.dart` parts
- `@JsonKey(name:)` for snake_case → camelCase mapping
- No business logic
- Never returned from repository — always mapped to entity first

## Code Pattern

```dart
// data/models/employee_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee_model.freezed.dart';
part 'employee_model.g.dart';

@freezed
class EmployeeModel with _$EmployeeModel {
  const factory EmployeeModel({
    @JsonKey(name: 'employee_id') String? id,
    @JsonKey(name: 'full_name') String? name,
    String? email,
    @JsonKey(name: 'join_date') String? joinDate,
    @JsonKey(name: 'department_id') String? departmentId,
  }) = _EmployeeModel;

  factory EmployeeModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeModelFromJson(json);
}
```
