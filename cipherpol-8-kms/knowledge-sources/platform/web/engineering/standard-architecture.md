---
scope: platform/web
discipline: engineering
artifact: standard-architecture
---
Consolidated Next.js 15 Clean Architecture reference — covers all engineering layers, patterns, and cross-cutting concerns used across web projects.

# Domain

## Creation Order

### Theory

When building a new feature's domain layer:

```
Entity → Repository Interface → Use Case(s) → Domain Service (only if needed)
```

Never create a use case before the repository interface it depends on.

---

### Code Pattern

```
1. domain/entities/[feature].entity.ts               ← Entity (plain TS interface, immutable)
2. domain/repositories/[feature].repository.ts       ← Repository interface
3. domain/usecases/[feature]/get-[feature].usecase.ts
   domain/usecases/[feature]/update-[feature].usecase.ts
   ...                                               ← Use Case(s)
4. domain/services/[feature]-[calculator|validator].service.ts
                                                     ← Domain Service (only if needed)
```

## Dependency Rule

### Theory

Domain is the innermost layer. It imports nothing from outer layers.

```
UI  →  Presentation  →  Data  →  Domain
```

Allowed imports: TypeScript/JavaScript language primitives only.
Forbidden: any framework, UI library, HTTP client, database driver, or data-layer type.

---

**Allowed:** TypeScript built-ins, `neverthrow` (for `Result`/`Either`).

**Forbidden:**
- `axios` / `fetch` — HTTP clients belong in data
- `react`, `next` — UI frameworks must not enter domain
- Any Zustand store or TanStack Query import
- Any data-layer import — no `*Dto`, `*Schema`, or `*DataSource` types from `data/`

## Domain Enum

### Theory

Business-level constants. Place in `domain/enums/`.

**Rules:**
- String values only when needed for direct API mapping
- No UI labels — display formatting belongs in presentation

### Code Pattern

```typescript
// domain/enums/leave-status.enum.ts
export enum LeaveStatus {
  Pending = 'pending',
  Approved = 'approved',
  Rejected = 'rejected',
  Cancelled = 'cancelled',
}

export const isTerminalLeaveStatus = (status: LeaveStatus): boolean =>
  status === LeaveStatus.Approved ||
  status === LeaveStatus.Rejected ||
  status === LeaveStatus.Cancelled;
```

## Domain Error

### Theory

A **Domain Error** is the unified error type returned from all repository and use case operations. It decouples the domain from transport-layer error types (HTTP status codes, network errors).

**Invariants:**
- Domain operations return a `Result<T, Failure>` — they never propagate raw network errors upward
- Repositories map transport errors to domain errors before returning
- Error codes are business-meaningful — not HTTP status codes

---

### Code Pattern

```typescript
// domain/errors/failure.ts
export type Failure =
  | { kind: 'server'; message: string; developerMessage: string; statusCode?: number; errorCode?: string }
  | { kind: 'validation'; message: string; errors?: Record<string, string[]>; statusCode?: number }
  | { kind: 'network'; message: string }
  | { kind: 'unknown'; message: string }
  | { kind: 'local'; message: string };

export const Failure = {
  server: (p: Omit<Extract<Failure, { kind: 'server' }>, 'kind'>): Failure => ({ kind: 'server', ...p }),
  validation: (p: Omit<Extract<Failure, { kind: 'validation' }>, 'kind'>): Failure => ({ kind: 'validation', ...p }),
  network: (message: string): Failure => ({ kind: 'network', message }),
  unknown: (message: string): Failure => ({ kind: 'unknown', message }),
  local: (message: string): Failure => ({ kind: 'local', message }),
} as const;
```

## Domain Service

### Theory

A **Domain Service** contains pure business logic that spans multiple entities or is reused across multiple use cases.

**Invariants:**
- No I/O — no async, no network, no database, no file system
- No side effects — pure functions; same input always produces the same output
- No framework imports
- Returns structured data — never formatted strings or display labels

**When to extract to a service:**

| Scenario | Decision |
|----------|----------|
| 1–3 line condition | Keep inline in use case |
| Complex multi-step validation | Extract to service |
| Logic reused across ≥ 2 use cases | Extract to service |
| Needs independent unit testing | Extract to service |

**Naming:** `[Feature][Noun]Service` — e.g. `LeaveBalanceCalculator`, `AttendanceScheduleResolver`

---

### Code Pattern

```typescript
// domain/services/leave-balance-calculator.service.ts
import type { LeaveEntitlementEntity } from '../entities/leave-entitlement.entity';
import { LeaveStatus } from '../enums/leave-status.enum';

export class LeaveBalanceCalculator {
  remainingDays(entitlement: LeaveEntitlementEntity): number {
    const pendingDays = entitlement.pendingRequests
      .filter(r => r.status === LeaveStatus.Pending)
      .reduce((sum, r) => sum + r.days, 0);
    const remaining = entitlement.annualDays - entitlement.usedDays - pendingDays;
    return remaining < 0 ? 0 : remaining;
  }

  isSufficient(entitlement: LeaveEntitlementEntity, requestedDays: number): boolean {
    return this.remainingDays(entitlement) >= requestedDays;
  }
}
```

## Entity

### Theory

An **Entity** is a pure data structure representing a business concept.

