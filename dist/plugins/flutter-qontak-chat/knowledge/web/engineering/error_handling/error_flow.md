---
platform: web
project: web
discipline: engineering
topic: error_handling
pattern: error_flow
---

## Theory

Errors travel inward-to-outward, mapped at each layer boundary:

```
DataSource throws transport error (NetworkError, HTTP 4xx/5xx, DB exception)
    ↓ caught and mapped by
Repository Implementation → DomainError
    ↓ returned to
Use Case → propagates DomainError unchanged
    ↓ received by
StateHolder → maps to UI error State
    ↓ observed by
Screen → renders error UI
```

**Rule:** Each layer catches the error type from the layer below it and converts it to the type its consumers expect. No raw transport errors escape the Data layer. No domain errors escape the Presentation layer uncaught.

---

## Error Flow

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

## Error Mapping

`ErrorMapperImpl` follows the same interface-based pattern as other mappers. Repositories inject `ErrorMapper` to convert `NetworkError` → `DomainError`:

```typescript
// Usage in repository — pattern is already shown in Repository Implementation
// The key principle: DataSource throws NetworkError, Repository catches and maps to DomainError

// Displaying errors in components — use TanStack Query's error state
const { error } = useQuery({ ... });
const message = error instanceof DomainError
  ? humanizeError(error.code)
  : 'Something went wrong';

// presentation/common/utils/errorMessages.ts
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
// Note: humanizeError lives in the presentation layer — user-facing message
// strings are a display concern, not a domain concept.
```

## Error UI

React error boundaries catch rendering errors; TanStack Query's error state surfaces data-fetch errors.

```typescript
// app/employees/error.tsx — Next.js error boundary (per route segment)
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
      <button onClick={reset} className="btn btn-primary">Try again</button>
    </div>
  );
}

// In components — TanStack Query error state (non-blocking)
const { error } = useQuery({ ... });
if (error) return <ErrorView message={humanizeError(error.code)} />;
```

**Rules:**
- Place `error.tsx` at the route segment level, not globally — scope errors to the affected section
- Never expose raw error codes or stack traces to users — use `humanizeError(code)`
- `humanizeError` lives in `presentation/common/utils/errorMessages.ts` (presentation layer, not domain)

## Layer Invariants

- DataSources throw `NetworkError` — they never return `null` or a partial response to signal failure
- Repository implementations always catch and map to `DomainError` — no `NetworkError` propagates to use cases
- Use cases propagate `DomainError` unchanged — they do not re-map errors
- ViewModel hooks (TanStack Query) handle all errors from use cases — no unhandled promise rejection reaches the component
- Components never inspect `DomainErrorCode` directly — they render the error UI via `humanizeError(code)`
