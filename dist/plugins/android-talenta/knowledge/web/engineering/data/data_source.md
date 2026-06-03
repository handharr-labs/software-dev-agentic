---
platform: web
project: web
discipline: engineering
topic: data
pattern: data_source
---

## Theory

A **DataSource** is an abstract interface for raw data access — remote (HTTP) or local (DB, cache).

**Invariants:**
- Interface only in the data layer — implementation is injected, never instantiated directly
- Methods return raw data (DTOs or primitives) — never domain entities
- One DataSource per data origin (remote API, local DB, cache) — do not mix sources in one interface
- Throws or returns transport-layer errors — the repository implementation maps these to domain errors

**When to create:** One DataSource interface per data origin per feature. Created after the DTO and mapper, before the repository implementation.

---

## Data Sources

Abstract the data origin (remote API, local storage, cache).

```typescript
// data/data-sources/remote/EmployeeRemoteDataSource.ts
import { EmployeeDTO } from '../../dtos/EmployeeDTO';
import { PaginatedDTO } from '../../dtos/PaginatedDTO';
import { UpdateEmployeeRequest } from '../../mappers/EmployeeMapper';

export interface EmployeeRemoteDataSource {
  fetchEmployee(id: string): Promise<EmployeeDTO>;
  fetchEmployees(page: number, limit: number): Promise<PaginatedDTO<EmployeeDTO>>;
  updateEmployee(id: string, request: UpdateEmployeeRequest): Promise<EmployeeDTO>;
  deleteEmployee(id: string): Promise<void>;
}

export class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  constructor(private readonly client: HTTPClient) {}

  async fetchEmployee(id: string): Promise<EmployeeDTO> {
    const response = await this.client.get<APIResponse<EmployeeDTO>>(
      `/api/v1/employees/${id}`
    );
    return response.data;
  }

  async fetchEmployees(page: number, limit: number): Promise<PaginatedDTO<EmployeeDTO>> {
    const response = await this.client.get<APIResponse<PaginatedDTO<EmployeeDTO>>>(
      '/api/v1/employees',
      { params: { page, limit } }
    );
    return response.data;
  }

  async updateEmployee(id: string, request: UpdateEmployeeRequest): Promise<EmployeeDTO> {
    const response = await this.client.put<APIResponse<EmployeeDTO>>(
      `/api/v1/employees/${id}`,
      request
    );
    return response.data;
  }

  async deleteEmployee(id: string): Promise<void> {
    await this.client.delete(`/api/v1/employees/${id}`);
  }
}
```
