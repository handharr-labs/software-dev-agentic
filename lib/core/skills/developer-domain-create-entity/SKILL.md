---
name: developer-domain-create-entity
description: Create a domain entity class.
user-invocable: false
---

Create a domain Entity following `.claude/reference/code-architecture/domain-impl.md ## Entities`.

## Steps

1. **Read** `.claude/reference/code-architecture/domain-impl.md` — locate `## Entities` for the canonical pattern and path convention
2. **Identify** the business concept the entity represents
3. **Locate** path per the impl doc's entity directory convention
4. **Create** the entity file following the impl doc pattern

## Rules

- Entity contains only domain fields and business identity — no persistence annotations, no UI types
- Immutable by default — use value equality

## Output

Confirm file path and list all fields.
