---
name: developer-pres-create-stateholder
description: Create the StateHolder (BLoC / ViewModel / Presenter) for a feature screen.
user-invocable: false
knowledge_scope: engineering
---

Create the StateHolder following the {platform} standard architecture in `kms/knowledge-sources/engineering/{platform}-standard-architecture.md`.

## Steps

1. **Fetch pattern** — `kms_query(text="state management bloc cubit naming convention code pattern", platform={platform}, discipline="engineering", n_results=3)` for the canonical pattern and path convention. **Fallback** if no results: Read `kms/knowledge-sources/engineering/{platform}-standard-architecture.md` and locate the relevant section.
2. **Confirm** use cases exist in domain layer before proceeding
3. **Locate** path per `### Creation Order` in the impl doc
4. **Create** the StateHolder file(s) following the implementation pattern
5. **Produce** `.claude/runs/<feature>/stateholder-contract.md` per `### StateHolder Contract`

## Rules

- StateHolder never imports from the data layer — no DTOs, no `RepositoryImpl`, no `DataSource`
- Use cases injected via constructor — never instantiated inline
- Follows the platform's DI registration pattern (see impl doc)

## Output

Confirm file path(s), list all state fields, list all events/methods, and confirm stateholder-contract.md written.
