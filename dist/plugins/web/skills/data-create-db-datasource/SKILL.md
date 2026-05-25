---
name: data-create-db-datasource
description: Create a DB record type, DB data source interface, and ORM-agnostic implementation stub. Called by data-worker for full-stack features.
user-invocable: false
tools: Read, Write, Glob
---

Create three files for a DB-backed data source:
1. `src/data/data-sources/db/records/[Feature]DbRecord.ts`
2. `src/data/data-sources/db/[Feature]DbDataSource.ts`
3. `src/data/data-sources/db/[Feature]DbDataSourceImpl.ts`

**Preconditions:**
- `src/domain/entities/[Name].ts` must exist
- Check `Glob: src/data/data-sources/db/*Impl.ts` — read one to match project style

**Rules:**
- DB Record uses snake_case column names, nullable columns typed as `[type] | null`
- DB DataSource interface includes only the requested CRUD operations
- DB DataSourceImpl is an **ORM-agnostic stub** — never generate ORM-specific code unless the ORM is explicitly named. Add commented Prisma + Drizzle examples and `throw new Error('Not implemented')` until ORM is chosen.
- `DbClient` type aliased as `unknown` until ORM is chosen

**Pattern:** `reference/database.md` — Grep `## DB DataSource`

**Return:** all three file paths. Suggest next step: `data-create-db-repository`.
