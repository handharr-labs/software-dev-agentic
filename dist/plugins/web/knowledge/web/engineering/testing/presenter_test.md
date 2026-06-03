---
platform: web
project: web
discipline: engineering
topic: testing
pattern: presenter_test
---

## Theory

| Use a mock/stub when… | Use a real implementation when… |
|---|---|
| The dependency has I/O (network, DB, file) | The dependency is pure (mappers, domain services) |
| The test must control exact return values | The test verifies the full integration path |
| Speed matters — unit test suite | Correctness of wiring matters — integration test |

**Never mock domain services or mappers in unit tests** — they are pure functions; test them with real inputs and outputs.

---

## Presenter Tests

```typescript
// __tests__/presentation/hooks/useEmployeeListViewModel.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook, waitFor } from '@testing-library/react';
import { useEmployeeListViewModel } from '@/presentation/features/employee-list/useEmployeeListViewModel';
import { createQueryClientWrapper } from '@/__tests__/utils/queryClientWrapper';

const mockGetEmployeesUseCase = {
  execute: vi.fn(),
};

const mockDeleteEmployeeUseCase = {
  execute: vi.fn(),
};

describe('useEmployeeListViewModel', () => {
  beforeEach(() => vi.clearAllMocks());

  it('loads employees on mount', async () => {
    const employees = [{ id: '1', name: 'John', email: 'john@example.com', department: { id: 'd1', name: 'Eng', headCount: 5 }, joinDate: new Date() }];
    mockGetEmployeesUseCase.execute.mockResolvedValue({ items: employees, totalCount: 1, currentPage: 1, totalPages: 1 });

    const { result } = renderHook(
      () => useEmployeeListViewModel({
        getEmployeesUseCase: mockGetEmployeesUseCase,
        deleteEmployeeUseCase: mockDeleteEmployeeUseCase,
      }),
      { wrapper: createQueryClientWrapper() }
    );

    await waitFor(() => {
      expect(result.current.employees).toEqual(employees);
    });
  });

  it('updates search query on handleSearchChange', () => {
    const { result } = renderHook(
      () => useEmployeeListViewModel({
        getEmployeesUseCase: mockGetEmployeesUseCase,
        deleteEmployeeUseCase: mockDeleteEmployeeUseCase,
      }),
      { wrapper: createQueryClientWrapper() }
    );

    result.current.handleSearchChange('John');
    expect(result.current.searchQuery).toBe('John');
  });
});
```

## Mock vs Real

| Use a mock/stub when… | Use a real implementation when… |
|---|---|
| The dependency has I/O (HTTP, browser storage) | The dependency is pure (Mapper, domain service) |
| The test must control exact return values | The test verifies full integration wiring |
| Unit test speed matters | Correctness of data transformation matters |

**Never mock Mappers or domain Services** — they are pure functions. Instantiate and test with real inputs/outputs.

Use `vi.fn()` for simple stubs; inline object mocks (`{ execute: vi.fn() }`) for use cases and repositories. Pass mocks directly to ViewModel hooks via constructor arguments.
