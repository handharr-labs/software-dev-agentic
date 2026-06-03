---
name: developer-test-create-domain
description: Create unit tests for domain use cases and services.
user-invocable: false
knowledge_scope: engineering
---

Create domain tests following `lib/core/knowledge/{platform}/engineering/testing/use_case_test.md`.

## Steps

1. **Fetch pattern** — `kms_fetch(discipline="engineering", topic="testing", pattern="use_case_test", platform={platform}, project={project})` for the canonical pattern and path convention. **Fallback** if KMS unavailable: `Read lib/core/knowledge/{project}/engineering/testing/use_case_test.md` (project override) → `Read lib/core/knowledge/{platform}/engineering/testing/use_case_test.md` (platform-base).
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
