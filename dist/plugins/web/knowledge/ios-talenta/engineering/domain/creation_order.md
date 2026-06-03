---
platform: ios
project: ios-talenta
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

## Creation Order

When building a new feature's domain layer, create files in this sequence:

```
1. Domain/Entities/[Feature]Model.swift          ← Entity (pure struct)
2. Domain/Repository/[Feature]Repository.swift   ← Repository protocol
3. Domain/UseCase/[Feature]/Get[Feature]UseCase.swift
   Domain/UseCase/[Feature]/Post[Feature]UseCase.swift
   ...                                            ← Use Case(s)
4. Domain/Services/[Feature]Service.swift        ← Domain Service (only if needed)
```

Never create a use case before the repository protocol it depends on.
`EmployeeRepositoryImpl.sharedInstance` used as the default in `init` must already exist at dependency-injection time — but the protocol is what domain depends on.
