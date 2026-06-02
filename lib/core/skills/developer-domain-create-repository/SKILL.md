---
name: developer-domain-create-repository
description: Create a domain repository interface.
user-invocable: false
---

Create a Repository interface following `.claude/reference/code-architecture/domain-impl.md ## Repository Interfaces`.

## Steps

1. **Read** `.claude/reference/code-architecture/domain-impl.md` — locate `## Repository Interfaces` for the canonical pattern and path convention
2. **Identify** the data operations the feature needs
3. **Locate** path per the impl doc's repository interface convention
4. **Create** the interface file following the impl doc pattern

## Rules

- Interface lives in the domain layer — no data layer imports
- Methods return domain entities or primitives — no DTOs, no DB types
- Error handling follows the platform's domain error pattern (see impl doc)

## Output

Confirm file path and list all interface methods with return types.
