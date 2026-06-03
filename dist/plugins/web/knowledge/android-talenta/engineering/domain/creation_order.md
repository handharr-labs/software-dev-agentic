---
platform: android
project: android-talenta
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

## Definition

When building a new feature's domain layer, create files in this sequence.

## Code Pattern

```
1. domain/entity/[Feature].kt                          ← Entity (pure Kotlin data class)
2. domain/repository/[Feature]Repository.kt            ← Repository interface
3. domain/usecase/Get[Feature]UseCase.kt
   domain/usecase/Submit[Feature]UseCase.kt
   ...                                                 ← Use Case(s) (extend SingleUseCase)
4. domain/service/[Feature][Concept]Service.kt         ← Domain Service (only if needed)
```

Never create a use case before the repository interface it depends on.
