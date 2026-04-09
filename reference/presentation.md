## 5. Presentation Layer

### 5.1 QueryState

A unified state type for all view states — mirrors the `ViewState<T>` enum from the SwiftUI kit.

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

### 5.2 ViewModel Hook

The ViewModel pattern is implemented as a custom React hook. No class inheritance — just a hook that orchestrates use cases, manages state, and handles navigation.

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

### 5.3 ViewModel Hook with Service Integration

When a ViewModel hook needs business decisions, it delegates to a Domain Service:

```typescript
// presentation/features/leave-request/useLeaveRequestViewModel.ts
'use client';

import { useState, useCallback } from 'react';
import { useQuery, useMutation } from '@tanstack/react-query';
import { LeaveRequestValidator, LeaveRequestValidatorService } from '@/domain/services/LeaveRequestValidator';

interface LeaveRequestViewModelDeps {
  getEntitlementUseCase: GetLeaveEntitlementUseCase;
  submitLeaveUseCase: SubmitLeaveRequestUseCase;
  validator?: LeaveRequestValidator; // Domain Service (interface)
}

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

### 5.4 React Component (View)

Components are dumb renderers. They receive state and callbacks from the ViewModel hook and render UI.

```typescript
// presentation/features/employee-list/EmployeeListView.tsx
'use client';

import { useEmployeeListViewModel } from './useEmployeeListViewModel';
import { useDI } from '@/di/DIContext';
import { EmployeeRow } from './components/EmployeeRow';
import { LoadingView } from '@/presentation/common/LoadingView';
import { ErrorView } from '@/presentation/common/ErrorView';
import { PaginatedResult } from '@/domain/entities/PaginatedResult';
import { Employee } from '@/domain/entities/Employee';

interface Props {
  // Optional: pre-fetched by the Server Component page — seeds TanStack Query cache
  initialData?: PaginatedResult<Employee>;
}

export function EmployeeListView({ initialData }: Props) {
  const { getEmployeesUseCase, deleteEmployeeUseCase } = useDI();

  const {
    employees,
    isLoading,
    isError,
    errorMessage,
    searchQuery,
    handleEmployeeClick,
    handleDeleteEmployee,
    handleSearchChange,
    handleRefresh,
  } = useEmployeeListViewModel({ getEmployeesUseCase, deleteEmployeeUseCase, initialData });

  if (isLoading) return <LoadingView />;
  if (isError) return <ErrorView message={errorMessage ?? 'Something went wrong'} onRetry={handleRefresh} />;

  return (
    <div className="flex flex-col gap-4">
      <input
        type="search"
        value={searchQuery}
        onChange={(e) => handleSearchChange(e.target.value)}
        placeholder="Search employees..."
        className="input input-bordered w-full"
      />
      <ul className="divide-y divide-base-200">
        {employees.map((employee) => (
          <EmployeeRow
            key={employee.id}
            employee={employee}
            onClick={() => handleEmployeeClick(employee)}
            onDelete={() => handleDeleteEmployee(employee)}
          />
        ))}
      </ul>
    </div>
  );
}
```

---

### 5.5 Atomic Design within the Presentation Layer

Clean Architecture owns the **vertical** slice (domain → data → presentation).
Atomic Design owns the **horizontal** slice (how components are structured *within* presentation).

| Atomic Level | Location | Description | Example |
|---|---|---|---|
| Atoms | `shared/presentation/common/atoms/` | Indivisible elements. No business logic, primitive props only | `ErrorBanner`, `ProgressBar`, `Badge` |
| Molecules | `shared/presentation/common/molecules/` | Small groups of atoms forming a meaningful unit | `PageHeader`, `PageShell` |
| Organisms | `features/{name}/presentation/organisms/` | Complex, feature-aware sections. May accept domain entities as props | `TransactionListItem`, `CategoryItemEditor` |
| Views (Pages) | `features/{name}/presentation/` | Connects ViewModel hook to organisms. No direct API calls | `TransactionsView`, `DashboardView` |

**Rules:**
1. Atoms and molecules accept only primitive props (`string`, `number`, `boolean`, `ReactNode`). No domain entities, no use case hooks.
2. Organisms may accept domain entities as props — they render, but do not fetch.
3. Only Views call `useDI()` and ViewModel hooks — they pass data down to organisms.
4. Shared atoms/molecules live in `src/shared/presentation/common/`. Feature-specific organisms live inside their own feature slice.
5. A component that is used in ≥2 features must be promoted to `shared/presentation/common/`.

### 5.6 View Data Transformer Pattern

Domain objects return structured, semantic data. The presentation layer is responsible for converting that data into display-ready values like CSS class strings, labels, and icons. **Never put Tailwind class strings or locale-formatted display strings inside domain services or use cases.**

**Pattern: status enum → display config map**

When a domain service communicates visual severity (progress state, health status), it returns a typed status string. The organism (or a shared presentation util if used in ≥2 places) defines a lookup map from that status to CSS classes.

```typescript
// domain/services/BudgetProgressService.ts — domain returns semantic status
export type BudgetStatus = 'on-track' | 'at-risk' | 'over';

export interface BudgetProgressData {
  readonly percent: number;
  readonly remaining: number;
  readonly isOverrun: boolean;
  readonly status: BudgetStatus;   // semantic, not visual
}
```

```typescript
// presentation/organisms/CategoryBreakdownSection.tsx — presentation maps to CSS
import type { BudgetStatus } from '@/features/dashboard/domain/services/BudgetProgressService';

const STATUS_COLOR: Record<BudgetStatus, string> = {
  'on-track': 'bg-emerald-400',
  'at-risk':  'bg-yellow-400',
  'over':     'bg-red-400',
};

const STATUS_TEXT: Record<BudgetStatus, string> = {
  'on-track': 'text-emerald-600 dark:text-emerald-300',
  'at-risk':  'text-yellow-600 dark:text-yellow-300',
  'over':     'text-red-600 dark:text-red-300',
};

// Usage in JSX:
<div className={STATUS_COLOR[progress.status]} />
<span className={STATUS_TEXT[progress.status]} />
```

**Placement rule:** If the same config map is needed in ≥2 organisms, extract it to `src/shared/presentation/common/utils/[feature]StatusConfig.ts`.

**Domain vs presentation boundary:**

| Concern | Layer | Example |
|---------|-------|---------|
| Severity classification | Domain | `status: 'over' \| 'at-risk' \| 'on-track'` |
| CSS class strings | Presentation | `'bg-red-400'`, `'text-red-600 dark:text-red-300'` |
| Locale-formatted numbers | Presentation | `'Rp 1.2jt'` via `formatCompactCurrency` |
| Raw numbers / booleans | Domain | `remaining: number`, `isOverrun: boolean` |
| User-facing message strings | Presentation | `'The requested resource was not found.'` |

---

