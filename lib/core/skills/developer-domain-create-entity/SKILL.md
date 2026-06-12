---
name: developer-domain-create-entity
description: Create a domain entity class.
user-invocable: false
knowledge_scope: engineering
---

Create a domain Entity following the {platform} standard architecture, loaded from the KMS.

## Steps

1. **Load pattern** (fetch-by-topic — see `kms-conventions.md §Retrieval Protocol`):
   - `kms_list(discipline="engineering", artifact="standard-architecture", topic="domain", platform={platform})` — scan the domain TOC for the entity pattern slug (e.g. `entity`).
   - `kms_fetch(discipline="engineering", artifact="standard-architecture", topic="domain", pattern="<entity slug from list>", platform={platform})` — full content: naming, path convention, code pattern.
   - If the TOC has no entity pattern, STOP and report a KMS seed gap for `{platform}/engineering/standard-architecture/domain` — do not guess.
2. **Identify** the business concept the entity represents
3. **Locate** path per the impl doc's entity directory convention
4. **Create** the entity file following the impl doc pattern

## Rules

- Entity contains only domain fields and business identity — no persistence annotations, no UI types
- Immutable by default — use value equality

## Output

Confirm file path and list all fields.
