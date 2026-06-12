---
name: developer-domain-create-usecase
description: Create a domain use case.
user-invocable: false
knowledge_scope: engineering
---

Create a Use Case following the {platform} standard architecture, loaded from the KMS.

## Steps

1. **Load pattern** (fetch-by-topic — see `kms-conventions.md §Retrieval Protocol`):
   - `kms_list(discipline="engineering", artifact="standard-architecture", topic="domain", platform={platform})` — scan the domain TOC for the use-case pattern slug (e.g. `use_case`).
   - `kms_fetch(discipline="engineering", artifact="standard-architecture", topic="domain", pattern="<use-case slug from list>", platform={platform})` — full content: naming, path convention, code pattern.
   - If the TOC has no use-case pattern, STOP and report a KMS seed gap for `{platform}/engineering/standard-architecture/domain` — do not guess.
2. **Identify** the single business operation this use case performs
3. **Locate** path per the fetched doc's use case directory convention
4. **Create** the use case file following the fetched pattern

## Rules

- One use case per business operation — no multi-responsibility use cases
- Depends only on repository interfaces — never on concrete implementations
- Returns domain entities or errors — no DTOs, no UI types

## Output

Confirm file path, use case name, input params type, and return type.
