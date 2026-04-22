---
name: domain-create-repository
description: Create a Domain Repository abstract class for a new feature.
user-invocable: false
---

Create a Repository interface following `.claude/reference/contract/builder/domain.md ## Repository Interfaces section`.

## Steps

1. **Grep** `.claude/reference/contract/builder/domain.md` for `## Repository Interfaces`; only **Read** the full file if the section cannot be located
2. **Verify** the entity exists in `lib/src/features/[feature]/domain/entities/`
3. **Locate** path: `lib/src/features/[feature]/domain/repositories/`
4. **Create** `[feature]_repository.dart`

## Repository Pattern

```dart
import 'package:fpdart/fpdart.dart';
import '../entities/[feature]_entity.dart';
import '../../../../shared/domain/errors/failure.dart';

abstract class [Feature]Repository {
  Future<Either<Failure, [Feature]Entity>> get[Feature](String id);
  Future<Either<Failure, List<[Feature]Entity>>> get[Feature]s({
    int page = 1,
    int limit = 20,
  });
  Future<Either<Failure, [Feature]Entity>> update[Feature](
    String id,
    Update[Feature]Params params,
  );
  Future<Either<Failure, void>> delete[Feature](String id);
}
```

Rules:
- `abstract class` — no `interface`, no `mixin`
- All methods return `Either<Failure, T>` — never throw
- Parameters use domain Params objects, not raw `Map<String, dynamic>`
- Return domain entities only — no models, no DTOs
- Method names: `get*`, `create*`, `update*`, `delete*`

## Output

Confirm file path and list all declared method signatures.
