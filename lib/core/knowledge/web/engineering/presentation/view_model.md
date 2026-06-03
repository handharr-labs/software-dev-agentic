---
platform: web
project: web
discipline: engineering
topic: presentation
pattern: view_model
---

## Theory

A **StateHolder** is the single source of truth for a screen's UI state. Platform names vary (ViewModel, BLoC, Presenter) but the contract is identical across platforms.

**Invariants:**
- Owns no view imports — no UI framework, no widget, no component type
- Depends on use case interfaces only — never calls repositories or data sources directly
- Use cases are injected via DI — never instantiated directly inside the StateHolder
- Exposes state as a read-only stream or observable — UI observes, never mutates
- One StateHolder per screen — never shared across screens unless explicitly scoped

**When to create:** One StateHolder per screen. Created before the screen that observes it.

---

## StateHolder

In Web, the StateHolder is implemented as a **ViewModel Hook** (`use*ViewModel`) for client components, or a **pure `build*ViewModel` function** for Server Components.

Invariants:
- Receives use cases via a `deps` parameter or `useDI()` — never imports a concrete repository or API client
- Exposes state as hook return values — components destructure and render, never mutate
- Handles navigation via `useRouter()` inside the hook — component receives handler functions, not router instances
- One ViewModel hook per screen/view — not shared across sibling pages

---

### State

In Web, **State** is the return value of the ViewModel hook — a plain object with typed fields. TanStack Query's `isLoading`/`isError`/`data` pattern maps to `loading → error → data`.

Invariants:
- Immutable from the component's perspective — component receives values, never calls `setState` directly
- Covers all render cases: `isLoading`, `isError`, `errorMessage`, `data` fields
- No JSX types — no `ReactNode`, `JSX.Element` in ViewModel return types

---

### Events / Input

In Web, Events/Input are **handler functions** returned by the ViewModel hook (e.g. `handleEmployeeClick`, `handleSearchChange`). Components wire them to `onClick`/`onChange` props.

Invariants:
- Named after user actions with `handle` prefix — `handleSubmit`, `handleSearchChange`, not `setQuery`
- Carry only the data needed — no raw `SyntheticEvent` or DOM element references
- Side effects (navigation, mutation) execute inside the handler — component never calls router directly

---

### Actions / Output

In Web, Actions/Output are callbacks and router navigations executed inside handler functions. There is no separate action stream — navigation is triggered directly inside the hook's handler.

Invariants:
- One-shot — `router.push(...)` or `onSuccess` callback fires once per interaction
- Named after the outcome — `handleNavigateToDetail`, `handleDeleteSuccess`
- Navigation targets are defined in `ROUTES` constants — hooks reference routes by key, not raw strings

---

### State Management

A unified state type for all view states:

```typescript
// presentation/common/QueryState.ts
export type QueryState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'loaded'; data: T }
  | { status: 'error'; message: string };

export function isIdle<T>(state: QueryState<T>): state is { status: 'idle' } {
  return state.status === 'idle';
}

export function isLoading<T>(state: QueryState<T>): state is { status: 'loading' } {
  return state.status === 'loading';
}

export function isLoaded<T>(state: QueryState<T>): state is { status: 'loaded'; data: T } {
  return state.status === 'loaded';
}

export function isError<T>(state: QueryState<T>): state is { status: 'error'; message: string } {
  return state.status === 'error';
}

export function getDataOrNull<T>(state: QueryState<T>): T | null {
  return isLoaded(state) ? state.data : null;
}
```

### ViewModel Hook

```typescript
// presentation/features/employee-list/useEmployeeListViewModel.ts
'use client';

import { useRouter } from 'next/navigation';
import { useState, useCallback } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Employee } from '@/domain/entities/Employee';
import { GetEmployeesUseCase } from '@/domain/use-cases/employee/GetEmployeesUseCase';
import { DeleteEmployeeUseCase } from '@/domain/use-cases/employee/DeleteEmployeeUseCase';
import { ROUTES } from '@/presentation/navigation/routes';

interface EmployeeListViewModelDeps {
  getEmployeesUseCase: GetEmployeesUseCase;
  deleteEmployeeUseCase: DeleteEmployeeUseCase;
}

export function useEmployeeListViewModel({
  getEmployeesUseCase,
  deleteEmployeeUseCase,
}: EmployeeListViewModelDeps) {
  const router = useRouter();
  const queryClient = useQueryClient();
  const [searchQuery, setSearchQuery] = useState('');
  const [currentPage, setCurrentPage] = useState(1);

  // Data fetching — TanStack Query handles loading/error/data states
  const { data, isLoading, isError, error, refetch } = useQuery({
    queryKey: ['employees', currentPage, searchQuery],
    queryFn: () =>
      getEmployeesUseCase.execute({ page: currentPage, limit: 20, searchQuery }),
  });

  // Mutation — TanStack Query handles optimistic updates
  const deleteMutation = useMutation({
    mutationFn: (employee: Employee) =>
      deleteEmployeeUseCase.execute({ employeeId: employee.id }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['employees'] });
    },
  });

  // Navigation
  const handleEmployeeClick = useCallback(
    (employee: Employee) => {
      router.push(ROUTES.employeeDetail(employee.id));
    },
    [router]
  );

  const handleDeleteEmployee = useCallback(
    (employee: Employee) => {
      deleteMutation.mutate(employee);
    },
    [deleteMutation]
  );

  const handleSearchChange = useCallback((query: string) => {
    setSearchQuery(query);
    setCurrentPage(1);
  }, []);

  const handleRefresh = useCallback(() => {
    refetch();
  }, [refetch]);

  return {
    // State
    employees: data?.items ?? [],
    totalPages: data?.totalPages ?? 0,
    currentPage,
    searchQuery,
    isLoading,
    isError,
    errorMessage: error?.message ?? null,
    isDeleting: deleteMutation.isPending,

    // Actions
    handleEmployeeClick,
    handleDeleteEmployee,
    handleSearchChange,
    handleRefresh,
    handlePageChange: setCurrentPage,
  };
}
```

