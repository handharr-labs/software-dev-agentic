---
name: new-feature
description: Scaffold a complete new feature following Clean Architecture. Generates all layers from entity to view, including DI wiring.
context: fork
allowed-tools: Read, Write, Edit, Glob, Grep
---

Scaffold a complete new feature for this Next.js Clean Architecture project.

First, ask me:
1. Feature name (kebab-case, e.g. `leave-request`)
2. Entity fields (name, TypeScript type, required or optional)
3. Which operations are needed: GET list / GET single / POST / PUT / DELETE
4. API base endpoint (e.g. `/api/v1/leave-requests`)
5. Does this need a new page/route? If yes, what path?

Then generate all files in this order:

**Domain layer** (`src/domain/`):
- `entities/[Name].ts` — readonly interface, zero imports
- `repositories/[Feature]Repository.ts` — interface, returns entities not DTOs
- `use-cases/[feature]/[Verb][Feature]UseCase.ts` — one file per operation, each has interface + Impl

**Data layer** (`src/data/`):
- `dtos/[Name]DTO.ts` — raw API response shape
- `mappers/[Name]Mapper.ts` — interface + MapperImpl class
- `data-sources/remote/[Feature]RemoteDataSource.ts` — interface
- `data-sources/remote/[Feature]RemoteDataSourceImpl.ts` — Axios implementation
- `repositories/[Feature]RepositoryImpl.ts` — implements domain interface

**Presentation layer** (`src/features/[feature-name]/presentation/`):
- `organisms/` — Feature-specific composite components (create if feature has reusable sections)
- `use[Feature]ViewModel.ts` — `'use client'`, TanStack Query hooks, deps-injected
- `[Feature]View.tsx` — `'use client'`, calls `useDI()`, renders loading/error/data states

**Routing** (if new page):
- Add to `src/presentation/navigation/routes.ts`
- Create `src/app/[route]/page.tsx` as Server Component

**DI wiring**:
- `src/di/container.server.ts` — for RSC / initial data fetching
- `src/di/container.client.ts` — for client-side interactions

After generating, list the test files that should be created and offer to generate them.
