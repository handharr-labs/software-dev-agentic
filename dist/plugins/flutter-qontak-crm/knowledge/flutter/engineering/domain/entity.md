---
platform: flutter
discipline: engineering
topic: domain
pattern: entity
---

## Theory

An **Entity** is a pure data structure representing a business concept.

**Invariants:**
- No framework imports — value types or pure classes only
- No business logic — entities hold data; use cases execute logic
- No serialization annotations — no `@JsonKey`, no `Codable`, no `fromJson`
- Immutable — all properties are read-only; mutation produces a new instance (`copyWith`)
- Represent domain concepts, not API shapes — field names match the business domain, not the JSON payload

**When to create:** When the domain needs a named, typed concept with identified fields (e.g. `Employee`, `LeaveRequest`, `AttendanceRecord`).

---

Immutable business objects. `@freezed` is recommended for `copyWith` and pattern matching, but plain Dart classes are acceptable when the entity is simple and not pattern-matched in the UI.

**Rules:**
- `@freezed` recommended for immutability + `copyWith`; plain Dart class acceptable for simple entities
- Only `.freezed.dart` part — never `.g.dart`
- No `@JsonKey` annotations
- No `fromJson` / `toJson` factories
- Represent business concepts, not API shapes

## Code Pattern

```dart
// domain/entities/employee_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee_entity.freezed.dart';

@freezed
class EmployeeEntity with _$EmployeeEntity {
  const factory EmployeeEntity({
    required String id,
    required String name,
    required String email,
    DateTime? joinDate,
  }) = _EmployeeEntity;
}
```
