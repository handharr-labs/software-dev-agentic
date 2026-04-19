# Next.js StarterKit — Architecture Index

Load only the file relevant to your task.

## Contract References (cross-platform standard — same filename on every platform)

| File | Contents |
|------|----------|
| contract/domain.md | Entities, repository protocols, use cases, services, domain errors |
| contract/data.md | DTOs, mappers, data sources, repository impl, fetch/axios networking |
| contract/presentation.md | Component patterns, hooks, state management conventions, atomic design |
| contract/navigation.md | App Router structure, route definitions, middleware, redirects |
| contract/di.md | DI container, server/client context, DI principles |
| contract/testing.md | Test pyramid, component/hook/repository/mapper tests |

## Platform-Specific References

| File | Contents |
|------|----------|
| overview.md | Core principles, layer diagram, dependency rule |
| error-handling.md | Error flow, error types, error boundaries |
| utilities.md | StorageService, DateService, Logger, API client, Validator, etc. |
| modular.md | Turborepo packages, module structure, cross-package communication |
| project.md | Project layout, naming conventions, design decisions, appendix |
| ssr.md | Server vs client rendering decision table and patterns |
| server-actions.md | Full-stack mutations — next-safe-action setup, action pattern, auth guard, cache revalidation |
| database.md | DB data source layer, ORM-agnostic repository impl, DB mappers, container wiring |
| api-routes.md | Route Handlers — when to use, webhook pattern, error responses (not for own-UI mutations) |
| project-setup.md | Project-specific decisions checklist — styling, ORM, auth, env vars, testing framework |
