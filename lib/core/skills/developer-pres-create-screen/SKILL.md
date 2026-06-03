---
name: developer-pres-create-screen
description: Create the Screen / View that binds to the StateHolder and renders state.
user-invocable: false
knowledge_scope: engineering/presentation
---

Create a Screen following `lib/core/knowledge/{platform}/engineering/presentation/screen_structure.md`.

## Steps

1. **Read** `.claude/runs/<feature>/stateholder-contract.md` completely — must match state fields and events exactly
2. **Read** `lib/core/knowledge/{platform}/engineering/presentation/screen_structure.md` for the canonical pattern and file path convention. Check `lib/core/knowledge/{project}/engineering/presentation/screen_structure.md` first (project-specific override), fall back to `lib/core/knowledge/{platform}/engineering/presentation/screen_structure.md` (platform-base).
3. **Locate** path per the impl doc's screen directory convention
4. **Create** the screen file following the impl doc pattern
5. **Register** route/navigation entry if required by the platform (see impl doc)

## Rules

- Screen is state-management-aware only as a consumer — it reads state and dispatches events; it never contains business logic
- Navigation side effects belong in the listener/observer pattern (see impl doc), not inline in render methods
- All state fields and event types must match the stateholder-contract exactly

## Output

Confirm file path, list all handled state cases, list all dispatched events, and confirm route registration if applicable.
