---
name: developer-domain-create-service
description: Create a domain service for business logic that spans multiple entities or use cases.
user-invocable: false
knowledge_scope: engineering
---

Create a Domain Service following the {platform} standard architecture, loaded from the KMS.

## Steps

1. **Load pattern** (fetch-by-topic — see `kms-conventions.md §Retrieval Protocol`):
   - `kms_list(discipline="engineering", artifact="standard-architecture", topic="domain", platform={platform})` — scan the domain TOC for the domain-service pattern slug (e.g. `domain_service`).
   - `kms_fetch(discipline="engineering", artifact="standard-architecture", topic="domain", pattern="<domain-service slug from list>", platform={platform})` — full content: naming, path convention, code pattern.
   - If the TOC has no domain-service pattern, STOP and report a KMS seed gap for `{platform}/engineering/standard-architecture/domain` — do not guess.
2. **Confirm** this logic cannot live in a single entity or use case before creating a service
3. **Locate** path per the impl doc's service directory convention
4. **Create** the service file following the impl doc pattern

## Rules

- Domain service contains pure business logic — no infrastructure dependencies
- Stateless — no mutable fields
- Depends only on domain types — entities, value objects, domain errors

## Output

Confirm file path and list all public methods with signatures.
