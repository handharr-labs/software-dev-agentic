---
platform: web
project: web
discipline: engineering
topic: presentation
pattern: screen_structure
---

## Theory

A **Screen** is a full-page view bound to a single StateHolder. It observes state and sends events — it contains no business logic.

**Invariants:**
- Bound to exactly one StateHolder — instantiated via DI, never with direct `new` / `init`
- Observes every State field declared in the StateHolder contract — no State field goes unhandled
- Sends events to the StateHolder for every user interaction — never mutates state directly
- Contains no business logic — conditionals exist only to decide what to render, not what to compute
- No use case calls — all data flows through the StateHolder

**When to create:** One screen per route/destination. Created after the StateHolder contract exists.

---

## Screen Structure

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
