---
name: developer-domain-create-entity
description: Create a domain entity class.
user-invocable: false
knowledge_scope: engineering
---

Create a domain Entity following the {platform} standard architecture in `kms/knowledge-sources/engineering/{platform}-standard-architecture.md`.

## Steps

1. **Fetch pattern** — `kms_query(text="domain entity naming convention code pattern", platform={platform}, discipline="engineering", n_results=3)` for the canonical pattern and path convention. **Fallback** if no results: Read `kms/knowledge-sources/engineering/{platform}-standard-architecture.md` and locate the relevant section.
2. **Identify** the business concept the entity represents
3. **Locate** path per the impl doc's entity directory convention
4. **Create** the entity file following the impl doc pattern

## Rules

- Entity contains only domain fields and business identity — no persistence annotations, no UI types
- Immutable by default — use value equality

## Output

Confirm file path and list all fields.
