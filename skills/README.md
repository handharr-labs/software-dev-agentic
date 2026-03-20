# Skills

User-invocable prompt expansions triggered with `/skill-name`.

Each skill lives in its own directory as `SKILL.md` following the current Claude Code convention.

| Skill | Trigger | What it does |
|-------|---------|-------------|
| `create-issue` | `/create-issue` | Create issue file + git branch + backlog entry |
| `new-feature` | `/new-feature` | Full feature scaffold — all layers + DI wiring |
| `new-entity` | `/new-entity` | Domain entity + DTO + Mapper |
| `new-usecase` | `/new-usecase` | UseCase interface + implementation |
| `new-viewmodel` | `/new-viewmodel` | ViewModel hook + View component |
| `new-server-action` | `/new-server-action` | Scaffold a validated Server Action with next-safe-action |
| `new-db-repository` | `/new-db-repository` | Scaffold a DB-backed DataSource + Repository impl |
| `write-tests` | `/write-tests` | Tests for any file — auto-selects test type by layer |
| `scaffold-service` | `/scaffold-service` | Create a pure domain service (no async, no I/O) |
| `scaffold-repository` | `/scaffold-repository` | Create a repository implementation with mapper + ErrorMapper |
| `create-mock` | `/create-mock` | Scaffold a `Mock[Name]` class with `vi.fn()` for every interface method |
| `integration-test` | `/integration-test` | Scaffold integration tests covering happy path + all HTTP error codes |
| `ssr-check` | `/ssr-check` | Server vs Client Component decision + code structure |
| `wire-di` | `/wire-di` | Wire a use case into `container.server.ts` and/or `container.client.ts` |
