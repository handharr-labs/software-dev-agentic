---
name: developer-domain-create-entity
description: Create a Domain Entity class for a new feature using freezed.
user-invocable: false
---

Create a Domain Entity following `.claude/reference/code-architecture/domain-impl.md ## Entities section`.

## Steps

1. **Grep** `.claude/reference/code-architecture/domain-impl.md` for `## Entities`; only **Read** the full file if the section cannot be located
2. **Locate** the correct feature path: `features/<feature>/lib/src/domain/entities/`
3. **Create** `<entity_name>.dart`
4. **Export** from the barrel: `features/<feature>/lib/src/domain/entities/entities.dart`

## Entity Pattern

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '<entity_name>.freezed.dart'; // .freezed.dart only — entities are not serialised

@freezed
class <EntityName> with _$<EntityName> {
  const factory <EntityName>({
    required int id,
    required String name,
    // required fields first; T? only when domain genuinely allows null
    @Default(false) bool isActive,
    String? optionalField,
  }) = _<EntityName>;
  // no fromJson — entities are never deserialised from JSON
}
```

## Output

Confirm file path, list all entity fields, and confirm barrel export updated.