**Invariants:**
- No framework imports — plain TypeScript types only
- No business logic — entities hold data; use cases execute logic
- No serialization logic — no `toJson`, no Zod schema
- Immutable — all properties are `readonly`
- Represent domain concepts, not API shapes — field names match the business domain

---

### Code Pattern

```typescript
// domain/entities/employee.entity.ts
export interface EmployeeEntity {
  readonly id: string;
  readonly name: string;
  readonly email: string;
  readonly joinDate?: Date;
  readonly departmentId?: string;
}
```

## Repository Interface

### Theory

A **Repository** is a contract that defines data access operations — *what* is needed, not *how* it is done.

**Invariants:**
- Lives in Domain as an interface only — implementation lives in Data
- Returns domain Entities wrapped in `Result<T, Failure>` — never raw DTOs
- Method names follow the operation's intent: `get*`, `create*`, `update*`, `delete*`
- Parameters are domain objects — not raw JSON or HTTP types

---

### Code Pattern

```typescript
// domain/repositories/employee.repository.ts
import type { Result } from 'neverthrow';
import type { EmployeeEntity } from '../entities/employee.entity';
import type { Failure } from '../errors/failure';

export interface GetEmployeesParams {
  page?: number;
  limit?: number;
  departmentId?: string;
}

export interface UpdateEmployeeParams {
  id: string;
  name: string;
  email: string;
  departmentId?: string;
}

export interface EmployeeRepository {
  getEmployee(id: string): Promise<Result<EmployeeEntity, Failure>>;
  getEmployees(params?: GetEmployeesParams): Promise<Result<EmployeeEntity[], Failure>>;
  updateEmployee(params: UpdateEmployeeParams): Promise<Result<EmployeeEntity, Failure>>;
  deleteEmployee(id: string): Promise<Result<void, Failure>>;
}
```

## Use Case

### Theory

A **UseCase** encapsulates a single business operation: one class, one public method, one responsibility.

**Invariants:**
- One business operation per class — never combine unrelated operations
- Depends only on repository interfaces — never on repository implementations
- No framework dependencies
- Accepts typed input (Params struct) — never raw objects
- Returns domain entities or primitives wrapped in `Result` — never DTOs
- All I/O goes through the repository — use cases never call APIs directly

**Mandatory call flow:**
```
Presentation → UseCase → Repository    ✅
Presentation → Repository              ❌  direct call is a Clean Architecture violation
```

---

**Naming:** `[Verb][Feature]UseCase` — `GetEmployeeUseCase`, `SubmitLeaveRequestUseCase`

### Code Pattern

```typescript
// domain/usecases/employee/get-employee.usecase.ts
import { injectable, inject } from 'tsyringe';
import type { Result } from 'neverthrow';
import type { EmployeeEntity } from '../../entities/employee.entity';
import type { Failure } from '../../errors/failure';
import type { EmployeeRepository } from '../../repositories/employee.repository';
import { TOKENS } from '@di/tokens';

@injectable()
export class GetEmployeeUseCase {
  constructor(
    @inject(TOKENS.EmployeeRepository) private readonly repository: EmployeeRepository,
  ) {}

  execute(id: string): Promise<Result<EmployeeEntity, Failure>> {
    return this.repository.getEmployee(id);
  }
}
```

```typescript
// GET — list with params
@injectable()
export class GetEmployeesUseCase {
  constructor(
    @inject(TOKENS.EmployeeRepository) private readonly repository: EmployeeRepository,
  ) {}

  execute(params?: GetEmployeesParams): Promise<Result<EmployeeEntity[], Failure>> {
    return this.repository.getEmployees(params);
  }
}
```

# Data

## Creation Order

### Theory

**Remote API feature:**

```
Zod Schema (DTO) → Mapper → DataSource interface → DataSource impl → Repository impl
```

Never create a repository implementation before the DataSource it depends on.

---

### Code Pattern

```
1. data/models/[feature].dto.ts                              ← DTO (Zod schema + inferred type)
   data/models/[feature]-payload.dto.ts                      ← Write payload (if POST/PUT)
2. data/mappers/[feature].mapper.ts                          ← Mapper (toEntity function)
3. data/datasources/[feature]-remote.datasource.ts           ← DataSource interface
   data/datasources/[feature]-remote.datasource.impl.ts      ← DataSource implementation (axios)
4. data/repositories/[feature].repository.impl.ts            ← Repository implementation
```

## Data Source

### Theory

A **DataSource** is an interface for raw data access — remote (HTTP) or local (storage/cache).

**Invariants:**
- Interface only in the data layer — implementation is injected, never instantiated directly
- Methods return raw data (DTOs or primitives) — never domain entities
- Throws or propagates transport-layer errors — the repository implementation maps these to domain errors

---

### Code Pattern

```typescript
// data/datasources/employee-remote.datasource.ts
import type { EmployeeDto, UpdateEmployeePayloadDto } from '../models/employee.dto';

export interface EmployeeRemoteDataSource {
  getEmployee(id: string): Promise<EmployeeDto>;
  getEmployees(params?: { page?: number; limit?: number; departmentId?: string }): Promise<EmployeeDto[]>;
  updateEmployee(id: string, payload: UpdateEmployeePayloadDto): Promise<EmployeeDto>;
  deleteEmployee(id: string): Promise<void>;
}
```

