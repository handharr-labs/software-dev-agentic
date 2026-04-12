---
name: arch-check-web
description: Check web-specific Clean Architecture rules for a Next.js 15 / TypeScript project — import direction, React directives, Server Actions, hook patterns, and Atomic Design. Called by arch-review-worker.
user-invocable: false
tools: Read, Glob, Grep
---

Check the provided files against web-specific architecture rules. Report violations with file path, line number, and fix.

## Web-Specific Rules

**W1. Dependency Rule — Import Direction (Critical)**
- `src/domain/`: zero imports from `react`, `next`, `axios`, `src/data/`, or `src/presentation/`
- `src/data/`: imports from `src/domain/` and Node.js built-ins only — never `src/presentation/`
- `src/presentation/`, `src/app/`: imports from `react`, `next`, `src/domain/` — never from `src/data/` impls directly
- `container.server.ts`: never imports React or `client-only`
- `container.client.ts`: never imports `server-only`

How to check: `Grep` for `from '@/data/` in `src/presentation/` files; `Grep` for `from 'react'` in `src/domain/` files.

**W2. Hook Exposure (Critical)**
- `use*ViewModel` hooks must return `readonly` state — no raw `useState` setters exposed to callers

How to check: `Grep` for `useState` returns in `use*ViewModel` files.

**W3. ViewModel Pattern Correctness (Critical)**
- `use*ViewModel` files must have `'use client'` and use at least one React hook
- `build*ViewModel` files must be pure functions — no hooks, no `async`, no side effects, no `react` imports
- `async page.tsx` that uses data must call `build*ViewModel` or pass `initialData` — never fetch inside a Client Component when a Server Component can do it

How to check: `Grep` for `'use client'` in `use*ViewModel` files; `Grep` for `useState\|useEffect` in `build*ViewModel` files.

**W4. Directive Placement (Critical)**
- `'use client'` or `'use server'` in any `src/domain/` or `src/data/` file is a violation

How to check: `Grep` for `'use client'\|'use server'` across `src/domain/` and `src/data/`.

**W5. Server Action Rules (Critical)**
- Server Actions must use `next-safe-action`
- Server Actions must call use cases from `container.server.ts` — never instantiate repositories directly

How to check: `Grep` for `'use server'` files; verify `next-safe-action` import present; verify use case is sourced from `container.server.ts`.

**W6. Atomic Design Hierarchy (Warning)**
- `atoms/` and `molecules/` accept only primitive props — no entity types
- `organisms/` accept entities but must never call `useDI()`
- Only `Views/` call `useDI()`

How to check: `Grep` for `useDI` in `atoms/`, `molecules/`, `organisms/` files.

## Naming Conventions

Grep `reference/project.md` for the naming convention table — report deviations as Warning.

## Output

Return raw findings in the format expected by `arch-generate-report`:

```
FILE: <path>
  [CRITICAL] <rule id> — <specific violation with line reference>
  [WARNING]  <rule id> — <specific violation>
PASS: <path>
```
