---
name: developer-domain-create-service
description: Create a domain service for business logic that spans multiple entities or use cases.
user-invocable: false
knowledge_scope: engineering
---

Create a Domain Service following the {platform} standard architecture in `kms/knowledge-sources/engineering/{platform}-standard-architecture.md`.

## Steps

1. **Fetch pattern** — `kms_query(text="domain service naming convention code pattern", platform={platform}, discipline="engineering", n_results=3)` for the canonical pattern and path convention. **Fallback** if no results: Read `kms/knowledge-sources/engineering/{platform}-standard-architecture.md` and locate the relevant section.
2. **Confirm** this logic cannot live in a single entity or use case before creating a service
3. **Locate** path per the impl doc's service directory convention
4. **Create** the service file following the impl doc pattern

## Rules

- Domain service contains pure business logic — no infrastructure dependencies
- Stateless — no mutable fields
- Depends only on domain types — entities, value objects, domain errors

## Output

Confirm file path and list all public methods with signatures.