### ViewModel Hook with Service Integration

```typescript
// presentation/features/leave-request/useLeaveRequestViewModel.ts
'use client';

export function useLeaveRequestViewModel({
  getEntitlementUseCase,
  submitLeaveUseCase,
  validator = new LeaveRequestValidatorService(), // default injection
}: LeaveRequestViewModelDeps) {
  const [requestedDays, setRequestedDays] = useState(0);

  const { data: entitlement } = useQuery({
    queryKey: ['leaveEntitlement'],
    queryFn: () => getEntitlementUseCase.execute({}),
  });

  // Hook is a thin orchestrator — validation is delegated to Domain Service
  const validationResult = entitlement
    ? validator.validate(entitlement, requestedDays, new Date())
    : 'valid';

  const submitMutation = useMutation({
    mutationFn: (payload: SubmitLeaveRequestPayload) => {
      if (!entitlement) throw new Error('No entitlement loaded');
      return submitLeaveUseCase.execute({ entitlement, payload });
    },
  });

  const handleDaysChange = useCallback((days: number) => {
    setRequestedDays(days);
  }, []);

  return {
    entitlement,
    validationResult,
    requestedDays,
    isSubmitting: submitMutation.isPending,
    submitError: submitMutation.error?.message ?? null,
    handleDaysChange,
    handleSubmit: submitMutation.mutate,
  };
}
```

### Server-Side ViewModel (Pure Function)

When a page is a **Server Component** (`async page.tsx`), data is fetched server-side and there are no React hooks. The ViewModel is a **pure function** instead of a hook.

**Naming:** `build[Feature]ViewModel` — the `build*` prefix signals "not a hook, not stateful"
**Location:** `src/presentation/features/[feature]/build[Feature]ViewModel.ts`

```typescript
// presentation/features/career-page/buildCareerPageViewModel.ts
import type { Company } from '@/domain/entities/Company';
import type { Job } from '@/domain/entities/Job';

export interface CareerPageViewModelInput {
  company: Company;
  jobs: Job[];
}

export interface CareerPageViewModel {
  company: Company;
  jobs: Job[];
  isHiring: boolean;
  featuredJobs: Job[];
}

export function buildCareerPageViewModel(input: CareerPageViewModelInput): CareerPageViewModel {
  return {
    company: input.company,
    jobs: input.jobs,
    isHiring: input.company.siteStatus === 'active',
    featuredJobs: input.jobs.filter((j) => j.isFeatured),
  };
}
```

**Pattern selection guide:**

| Scenario | Pattern |
|----------|---------|
| Server Component, read-only | `build*ViewModel` pure function |
| Client Component, live data / caching | `use*ViewModel` hook + TanStack Query |
| Client Component, mutations (full-stack) | `use*ViewModel` hook + Server Actions |
| RSC page + client interactivity | `build*ViewModel` → pass as `initialData` to `use*ViewModel` hook |

### Layer Invariants

- ViewModel hook never imports from the data layer — no `RepositoryImpl`, no `ApiClient`, no `fetch` calls
- Use cases injected via deps parameter or `useDI()` — never `new GetEmployeesUseCase()` inside a hook
- State is read-only from the component's perspective — components destructure hook return values, never mutate
- Navigation is one-shot — `router.push` inside a handler, never stored as state
- Route paths are abstract — defined in `ROUTES` constants; hooks reference keys, not raw string paths

### Creation Order

```
Use Cases → ViewModel Hook (StateHolder) → StateHolder contract → View Component (developer-ui-worker)
```

Never write the View component before the StateHolder contract exists.
