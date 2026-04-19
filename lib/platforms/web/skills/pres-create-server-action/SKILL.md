---
name: pres-create-server-action
description: Create a next-safe-action Server Action for a mutation. Called by presentation-worker for full-stack features.
user-invocable: false
tools: Read, Write, Glob
---

Create `src/presentation/features/[feature]/actions/[verb][Feature]Action.ts`.

**Preconditions:**
- `src/lib/safe-action.ts` must exist — fail fast if it doesn't (user must set it up first)
- Use case for this operation must exist in `src/domain/use-cases/[feature]/`
- Check `Glob: src/presentation/features/*/actions/*.ts` — read one to match project style

**Rules:**
- `'use server'` directive at the top of the file
- Use `authActionClient` (authenticated) or `actionClient` (public) from `src/lib/safe-action.ts`
- Validate input with Zod schema (`.schema(z.object({...}))`)
- Call use case from `src/di/container.server.ts` — never instantiate repos directly
- Call `revalidatePath()` on mutations that affect cached Server Component data

**Pattern:** `reference/server-actions.md` — Grep `## Action File Pattern`, `## Client-Side Consumption`

**Return:** created file path. Suggest next step: `pres-wire-di`.
