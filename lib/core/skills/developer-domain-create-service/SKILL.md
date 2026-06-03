---
name: developer-domain-create-service
description: Create a domain service for business logic that spans multiple entities or use cases.
user-invocable: false
knowledge_scope: engineering/domain
---

Create a Domain Service following `lib/core/knowledge/{platform}/engineering/domain/domain_service.md`.

## Steps

1. **Read** `lib/core/knowledge/{platform}/engineering/domain/domain_service.md` for the canonical pattern and path convention. Check `lib/core/knowledge/{project}/engineering/domain/domain_service.md` first (project-specific override), fall back to `lib/core/knowledge/{platform}/engineering/domain/domain_service.md` (platform-base).
2. **Confirm** this logic cannot live in a single entity or use case before creating a service
3. **Locate** path per the impl doc's service directory convention
4. **Create** the service file following the impl doc pattern

## Rules

- Domain service contains pure business logic — no infrastructure dependencies
- Stateless — no mutable fields
- Depends only on domain types — entities, value objects, domain errors

## Output

Confirm file path and list all public methods with signatures.
