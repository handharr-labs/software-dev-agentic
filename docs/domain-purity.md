---
description: Rules enforcing zero external dependencies in the domain layer — entities, use cases, and domain services.
globs:
  - src/features/*/domain/**/*.ts
  - src/shared/domain/**/*.ts
---

## Domain Purity Rules

### Zero external imports
Domain files must never import from:
- `react`, `react-dom`, or any React ecosystem package
- `next`, `next/navigation`, `next/cache`, or any Next.js package
- `axios`, `fetch` wrappers, or any HTTP library
- `@supabase/*`, `drizzle-orm`, or any ORM/DB package
- Any path containing `/data/` or `/presentation/`

Only allowed imports: other files within `src/features/*/domain/`, `src/shared/domain/`, and TypeScript built-ins.

### Entity properties
- All entity interface properties must be `readonly`
- Entities are plain TypeScript interfaces — no classes, no decorators, no methods
- Property names use camelCase (domain concepts, not API field names)

### Domain services
- Must be **synchronous** — no `async`, no `await`, no `Promise` return types
- No side effects: no `fetch`, no `console`, no filesystem, no DOM access
- Parameters and return types use only domain entities, primitives, or value objects defined within the domain layer

### Service placement
- Place a service in the feature that *owns the domain concept* it encapsulates
- If two or more features depend on the same service, move it to `src/shared/domain/services/`
- A service used exclusively by feature X but conceptually about feature Y's domain → feature Y
- A service used exclusively by feature X and about feature X's domain → feature X

### Use cases
- Constructor receives repository **interfaces** only — never `*Impl` classes
- One `execute()` method per use case — single responsibility
- Validation logic > 3 lines belongs in a domain service, not inline in `execute()`
