---
name: developer-pres-create-stateholder
description: Create the StateHolder (BLoC / ViewModel / Presenter) for a feature screen.
user-invocable: false
knowledge_scope: engineering/state_management
---

Create the StateHolder following `lib/core/knowledge/{platform}/engineering/state_management/bloc.md`.

## Steps

1. **Read** `lib/core/knowledge/{platform}/engineering/state_management/bloc.md` — read all sections for invariants and the platform-specific implementation pattern. Check `lib/core/knowledge/{project}/engineering/state_management/bloc.md` first (project-specific override), fall back to `lib/core/knowledge/{platform}/engineering/state_management/bloc.md` (platform-base).
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