```typescript
// data/datasources/employee-remote.datasource.impl.ts
import { injectable, inject } from 'tsyringe';
import type { AxiosInstance } from 'axios';
import { TOKENS } from '@di/tokens';
import { employeeDtoSchema } from '../models/employee.dto';
import type { EmployeeDto, UpdateEmployeePayloadDto } from '../models/employee.dto';
import type { EmployeeRemoteDataSource } from './employee-remote.datasource';

@injectable()
export class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  constructor(@inject(TOKENS.HttpClient) private readonly http: AxiosInstance) {}

  async getEmployee(id: string): Promise<EmployeeDto> {
    const { data } = await this.http.get(`/api/v1/employees/${id}`);
    return employeeDtoSchema.parse(data.data);
  }

  async getEmployees(params?: { page?: number; limit?: number; departmentId?: string }): Promise<EmployeeDto[]> {
    const { data } = await this.http.get('/api/v1/employees', { params });
    return employeeDtoSchema.array().parse(data.data ?? []);
  }

  async updateEmployee(id: string, payload: UpdateEmployeePayloadDto): Promise<EmployeeDto> {
    const { data } = await this.http.put(`/api/v1/employees/${id}`, payload);
    return employeeDtoSchema.parse(data.data);
  }

  async deleteEmployee(id: string): Promise<void> {
    await this.http.delete(`/api/v1/employees/${id}`);
  }
}
```

## DTO

### Theory

A **DTO (Data Transfer Object)** mirrors the raw API or database shape exactly.

**Invariants:**
- No domain logic — plain data container only
- No computed fields — no derived values, no formatting
- Serialization/validation annotations live here (Zod schema), not on domain entities
- Field names match the API/DB schema — not the business domain vocabulary
- All fields nullable — API data is untrusted

---

### Code Pattern

```typescript
// data/models/employee.dto.ts
import { z } from 'zod';

export const employeeDtoSchema = z.object({
  employee_id: z.string().nullable().optional(),
  full_name: z.string().nullable().optional(),
  email: z.string().nullable().optional(),
  join_date: z.string().nullable().optional(),
  department_id: z.string().nullable().optional(),
});

export type EmployeeDto = z.infer<typeof employeeDtoSchema>;

// Write payload
export const updateEmployeePayloadSchema = z.object({
  full_name: z.string(),
  email: z.string().email(),
  department_id: z.string().optional(),
});

export type UpdateEmployeePayloadDto = z.infer<typeof updateEmployeePayloadSchema>;
```

## Exception

### Theory

Typed exceptions thrown by DataSources. Converted to `Failure` in the repository. Never propagated to domain or presentation.

### Code Pattern

```typescript
// data/exceptions/app.exception.ts
export class AppException extends Error {
  constructor(
    message: string,
    public readonly kind: 'server' | 'validation' | 'network' | 'unknown',
    public readonly statusCode?: number,
    public readonly errorCode?: string,
    public readonly errors?: Record<string, string[]>,
  ) {
    super(message);
    this.name = 'AppException';
  }

  static server(message: string, statusCode?: number, errorCode?: string): AppException {
    return new AppException(message, 'server', statusCode, errorCode);
  }

  static validation(message: string, errors?: Record<string, string[]>, statusCode?: number): AppException {
    return new AppException(message, 'validation', statusCode, undefined, errors);
  }

  static network(message: string): AppException {
    return new AppException(message, 'network');
  }

  static unknown(message: string): AppException {
    return new AppException(message, 'unknown');
  }
}
```

## HTTP Client

### Theory

`ErrorInterceptor` translates Axios errors → `AppException` before they reach the repository. Registered on Axios instance creation.

### Code Pattern

```typescript
// data/network/error.interceptor.ts
import type { AxiosError } from 'axios';
import { AppException } from '../exceptions/app.exception';

export function attachErrorInterceptor(axiosInstance: AxiosInstance): void {
  axiosInstance.interceptors.response.use(
    response => response,
    (error: AxiosError<{ message?: string; errors?: Record<string, string[]> }>) => {
      if (!error.response) {
        return Promise.reject(AppException.network('No internet connection'));
      }

      const { status, data } = error.response;
      const message = data?.message ?? error.message ?? 'Server error';

      if (status === 422) {
        return Promise.reject(AppException.validation(message, data?.errors, status));
      }

      return Promise.reject(AppException.server(message, status));
    },
  );
}
```

## Mapper

### Theory

A **Mapper** converts between a DTO and a domain entity.

**Invariants:**
- Pure transformation only — no I/O, no network, no DB
- No business logic — field mapping only
- Null/missing fields handled defensively — never let a missing API field crash the mapper
- Date strings → `Date` conversion happens in mapper, not entity

---

### Code Pattern

```typescript
// data/mappers/employee.mapper.ts
import type { EmployeeDto } from '../models/employee.dto';
import type { EmployeeEntity } from '@domain/entities/employee.entity';
import { orEmpty } from '@shared/utils/null-safety';

export function mapEmployeeDtoToEntity(dto: EmployeeDto): EmployeeEntity {
  return {
    id: orEmpty(dto.employee_id),
    name: orEmpty(dto.full_name),
    email: orEmpty(dto.email),
    joinDate: dto.join_date ? new Date(dto.join_date) : undefined,
    departmentId: dto.department_id ?? undefined,
  };
}
```

## Repository Implementation

### Theory

