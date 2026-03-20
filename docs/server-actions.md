---
description: Rules for Server Action files — directive, safe-action wrapper, DI usage, and cache revalidation.
globs:
  - src/features/*/presentation/actions/**/*.ts
---

## Server Action Rules

### Directive
- Every action file **must** begin with `'use server';` as the first line (before imports)

### Validation wrapper
- Use `authActionClient` from `src/lib/safe-action.ts` for authenticated actions
- Use `actionClient` only for public (unauthenticated) mutations
- Pattern: `authActionClient.schema(z.object({...})).action(async ({ parsedInput, ctx }) => { ... })`
- Never export a raw `async function` with `'use server'` — always use the `next-safe-action` wrapper

### DI usage
- Call use cases from `createServerContainer()` or the exported factory functions in `src/shared/di/container.server.ts`
- Never instantiate `*RepositoryImpl`, `*DataSourceImpl`, or `*UseCaseImpl` directly inside an action
- Pattern: `const result = await verbFeatureUseCase().execute({ payload: parsedInput })`

### Cache revalidation
- Call `revalidatePath('/affected-route')` after every mutation (create, update, delete)
- Import `revalidatePath` from `'next/cache'`
- Place the `revalidatePath` call **after** the use case returns successfully

### Error handling
- Do not try/catch inside actions — let `next-safe-action` handle `DomainError` via `handleServerError` in `safe-action.ts`
