---
name: developer-domain-create-usecase
description: Create a domain use case.
user-invocable: false
knowledge_scope: engineering/domain
---

Create a Use Case following `lib/core/knowledge/{platform}/engineering/domain/use_case.md`.

## Steps

1. **Read** `lib/core/knowledge/{platform}/engineering/domain/use_case.md` for the canonical pattern and path convention. Check `lib/core/knowledge/{project}/engineering/domain/use_case.md` first (project-specific override), fall back to `lib/core/knowledge/{platform}/engineering/domain/use_case.md` (platform-base).
2. **Identify** the single business operation this use case performs
3. **Locate** path per the impl doc's use case directory convention
4. **Create** the use case file following the impl doc pattern

## Rules

- One use case per business operation — no multi-responsibility use cases
- Depends only on repository interfaces — never on concrete implementations
- Returns domain entities or errors — no DTOs, no UI types

## Output

Confirm file path, use case name, input params type, and return type.
