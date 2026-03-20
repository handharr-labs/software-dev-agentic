---
name: new-viewmodel
description: Create a ViewModel hook and its paired View component for a feature. Use when building a new screen or interactive UI section.
allowed-tools: Read, Write, Glob, Grep
---

Create a ViewModel hook and View component for this Next.js Clean Architecture project.

Ask me:
1. Feature name (PascalCase, e.g. `EmployeeList`, `LeaveRequest`)
2. What data does it display? (entity type, list or single)
3. What user actions does it handle? (search, delete, submit, navigate, etc.)
4. Does it navigate anywhere on action? If yes, to which route?
5. Is there initial server-fetched data (SSR seed via `initialData` prop)?

Then generate:

**`src/presentation/features/[feature-name]/use[Feature]ViewModel.ts`**

Rules:
- `'use client'` directive at top
- Receives use cases via typed deps parameter: `use[Feature]ViewModel(deps: [Feature]ViewModelDeps)`
- Uses `useQuery` for reads, `useMutation` for writes — never raw `fetch` or Axios
- Query key array: `['[feature]', ...params]`
- Returns a flat readonly object — no raw setters, no class instances
- Callbacks wrapped in `useCallback` with correct deps
- Navigation via `useRouter()` from `next/navigation`

Return shape pattern:
```typescript
return {
  // state
  [data], isLoading, isError, errorMessage,
  // actions
  handle[Action]: useCallback(...),
} as const;
```

**`src/presentation/features/[feature-name]/[Feature]View.tsx`**

Rules:
- `'use client'` directive at top
- Gets use cases from `useDI()` hook
- Passes them to ViewModel hook
- Renders `<LoadingView />` when `isLoading`
- Renders `<ErrorView message={...} onRetry={...} />` when `isError`
- Is a dumb renderer — no business logic, no direct API calls
- Accepts `initialData?` prop if SSR seeding is needed
- Composes feature organisms from `./organisms/` for complex UI sections
- Atoms/molecules come from `@/shared/presentation/common/atoms/` or `molecules/`

After creating, remind me to:
- Add the feature's use cases to DI containers if not yet wired
- Add route constant if navigating to a new page
- Add test: `__tests__/presentation/hooks/use[Feature]ViewModel.test.ts`