A **Repository Implementation** implements the domain repository interface using a DataSource and Mapper.

**Invariants:**
- Wraps all DataSource calls with error handling — maps transport errors to domain errors
- Never lets raw HTTP errors propagate to the domain
- `*Dto` instances never cross into domain — the mapper function is the boundary
- Registered as the concrete implementation for the domain interface

---

### Code Pattern

```typescript
// data/repositories/employee.repository.impl.ts
import { injectable, inject } from 'tsyringe';
import { ok, err, type Result } from 'neverthrow';
import { TOKENS } from '@di/tokens';
import type { EmployeeRepository, GetEmployeesParams, UpdateEmployeeParams } from '@domain/repositories/employee.repository';
import type { EmployeeEntity } from '@domain/entities/employee.entity';
import { Failure } from '@domain/errors/failure';
import { AppException } from '../exceptions/app.exception';
import type { EmployeeRemoteDataSource } from '../datasources/employee-remote.datasource';
import { mapEmployeeDtoToEntity } from '../mappers/employee.mapper';
import type { UpdateEmployeePayloadDto } from '../models/employee.dto';

@injectable()
export class EmployeeRepositoryImpl implements EmployeeRepository {
  constructor(
    @inject(TOKENS.EmployeeRemoteDataSource) private readonly dataSource: EmployeeRemoteDataSource,
  ) {}

  async getEmployee(id: string): Promise<Result<EmployeeEntity, Failure>> {
    try {
      const dto = await this.dataSource.getEmployee(id);
      return ok(mapEmployeeDtoToEntity(dto));
    } catch (e) {
      return err(toFailure(e));
    }
  }

  async updateEmployee(params: UpdateEmployeeParams): Promise<Result<EmployeeEntity, Failure>> {
    try {
      const payload: UpdateEmployeePayloadDto = {
        full_name: params.name,
        email: params.email,
        department_id: params.departmentId,
      };
      const dto = await this.dataSource.updateEmployee(params.id, payload);
      return ok(mapEmployeeDtoToEntity(dto));
    } catch (e) {
      return err(toFailure(e));
    }
  }

  async getEmployees(params?: GetEmployeesParams): Promise<Result<EmployeeEntity[], Failure>> {
    try {
      const dtos = await this.dataSource.getEmployees(params);
      return ok(dtos.map(mapEmployeeDtoToEntity));
    } catch (e) {
      return err(toFailure(e));
    }
  }

  async deleteEmployee(id: string): Promise<Result<void, Failure>> {
    try {
      await this.dataSource.deleteEmployee(id);
      return ok(undefined);
    } catch (e) {
      return err(toFailure(e));
    }
  }
}

function toFailure(e: unknown): Failure {
  if (e instanceof AppException) {
    switch (e.kind) {
      case 'server': return Failure.server({ message: e.message, developerMessage: `HTTP ${e.statusCode}`, statusCode: e.statusCode, errorCode: e.errorCode });
      case 'validation': return Failure.validation({ message: e.message, errors: e.errors, statusCode: e.statusCode });
      case 'network': return Failure.network(e.message);
    }
  }
  return Failure.unknown(e instanceof Error ? e.message : String(e));
}
```

# Presentation

## State Holder (Hook)

### Theory

A **StateHolder** is the single source of truth for a screen's UI state. In Next.js / React, this is a custom hook that encapsulates use case calls, loading/error/data state, and exposes events as handler functions.

**Invariants:**
- Owns no view imports — no JSX, no component types
- Depends on use case instances only — never calls repositories or data sources directly
- Use cases are injected (via hook params or DI container) — never instantiated directly inside the hook
- Exposes state as immutable values — UI reads, never mutates state directly
- One hook per screen — never shared across unrelated screens

---

**TanStack Query** is the StateHolder for server state (fetch, cache, revalidate).
**Zustand** is the StateHolder for client-only UI state (modals, selections, multi-step flows).

### Code Pattern

```typescript
// presentation/hooks/use-employee.ts
'use client';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { container } from '@di/container';
import { TOKENS } from '@di/tokens';
import type { UpdateEmployeeParams } from '@domain/repositories/employee.repository';

const EMPLOYEE_QUERY_KEY = (id: string) => ['employee', id] as const;

export function useEmployee(id: string) {
  const useCase = container.resolve<GetEmployeeUseCase>(TOKENS.GetEmployeeUseCase);

  return useQuery({
    queryKey: EMPLOYEE_QUERY_KEY(id),
    queryFn: async () => {
      const result = await useCase.execute(id);
      if (result.isErr()) throw result.error;
      return result.value;
    },
  });
}

export function useUpdateEmployee() {
  const queryClient = useQueryClient();
  const useCase = container.resolve<UpdateEmployeeUseCase>(TOKENS.UpdateEmployeeUseCase);

  return useMutation({
    mutationFn: async (params: UpdateEmployeeParams) => {
      const result = await useCase.execute(params);
      if (result.isErr()) throw result.error;
      return result.value;
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: EMPLOYEE_QUERY_KEY(data.id) });
    },
  });
}
```

**Zustand for client state (multi-step form, modals):**

