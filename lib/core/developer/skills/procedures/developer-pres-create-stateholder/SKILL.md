---
name: developer-pres-create-stateholder
description: Create the StateHolder (BLoC / ViewModel / Presenter) for a feature screen.
user-invocable: false
knowledge_scope: engineering
---

Create the StateHolder following the {platform} standard architecture, loaded from the KMS.

## Steps

1. **Load pattern** (fetch-by-topic — see `kms-conventions.md §Retrieval Protocol`). The StateHolder topic is platform-specific (flutter → `state_management`; MVP platforms → `presentation`):
   - `kms_list(discipline="engineering", artifact="standard-architecture", platform={platform})` — scan the TOC; locate the state-holder topic (`state_management` with `bloc`/`cubit`, or `presentation` with `presenter`/`mvp_contract`).
   - `kms_fetch(discipline="engineering", artifact="standard-architecture", topic="<state-holder topic>", pattern="<slug from list>", platform={platform})` — full content: naming, path convention, code pattern.
   - If the TOC has no state-holder pattern, STOP and report a KMS seed gap for `{platform}/engineering/standard-architecture` — do not guess.
2. **Confirm** use cases exist in domain layer before proceeding
3. **Locate** path per `### Creation Order` in the impl doc
4. **Create** the StateHolder file(s) following the implementation pattern
5. **Produce** `.claude/agentic-state/developer/runs/<feature>/stateholder-contract.md` per `### StateHolder Contract`

## Rules

- StateHolder never imports from the data layer — no DTOs, no `RepositoryImpl`, no `DataSource`
- Use cases injected via constructor — never instantiated inline
- Follows the platform's DI registration pattern (see impl doc)

## Output

Confirm file path(s), list all state fields, list all events/methods, and confirm stateholder-contract.md written.
