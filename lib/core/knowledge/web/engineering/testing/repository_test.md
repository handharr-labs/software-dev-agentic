---
platform: web
project: web
discipline: engineering
topic: testing
pattern: repository_test
---

## Theory

Repository implementation tests verify the bridge between DataSource and Domain:

- Use a test double (mock/stub) for the DataSource — not a real network or DB
- Assert that the repository maps DataSource output to the correct domain entity
- Assert that DataSource errors are caught and mapped to the correct domain error type
- One test per operation (get, create, update, delete)

---

## Repository Tests

With injectable mappers, you can isolate repository logic from mapping logic:

```typescript
// __tests__/data/repositories/EmployeeRepositoryImpl.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { EmployeeRepositoryImpl } from '@/data/repositories/EmployeeRepositoryImpl';

const mockRemoteDataSource = {
  fetchEmployee: vi.fn(),
  fetchEmployees: vi.fn(),
  updateEmployee: vi.fn(),
  deleteEmployee: vi.fn(),
};

const mockMapper = {
  toDomain: vi.fn(),
  toRequest: vi.fn(),
};

describe('EmployeeRepositoryImpl', () => {
  let sut: EmployeeRepositoryImpl;

  beforeEach(() => {
    vi.clearAllMocks();
    sut = new EmployeeRepositoryImpl(mockRemoteDataSource, mockMapper);
  });

  it('calls data source and mapper on getEmployee', async () => {
    const dto = { id: '1', full_name: 'John', email_address: 'john@example.com', department: { id: 'd1', name: 'Eng' }, joined_at: '2024-01-01T00:00:00Z' };
    const entity = { id: '1', name: 'John', email: 'john@example.com', department: { id: 'd1', name: 'Eng', headCount: 0 }, joinDate: new Date() };

    mockRemoteDataSource.fetchEmployee.mockResolvedValue(dto);
    mockMapper.toDomain.mockReturnValue(entity);

    const result = await sut.getEmployee('1');

    expect(mockRemoteDataSource.fetchEmployee).toHaveBeenCalledWith('1');
    expect(mockMapper.toDomain).toHaveBeenCalledWith(dto);
    expect(result).toEqual(entity);
  });
});
```
