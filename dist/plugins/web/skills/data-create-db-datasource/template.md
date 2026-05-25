# DB DataSource Templates

## DB Record
```typescript
// src/data/data-sources/db/records/[Feature]DbRecord.ts
export interface [Feature]DbRecord {
  id: string;
  [column_name]: [type];          // required
  [nullable_column]: [type] | null; // nullable
  created_at: Date;
  updated_at: Date;
}
```

## DB DataSource Interface
```typescript
// src/data/data-sources/db/[Feature]DbDataSource.ts
import type { [Feature]DbRecord } from './records/[Feature]DbRecord';

export interface [Feature]DbDataSource {
  findById(id: string): Promise<[Feature]DbRecord>;
  findMany(params: { page: number; limit: number }): Promise<{
    records: [Feature]DbRecord[];
    total: number;
    page: number;
    pageSize: number;
  }>;
  create(data: Omit<[Feature]DbRecord, 'id' | 'created_at' | 'updated_at'>): Promise<[Feature]DbRecord>;
  update(id: string, data: Partial<[Feature]DbRecord>): Promise<[Feature]DbRecord>;
  delete(id: string): Promise<void>;
}
```

## DB DataSource Impl (ORM stub)
```typescript
// src/data/data-sources/db/[Feature]DbDataSourceImpl.ts
type DbClient = unknown; // TODO: replace when ORM is chosen
// Prisma: import { PrismaClient } from '@prisma/client' → type DbClient = PrismaClient

export class [Feature]DbDataSourceImpl implements [Feature]DbDataSource {
  constructor(private readonly db: DbClient) {}

  async findById(id: string): Promise<[Feature]DbRecord> {
    // Prisma:  return (this.db as any).[feature].findUniqueOrThrow({ where: { id } });
    // Drizzle: const [r] = await (this.db as any).select().from([feature]Table).where(eq(...)); return r;
    throw new Error('Not implemented — add ORM query');
  }
  // ... one stub per method
}
```
