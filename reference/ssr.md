## 15. Server vs Client Rendering Reference

Next.js App Router runs some code on the server and some in the browser. Each component, hook, and utility in this architecture has a rendering context — understanding it prevents runtime bugs (e.g., `window is not defined`) and ensures best performance (e.g., pre-fetching data in Server Components to eliminate client waterfalls).

### 15.1 Next.js Rendering Rules (Quick Recap)

| Feature | Server Component | Client Component |
|---------|-----------------|-----------------|
| How to declare | Default (no directive) | `'use client'` at top of file |
| Can be `async` | Yes | No |
| `useState`, `useEffect`, hooks | No | Yes |
| React Context (consumer) | No | Yes |
| Browser APIs (`window`, `document`, `localStorage`) | No | Yes |
| Fetches data at render time | Yes | Via hooks after hydration |
| Props from server → client | Must be serializable (no functions, class instances) | — |
| DI strategy | Import from `container.server.ts` | `useDI()` hook |

> **`'use client'` is a module-graph boundary.** Every module imported inside a `'use client'` file becomes part of the client bundle, whether or not it itself has `'use client'`. This means even a plain TypeScript utility will be bundled client-side if it is imported from a Client Component.

### 15.2 Domain Layer — Isomorphic

All Domain layer code is **isomorphic** — it runs correctly on both the server and in the browser. It has no framework dependencies (`react`, `next`, browser APIs), making it safe to import from Server Components, Client Components, or any utility.

| File | Runtime | Why |
|------|---------|-----|
| `domain/entities/*.ts` | **Both** | Plain TypeScript interfaces, zero deps |
| `domain/repositories/*.ts` | **Both** | Interface definitions only |
| `domain/use-cases/**/*.ts` | **Both** | Instantiated in `container.server.ts` (server) and `container.client.ts` (client) |
| `domain/services/**/*.ts` | **Both** | Pure synchronous classes, no I/O |
| `domain/errors/DomainError.ts` | **Both** | Plain `Error` subclass |
| `domain/errors/errorMessages.ts` | **Both** | Pure `switch` function |

> **Rule:** Domain code must never import from `react`, `next`, or browser-specific APIs. This is what keeps it isomorphic and independently testable.

### 15.3 Data Layer — Isomorphic Code, Split Instantiation

Data layer **classes and interfaces** are isomorphic — just TypeScript. What determines their runtime is **which container instantiates them**: `container.server.ts` (server) or `container.client.ts` (client).

| File | Runtime | Why |
|------|---------|-----|
| `data/dtos/*.ts` | **Both** | Plain TypeScript interfaces |
| `data/mappers/*.ts` | **Both** | Pure transformation classes, no framework deps |
| `data/networking/HTTPClient.ts` | **Both** | Interface definition only |
| `data/networking/NetworkError.ts` | **Both** | Plain `Error` subclass |
| `data/networking/AxiosHTTPClient.ts` | **Both** | Axios is universal — Node.js adapter on server, XHR adapter in browser |
| `data/networking/TokenRefreshService.ts` | **Both** | Pure class — runtime depends on injected `TokenStorage` |
| `data/data-sources/remote/*.ts` | **Both** | Pure class — makes HTTP calls via the `HTTPClient` interface |
| `data/repositories/*.ts` | **Both** | Pure class — orchestrates DataSource + Mappers |

The `TokenStorage` implementations are where the split actually happens:

| Class | Runtime | Why |
|-------|---------|-----|
| `ServerTokenStorage` | **Server only** | Reads cookies via `next/headers` — only available in RSC |
| `LocalStorageTokenProvider` | **Client only** | Uses `window.localStorage` — browser only |
| `InMemoryStorageService` | **Both** | Pure in-memory `Map`, no browser or server APIs |

> **Why Axios works on both:** Axios detects its environment and picks the right adapter — `http`/`https` modules in Node.js, `XMLHttpRequest` in the browser. You write the same code either way.

### 15.4 DI Layer — Strictly Split

This is the only layer where the server/client boundary is enforced at **compile time** via `server-only` and `client-only` packages.

| File | Runtime | Enforcement |
|------|---------|-------------|
| `di/container.server.ts` | **Server only** | `import 'server-only'` — build error if imported in a `'use client'` file |
| `di/container.client.ts` | **Client only** | `import 'client-only'` — build error if imported in a Server Component |
| `di/DIContext.tsx` (`DIProvider`) | **Client only** | `'use client'` — React Context providers cannot run in RSC |
| `di/DIContext.tsx` (`useDI()`) | **Client only** | Calls `useContext()` — hooks are client-only |

**Usage pattern by component type:**

