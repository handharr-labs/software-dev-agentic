---
name: developer-domain-create-repository
description: Create a domain repository interface.
user-invocable: false
knowledge_scope: engineering
---

Create a Repository interface following `lib/core/knowledge/{platform}/engineering/domain/repository_interface.md`.

## Steps

1. **Fetch pattern** — `kms_fetch(discipline="engineering", topic="domain", pattern="repository_interface", platform={platform}, project={project})` for the canonical pattern and path convention. **Fallback** if KMS unavailable: `Read lib/core/knowledge/{project}/engineering/domain/repository_interface.md` (project override) → `Read lib/core/knowledge/{platform}/engineering/domain/repository_interface.md` (platform-base).
2. **Identify** the data operations the feature needs
3. **Locate** path per the impl doc's repository interface convention
4. **Create** the interface file following the impl doc pattern

## Rules

- Interface lives in the domain layer — no data layer imports
- Methods return domain entities or primitives — no DTOs, no DB types
- Error handling follows the platform's domain error pattern (see impl doc)

## Output

Confirm file path and list all interface methods with return types.
