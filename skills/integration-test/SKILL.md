---
name: integration-test
description: Scaffold integration tests for a data layer file (repository or data source). Covers happy path, all HTTP error codes, and network failure.
allowed-tools: Read, Write, Glob, Grep
---

Scaffold integration tests for a data layer file in this Next.js Clean Architecture project.

First, ask me:
1. Target file path (e.g. `src/data/repositories/LeaveRepositoryImpl.ts`)

Then:

**Step 1 — Read the target file**

Read the target file to extract:
- Class name and constructor dependencies
- Every public method: name, parameters, return type
- Which data source / mapper / errorMapper it injects

Also check `__tests__/mocks/` for existing `MockHTTPClient`, `Mock[Feature]Mapper`, and `Mock[Feature]DataSource` — reuse if found.

**Step 2 — Create `MockHTTPClient` if not already in `__tests__/mocks/`**

```typescript
// __tests__/mocks/MockHTTPClient.ts
import { vi } from 'vitest';
import type { HTTPClient } from '@/data/networking/HTTPClient';

export class MockHTTPClient implements HTTPClient {
  get = vi.fn<Parameters<HTTPClient['get']>, ReturnType<HTTPClient['get']>>();
  post = vi.fn<Parameters<HTTPClient['post']>, ReturnType<HTTPClient['post']>>();
  put = vi.fn<Parameters<HTTPClient['put']>, ReturnType<HTTPClient['put']>>();
  delete = vi.fn<Parameters<HTTPClient['delete']>, ReturnType<HTTPClient['delete']>>();
}
```

**Step 3 — Scaffold the integration test**

Output file:
- Repository → `__tests__/data/repositories/[Feature]RepositoryImpl.test.ts`
- DataSource → `__tests__/data/data-sources/[Feature]RemoteDataSourceImpl.test.ts`

```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { [Feature]RepositoryImpl } from '@/data/repositories/[Feature]RepositoryImpl';
import { Mock[Feature]DataSource } from '@/__tests__/mocks/Mock[Feature]DataSource';
import { Mock[Feature]Mapper } from '@/__tests__/mocks/Mock[Feature]Mapper';
import { MockErrorMapper } from '@/__tests__/mocks/MockErrorMapper';
import { DomainError } from '@/domain/errors/DomainError';
import { NetworkError } from '@/data/networking/NetworkError';

describe('[Feature]RepositoryImpl', () => {
  let dataSource: Mock[Feature]DataSource;
  let mapper: Mock[Feature]Mapper;
  let errorMapper: MockErrorMapper;
  let repository: [Feature]RepositoryImpl;

  beforeEach(() => {
    dataSource = new Mock[Feature]DataSource();
    mapper = new Mock[Feature]Mapper();
    errorMapper = new MockErrorMapper();
    repository = new [Feature]RepositoryImpl(dataSource, mapper, errorMapper);
  });

  // Repeat describe block for each public method:
  describe('[methodName]', () => {

    it('calls data source with correct params and returns mapped entity', async () => {
      const mockDto = { /* raw DTO shape */ };
      const mockEntity = { /* expected entity */ };
      dataSource.[methodName].mockResolvedValue(mockDto);
      mapper.toEntity.mockReturnValue(mockEntity);

      const result = await repository.[methodName]([params]);

      expect(dataSource.[methodName]).toHaveBeenCalledWith([params]);
      expect(mapper.toEntity).toHaveBeenCalledWith(mockDto);
      expect(result).toEqual(mockEntity);
    });

    it('maps 400 to DomainError.badRequest', async () => {
      const networkError = new NetworkError(400, 'Bad Request');
      const domainError = new DomainError('badRequest');
      dataSource.[methodName].mockRejectedValue(networkError);
      errorMapper.map.mockReturnValue(domainError);

      await expect(repository.[methodName]([params])).rejects.toThrow(DomainError);
      expect(errorMapper.map).toHaveBeenCalledWith(networkError);
    });

    it('maps 401 to DomainError.unauthorized', async () => {
      const networkError = new NetworkError(401, 'Unauthorized');
      const domainError = new DomainError('unauthorized');
      dataSource.[methodName].mockRejectedValue(networkError);
      errorMapper.map.mockReturnValue(domainError);

      await expect(repository.[methodName]([params])).rejects.toThrow(DomainError);
    });

    it('maps 403 to DomainError.forbidden', async () => {
      const networkError = new NetworkError(403, 'Forbidden');
      const domainError = new DomainError('forbidden');
      dataSource.[methodName].mockRejectedValue(networkError);
      errorMapper.map.mockReturnValue(domainError);

      await expect(repository.[methodName]([params])).rejects.toThrow(DomainError);
    });

    it('maps 404 to DomainError.notFound', async () => {
      const networkError = new NetworkError(404, 'Not Found');
      const domainError = new DomainError('notFound');
      dataSource.[methodName].mockRejectedValue(networkError);
      errorMapper.map.mockReturnValue(domainError);

      await expect(repository.[methodName]([params])).rejects.toThrow(DomainError);
    });

    it('maps 500 to DomainError.serverError', async () => {
      const networkError = new NetworkError(500, 'Internal Server Error');
      const domainError = new DomainError('serverError');
      dataSource.[methodName].mockRejectedValue(networkError);
      errorMapper.map.mockReturnValue(domainError);

      await expect(repository.[methodName]([params])).rejects.toThrow(DomainError);
    });

    it('maps network failure (no response) to DomainError.networkFailure', async () => {
      const networkError = new NetworkError(0, 'Network Error');
      const domainError = new DomainError('networkFailure');
      dataSource.[methodName].mockRejectedValue(networkError);
      errorMapper.map.mockReturnValue(domainError);

      await expect(repository.[methodName]([params])).rejects.toThrow(DomainError);
    });

  });
});
```

**Coverage checklist — every test file must cover:**
- Happy path: correct params forwarded, DTO mapped to entity, result returned
- HTTP 400 → `DomainError.badRequest`
- HTTP 401 → `DomainError.unauthorized`
- HTTP 403 → `DomainError.forbidden`
- HTTP 404 → `DomainError.notFound`
- HTTP 500 → `DomainError.serverError`
- Network failure (no HTTP response) → `DomainError.networkFailure`
- `errorMapper.map` is always called with the original error (not re-wrapped)

**Reminder:** These tests validate that `ErrorMapper` is always invoked — they will catch the common bug where a developer forgets `try/catch` in a new repository method.
