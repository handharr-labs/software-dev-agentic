---
name: developer-domain-create-usecase
description: Create a domain use case.
user-invocable: false
---

Create a Use Case following `.claude/reference/code-architecture/domain-impl.md ## Use Cases`.

## Steps

1. **Read** `.claude/reference/code-architecture/domain-impl.md` — locate `## Use Cases` for the canonical pattern and path convention
2. **Identify** the single business operation this use case performs
3. **Locate** path per the impl doc's use case directory convention
4. **Create** the use case file following the impl doc pattern

## Rules

- One use case per business operation — no multi-responsibility use cases
- Depends only on repository interfaces — never on concrete implementations
- Returns domain entities or errors — no DTOs, no UI types

## Output

Confirm file path, use case name, input params type, and return type.
