---
platform: web
project: web
discipline: engineering
topic: dependency_injection
pattern: registration_order
---

## Theory

Dependencies must be registered before they are resolved. The correct registration order mirrors the dependency graph:

```
Infrastructure (HTTP client, DB driver)
  → DataSources
  → Mappers
  → Repository Implementations
  → Use Cases
  → StateHolders
```

Register leaf nodes (no dependencies) first. Register consumers after their dependencies.

---

## Registration Order

Instantiate in leaf-first order — infrastructure before consumers. Node.js module caching enforces this naturally for the server container:

```typescript
// container.server.ts — registration order
// 1. Infrastructure
const tokenStorage = new ServerTokenStorage();
const unauthClient = createUnauthenticatedHTTPClient(process.env.API_BASE_URL!);
const tokenRefresher = new TokenRefreshService(unauthClient, tokenStorage);
const httpClient = createHTTPClient(process.env.API_BASE_URL!, tokenStorage, tokenRefresher);

// 2. DataSources (depend on httpClient)
const employeeRemoteDS = new EmployeeRemoteDataSourceImpl(httpClient);

// 3. Repositories (depend on DataSource + Mapper)
const employeeRepository = new EmployeeRepositoryImpl(employeeRemoteDS);

// 4. Use Cases (factories — stateless, cheap; depend on Repository)
export const getEmployeesUseCase = () => new GetEmployeesUseCaseImpl(employeeRepository);
```

For the client container, the same order applies inside `createClientContainer()`.

## Scope Rules

| Scope | Web pattern | Use for |
|---|---|---|
| Singleton (server) | Module-level `const` in `container.server.ts` | HTTP client, token storage, repositories — one per server process |
| Singleton (client) | Module-level inside `createClientContainer()` | Repositories — one per `DIProvider` mount |
| Factory | `get` accessor or inline `new` in ViewModel hook | Use Cases — stateless, cheap |
| Transient | Default parameter: `constructor(dep = new Dep())` | Pure domain services — overridable in tests |

**Never store mutable UI state in a container-level singleton.** ViewModel hooks manage their own state via `useState`/`useReducer` — the container only holds pure, stateless dependencies.

## Testing with DI

ViewModel hooks receive dependencies as arguments — substitute mocks directly without touching the container:

```typescript
// Unit test — no DIProvider needed
const mockGetEmployeesUseCase = { execute: vi.fn() };
const mockDeleteEmployeeUseCase = { execute: vi.fn() };

const { result } = renderHook(
  () => useEmployeeListViewModel({
    getEmployeesUseCase: mockGetEmployeesUseCase,
    deleteEmployeeUseCase: mockDeleteEmployeeUseCase,
  }),
  { wrapper: createQueryClientWrapper() }
);
```

For server-side functions, override default-parameter services inline:

```typescript
// Override a domain service with a stub
const result = leaveRequestService.validate(entitlement, 3, date, MockValidatorService());
```

Never instantiate `container.server.ts` or `container.client.ts` in unit tests — test collaborators in isolation.
