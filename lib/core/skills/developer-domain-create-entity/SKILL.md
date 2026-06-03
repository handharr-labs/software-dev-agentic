---
name: developer-domain-create-entity
description: Create a domain entity class.
user-invocable: false
knowledge_scope: engineering
---

Create a domain Entity following `lib/core/knowledge/{platform}/engineering/domain/entity.md`.

## Steps

1. **Fetch pattern** — `kms_fetch(discipline="engineering", topic="domain", pattern="entity", platform={platform}, project={project})` for the canonical pattern and path convention. **Fallback** if KMS unavailable: `Read lib/core/knowledge/{project}/engineering/domain/entity.md` (project override) → `Read lib/core/knowledge/{platform}/engineering/domain/entity.md` (platform-base).
2. **Identify** the business concept the entity represents
3. **Locate** path per the impl doc's entity directory convention
4. **Create** the entity file following the impl doc pattern

## Rules

- Entity contains only domain fields and business identity — no persistence annotations, no UI types
- Immutable by default — use value equality

## Output

Confirm file path and list all fields.
