# Server Action Template

```typescript
// src/presentation/features/[feature]/actions/[verb][Feature]Action.ts
'use server';
import { z } from 'zod';
import { revalidatePath } from 'next/cache';
import { authActionClient } from '@/lib/safe-action';
import { [verb][Feature]UseCase } from '@/di/container.server';

export const [verb][Feature]Action = authActionClient
  .schema(z.object({
    // define input fields here
    [field]: z.[type](),
  }))
  .action(async ({ parsedInput, ctx }) => {
    const result = await [verb][Feature]UseCase().execute({
      payload: parsedInput,
      employeeId: ctx.session.user.id,
    });
    revalidatePath('/[affected-path]');
    return result;
  });
```
