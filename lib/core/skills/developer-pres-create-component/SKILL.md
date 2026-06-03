---
name: developer-pres-create-component
description: Create a reusable presentational component that takes plain domain entities with no state-management awareness.
user-invocable: false
knowledge_scope: engineering/presentation
---

Create a presentational component following `lib/core/knowledge/{platform}/engineering/presentation/component.md`.

## Steps

1. **Read** `lib/core/knowledge/{platform}/engineering/presentation/component.md` for the canonical pattern and path convention. Check `lib/core/knowledge/{project}/engineering/presentation/component.md` first (project-specific override), fall back to `lib/core/knowledge/{platform}/engineering/presentation/component.md` (platform-base).
2. **Check** `## Shared Component Paths` for existing reusable components before creating a new one
3. **Identify** the entity or data type the component displays
4. **Locate** the path per the impl doc's component directory convention
5. **Create** the component file following the impl doc pattern

## Rules

- Component is state-management-unaware — receives only plain entity data via constructor/props
- No state manager bindings inside a component
- Use immutable/const constructor — all fields final/readonly

## Output

Confirm file path and list all constructor parameters / props.
