---
platform: web
project: web
discipline: engineering
topic: domain
pattern: repository_interface
---

## Theory

A **Repository** is a contract that defines data access operations — *what* is needed, not *how* it is done.

**Invariants:**
- Lives in Domain as an interface/protocol/abstract class only — implementation lives in Data
- Returns domain Entities — never raw DTOs, API response types, or database records
- Method names follow the operation's intent: `get*`, `create*`, `update*`, `delete*`, `submit*`
- Parameters are domain objects — not raw dictionaries, JSON maps, or HTTP types
- Error type is the domain error type — never a networking or transport error

**When to create:** One repository per aggregate root or feature domain. Created before use cases — use cases depend on the repository interface.

---

## Repository Interfaces

```typescript
// domain/repositories/EmployeeRepository.ts
export interface EmployeeRepository {
  getEmployee(id: string): Promise<Employee>;
  getEmployees(params: {
    page: number;
    limit: number;
    departmentId?: string;
    searchQuery?: string;
  }): Promise<PaginatedResult<Employee>>;
  updateEmployee(employee: Employee): Promise<Employee>;
  deleteEmployee(id: string): Promise<void>;
}
```

**Rules:**
- Always return `Promise<T>` — async by default
- Return domain entities, never DTOs
- Interface must be in the Domain layer — implementations go in Data
