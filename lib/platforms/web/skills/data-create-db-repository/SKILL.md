---
name: data-create-db-repository
description: Create a DB mapper and DB repository implementation. Called by data-worker for full-stack features.
user-invocable: false
tools: Read, Write, Glob
---

Create two files:
1. `src/data/mappers/db/[Feature]DbMapper.ts`
2. `src/data/repositories/[Feature]DbRepositoryImpl.ts`

Also create `src/data/mappers/db/DbErrorMapper.ts` if it does not exist.

**Preconditions:**
- `src/data/data-sources/db/[Feature]DbDataSource.ts` must exist
- `src/domain/repositories/[Feature]Repository.ts` must exist
- `src/domain/entities/[Name].ts` must exist

**DB Mapper rules:**
- Interface: `[Feature]DbMapper` with `toDomain(record: [Feature]DbRecord): [Entity]`
- Implementation: `[Feature]DbMapperImpl`
- Map snake_case DB columns to camelCase domain fields
- Map `Date` columns directly — no string parsing

**DB Repository impl rules:**
- Every method wraps with `try/catch → this.errorMapper.toDomain(error)` — no exceptions
- Constructor injects: `dataSource`, `mapper`, `errorMapper`

**DbErrorMapper rules (if creating):**
- Maps ORM-specific errors to `DomainError`
- Add `// TODO: add ORM-specific error code checks when ORM is chosen` comments

**Pattern:** `reference/database.md` — Grep `## DB Mapper`, `## DB Repository Implementation`, `## DB Error Mapper`

**Return:** all created file paths. Suggest next step: `pres-wire-di`.
