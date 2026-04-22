---
name: domain-create-entity
description: Create a Domain Entity class for a new feature using freezed.
user-invocable: false
---

Create a Domain Entity following `.claude/reference/contract/builder/domain.md ## Entities section`.

## Steps

1. **Grep** `.claude/reference/contract/builder/domain.md` for `## Entities`; only **Read** the full file if the section cannot be located
2. **Locate** the correct feature path: `lib/src/features/[feature]/domain/entities/`
3. **Create** `[feature]_entity.dart`

## Entity Pattern

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '[feature]_entity.freezed.dart';

@freezed
class [Feature]Entity with _$[Feature]Entity {
  const factory [Feature]Entity({
    required String id,
    required String name,
    // all required fields first, optional last
    DateTime? createdAt,
  }) = _[Feature]Entity;
}
```

Rules:
- `@freezed` only — `.freezed.dart` part only, **never** `.g.dart`
- **No `fromJson` factory** — entities are not serialised
- All immutable (`const factory`)
- Field types use domain terminology, not API field names
- `required` for mandatory fields; `T?` only when the domain genuinely allows null

## Output

Confirm file path and list all entity fields.
