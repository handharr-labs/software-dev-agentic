---
name: developer-test-create-data
description: Create unit tests for repository implementations and mappers.
user-invocable: false
---

Create data layer tests following `.claude/reference/code-architecture/testing-impl.md ## Repository Tests` and `## Mapper Tests`.

## Steps

1. **Read** `.claude/reference/code-architecture/testing-impl.md` — locate `## Repository Tests` and `## Mapper Tests` for the canonical pattern
2. **Read** the repository impl and mapper implementations completely
3. **Identify** all code paths: data source success, data source error, mapping edge cases
4. **Locate** path per the impl doc's test directory convention
5. **Create** test file(s) following the impl doc pattern

## Rules

- Mock the data source — never make real network calls in unit tests
- Mapper tests use static fixtures — no mocks needed
- Verify DTO → entity mapping covers all fields

## Output

Confirm file path(s) and list all test cases by name.
