---
name: developer-test-create-data
description: Create unit tests for repository implementations and mappers.
user-invocable: false
knowledge_scope: engineering
---

Create data layer tests following the {platform} standard architecture in `kms/knowledge-sources/engineering/{platform}-standard-architecture.md`.

## Steps

1. **Fetch pattern** — `kms_query(text="testing repository test naming convention code pattern", platform={platform}, discipline="engineering", n_results=3)` for the canonical pattern and path convention. **Fallback** if no results: Read `kms/knowledge-sources/engineering/{platform}-standard-architecture.md` and locate the relevant section.
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
