---
platform: web
project: web
discipline: engineering
topic: data
pattern: repository_impl
---

## Theory

A **Repository Implementation** implements the domain repository interface using a DataSource and Mapper.

**Invariants:**
- Implements a domain repository interface — it is the bridge between Data and Domain
- Calls the DataSource for raw data, calls the Mapper to convert to domain entities
- Wraps all DataSource calls with error handling — maps transport errors to domain errors before returning
- Never lets raw HTTP errors, DB exceptions, or transport-layer types propagate to the domain
- Never calls another repository implementation directly

**When to create:** Last in the creation order — after DataSource interface and implementation exist.

---

## Repository Implementation

Repositories receive mappers through injection — this lets you mock mappers in tests and isolate repository logic.

```typescript
// data/repositories/EmployeeRepositoryImpl.ts
import { EmployeeRepository } from '../../domain/repositories/EmployeeRepository';
import { Employee } from '../../domain/entities/Employee';
import { PaginatedResult } from '../../domain/entities/PaginatedResult';
import { EmployeeRemoteDataSource } from '../data-sources/remote/EmployeeRemoteDataSource';
import { EmployeeMapper, EmployeeMapperImpl } from '../mappers/EmployeeMapper';
import { ErrorMapper, ErrorMapperImpl } from '../mappers/ErrorMapper';
import { NetworkError } from '../networking/NetworkError';

export class EmployeeRepositoryImpl implements EmployeeRepository {
  constructor(
    private readonly remoteDataSource: EmployeeRemoteDataSource,
    private readonly mapper: EmployeeMapper = new EmployeeMapperImpl(),
    private readonly errorMapper: ErrorMapper = new ErrorMapperImpl()
  ) {}

  async getEmployee(id: string): Promise<Employee> {
    try {
      const dto = await this.remoteDataSource.fetchEmployee(id);
      return this.mapper.toDomain(dto);
    } catch (error) {
      throw this.errorMapper.toDomain(error as NetworkError);
    }
  }

  async getEmployees(params: {
    page: number;
    limit: number;
    departmentId?: string;
    searchQuery?: string;
  }): Promise<PaginatedResult<Employee>> {
    try {
      const dto = await this.remoteDataSource.fetchEmployees(params.page, params.limit);
      return {
        items: dto.items.map((item) => this.mapper.toDomain(item)),
        totalCount: dto.total_count,
        currentPage: dto.current_page,
        totalPages: dto.total_pages,
      };
    } catch (error) {
      throw this.errorMapper.toDomain(error as NetworkError);
    }
  }

  async updateEmployee(employee: Employee): Promise<Employee> {
    try {
      const request = this.mapper.toRequest(employee);
      const dto = await this.remoteDataSource.updateEmployee(employee.id, request);
      return this.mapper.toDomain(dto);
    } catch (error) {
      throw this.errorMapper.toDomain(error as NetworkError);
    }
  }

  async deleteEmployee(id: string): Promise<void> {
    try {
      await this.remoteDataSource.deleteEmployee(id);
    } catch (error) {
      throw this.errorMapper.toDomain(error as NetworkError);
    }
  }
}
```

## Creation Order

When building a new feature's data layer, create files in this sequence:

```
1. data/dtos/[Feature]DTO.ts                                      ← DTO (plain interface, snake_case)
2. data/mappers/[Feature]Mapper.ts                                ← Mapper (interface + impl)
3. data/data-sources/remote/[Feature]RemoteDataSource.ts          ← DataSource interface
   data/data-sources/remote/[Feature]RemoteDataSourceImpl.ts      ← DataSource implementation (Axios)
4. data/repositories/[Feature]RepositoryImpl.ts                   ← Repository implementation
```

Never create a repository implementation before the data source it depends on.
