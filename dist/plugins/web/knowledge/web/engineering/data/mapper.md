---
platform: web
project: web
discipline: engineering
topic: data
pattern: mapper
---

## Theory

A **Mapper** converts between a DTO and a domain entity — always defined as an interface with a concrete implementation.

**Invariants:**
- Always interface + implementation — never a plain utility function or static helper
- One direction per method: `toDomain(dto)` converts inward; `toDTO(entity)` converts outward (if write operations exist)
- No I/O — pure transformation only; no network calls, no DB reads
- No business logic — field mapping only; validation belongs in domain use cases
- Null/missing fields handled defensively — never let a missing API field crash the mapper

**When to create:** One mapper per DTO ↔ entity pair. Created after the DTO, before the DataSource implementation.

---

## Mappers

Transform DTOs to domain entities and vice versa. **Each DTO-Entity pair gets its own dedicated mapper.** Mappers are interface-based and injectable — this lets you mock them in repository tests and swap mapping strategies when needed.

```typescript
// data/mappers/DepartmentMapper.ts
import { Department } from '../../domain/entities/Department';
import { DepartmentDTO } from '../dtos/DepartmentDTO';

export interface DepartmentMapper {
  toDomain(dto: DepartmentDTO): Department;
}

export class DepartmentMapperImpl implements DepartmentMapper {
  toDomain(dto: DepartmentDTO): Department {
    return {
      id: dto.id,
      name: dto.name,
      headCount: dto.head_count ?? 0,
    };
  }
}
```

```typescript
// data/mappers/EmployeeMapper.ts
import { Employee } from '../../domain/entities/Employee';
import { EmployeeDTO } from '../dtos/EmployeeDTO';
import { DepartmentMapper, DepartmentMapperImpl } from './DepartmentMapper';

export interface UpdateEmployeeRequest {
  full_name: string;
  email_address: string;
  department_id: string;
}

export interface EmployeeMapper {
  toDomain(dto: EmployeeDTO): Employee;
  toRequest(employee: Employee): UpdateEmployeeRequest;
}

export class EmployeeMapperImpl implements EmployeeMapper {
  constructor(
    private readonly departmentMapper: DepartmentMapper = new DepartmentMapperImpl()
  ) {}

  toDomain(dto: EmployeeDTO): Employee {
    return {
      id: dto.id,
      name: dto.full_name,
      email: dto.email_address,
      department: this.departmentMapper.toDomain(dto.department), // delegates to child mapper
      joinDate: new Date(dto.joined_at),
    };
  }

  toRequest(employee: Employee): UpdateEmployeeRequest {
    return {
      full_name: employee.name,
      email_address: employee.email,
      department_id: employee.department.id,
    };
  }
}
```

```typescript
// data/mappers/ErrorMapper.ts
import { DomainError } from '../../domain/errors/DomainError';
import { NetworkError } from '../networking/NetworkError';

export interface ErrorMapper {
  toDomain(error: NetworkError): DomainError;
}

export class ErrorMapperImpl implements ErrorMapper {
  toDomain(error: NetworkError): DomainError {
    switch (error.type) {
      case 'httpError':
        if (error.statusCode === 401) return DomainError.unauthorized();
        if (error.statusCode === 404) return DomainError.notFound('Resource', '');
        if (error.statusCode >= 500) return DomainError.serverError(error.message ?? 'Server error');
        return new DomainError('unknown', { statusCode: error.statusCode });
      case 'noConnection':
      case 'timeout':
        return DomainError.networkUnavailable();
      default:
        return new DomainError('unknown', { message: error.message });
    }
  }
}
```

**Rules:**
- One mapper per DTO-Entity pair: `EmployeeMapper`, `DepartmentMapper`, `LeaveMapper`, etc.
- Interface-based: each mapper has a `[Name]Mapper` interface and a `[Name]MapperImpl` class
- Mappers compose via injection: `EmployeeMapperImpl` receives `DepartmentMapper` in its constructor
- Default parameter injection: `constructor(departmentMapper = new DepartmentMapperImpl())` — overridable in tests
