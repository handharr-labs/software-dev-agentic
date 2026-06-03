---
name: developer-domain-create-service
description: Create a domain service for business logic that spans multiple entities or use cases.
user-invocable: false
knowledge_scope: engineering
---

Create a Domain Service following `lib/core/knowledge/{platform}/engineering/domain/domain_service.md`.

## Steps

1. **Fetch pattern** — `kms_fetch(discipline="engineering", topic="domain", pattern="domain_service", platform={platform}, project={project})` for the canonical pattern and path convention. **Fallback** if KMS unavailable: `Read lib/core/knowledge/{project}/engineering/domain/domain_service.md` (project override) → `Read lib/core/knowledge/{platform}/engineering/domain/domain_service.md` (platform-base).
2. **Confirm** this logic cannot live in a single entity or use case before creating a service
3. **Locate** path per the impl doc's service directory convention
4. **Create** the service file following the impl doc pattern

## Rules

- Domain service contains pure business logic — no infrastructure dependencies
- Stateless — no mutable fields
- Depends only on domain types — entities, value objects, domain errors

## Output

Confirm file path and list all public methods with signatures.