```typescript
// presentation/stores/employee-form.store.ts
import { create } from 'zustand';

interface EmployeeFormState {
  step: number;
  formData: Partial<UpdateEmployeeParams>;
  setStep: (step: number) => void;
  setFormData: (data: Partial<UpdateEmployeeParams>) => void;
  reset: () => void;
}

export const useEmployeeFormStore = create<EmployeeFormState>(set => ({
  step: 0,
  formData: {},
  setStep: step => set({ step }),
  setFormData: data => set(state => ({ formData: { ...state.formData, ...data } })),
  reset: () => set({ step: 0, formData: {} }),
}));
```

## Component

### Theory

A **Component** is a reusable UI element smaller than a full page.

**Invariants:**
- Stateless by default — receives data via props and emits callbacks
- If stateful, bound to a scoped store/hook — never manages business state inline
- No direct use case calls — all data passed in from the parent page or a scoped hook
- Reuse check required before creating — search shared component directories first

**When to create:** When a UI element appears in ≥2 pages, or when a page section is complex enough to isolate for readability.

---

### Code Pattern

```typescript
// presentation/components/EmployeeCard.tsx
import type { EmployeeEntity } from '@domain/entities/employee.entity';

interface EmployeeCardProps {
  employee: EmployeeEntity;
  onEdit?: (id: string) => void;
}

export function EmployeeCard({ employee, onEdit }: EmployeeCardProps) {
  return (
    <div className="card">
      <h3>{employee.name}</h3>
      <p>{employee.email}</p>
      {onEdit && (
        <button onClick={() => onEdit(employee.id)}>Edit</button>
      )}
    </div>
  );
}
```

**Component reuse search paths:**

| Scope | Path |
|---|---|
| Shared core (cross-feature) | `src/shared/components/` |
| Feature pages | `src/features/*/presentation/pages/` |
| Feature components | `src/features/*/presentation/components/` |

## Page Structure

### Theory

A **Page** is a full-view component bound to a route. It observes state from hooks and dispatches mutations — it contains no business logic.

**Invariants:**
- Bound to exactly one set of StateHolder hooks — never instantiates use cases directly
- Observes every state field — no state slice goes unhandled (loading, error, data)
- Contains no business logic — conditionals exist only to decide what to render
- Server Components by default in Next.js App Router — use `'use client'` only when interactivity requires it

**When to create:** One page per route/destination. Created after the hook contracts exist.

---

**Next.js App Router split:**

| Component Type | When to use |
|---|---|
| Server Component (default) | Data fetch at render time, no client interactivity |
| Client Component (`'use client'`) | User events, TanStack Query, Zustand, browser APIs |

### Code Pattern

```typescript
// app/employees/[id]/page.tsx  (Server Component — initial data fetch)
import { container } from '@di/container';
import { TOKENS } from '@di/tokens';
import { EmployeeDetailClient } from './_components/EmployeeDetailClient';

interface PageProps {
  params: { id: string };
}

export default async function EmployeeDetailPage({ params }: PageProps) {
  const useCase = container.resolve<GetEmployeeUseCase>(TOKENS.GetEmployeeUseCase);
  const result = await useCase.execute(params.id);

  if (result.isErr()) {
    // Handled by Next.js error.tsx boundary
    throw result.error;
  }

  return <EmployeeDetailClient initialData={result.value} employeeId={params.id} />;
}
```

```typescript
// app/employees/[id]/_components/EmployeeDetailClient.tsx
'use client';
import { useEmployee, useUpdateEmployee } from '@features/employee/presentation/hooks/use-employee';
import type { EmployeeEntity } from '@domain/entities/employee.entity';

interface Props {
  initialData: EmployeeEntity;
  employeeId: string;
}

export function EmployeeDetailClient({ initialData, employeeId }: Props) {
  const { data: employee, isLoading, error } = useEmployee(employeeId);
  const { mutate: updateEmployee, isPending } = useUpdateEmployee();

  if (isLoading) return <LoadingSpinner />;
  if (error) return <ErrorView failure={error} />;
  if (!employee) return <EmptyState />;

  return (
    <EmployeeCard
      employee={employee}
      onEdit={id => updateEmployee({ id, name: employee.name, email: employee.email })}
    />
  );
}
```

## Screen Entry Points

### Theory

When tracing a page's full layer stack, start from the page component and follow imports inward through each layer.

### Definition

**Layer file patterns:**

| Layer | Glob | Grep |
|---|---|---|
| Page | `**/app/**/*page.tsx`, `**/app/**/*page.ts` | `export default async function.*Page`, `export default function.*Page` |
| Hook (StateHolder) | `**/presentation/hooks/use-*.ts` | `export function use[A-Z]` |
| UseCase | `**/domain/usecases/**/*.usecase.ts` | `export class.*UseCase` |
| Repository interface | `**/domain/repositories/**/*.repository.ts` | `export interface.*Repository` |
| Repository impl | `**/data/repositories/**/*.repository.impl.ts` | `export class.*RepositoryImpl.*implements` |
| Remote DataSource | `**/data/datasources/**/*-remote.datasource.ts` | `export interface.*RemoteDataSource` |
| DTO / Schema | `**/data/models/**/*.dto.ts` | `export const.*Schema`, `export type.*Dto` |
| Mapper | `**/data/mappers/**/*.mapper.ts` | `export function map.*DtoToEntity` |

