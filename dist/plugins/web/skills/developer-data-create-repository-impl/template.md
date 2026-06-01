# Repository Impl Template

```typescript
// src/data/repositories/[Feature]RepositoryImpl.ts
import type { [Feature]Repository } from '@/domain/repositories/[Feature]Repository';
import type { [Entity] } from '@/domain/entities/[Entity]';
import type { [Feature]RemoteDataSource } from '@/data/data-sources/remote/[Feature]RemoteDataSource';
import type { [Name]Mapper } from '@/data/mappers/[Name]Mapper';
import type { ErrorMapper } from '@/data/mappers/ErrorMapper';

export class [Feature]RepositoryImpl implements [Feature]Repository {
  constructor(
    private readonly dataSource: [Feature]RemoteDataSource,
    private readonly mapper: [Name]Mapper,
    private readonly errorMapper: ErrorMapper,
  ) {}

  async getById(id: string): Promise<[Entity]> {
    try {
      const dto = await this.dataSource.getById(id);
      return this.mapper.toEntity(dto);
    } catch (error) {
      throw this.errorMapper.map(error);
    }
  }
}
```
