---
name: new-db-repository
description: Scaffold a DB-backed data source and repository implementation. Use when adding a full-stack feature that reads from or writes to a database instead of an external API.
disable-model-invocation: true
context: fork
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

Scaffold a database-backed data source and repository for this full-stack Next.js Clean Architecture project.

First, ask me:
1. Feature name (e.g. `Leave`, `Employee`, `Payroll`)
2. Which CRUD operations are needed: `findById` / `findMany` / `create` / `update` / `delete`
3. Entity fields — for each: column name, TypeScript type, nullable (yes/no)

Then:

**Step 1 — Read existing patterns before writing**

```
Read: src/domain/repositories/[Feature]Repository.ts     (interface to implement)
Read: src/domain/entities/[Entity].ts                    (entity shape)
Glob: src/data/data-sources/db/*                         (check if db/ folder exists)
Glob: src/data/repositories/*DbRepositoryImpl.ts         (check if any DB repo exists)
```

If a DB repository already exists, match its exact pattern.

**Step 2 — Generate DB Record type**

Output file: `src/data/data-sources/db/records/[Feature]DbRecord.ts`

```typescript
export interface [Feature]DbRecord {
  id: string;
  // snake_case column names matching the DB schema
  [column_name]: [type]; // nullable columns: [type] | null
  created_at: Date;
  updated_at: Date;
}
```

**Step 3 — Generate DB DataSource interface**

Output file: `src/data/data-sources/db/[Feature]DbDataSource.ts`

```typescript
import type { [Feature]DbRecord } from './records/[Feature]DbRecord';

export interface [Feature]DbDataSource {
  findById(id: string): Promise<[Feature]DbRecord>;
  findMany(params: { page: number; limit: number; /* filters */ }): Promise<{
    records: [Feature]DbRecord[];
    total: number;
    page: number;
    pageSize: number;
  }>;
  create(data: Omit<[Feature]DbRecord, 'id' | 'created_at' | 'updated_at'>): Promise<[Feature]DbRecord>;
  update(id: string, data: Partial<[Feature]DbRecord>): Promise<[Feature]DbRecord>;
  delete(id: string): Promise<void>;
}
// Include only the methods that were requested
```

**Step 4 — Generate DB DataSource implementation (ORM stub)**

Output file: `src/data/data-sources/db/[Feature]DbDataSourceImpl.ts`

```typescript
// ORM client type — replace `DbClient` with your ORM's client type when chosen:
// Prisma:  import { PrismaClient } from '@prisma/client'  →  type DbClient = PrismaClient
// Drizzle: import { LibSQLDatabase } from 'drizzle-orm/libsql'  →  type DbClient = LibSQLDatabase
type DbClient = unknown; // TODO: replace when ORM is chosen

export class [Feature]DbDataSourceImpl implements [Feature]DbDataSource {
  constructor(private readonly db: DbClient) {}

  async findById(id: string): Promise<[Feature]DbRecord> {
    // Prisma:  return (this.db as any).[feature].findUniqueOrThrow({ where: { id } });
    // Drizzle: const [r] = await (this.db as any).select().from([feature]Table).where(eq([feature]Table.id, id)); return r;
    throw new Error('Not implemented — add ORM query');
  }
  // ... one stub per method
}
```

**Step 5 — Generate DB Mapper**

Output file: `src/data/mappers/db/[Feature]DbMapper.ts`

```typescript
import type { [Entity] } from '@/domain/entities/[Entity]';
import type { [Feature]DbRecord } from '@/data/data-sources/db/records/[Feature]DbRecord';

export interface [Feature]DbMapper {
  toDomain(record: [Feature]DbRecord): [Entity];
}

export class [Feature]DbMapperImpl implements [Feature]DbMapper {
  toDomain(record: [Feature]DbRecord): [Entity] {
    return {
      id: record.id,
      // map snake_case columns to camelCase entity fields
      // map Date columns directly (no string parsing needed)
    };
  }
}
```

**Step 6 — Check if `DbErrorMapper` exists**

```
Glob: src/data/mappers/db/DbErrorMapper.ts
```

If missing, generate it:

```typescript
// src/data/mappers/db/DbErrorMapper.ts
import { DomainError } from '@/domain/errors/DomainError';

export interface DbErrorMapper {
  toDomain(error: unknown): DomainError;
}

export class DbErrorMapperImpl implements DbErrorMapper {
  toDomain(error: unknown): DomainError {
    if (error instanceof DomainError) return error;
    // TODO: add ORM-specific error code checks when ORM is chosen
    // Prisma P2025 → DomainError.notFound
    // Prisma P2002 → DomainError.conflict
    return new DomainError('unknown', { message: String(error) });
  }
}
```

**Step 7 — Generate DB Repository implementation**

Output file: `src/data/repositories/[Feature]DbRepositoryImpl.ts`

Follow the exact pattern from `database.md` Section 17.5 — every method wraps with `try/catch → this.errorMapper.toDomain(error)`.

**Step 8 — Remind: wire into container.server.ts**

After generating, remind me to:

```typescript
// src/di/container.server.ts — add:
import { db } from '@/lib/db';
import { [Feature]DbDataSourceImpl } from '@/data/data-sources/db/[Feature]DbDataSourceImpl';
import { [Feature]DbRepositoryImpl } from '@/data/repositories/[Feature]DbRepositoryImpl';
import { [Feature]DbMapperImpl } from '@/data/mappers/db/[Feature]DbMapper';
import { DbErrorMapperImpl } from '@/data/mappers/db/DbErrorMapper';

const [feature]DataSource = new [Feature]DbDataSourceImpl(db);
const [feature]Mapper = new [Feature]DbMapperImpl();
const dbErrorMapper = new DbErrorMapperImpl(); // reuse if already instantiated
const [feature]Repository = new [Feature]DbRepositoryImpl(
  [feature]DataSource, [feature]Mapper, dbErrorMapper
);
```

Also remind: run `/create-mock [Feature]DbDataSource` to scaffold the mock for repository tests.
