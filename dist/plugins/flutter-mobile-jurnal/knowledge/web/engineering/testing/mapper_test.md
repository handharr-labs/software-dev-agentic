---
platform: web
project: web
discipline: engineering
topic: testing
pattern: mapper_test
---

## Theory

Mapper tests are pure input → output assertions — the simplest tests to write:

- Provide a fully-populated DTO → assert every field maps to the correct entity field
- Provide a DTO with missing/null optional fields → assert safe defaults or null handling
- No mocks needed — mappers have no dependencies

---

## Mapper Tests

Pure input → output, no mocks needed:

```typescript
// __tests__/data/mappers/EmployeeMapper.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { EmployeeMapperImpl } from '@/data/mappers/EmployeeMapper';

describe('EmployeeMapperImpl', () => {
  let sut: EmployeeMapperImpl;

  beforeEach(() => {
    sut = new EmployeeMapperImpl();
  });

  it('maps all fields correctly', () => {
    const dto = {
      id: '1',
      full_name: 'John Doe',
      email_address: 'john@example.com',
      department: { id: 'd1', name: 'Engineering', head_count: 10 },
      joined_at: '2024-01-01T00:00:00Z',
    };

    const employee = sut.toDomain(dto);

    expect(employee.id).toBe('1');
    expect(employee.name).toBe('John Doe');
    expect(employee.email).toBe('john@example.com');
    expect(employee.department.id).toBe('d1');
    expect(employee.department.name).toBe('Engineering');
    expect(employee.department.headCount).toBe(10);
  });

  it('uses injected child mapper for department', () => {
    const mockDeptMapper = { toDomain: vi.fn().mockReturnValue({ id: 'mock', name: 'Mocked', headCount: 0 }) };
    const sut = new EmployeeMapperImpl(mockDeptMapper);

    const dto = {
      id: '1', full_name: 'John', email_address: 'john@test.com',
      department: { id: 'd1', name: 'Eng', head_count: 5 },
      joined_at: '2024-01-01T00:00:00Z',
    };

    const employee = sut.toDomain(dto);
    expect(employee.department.name).toBe('Mocked'); // proves child mapper was used
    expect(mockDeptMapper.toDomain).toHaveBeenCalledTimes(1);
  });
});
```
