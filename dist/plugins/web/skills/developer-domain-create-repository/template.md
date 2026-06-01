# Repository Interface Template

```typescript
// src/domain/repositories/[Feature]Repository.ts
import type { [Entity] } from '@/domain/entities/[Entity]';

export interface [Feature]Repository {
  findById(id: string): Promise<[Entity]>;
  findMany(params: { page: number; limit: number }): Promise<{ items: [Entity][]; total: number }>;
  create(data: Omit<[Entity], 'id'>): Promise<[Entity]>;
  update(id: string, data: Partial<Omit<[Entity], 'id'>>): Promise<[Entity]>;
  delete(id: string): Promise<void>;
}
```
