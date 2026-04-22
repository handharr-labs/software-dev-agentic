---
name: data-create-mapper
description: Create a Model (DTO) and Mapper for a feature — both the freezed model and the BaseMapper implementation.
user-invocable: false
---

Create a Model and Mapper following `.claude/reference/contract/builder/data.md ## DTOs` and `## Mappers sections`.

## Steps

1. **Grep** `.claude/reference/contract/builder/data.md` for `## DTOs` and `## Mappers`; only **Read** the full file if sections cannot be located
2. **Verify** the domain entity exists
3. **Locate** paths:
   - Model: `lib/src/features/[feature]/data/models/`
   - Mapper: `lib/src/features/[feature]/data/mappers/`
4. **Create** `[feature]_model.dart` then `[feature]_mapper.dart`

## Model Pattern

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '[feature]_model.freezed.dart';
part '[feature]_model.g.dart';

@freezed
class [Feature]Model with _$[Feature]Model {
  const factory [Feature]Model({
    @JsonKey(name: '[api_field]') String? id,
    @JsonKey(name: '[api_field]') String? name,
    @JsonKey(name: '[api_field]') String? createdAt,
  }) = _[Feature]Model;

  factory [Feature]Model.fromJson(Map<String, dynamic> json) =>
      _$[Feature]ModelFromJson(json);
}
```

## Mapper Pattern

```dart
import 'package:injectable/injectable.dart';
import '../../domain/entities/[feature]_entity.dart';
import '../models/[feature]_model.dart';
import 'base_mapper.dart';

@lazySingleton
class [Feature]Mapper extends BaseMapper<[Feature]Model, [Feature]Entity> {
  @override
  [Feature]Entity toEntity([Feature]Model model) => [Feature]Entity(
        id: model.id ?? '',
        name: model.name ?? '',
        createdAt: model.createdAt != null
            ? DateTime.tryParse(model.createdAt!)
            : null,
      );
}
```

Rules:
- Model: all fields nullable (`String?`, `int?`) — API is untrusted
- Model: both `.freezed.dart` and `.g.dart` parts
- Model: `@JsonKey(name:)` for every field that differs from the Dart name
- Mapper: handle every nullable with an explicit default — never `!` without a null check
- Mapper: `@lazySingleton`
- Mapper: date strings parsed in the mapper, not in the entity

## Output

Confirm both file paths and list all mapped fields with their source → target names.
