---
name: developer-domain-create-repository
description: Create a domain repository interface.
user-invocable: false
knowledge_scope: engineering
---

Create a Repository interface following the {platform} standard architecture, loaded from the KMS.

## Steps

1. **Load pattern** (fetch-by-topic — see `kms-conventions.md §Retrieval Protocol`):
   - `kms_list(discipline="engineering", artifact="standard-architecture", topic="domain", platform={platform})` — scan the domain TOC for the repository-interface pattern slug (e.g. `repository_interface`).
   - `kms_fetch(discipline="engineering", artifact="standard-architecture", topic="domain", pattern="<repository-interface slug from list>", platform={platform})` — full content: naming, path convention, code pattern.
   - If the TOC has no repository-interface pattern, STOP and report a KMS seed gap for `{platform}/engineering/standard-architecture/domain` — do not guess.
2. **Identify** the data operations the feature needs
3. **Locate** path per the impl doc's repository interface convention
4. **Create** the interface file following the impl doc pattern

## Rules

- Interface lives in the domain layer — no data layer imports
- Methods return domain entities or primitives — no DTOs, no DB types
- Error handling follows the platform's domain error pattern (see impl doc)

## Output

Confirm file path and list all interface methods with return types.
