---
platform: flutter
discipline: engineering
topic: data
pattern: mapper
---

## Theory

A **Mapper** converts between a DTO and a domain entity — always defined as an interface with a concrete implementation.

**Invariants:**
- Always interface + implementation — never a plain utility function or static helper
- One direction per method: `toDomain(dto)` converts inward; `toDTO(entity)` converts outward (if write operations exist)
- No I/O — pure transformation only; no network calls, no DB reads
- No business logic — field mapping only; validation belongs in domain use cases
- Null/missing fields handled defensively — never let a missing API field crash the mapper

**When to create:** One mapper per DTO ↔ entity pair. Created after the DTO, before the DataSource implementation.

---

Convert Models → Entities. One mapper per aggregate root. Handle nulls with explicit defaults.

**Rules:**
- One mapper per entity type
- Handle nulls with explicit defaults — never assume API fields are present
- Date strings → `DateTime` conversion happens in mapper, not entity
- List mappers call `toEntity` per item: `models.map(mapper.toEntity).toList()`

## Code Pattern

```dart
// data/mappers/base_mapper.dart
abstract class BaseMapper<Model, Entity> {
  Entity toEntity(Model model);
}
```

```dart
// data/mappers/employee_mapper.dart
@lazySingleton
class EmployeeMapper extends BaseMapper<EmployeeModel, EmployeeEntity> {
  @override
  EmployeeEntity toEntity(EmployeeModel model) => EmployeeEntity(
        id: model.id ?? '',
        name: model.name ?? '',
        email: model.email ?? '',
        joinDate: model.joinDate != null
            ? DateTime.tryParse(model.joinDate!)
            : null,
      );
}
```
