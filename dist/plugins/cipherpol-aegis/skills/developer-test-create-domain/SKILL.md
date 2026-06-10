---
name: developer-test-create-domain
description: Create unit tests for domain use cases and services.
user-invocable: false
knowledge_scope: engineering
---

Create domain tests following the {platform} standard architecture in `kms/knowledge-sources/engineering/{platform}-standard-architecture.md`.

## Steps

1. **Fetch pattern** — `kms_query(text="testing use case test naming convention code pattern", platform={platform}, discipline="engineering", n_results=3)` for the canonical pattern and path convention. **Fallback** if no results: Read `kms/knowledge-sources/engineering/{platform}-standard-architecture.md` and locate the relevant section.
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
