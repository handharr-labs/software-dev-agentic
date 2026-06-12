---
name: developer-test-create-domain
description: Create unit tests for domain use cases and services.
user-invocable: false
knowledge_scope: engineering
---

Create domain tests following the {platform} standard architecture, loaded from the KMS.

## Steps

1. **Load pattern** (fetch-by-topic — see `kms-conventions.md §Retrieval Protocol`):
   - `kms_list(discipline="engineering", artifact="standard-architecture", topic="testing", platform={platform})` — scan the testing TOC for the use-case-test pattern slug (e.g. `use_case_test`).
   - `kms_fetch(discipline="engineering", artifact="standard-architecture", topic="testing", pattern="<use-case-test slug from list>", platform={platform})` — full content: naming, path convention, code pattern.
   - If the TOC has no use-case-test pattern, STOP and report a KMS seed gap for `{platform}/engineering/standard-architecture` (testing topic) — do not guess.
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
