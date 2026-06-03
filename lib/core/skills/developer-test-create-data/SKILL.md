---
name: developer-test-create-data
description: Create unit tests for repository implementations and mappers.
user-invocable: false
knowledge_scope: engineering/testing
---

Create data layer tests following `lib/core/knowledge/{platform}/engineering/testing/repository_test.md`.

## Steps

1. **Read** `lib/core/knowledge/{platform}/engineering/testing/repository_test.md` for the canonical pattern. Check `lib/core/knowledge/{project}/engineering/testing/repository_test.md` first (project-specific override), fall back to `lib/core/knowledge/{platform}/engineering/testing/repository_test.md` (platform-base).
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
