---
name: developer-test-create-domain
description: Create unit tests for domain use cases and services.
user-invocable: false
---

Create domain tests following `.claude/reference/code-architecture/testing-impl.md ## Use Case Tests`.

## Steps

1. **Read** `.claude/reference/code-architecture/testing-impl.md` — locate `## Use Case Tests` (and `## Service Tests` if applicable) for the canonical pattern
2. **Read** the use case / service implementation completely
3. **Identify** all code paths and edge cases to cover
4. **Locate** path per the impl doc's test directory convention
5. **Create** the test file following the impl doc pattern

## Rules

- Use mocks for all dependencies — never hit real repositories or APIs in unit tests
- Test each handler/method independently
- Cover success, error, and edge cases

## Output

Confirm file path and list all test cases by name.
