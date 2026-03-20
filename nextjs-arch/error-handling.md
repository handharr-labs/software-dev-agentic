## 8. Error Handling

### 8.1 Error Flow

```
DataSource throws NetworkError
    ↓ caught by
Repository maps to DomainError
    ↓ propagated via
UseCase (passes through or enriches)
    ↓ caught by
ViewModel hook → TanStack Query error state
    ↓ rendered by
Component shows error UI
```

### 8.2 Error Types

```typescript
// data/networking/NetworkError.ts (already defined above)

// domain/errors/DomainError.ts (already defined above)

// For React boundaries — wrap pages
// app/employees/error.tsx
'use client';

export default function EmployeesError({
  error,
  reset,
}: {
  error: Error;
  reset: () => void;
}) {
  return (
    <div className="flex flex-col items-center gap-4 p-8">
      <p className="text-error">{error.message}</p>
      <button onClick={reset} className="btn btn-primary">
        Try again
      </button>
    </div>
  );
}
```

### 8.3 Error Mapping

`ErrorMapperImpl` follows the same interface-based pattern as other mappers (see Section 4.2). Repositories inject `ErrorMapper` to convert `NetworkError` → `DomainError`:

```typescript
// Usage in repository — pattern is already shown in Section 4.4
// The key principle: DataSource throws NetworkError, Repository catches and maps to DomainError

// Displaying errors in components — use TanStack Query's error state
const { error } = useQuery({ ... });
const message = error instanceof DomainError
  ? humanizeError(error.code)
  : 'Something went wrong';

// domain/errors/errorMessages.ts
export function humanizeError(code: DomainErrorCode): string {
  const messages: Record<DomainErrorCode, string> = {
    notFound: 'The requested resource was not found.',
    validationFailed: 'Please check your input and try again.',
    unauthorized: 'You are not authorized to perform this action.',
    networkUnavailable: 'No internet connection. Please check your network.',
    serverError: 'Something went wrong on our end. Please try again.',
    unknown: 'An unexpected error occurred.',
  };
  return messages[code];
}
```

---

