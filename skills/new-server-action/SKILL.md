---
name: new-server-action
description: Scaffold a validated Server Action using next-safe-action. Use when adding a mutation (create, update, delete, form submit) in a full-stack Next.js project.
disable-model-invocation: true
allowed-tools: Read, Write, Glob
---

Scaffold a Server Action for this full-stack Next.js Clean Architecture project.

First, ask me:
1. Feature name (e.g. `leave-request`, `employee`)
2. Action verb + noun (e.g. `submitLeaveRequest`, `deleteEmployee`, `updateProfile`)
3. Input fields — for each: name, TypeScript type, validation rule (e.g. `required`, `min 1`, `uuid`, `date`)
4. Does this action require authentication? (yes / no — almost always yes)
5. Which use case does this action call? (e.g. `SubmitLeaveRequestUseCase`)

Then:

**Step 1 — Check if `lib/safe-action.ts` exists**

```
Read: src/lib/safe-action.ts
```

If missing, generate it first:

```typescript
// src/lib/safe-action.ts
import { createSafeActionClient } from 'next-safe-action';
import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';
import { DomainError } from '@/domain/errors/DomainError';

export const actionClient = createSafeActionClient({
  handleServerError(error) {
    if (error instanceof DomainError) return error.message;
    return 'An unexpected error occurred.';
  },
});

export const authActionClient = actionClient.use(async ({ next }) => {
  const session = await getServerSession(authOptions);
  if (!session?.user) throw new Error('Unauthorized');
  return next({ ctx: { session } });
});
```

**Step 2 — Read the use case file**

```
Read: src/domain/use-cases/[feature]/[Verb][Feature]UseCase.ts
```

Match the exact `execute()` params shape and return type.

**Step 3 — Generate the action file**

Output file: `src/presentation/features/[feature-name]/actions/[verb][Feature]Action.ts`

```typescript
'use server';

import { z } from 'zod';
import { authActionClient } from '@/lib/safe-action'; // or actionClient if public
import { [verb][Feature]UseCase } from '@/di/container.server';

const schema = z.object({
  // map each input field to its Zod validator:
  [field]: z.[type]([validationRule]),
});

export const [verb][Feature]Action = authActionClient
  .schema(schema)
  .action(async ({ parsedInput, ctx }) => {
    return [verb][Feature]UseCase().execute({
      payload: parsedInput,
      employeeId: ctx.session.user.id, // remove if action is public
    });
  });
```

**Step 4 — Generate the client-side hook usage**

Show how to consume the action in the View component:

```typescript
'use client';
import { useAction } from 'next-safe-action/hooks';
import { [verb][Feature]Action } from './actions/[verb][Feature]Action';

const { execute, result, isPending } = useAction([verb][Feature]Action, {
  onSuccess: ({ data }) => { /* handle success, e.g. router.push or toast */ },
  onError: ({ error }) => { /* error.serverError or error.validationErrors */ },
});
```

**Step 5 — Remind: wire use case in container if not already done**

Check `src/di/container.server.ts` — if `[verb][Feature]UseCase` is not exported, remind me to run `/wire-di` first.

**Step 6 — Remind: add cache revalidation if this action mutates data**

```typescript
// Inside .action(), after the use case call:
import { revalidatePath } from 'next/cache';
revalidatePath('/[affected-route]');
```
