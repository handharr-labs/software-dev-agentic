---
name: developer-pres-create-screen
description: Create the Screen / View that binds to the StateHolder and renders state.
user-invocable: false
knowledge_scope: engineering
---

Create a Screen following the {platform} standard architecture, loaded from the KMS.

## Steps

1. **Read** `.claude/runs/<feature>/stateholder-contract.md` completely — must match state fields and events exactly
2. **Load pattern** (fetch-by-topic — see `kms-conventions.md §Retrieval Protocol`):
   - `kms_list(discipline="engineering", artifact="standard-architecture", topic="presentation", platform={platform})` — scan the presentation TOC for the screen pattern slug (e.g. `screen_structure`).
   - `kms_fetch(discipline="engineering", artifact="standard-architecture", topic="presentation", pattern="<screen slug from list>", platform={platform})` — full content: naming, file path convention, code pattern.
   - If the TOC has no screen pattern, STOP and report a KMS seed gap for `{platform}/engineering/standard-architecture/presentation` — do not guess.
3. **Locate** path per the impl doc's screen directory convention
4. **Create** the screen file following the impl doc pattern
5. **Register** route/navigation entry if required by the platform (see impl doc)

## Rules

- Screen is state-management-aware only as a consumer — it reads state and dispatches events; it never contains business logic
- Navigation side effects belong in the listener/observer pattern (see impl doc), not inline in render methods
- All state fields and event types must match the stateholder-contract exactly

## Output

Confirm file path, list all handled state cases, list all dispatched events, and confirm route registration if applicable.
