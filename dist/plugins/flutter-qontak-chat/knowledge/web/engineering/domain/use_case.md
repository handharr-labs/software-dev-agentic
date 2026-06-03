---
platform: web
project: web
discipline: engineering
topic: domain
pattern: use_case
---

## Theory

A **UseCase** encapsulates a single business operation: one class, one public method, one responsibility.

**Invariants:**
- One business operation per class — never combine unrelated operations
- Depends only on repository interfaces — never on repository implementations or data-layer types
- No framework dependencies — no HTTP clients, no UI types
- Accepts typed input (Params/Request struct) — never raw dictionaries or loose primitives
- Returns domain entities or primitives — never DTOs or view models
- All I/O goes through the repository — use cases never call APIs or databases directly

**Mandatory call flow — no exceptions:**
```
Presentation → UseCase → Repository    ✅
Presentation → Repository              ❌  direct call is a CLEAN violation
```

**When to create:** One use case per business operation (e.g. `GetEmployeeUseCase`, `SubmitLeaveRequestUseCase`, `ApproveLeaveRequestUseCase`). Even thin pass-through use cases are mandatory — they preserve a stable indirection point for future validation, caching, or logging without touching the presentation layer.

---

## Use Cases

Each UseCase has a **Params** type that bundles all input parameters:

```typescript
// domain/use-cases/employee/GetEmployeeUseCase.ts
export interface GetEmployeeUseCaseParams {
  employeeId: string;
}

export interface GetEmployeeUseCase {
  execute(params: GetEmployeeUseCaseParams): Promise<Employee>;
}

export class GetEmployeeUseCaseImpl implements GetEmployeeUseCase {
  constructor(private readonly repository: EmployeeRepository) {}

  async execute(params: GetEmployeeUseCaseParams): Promise<Employee> {
    return this.repository.getEmployee(params.employeeId);
  }
}
```

```typescript
// domain/use-cases/employee/GetEmployeesUseCase.ts
export interface GetEmployeesUseCaseParams {
  page: number;
  limit: number;
  departmentId?: string;
  searchQuery?: string;
}

export interface GetEmployeesUseCase {
  execute(params: GetEmployeesUseCaseParams): Promise<PaginatedResult<Employee>>;
}

export class GetEmployeesUseCaseImpl implements GetEmployeesUseCase {
  constructor(private readonly repository: EmployeeRepository) {}

  async execute(params: GetEmployeesUseCaseParams): Promise<PaginatedResult<Employee>> {
    return this.repository.getEmployees(params);
  }
}
```

For **write operations** (POST/PUT), the Params type separates identifiers from the payload:

```typescript
// domain/use-cases/employee/UpdateEmployeeUseCase.ts
export interface UpdateEmployeeUseCasePayload {
  name: string;
  email: string;
  departmentId: string;
}

export interface UpdateEmployeeUseCaseParams {
  employeeId: string;   // path identifier
  payload: UpdateEmployeeUseCasePayload; // request body
}

export interface UpdateEmployeeUseCase {
  execute(params: UpdateEmployeeUseCaseParams): Promise<Employee>;
}

export class UpdateEmployeeUseCaseImpl implements UpdateEmployeeUseCase {
  constructor(private readonly repository: EmployeeRepository) {}

  async execute(params: UpdateEmployeeUseCaseParams): Promise<Employee> {
    const updated: Employee = {
      id: params.employeeId,
      name: params.payload.name,
      email: params.payload.email,
      department: { id: params.payload.departmentId, name: '', headCount: 0 },
      joinDate: new Date(),
    };
    return this.repository.updateEmployee(updated);
  }
}
```

**Params pattern summary:**

| Operation | Params structure |
|-----------|-----------------|
| GET (single) | `{ id }` |
| GET (list) | `{ page, limit, filters... }` |
| POST | `{ payload: { fields... } }` |
| PUT | `{ id, payload: { fields... } }` |
| DELETE | `{ id }` |

**Naming convention:** `[Verb][Feature]UseCase` — e.g., `GetEmployeeUseCase`, `SubmitAttendanceUseCase`, `CalculateLeaveBalanceUseCase`

## Creation Order

When building a new feature's domain layer, create files in this sequence:

```
1. domain/entities/[Feature].ts                              ← Entity (readonly interface)
2. domain/repositories/[Feature]Repository.ts               ← Repository interface
3. domain/use-cases/[feature]/Get[Feature]UseCase.ts
   domain/use-cases/[feature]/Update[Feature]UseCase.ts
   ...                                                       ← Use Case(s) (interface + impl)
4. domain/services/[Feature][Noun].ts                       ← Domain Service (only if needed)
```

Never create a use case before the repository interface it depends on.
