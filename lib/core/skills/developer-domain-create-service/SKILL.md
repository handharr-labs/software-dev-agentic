---
name: developer-domain-create-service
description: Create a domain service for business logic that spans multiple entities or use cases.
user-invocable: false
---

Create a Domain Service following `.claude/reference/code-architecture/domain-impl.md ## Domain Services`.

## Steps

1. **Read** `.claude/reference/code-architecture/domain-impl.md` — locate `## Domain Services` for the canonical pattern and path convention
2. **Confirm** this logic cannot live in a single entity or use case before creating a service
3. **Locate** path per the impl doc's service directory convention
4. **Create** the service file following the impl doc pattern

## Rules

- Domain service contains pure business logic — no infrastructure dependencies
- Stateless — no mutable fields
- Depends only on domain types — entities, value objects, domain errors

## Output

Confirm file path and list all public methods with signatures.
