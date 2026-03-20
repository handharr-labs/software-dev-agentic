## 16. Server Actions (Full-Stack Mode)

Server Actions are the primary mechanism for **mutations** when Next.js is the backend. They run exclusively on the server, are called directly from Client Components, and eliminate the need for separate API routes for your own UI.

> **Frontend-only projects**: skip this section. Use the existing ViewModel → UseCase → RemoteDataSource pattern.

### 16.1 When to Use What

```
Read data (initial load)
  → Server Component imports directly from container.server.ts
  → No Server Action needed

Mutation (create / update / delete / form submit)
  → Server Action calls use case from container.server.ts
  → Client Component calls action via useAction() hook

External API / webhook / file upload
  → Route Handler (see api-routes.md)
  → Not a Server Action
```

### 16.2 Setup — `next-safe-action`

Install:
```bash
npm install next-safe-action zod
```

Create two action clients — one public, one that enforces authentication:

```typescript
// lib/safe-action.ts
import { createSafeActionClient } from 'next-safe-action';
import { getServerSession } from 'next-auth'; // or your auth provider
import { authOptions } from '@/lib/auth';
import { DomainError } from '@/domain/errors/DomainError';

// Public client — no auth required
export const actionClient = createSafeActionClient({
  handleServerError(error) {
    // Translate known errors to safe messages
    if (error instanceof DomainError) return error.message;
    // Never leak internal error details to the client
    return 'An unexpected error occurred.';
  },
});

// Authenticated client — throws if no valid session
export const authActionClient = actionClient.use(async ({ next }) => {
  const session = await getServerSession(authOptions);
  if (!session?.user) throw new Error('Unauthorized');
  // ctx.session is now typed and available inside every .action() using this client
  return next({ ctx: { session } });
});
```

**Rules:**
- Always use `authActionClient` by default — opt into `actionClient` only for truly public actions (e.g., contact form, newsletter)
- `handleServerError` is the single place that decides what error details reach the client
- Never expose raw error messages, stack traces, or database errors to the client

### 16.3 Action File Pattern

One file per mutation. Actions live alongside the feature they belong to:

```
src/presentation/features/[feature-name]/actions/
└── [verb][Feature]Action.ts     ← one file per mutation
```

```typescript
// presentation/features/leave-request/actions/submitLeaveRequestAction.ts
'use server';

import { z } from 'zod';
import { authActionClient } from '@/lib/safe-action';
import { submitLeaveRequestUseCase } from '@/di/container.server';

// Schema is the single source of truth for input validation
const schema = z.object({
  startDate: z.string().date(),
  endDate: z.string().date(),
  reason: z.string().min(1, 'Reason is required').max(500),
  leaveTypeId: z.string().uuid(),
});

export const submitLeaveRequestAction = authActionClient
  .schema(schema)
  .action(async ({ parsedInput, ctx }) => {
    // parsedInput is fully typed and validated — no manual checks needed
    // ctx.session is available because we use authActionClient
    return submitLeaveRequestUseCase().execute({
      payload: parsedInput,
      employeeId: ctx.session.user.id,
    });
  });
```

**Rules:**
- `'use server'` directive is mandatory at the top of every action file
- Schema validation is always done via `.schema(zodSchema)` — never validate manually inside `.action()`
- Call use cases from `container.server.ts` — never instantiate repositories or data sources directly
- The action returns the use case result directly; `next-safe-action` wraps it in `{ data }` automatically

### 16.4 Client-Side Consumption

```typescript
// presentation/features/leave-request/LeaveRequestView.tsx
'use client';

import { useAction } from 'next-safe-action/hooks';
import { submitLeaveRequestAction } from './actions/submitLeaveRequestAction';

export function LeaveRequestView() {
  const { execute, result, isPending } = useAction(submitLeaveRequestAction, {
    onSuccess: ({ data }) => {
      // data is typed — same as the use case return type
      console.log('Submitted:', data);
    },
    onError: ({ error }) => {
      // error.serverError — from handleServerError in safe-action.ts
      // error.validationErrors — from Zod schema failures
      console.error(error.serverError);
    },
  });

  function handleSubmit(formData: FormData) {
    execute({
      startDate: formData.get('startDate') as string,
      endDate: formData.get('endDate') as string,
      reason: formData.get('reason') as string,
      leaveTypeId: formData.get('leaveTypeId') as string,
    });
  }

  return (
    <form action={handleSubmit}>
      {result.serverError && <p className="text-error">{result.serverError}</p>}
      {/* form fields */}
      <button type="submit" disabled={isPending}>
        {isPending ? 'Submitting...' : 'Submit'}
      </button>
    </form>
  );
}
```

### 16.5 Optimistic Updates

For mutations where you want instant UI feedback:

```typescript
import { useOptimisticAction } from 'next-safe-action/hooks';

const { execute, optimisticState } = useOptimisticAction(
  deleteLeaveRequestAction,
  {
    currentState: { requests: leaveRequests },
    updateFn: (state, input) => ({
      requests: state.requests.filter((r) => r.id !== input.id),
    }),
  }
);
```

### 16.6 Data Flow — Full-Stack Mutation

```
Client Component
    ↓ useAction(submitLeaveRequestAction)
Server Action (next-safe-action)
    ↓ Zod validates parsedInput
    ↓ auth middleware checks session
    ↓ calls use case from container.server.ts
Use Case
    ↓ calls repository
Repository
    ↓ calls DbDataSource (full-stack) or RemoteDataSource (frontend-only)
    ↓ maps result to domain entity
    ↑ returns entity to use case
    ↑ returns entity to action → next-safe-action wraps in { data }
    ↑ result available in useAction({ onSuccess })
```

### 16.7 Cache Revalidation

After a successful mutation, revalidate the affected data:

```typescript
// Inside .action() after the use case call:
import { revalidatePath, revalidateTag } from 'next/cache';

.action(async ({ parsedInput, ctx }) => {
  const result = await submitLeaveRequestUseCase().execute({ ... });
  revalidatePath('/leave/history');   // re-renders the Server Component at this path
  // or:
  revalidateTag('leave-requests');    // invalidates all fetch() calls tagged 'leave-requests'
  return result;
});
```

### 16.8 Full-Stack Project Structure Addition

```
src/
├── lib/
│   ├── safe-action.ts              ← actionClient + authActionClient (new)
│   └── auth.ts                     ← auth config (NextAuth or equivalent)
├── presentation/features/
│   └── [feature]/
│       ├── actions/                ← new subfolder per feature
│       │   └── [verb][Feature]Action.ts
│       ├── use[Feature]ViewModel.ts
│       └── [Feature]View.tsx
```

### 16.9 Naming Conventions

| Artifact | Pattern | Example |
|----------|---------|---------|
| Action file | `[verb][Feature]Action.ts` | `submitLeaveRequestAction.ts` |
| Action export | `[verb][Feature]Action` | `submitLeaveRequestAction` |
| Action folder | `actions/` inside feature folder | `leave-request/actions/` |
| Schema | `[verb][Feature]Schema` (optional const) | `submitLeaveRequestSchema` |

---