**Tracing strategy:**
1. Read the page file — find the hook or use case class name
2. Read the hook — find UseCase class names from `container.resolve` calls
3. Read each UseCase — find the Repository interface from the constructor parameter type
4. Grep `class.*RepositoryImpl.*implements.*{RepositoryName}` — find the concrete implementation
5. Read the RepositoryImpl — find DataSource class names from constructor parameters
6. Read each DataSource — extract HTTP method, endpoint string, and DTO type names

# Dependency Injection

## Container

### Theory

| Scope | Use for | Lifetime |
|---|---|---|
| Singleton | Shared infrastructure — HTTP client, token store, logger | App lifetime |
| Feature-scoped | Use cases and repositories for a single feature | Request/route lifetime |
| Transient | Stateless helpers, mappers | Per-resolution |

**Never register a state store (Zustand) in the DI container** — it is module-level singleton state owned by the store file itself.

---

`tsyringe` decorators + a central `container.ts` file. One tokens file for all DI tokens.

### Code Pattern

```typescript
// di/tokens.ts
export const TOKENS = {
  HttpClient: Symbol('HttpClient'),
  EmployeeRepository: Symbol('EmployeeRepository'),
  EmployeeRemoteDataSource: Symbol('EmployeeRemoteDataSource'),
  GetEmployeeUseCase: Symbol('GetEmployeeUseCase'),
  UpdateEmployeeUseCase: Symbol('UpdateEmployeeUseCase'),
} as const;
```

```typescript
// di/container.ts
import 'reflect-metadata';
import { container } from 'tsyringe';
import axios from 'axios';
import { TOKENS } from './tokens';
import { attachErrorInterceptor } from '@data/network/error.interceptor';

// 1. External deps
const httpClient = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL ?? 'https://api.example.com',
  timeout: 30_000,
});
attachErrorInterceptor(httpClient);
container.registerInstance(TOKENS.HttpClient, httpClient);

// 2. DataSources
container.register(TOKENS.EmployeeRemoteDataSource, { useClass: EmployeeRemoteDataSourceImpl });

// 3. Repositories
container.register(TOKENS.EmployeeRepository, { useClass: EmployeeRepositoryImpl });

// 4. Use Cases
container.register(TOKENS.GetEmployeeUseCase, { useClass: GetEmployeeUseCase });
container.register(TOKENS.UpdateEmployeeUseCase, { useClass: UpdateEmployeeUseCase });

export { container };
```

## Registration Order

### Theory

Dependencies must be registered before they are resolved. The correct registration order mirrors the dependency graph:

```
Infrastructure (HTTP client)
  → DataSources
  → Repository Implementations
  → Use Cases
```

---

| Layer | Lifetime | Why |
|---|---|---|
| External deps (HTTP client) | `registerInstance` | No app dependencies |
| DataSources | `register` / transient | Depend on HTTP client |
| Repositories | `register` / transient | Depend on DataSource |
| Use Cases | `register` / transient | Depend on Repository |

**Never register client-side state (Zustand store) in the container** — stores manage their own singleton lifecycle.

# Navigation

## App Router

### Theory

**Route Constants** are named, centralized identifiers for every navigation destination.

**Invariants:**
- All destination path strings defined in a single constants file — never hard-coded at the call site
- Parameterised routes expose a typed builder function — callers never construct path strings inline
- Route constants exported from the feature or navigation module

---

### Code Pattern

```typescript
// src/shared/core/navigation/routes.ts
export const Routes = {
  employees: '/employees',
  employeeDetail: (id: string) => `/employees/${id}`,
  employeeEdit: (id: string) => `/employees/${id}/edit`,
  login: '/login',
} as const;
```

```typescript
// Usage in a Client Component
import { useRouter } from 'next/navigation';
import { Routes } from '@shared/navigation/routes';

const router = useRouter();
router.push(Routes.employeeDetail(employee.id));
```

## Navigate From State

### Theory

State holders (hooks/stores) never call `useRouter` directly. They emit a navigation signal that the component layer consumes and resolves to a real route.

**Invariants:**
- Navigation intent expressed as a state value — `navAction?: EmployeeNavAction`
- Cleared after consumption — reset so it is not re-triggered on re-render
- Carries only data needed to resolve the destination (IDs, flags)

---

### Code Pattern

```typescript
// In Zustand store
interface EmployeeListState {
  navAction?: { kind: 'goToDetail'; id: string } | { kind: 'popAfterDelete' };
  setNavAction: (action: EmployeeListState['navAction']) => void;
}

// In component — consume and clear
const { navAction, setNavAction } = useEmployeeListStore();
const router = useRouter();

useEffect(() => {
  if (!navAction) return;
  if (navAction.kind === 'goToDetail') router.push(Routes.employeeDetail(navAction.id));
  if (navAction.kind === 'popAfterDelete') router.back();
  setNavAction(undefined);
}, [navAction]);
```

# Error Handling

## Error Boundaries

### Theory

Errors travel inward-to-outward, mapped at each layer boundary:

```
DataSource throws AppException
    ↓ caught and mapped by
Repository Implementation → Failure (Result.err)
    ↓ returned to
UseCase → propagates Result.err unchanged
    ↓ received by
Hook (TanStack Query / Zustand) → maps to UI error state
    ↓ observed by
Component → renders error UI or throws to Next.js error.tsx boundary
```

---

**Two patterns:**

| Error type | Handler |
|---|---|
| Blocking / full-page error | `throw` inside a Server Component → caught by `error.tsx` |
| Non-blocking / inline error | `result.isErr()` check → inline error message or toast |

