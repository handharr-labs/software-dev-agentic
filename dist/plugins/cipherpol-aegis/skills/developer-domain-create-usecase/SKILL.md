---
name: developer-domain-create-usecase
description: Create a domain use case.
user-invocable: false
knowledge_scope: engineering
---

Create a Use Case following the {platform} standard architecture in `kms/knowledge-sources/engineering/{platform}-standard-architecture.md`.

## Steps

1. **Fetch pattern** — `kms_query(text="domain use case naming convention code pattern", platform={platform}, discipline="engineering", n_results=3)` for the canonical pattern and path convention. **Fallback** if no results: Read `kms/knowledge-sources/engineering/{platform}-standard-architecture.md` and locate the relevant section.
2. **Identify** the single business operation this use case performs
3. **Locate** path per the impl doc's use case directory convention
4. **Create** the use case file following the impl doc pattern

## Rules

- One use case per business operation — no multi-responsibility use cases
- Depends only on repository interfaces — never on concrete implementations
- Returns domain entities or errors — no DTOs, no UI types

## Output

Confirm file path, use case name, input params type, and return type.
