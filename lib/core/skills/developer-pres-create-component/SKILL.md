---
name: developer-pres-create-component
description: Create a reusable presentational component that takes plain domain entities with no state-management awareness.
user-invocable: false
knowledge_scope: engineering
---

Create a presentational component following the {platform} standard architecture, loaded from the KMS.

## Steps

1. **Load pattern** (fetch-by-topic — see `kms-conventions.md §Retrieval Protocol`):
   - `kms_list(discipline="engineering", artifact="standard-architecture", topic="presentation", platform={platform})` — scan the presentation TOC for the component pattern slug (e.g. `component`).
   - `kms_fetch(discipline="engineering", artifact="standard-architecture", topic="presentation", pattern="<component slug from list>", platform={platform})` — full content: naming, path convention, code pattern.
   - If the TOC has no component pattern, STOP and report a KMS seed gap for `{platform}/engineering/standard-architecture/presentation` — do not guess.
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