```
Server Component page (no 'use client'):
  ✅ import { getEmployeesUseCase } from '@/di/container.server'
  ❌ import { useDI } from '@/di/DIContext'    ← hooks not allowed in RSC

Client Component ('use client'):
  ✅ const { getEmployeesUseCase } = useDI()
  ❌ import { getEmployeesUseCase } from '@/di/container.server'  ← server-only guard blocks this
```

### 15.5 Presentation Layer — Mostly Client

The Presentation layer is almost entirely client-side because it depends on hooks, state, and event handlers.

| File | Runtime | Why |
|------|---------|-----|
| `presentation/common/QueryState.ts` | **Both** | Plain TypeScript union type — no deps |
| `presentation/navigation/routes.ts` (`ROUTES` constant) | **Both** | Plain object literal, no framework deps |
| `presentation/navigation/useAppRouter.ts` | **Client only** | Uses `useRouter`, `usePathname`, `useSearchParams` |
| `presentation/features/**/use[Feature]ViewModel.ts` | **Client only** | Uses `useState`, `useQuery`, `useMutation`, `useRouter` |
| `presentation/features/**/*View.tsx` | **Client only** | `'use client'` directive; uses hooks + event handlers |
| `presentation/common/LoadingView.tsx` | **Both*** | Pure JSX with no hooks — Server-renderable |
| `presentation/common/ErrorView.tsx` | **Client only** | Has `onClick` event handler |
| `presentation/common/BottomNav.tsx` | **Client only** | Uses `usePathname()` |
| `presentation/providers/QueryClientProvider.tsx` | **Client only** | Wraps TanStack Query React Context |
| `stores/*.ts` (Zustand) | **Client only** | Zustand hooks (`useStore`) are client-only |

> *Simple presentational components with no hooks or event handlers can be Server Components. As soon as they call `useDI()`, `useQuery`, or any hook, they become client-only.

### 15.6 Navigation & App Directory

| File | Runtime | Why |
|------|---------|-----|
| `app/layout.tsx` (root) | **Server** | No `'use client'` — root layout is a Server Component |
| `app/(main)/layout.tsx` | **Client** | `'use client'` directive — needs `DIProvider` |
| `app/[route]/page.tsx` | **Server** | Default in App Router — no `'use client'` needed |
| `app/[route]/page.tsx` (with `'use client'`) | **Client** | Added explicitly when the page itself needs hooks |
| `app/[route]/error.tsx` | **Client** | Required by Next.js — error boundaries must be `'use client'` |
| `app/[route]/loading.tsx` | **Server** | Static Suspense fallback, rendered to HTML |

**When to make a page `async` (Server Component):**

When you want data pre-fetched before the browser receives any HTML. Call the use case directly in the page and pass `initialData` as a prop to the Client Component:

```typescript
// app/employees/page.tsx  ← Server Component (async)
import { getEmployeesUseCase } from '@/di/container.server';

export default async function EmployeesPage() {
  // Runs on server — data arrives with the HTML, no client waterfall
  const initialData = await getEmployeesUseCase().execute({ page: 1, limit: 20 });
  return <EmployeeListView initialData={initialData} />;
}
```

The `initialData` prop must be **serializable** — plain objects and arrays only. No `Date` instances, no class instances, no functions. Convert `Date` to ISO string before passing across the boundary and parse it back in the Client Component.

### 15.7 Core Services — Mixed

| Class | Runtime | Why |
|-------|---------|-----|
| `StorageService` interface | **Both** | Interface definition only |
| `LocalStorageService` | **Client only** | Uses `window.localStorage` |
| `InMemoryStorageService` | **Both** | Pure in-memory `Map` |
| `SecureStorageService` | **Client only** | Delegates to `LocalStorageService` |
| `DateServiceImpl` | **Both** | Uses `Intl` API and `Date` — available in both runtimes |
| `ConsoleLogger` | **Both** | Uses `console.*` — available in both runtimes |
| `BrowserNetworkMonitor` | **Client only** | Uses `navigator.onLine` + `window.addEventListener` |
| `ValidatorService` | **Both** | Pure synchronous class, no I/O |
| `ImageCacheService` (in-memory) | **Both** | Plain `Map` cache — isomorphic |
| Null safety utils (`orZero`, `orEmpty`, etc.) | **Both** | Pure functions, no deps |

### 15.8 Third-Party Libraries

