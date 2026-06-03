---
platform: flutter
discipline: engineering
topic: domain
pattern: creation_order
---

## Theory

When building a new feature's domain layer:

```
Entity → Repository Interface → Use Case(s) → Domain Service (only if needed)
```

Never create a use case before the repository interface it depends on.

---

When building a new feature's domain layer, create files in this sequence. Never create a use case before the repository abstract class it depends on.

## Code Pattern

```
1. domain/entities/[feature]_entity.dart           ← Entity (@freezed, no fromJson)
2. domain/repositories/[feature]_repository.dart   ← Repository abstract class
3. domain/usecases/[feature]/get_[feature]_usecase.dart
   domain/usecases/[feature]/update_[feature]_usecase.dart
   ...                                              ← Use Case(s)
4. domain/services/[feature]_[calculator|validator].dart
                                                   ← Domain Service (only if needed)
```
