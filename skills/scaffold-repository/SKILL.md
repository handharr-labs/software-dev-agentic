---
name: scaffold-repository
description: Create a repository implementation with mapper injection and ErrorMapper error mapping. Use when adding a new feature's data layer.
allowed-tools: Read, Write, Edit, Glob, Grep
---

Scaffold a repository implementation for this Next.js Clean Architecture project.

First, ask me:
1. Feature name (e.g. `Leave`, `Payroll`, `Attendance`)
2. Which CRUD methods are needed: `getList` / `getById` / `create` / `update` / `delete`
3. API endpoint pattern (e.g. `/api/v1/leave-requests`, `/api/v1/leave-requests/:id`)

Then:

**Step 1 — Read existing patterns before writing**

```
Read: src/data/repositories/[any existing]RepositoryImpl.ts   (error mapping pattern)
Read: src/domain/repositories/[Feature]Repository.ts          (interface to implement)
Read: src/data/mappers/[Feature]Mapper.ts                     (mapper interface)
```

Match the exact error mapping pattern already used in the project. Never invent a new pattern.

**Step 2 — Generate the repository implementation**

Output file: `src/data/repositories/[Feature]RepositoryImpl.ts`

```typescript
import type { [Feature]Repository } from '@/domain/repositories/[Feature]Repository';
import type { [Entity] } from '@/domain/entities/[Entity]';
import type { [Feature]RemoteDataSource } from '@/data/data-sources/remote/[Feature]RemoteDataSource';
import type { [Feature]Mapper } from '@/data/mappers/[Feature]Mapper';
import type { ErrorMapper } from '@/data/mappers/ErrorMapper';

export class [Feature]RepositoryImpl implements [Feature]Repository {
  constructor(
    private readonly dataSource: [Feature]RemoteDataSource,
    private readonly mapper: [Feature]Mapper,
    private readonly errorMapper: ErrorMapper,
  ) {}

  // Repeat this pattern for every method:
  async [method](params: [Params]): Promise<[ReturnType]> {
    try {
      const dto = await this.dataSource.[method](params);
      return this.mapper.toEntity(dto);       // or .toEntityList(dto) for arrays
    } catch (error) {
      throw this.errorMapper.map(error);      // NetworkError → DomainError
    }
  }
}
```

**Rules — every method must follow this pattern:**
- Wrap the `dataSource` call in `try/catch` — no exceptions
- In the `catch` block, always call `this.errorMapper.map(error)` and re-throw — never swallow errors or throw raw `NetworkError`
- Never call `axios` / `fetch` directly — always delegate to `dataSource`
- Return domain entities, never DTOs

**Step 3 — List files to update**

After generating, remind me to:
1. Wire the new repository in `src/di/container.server.ts`:
   ```typescript
   const [feature]RemoteDS = new [Feature]RemoteDataSourceImpl(httpClient);
   const [feature]Mapper = new [Feature]MapperImpl();
   const [feature]Repository = new [Feature]RepositoryImpl([feature]RemoteDS, [feature]Mapper, errorMapper);
   ```
2. Wire the same in `src/di/container.client.ts` inside `createClientContainer()`
3. Run `/create-mock [Feature]Repository` to scaffold the mock for use case tests
4. Run `/integration-test src/data/repositories/[Feature]RepositoryImpl.ts` to scaffold integration tests
