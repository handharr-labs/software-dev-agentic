---
name: developer-pres-create-screen
description: Create the Screen / View that binds to the StateHolder and renders state.
user-invocable: false
knowledge_scope: engineering
---

Create a Screen following the {platform} standard architecture in `kms/knowledge-sources/engineering/{platform}-standard-architecture.md`.

## Steps

1. **Read** `.claude/runs/<feature>/stateholder-contract.md` completely — must match state fields and events exactly
2. **Fetch pattern** — `kms_query(text="presentation screen structure naming convention code pattern", platform={platform}, discipline="engineering", n_results=3)` for the canonical pattern and file path convention. **Fallback** if no results: Read `kms/knowledge-sources/engineering/{platform}-standard-architecture.md` and locate the relevant section.
3. **Locate** path per the impl doc's screen directory convention
4. **Create** the screen file following the impl doc pattern
5. **Register** route/navigation entry if required by the platform (see impl doc)

## Rules

- Screen is state-management-aware only as a consumer — it reads state and dispatches events; it never contains business logic
- Navigation side effects belong in the listener/observer pattern (see impl doc), not inline in render methods
- All state fields and event types must match the stateholder-contract exactly

## Output

Confirm file path, list all handled state cases, list all dispatched events, and confirm route registration if applicable.