| Library / API | Runtime | Notes |
|---------------|---------|-------|
| `axios` | **Both** | Universal HTTP — Node.js adapter on server, XHR adapter in browser |
| `axios-retry` | **Both** | Pure Axios plugin |
| `@tanstack/react-query` (`useQuery`, `useMutation`, `useQueryClient`) | **Client only** | React hooks |
| `@tanstack/react-query` (`QueryClient`, `dehydrate`) | **Both** | Can be used on server for prefetching + cache transfer |
| `zustand` (`useStore`) | **Client only** | React hook |
| `next/navigation` (`useRouter`, `usePathname`, `useSearchParams`) | **Client only** | Hooks |
| `next/navigation` (`redirect`, `notFound`) | **Server only** | Used in Server Components and Route Handlers |
| `next/headers` (`cookies`, `headers`) | **Server only** | Reads request headers/cookies — RSC and Route Handlers only |

### 15.9 Complete Rendering Map (Quick Reference)

```
┌─────────────────────────────────────────────────────────────────┐
│  SERVER ONLY                                                    │
│                                                                 │
│  di/container.server.ts          (server-only guard)           │
│  app/*/page.tsx                  (default — no 'use client')   │
│  app/layout.tsx (root)           (no 'use client')             │
│  app/*/loading.tsx               (Suspense fallback)           │
│  ServerTokenStorage              (reads next/headers cookies)  │
│  next/headers (cookies, headers) (request-time data)           │
│  next/navigation (redirect, notFound)                          │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  CLIENT ONLY                                                    │
│                                                                 │
│  di/container.client.ts          (client-only guard)           │
│  di/DIContext.tsx                (DIProvider + useDI hook)     │
│  presentation/features/**/*View.tsx          ('use client')    │
│  presentation/features/**/use*ViewModel.ts   ('use client')    │
│  presentation/navigation/useAppRouter.ts     ('use client')    │
│  presentation/common/BottomNav.tsx           ('use client')    │
│  presentation/providers/QueryClientProvider  ('use client')    │
│  app/(main)/layout.tsx                       ('use client')    │
│  app/*/error.tsx                             ('use client')    │
│  LocalStorageService, SecureStorageService   (window.localStorage) │
│  LocalStorageTokenProvider                   (window.localStorage) │
│  BrowserNetworkMonitor                       (navigator.onLine)│
│  stores/*.ts (Zustand)                       (React hooks)     │
│  useQuery, useMutation, useQueryClient        (TanStack hooks) │
│  useRouter, usePathname, useSearchParams      (Next.js hooks)  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  ISOMORPHIC (server and client)                                 │
│                                                                 │
│  Domain layer — entities, repository interfaces, use cases,    │
│                 services, errors, errorMessages                 │
│  Data layer  — DTOs, Mappers, DataSources, Repositories,       │
│                AxiosHTTPClient, TokenRefreshService             │
│  presentation/common/QueryState.ts                             │
│  presentation/navigation/routes.ts (ROUTES constant)           │
│  core/date/DateServiceImpl                                      │
│  core/logger/ConsoleLogger                                      │
│  core/storage/InMemoryStorageService                           │
│  core/utils/nullSafety.ts                                       │
│  core/validators/ValidatorService                               │
│  axios, axios-retry                                             │
│  @tanstack/react-query (QueryClient, dehydrate)                │
└─────────────────────────────────────────────────────────────────┘
```

### 15.10 Common Mistakes to Avoid

| Mistake | Problem | Fix |
|---------|---------|-----|
| Using `LocalStorageService` in a Server Component | `window is not defined` at runtime | Use `InMemoryStorageService` or `ServerTokenStorage` on the server |
| Calling `useDI()` in a Server Component | `useContext` is not supported in RSC | Import directly from `container.server.ts` instead |
| Importing `container.server.ts` in a Client Component | `server-only` throws a build error | Use `useDI()` from `DIContext.tsx` |
| Passing a `Date` object as a prop from a Server page to a Client Component | Non-serializable prop — crashes hydration | Serialize to ISO string (`date.toISOString()`) before passing; parse back in the Client Component |
| Passing a class instance (e.g., `DomainError`, `Employee` class) as a Server → Client prop | Non-serializable — crashes hydration | Map to a plain object before passing |
| Adding `useRouter` or `useState` directly to a Server Component | `Error: useState can only be used in Client Components` | Add `'use client'` or extract the interactive part to a child Client Component |
| Wrapping `app/layout.tsx` (root) with `DIProvider` | Forces the entire tree client-side — defeats RSC | Keep `DIProvider` only in `app/(main)/layout.tsx` (authenticated route group) |
| Fetching data with `useQuery` in a page that could be a Server Component | Unnecessary client waterfall — blank screen until JS loads | Make the page `async`, fetch in the Server Component, pass `initialData` to the Client Component |
| Checking `typeof window !== 'undefined'` as a workaround for server-safe code | Fragile — still ships the browser-only code to the client bundle | Use `server-only` / `client-only` packages at the module level instead |
