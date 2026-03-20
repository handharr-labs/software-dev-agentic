---
name: ssr-check
description: Decide whether a component or page should be a Server Component or Client Component, and how to structure SSR data fetching. Use when unsure about 'use client' placement or rendering strategy.
allowed-tools: Read, Glob, Grep
---

Help me decide the rendering strategy for a component or page in this Next.js 15 / App Router project.

If I have a file already, read it. Otherwise ask me to describe what the component does.

Evaluate against these rules:

## Server Component (default — no 'use client')

Use when the component:
- Only renders data (no user interaction, no event handlers)
- Fetches data at request time for SEO or initial load
- Uses environment variables or server-only secrets
- Has no `useState`, `useEffect`, or any hook
- Does not use browser APIs (`window`, `localStorage`, etc.)

Pattern: import use case from `container.server.ts`, call `execute()` directly, pass data as props to Client Components.

## Client Component ('use client')

Required when the component:
- Uses any React hook (`useState`, `useEffect`, `useQuery`, etc.)
- Has event handlers (`onClick`, `onChange`, `onSubmit`)
- Uses browser APIs
- Uses `useRouter` or `usePathname`

Pattern: call `useDI()` to get use cases, pass to ViewModel hook, render.

## The Hybrid Pattern (recommended for most pages)

```
app/[route]/page.tsx          ← Server Component (no 'use client')
  fetches initialData via container.server.ts
  passes initialData prop to →

presentation/features/[f]/[F]View.tsx  ← Client Component ('use client')
  receives initialData, seeds TanStack Query cache
  handles all interactive behavior
```

This avoids client waterfall on first load while keeping interactivity.

## Decision Output

Provide:
1. **Verdict**: Server Component / Client Component / Hybrid
2. **Reason**: one sentence
3. **'use client' boundary**: which file gets the directive
4. **Data fetching**: where and how (server container vs `useQuery`)
5. **Code snippet**: show the recommended structure

## Common Mistakes to Flag

- `'use client'` on a page that only renders static data (unnecessary)
- `useQuery` inside a Server Component (not allowed)
- Importing `container.server.ts` inside a Client Component (will error)
- Using `localStorage` or `window` without `'use client'` (will fail on server)
- Passing non-serializable values (class instances, functions) from Server to Client props
