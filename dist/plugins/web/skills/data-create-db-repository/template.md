# DB Repository Templates

## DB Mapper
```typescript
// src/data/mappers/db/[Feature]DbMapper.ts
import type { [Entity] } from '@/domain/entities/[Entity]';
import type { [Feature]DbRecord } from '@/data/data-sources/db/records/[Feature]DbRecord';

export interface [Feature]DbMapper {
  toDomain(record: [Feature]DbRecord): [Entity];
}

export class [Feature]DbMapperImpl implements [Feature]DbMapper {
  toDomain(record: [Feature]DbRecord): [Entity] {
    return {
      id: record.id,
      [camelCaseField]: record.[snake_case_column],
    };
  }
}
```

## DB Repository Impl method pattern (repeat for every method)
```typescript
async [method](params: [Params]): Promise<[ReturnType]> {
  try {
    const record = await this.dataSource.[dbMethod](params);
    return this.mapper.toDomain(record);
  } catch (error) {
    throw this.errorMapper.toDomain(error);
  }
}
```

## DbErrorMapper (create once, shared across all DB repos)
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