### Code Pattern

```typescript
// app/employees/[id]/error.tsx
'use client';
import type { Failure } from '@domain/errors/failure';

export default function EmployeeError({ error }: { error: Failure }) {
  return (
    <div>
      <h2>Something went wrong</h2>
      <p>{error.message}</p>
    </div>
  );
}
```

```typescript
// Inline error in a Client Component
const { data, error, isError } = useEmployee(id);

if (isError) {
  return <ErrorView failure={error} onRetry={refetch} />;
}
```

## Validation Errors

### Theory

API validation errors (HTTP 422) carry structured field errors keyed by field name. Handled as `Failure.validation` — never encoded in the generic `message` string.

---

### Code Pattern

```typescript
// In a form mutation handler
const { mutate, error } = useUpdateEmployee();

const handleSubmit = (values: FormValues) => {
  mutate(values, {
    onError: (failure) => {
      if (failure.kind === 'validation' && failure.errors) {
        // Set field errors in react-hook-form
        Object.entries(failure.errors).forEach(([field, messages]) => {
          form.setError(field as keyof FormValues, { message: messages[0] });
        });
      } else {
        toast.error(failure.message);
      }
    },
  });
};
```

# Testing

## Mock Pattern

### Theory

Declare all mocks for a feature in one file using `vitest.fn()` or `jest.fn()`. Never mock mappers — they are pure functions, instantiate directly.

---

### Code Pattern

```typescript
// test/helpers/mocks/employee.mocks.ts
import { vi } from 'vitest';
import type { EmployeeRepository } from '@domain/repositories/employee.repository';

export const mockEmployeeRepository: EmployeeRepository = {
  getEmployee: vi.fn(),
  getEmployees: vi.fn(),
  updateEmployee: vi.fn(),
  deleteEmployee: vi.fn(),
};

// test/helpers/fixtures/employee.fixtures.ts
import type { EmployeeEntity } from '@domain/entities/employee.entity';
import type { EmployeeDto } from '@data/models/employee.dto';
import { Failure } from '@domain/errors/failure';

export const tEmployeeDto: EmployeeDto = {
  employee_id: '1', full_name: 'Alice', email: 'alice@example.com', join_date: null, department_id: null,
};

export const tEmployeeEntity: EmployeeEntity = {
  id: '1', name: 'Alice', email: 'alice@example.com',
};

export const tServerFailure = Failure.server({ message: 'Server error', developerMessage: 'HTTP 500' });
```

## Naming Convention

### Theory

`[unit under test]_[scenario]_[expected outcome]`

Examples:
- `getEmployeeUseCase_whenRepositoryReturnsEmployee_returnsEmployee`
- `employeeMapper_whenDtoHasNullDepartment_mapsToUndefined`
- `useEmployee_whenFetchFails_returnsErrorState`

---

### Code Pattern

```
// Plain test naming (returns X when Y)
'returns entity when repository succeeds'
'returns failure when repository fails'
'maps all fields correctly'
'handles null fields with defaults'
```

```
test/
  features/
    employee/
      data/
        mappers/employee.mapper.test.ts
        repositories/employee.repository.impl.test.ts
      domain/
        usecases/get-employee.usecase.test.ts
      presentation/
        hooks/use-employee.test.ts
  helpers/
    mocks/employee.mocks.ts
    fixtures/employee.fixtures.ts
```

## Repository Test

### Theory

Repository implementation tests verify the bridge between DataSource and Domain:
- Mock the DataSource — not a real network
- Assert the repository maps DataSource output to the correct domain entity
- Assert DataSource errors are caught and mapped to the correct Failure type

---

### Code Pattern

```typescript
describe('EmployeeRepositoryImpl', () => {
  let mockDataSource: EmployeeRemoteDataSource;
  let repository: EmployeeRepositoryImpl;

  beforeEach(() => {
    mockDataSource = { getEmployee: vi.fn(), getEmployees: vi.fn(), updateEmployee: vi.fn(), deleteEmployee: vi.fn() };
    repository = new EmployeeRepositoryImpl(mockDataSource);
  });

  describe('getEmployee', () => {
    it('returns entity when datasource succeeds', async () => {
      vi.mocked(mockDataSource.getEmployee).mockResolvedValue(tEmployeeDto);
      const result = await repository.getEmployee('1');
      expect(result.isOk()).toBe(true);
      expect(result._unsafeUnwrap()).toEqual(tEmployeeEntity);
    });

    it('returns server failure when datasource throws AppException', async () => {
      vi.mocked(mockDataSource.getEmployee).mockRejectedValue(AppException.server('Not found', 404));
      const result = await repository.getEmployee('1');
      expect(result.isErr()).toBe(true);
      expect(result._unsafeUnwrapErr().kind).toBe('server');
    });

    it('returns unknown failure for unexpected errors', async () => {
      vi.mocked(mockDataSource.getEmployee).mockRejectedValue(new Error('Crash'));
      const result = await repository.getEmployee('1');
      expect(result.isErr()).toBe(true);
    });
  });
});
```

## Use Case Test

### Code Pattern

