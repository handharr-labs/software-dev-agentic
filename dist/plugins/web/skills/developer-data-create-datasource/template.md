# Remote DataSource Templates

## Interface
```typescript
// src/data/data-sources/remote/[Feature]RemoteDataSource.ts
import type { [Name]DTO } from '@/data/dtos/[Name]DTO';

export interface [Feature]RemoteDataSource {
  getById(id: string): Promise<[Name]DTO>;
  getMany(params: { page: number; limit: number }): Promise<{ data: [Name]DTO[]; total: number }>;
  create(data: Omit<[Name]DTO, 'id'>): Promise<[Name]DTO>;
  update(id: string, data: Partial<[Name]DTO>): Promise<[Name]DTO>;
  delete(id: string): Promise<void>;
}
```

## Implementation
```typescript
// src/data/data-sources/remote/[Feature]RemoteDataSourceImpl.ts
import type { HTTPClient } from '@/data/networking/HTTPClient';
import type { [Feature]RemoteDataSource } from './[Feature]RemoteDataSource';
import type { [Name]DTO } from '@/data/dtos/[Name]DTO';

export class [Feature]RemoteDataSourceImpl implements [Feature]RemoteDataSource {
  constructor(private readonly httpClient: HTTPClient) {}

  async getById(id: string): Promise<[Name]DTO> {
    return this.httpClient.get<[Name]DTO>(`/api/v1/[feature]/${id}`);
  }
  // ...
}
```
