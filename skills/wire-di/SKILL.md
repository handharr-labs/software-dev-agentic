---
name: wire-di
description: Wire one or more use cases into the DI containers. Use after creating a new use case that hasn't been registered yet.
disable-model-invocation: true
allowed-tools: Read, Edit, Glob
---

Wire a use case into the DI containers for this Next.js Clean Architecture project.

First, ask me:
1. Use case name (e.g. `SubmitLeaveRequestUseCase`)
2. Which containers need this use case: **server**, **client**, or **both**?
3. Which repository does this use case depend on (e.g. `LeaveRepository`)?

Then:

**Step 1 — Read the existing containers before writing:**
- `src/di/container.server.ts`
- `src/di/container.client.ts`
- `src/di/DIContext.tsx`

Match the exact import style, variable naming, and indentation already present.

**Step 2 — Wire into `container.server.ts`** (if server or both):

```typescript
// 1. Add import at the top (match existing import order):
import { [Verb][Feature]UseCaseImpl } from '@/domain/use-cases/[feature]/[Verb][Feature]UseCase';

// 2. Add factory export at module level (use cases are factories, not singletons):
export const [verbFeature]UseCase = () => new [Verb][Feature]UseCaseImpl([feature]Repository);
```

The repository binding should already exist. If not, also add:
```typescript
// Add after existing DataSource instantiation:
const [feature]RemoteDS = new [Feature]RemoteDataSourceImpl(httpClient);
const [feature]Repository = new [Feature]RepositoryImpl([feature]RemoteDS);
```

**Step 3 — Wire into `container.client.ts`** (if client or both):

```typescript
// 1. Add import at the top:
import { [Verb][Feature]UseCaseImpl } from '@/domain/use-cases/[feature]/[Verb][Feature]UseCase';

// 2. Add getter inside createClientContainer() return object:
get [verbFeature]UseCase() { return new [Verb][Feature]UseCaseImpl([feature]Repository); },
```

The repository must be instantiated inside `createClientContainer()`. If not present:
```typescript
// Add before the return statement:
const [feature]Repository = new [Feature]RepositoryImpl(
  new [Feature]RemoteDataSourceImpl(httpClient)
);
```

**Step 4 — Check `DIContext.tsx`**

If this is a new interface being added to the client container for the first time, verify that `ClientContainer` (the return type of `createClientContainer`) automatically reflects the new getter — no manual type update needed since it uses `ReturnType<typeof createClientContainer>`.

If there is a manually maintained type or interface for the context, remind me to add the new use case there.

**Step 5 — Verify**

After wiring, confirm:
- Import path is correct (use `@/` alias, not relative)
- Use cases are getters / factories — **not** `const` singletons
- Repositories are `const` singletons — **not** recreated per call
- `server-only` / `client-only` guards are already present at the top of each file (do not remove them)

List the exact lines added to each file.