```typescript
describe('GetEmployeeUseCase', () => {
  let mockRepository: EmployeeRepository;
  let useCase: GetEmployeeUseCase;

  beforeEach(() => {
    mockRepository = { ...mockEmployeeRepository };
    useCase = new GetEmployeeUseCase(mockRepository);
  });

  it('returns entity when repository succeeds', async () => {
    vi.mocked(mockRepository.getEmployee).mockResolvedValue(ok(tEmployeeEntity));
    const result = await useCase.execute('1');
    expect(result.isOk()).toBe(true);
    expect(mockRepository.getEmployee).toHaveBeenCalledWith('1');
  });

  it('returns failure when repository fails', async () => {
    vi.mocked(mockRepository.getEmployee).mockResolvedValue(err(tServerFailure));
    const result = await useCase.execute('1');
    expect(result.isErr()).toBe(true);
  });
});
```

## Test Pyramid

### Theory

```
         ┌──────────────────┐
         │   E2E Tests      │  few — critical user journeys only (Playwright)
         └────────┬─────────┘
         ┌────────┴─────────┐
         │ Integration Tests│  moderate — repository + datasource wiring
         └────────┬─────────┘
         ┌────────┴─────────┐
         │   Unit Tests     │  many — use cases, mappers, domain services
         └──────────────────┘
```

| Layer | Test targets | What to assert |
|---|---|---|
| Domain | Use cases, domain services | Business rules, edge cases, error conditions |
| Data | Mappers, repository implementations | DTO → entity mapping correctness; error mapping |
| Presentation | Hooks (custom render + mock server) | State transitions; correct use case calls |
| UI | Page/Component rendering (React Testing Library) | Correct state → UI binding; event dispatch |

# Utilities

## Date Service

### Theory

Centralized abstraction for all date operations — formatting, parsing, comparison.

**Invariants:**
- All date formatting/parsing goes through `DateService` — never inline format strings at call sites
- The interface is injectable for testing — implementations can return fixed dates in tests

---

### Code Pattern

```typescript
// core/date/date.service.ts
export type DateFormatStyle = 'iso8601' | 'apiDate' | 'apiDateTime' | 'displayDate' | 'displayDateTime' | 'displayTime' | 'relative';

export interface DateService {
  now(): Date;
  format(date: Date, style: DateFormatStyle, locale?: string): string;
  parse(value: string, style: DateFormatStyle): Date | null;
  startOfDay(date: Date): Date;
  endOfDay(date: Date): Date;
  addDays(date: Date, days: number): Date;
  daysBetween(start: Date, end: Date): number;
  isSameDay(a: Date, b: Date): boolean;
  isToday(date: Date): boolean;
  isPast(date: Date): boolean;
}
```

## Logger

### Theory

Centralized logging abstraction with severity levels. All log output goes through this interface.

**Invariants:**
- Severity levels: `debug`, `info`, `warning`, `error` — debug stripped in production
- No `console.log` calls at call sites — always use the Logger interface
- Sensitive data (tokens, PII) must never appear in log output

---

### Code Pattern

```typescript
// core/logger/logger.ts
export interface AppLogger {
  debug(message: string, context?: Record<string, unknown>): void;
  info(message: string, context?: Record<string, unknown>): void;
  warning(message: string, context?: Record<string, unknown>): void;
  error(message: string, error?: unknown, context?: Record<string, unknown>): void;
}

// core/logger/console.logger.ts
export class ConsoleLogger implements AppLogger {
  private readonly isProduction = process.env.NODE_ENV === 'production';

  debug(message: string, context?: Record<string, unknown>): void {
    if (!this.isProduction) console.debug('[DEBUG]', message, context ?? '');
  }

  info(message: string, context?: Record<string, unknown>): void {
    console.info('[INFO]', message, context ?? '');
  }

  warning(message: string, context?: Record<string, unknown>): void {
    console.warn('[WARN]', message, context ?? '');
  }

  error(message: string, error?: unknown, context?: Record<string, unknown>): void {
    console.error('[ERROR]', message, error ?? '', context ?? '');
  }
}
```

## Storage Service

### Theory

Interface-based key-value store for persisting tokens, preferences, and session data.

**Invariants:**
- All keys are typed constants (enum or const object) — never raw strings at call sites
- Sensitive data (tokens) uses `httpOnly` cookies via a server-side session route — never `localStorage`
- `clearAll()` called only on logout

---

### Code Pattern

```typescript
// core/storage/storage.service.ts
export const StorageKey = {
  userId: 'userId',
  lastSelectedTab: 'lastSelectedTab',
  onboardingCompleted: 'onboardingCompleted',
} as const;

export type StorageKey = typeof StorageKey[keyof typeof StorageKey];

export interface StorageService {
  set<T>(key: StorageKey, value: T): void;
  get<T>(key: StorageKey): T | null;
  remove(key: StorageKey): void;
  clearAll(): void;
}

// core/storage/local-storage.service.ts
export class LocalStorageService implements StorageService {
  set<T>(key: StorageKey, value: T): void {
    localStorage.setItem(key, JSON.stringify(value));
  }

  get<T>(key: StorageKey): T | null {
    const raw = localStorage.getItem(key);
    if (raw === null) return null;
    try { return JSON.parse(raw) as T; } catch { return null; }
  }

  remove(key: StorageKey): void {
    localStorage.removeItem(key);
  }

  clearAll(): void {
    Object.values(StorageKey).forEach(k => localStorage.removeItem(k));
  }
}
```
