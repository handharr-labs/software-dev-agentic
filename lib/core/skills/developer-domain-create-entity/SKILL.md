---
name: developer-domain-create-entity
description: Create a domain entity class.
user-invocable: false
knowledge_scope: engineering/domain
---

Create a domain Entity following `lib/core/knowledge/{platform}/engineering/domain/entity.md`.

## Steps

1. **Read** `lib/core/knowledge/{platform}/engineering/domain/entity.md` for the canonical pattern and path convention. Check `lib/core/knowledge/{project}/engineering/domain/entity.md` first (project-specific override), fall back to `lib/core/knowledge/{platform}/engineering/domain/entity.md` (platform-base).
2. **Identify** the business concept the entity represents
3. **Locate** path per the impl doc's entity directory convention
4. **Create** the entity file following the impl doc pattern

## Rules

- Entity contains only domain fields and business identity — no persistence annotations, no UI types
- Immutable by default — use value equality

## Output

Confirm file path and list all fields.
