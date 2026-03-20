---
description: Rules for the DI container files — server/client split, import guards, and singleton vs getter patterns.
globs:
  - src/shared/di/container.*.ts
  - src/shared/di/DIContext.tsx
---

## DI Container Rules

### `container.server.ts`
- Must start with `import 'server-only'` as the very first import
- Never import React, hooks, or anything from `'client-only'`
- Use cases are exported as **factory functions** (recreated per call): `export const doThingUseCase = () => new DoThingUseCaseImpl(repo)`
- Repositories and data sources are **module-level singletons** (instantiated once at module load)

### `container.client.ts`
- Must start with `import 'client-only'` as the very first import
- Never import `'server-only'` or any server-only module
- Use cases are exposed as **getter properties** inside `createClientContainer()`: `get doThingUseCase() { return new DoThingUseCaseImpl(repo); }`
- Repositories are `const` singletons **inside** `createClientContainer()` (not at module level)

### `DIContext.tsx`
- Wraps the **client** container only — never the server container
- `ClientContainer` type is inferred via `ReturnType<typeof createClientContainer>` — no manual type maintenance needed
- Adding a new getter to `createClientContainer()` automatically exposes it through `useDI()`

### When to edit these files
- After creating a new use case: run `/wire-di` to add it to the correct container(s)
- Never edit both containers at the same time without reading both files first — the server/client split creates non-obvious constraints
- If you see a TypeScript error about a missing use case in `useDI()`, the fix is always in `container.client.ts`, not in `DIContext.tsx`
