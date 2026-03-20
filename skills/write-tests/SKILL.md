---
name: write-tests
description: Write tests for the current file or a named module. Automatically selects the right test type based on the layer.
allowed-tools: Read, Write, Edit, Glob, Grep
---

Write tests for this Next.js Clean Architecture project.

Read the target file (ask me for the path if not clear from context). Then:

1. Identify the layer from the file path and contents:
   - `src/domain/services/` → unit test, pure function coverage
   - `src/domain/use-cases/` → unit test, mock repository
   - `src/data/mappers/` → unit test, every field + null cases
   - `src/data/repositories/` → integration test, mock HTTP client
   - `src/presentation/features/*/use*.ts` → hook test with QueryClientWrapper
   - `src/presentation/features/*View.tsx` → component test with RTL

2. Check `__tests__/mocks/` for existing mocks before creating new ones.

3. Write the test file at the correct location:
   - Services → `__tests__/domain/services/[Name].test.ts`
   - UseCases → `__tests__/domain/use-cases/[Verb][Feature]UseCase.test.ts`
   - Mappers → `__tests__/data/mappers/[Name]Mapper.test.ts`
   - Repositories → `__tests__/data/repositories/[Name]RepositoryImpl.test.ts`
   - ViewModel hooks → `__tests__/presentation/hooks/use[Feature]ViewModel.test.ts`
   - View components → `__tests__/presentation/[Feature]View.test.tsx`

4. Coverage requirements:
   - Domain services: 100% branch coverage — test every condition
   - Mappers: every field, including null/undefined optional fields
   - UseCases: happy path + every error the repository can throw
   - Repositories: happy path + each HTTP error code → correct DomainError
   - ViewModel hooks: idle → loading → loaded → error state transitions
   - View components: loading state, error state, data state, user interaction

5. Always use `describe` blocks per class/hook, `it` blocks per behavior.
   Bad: `it('works')` — Good: `it('returns empty list when API returns no items')`

6. For ViewModel hook tests, always wrap with QueryClientWrapper:
```typescript
const wrapper = ({ children }) => (
  <QueryClientProvider client={new QueryClient({ defaultOptions: { queries: { retry: false } } })}>
    {children}
  </QueryClientProvider>
);
```

Create any missing mocks in `__tests__/mocks/` using the `Mock[Name]` naming convention.
