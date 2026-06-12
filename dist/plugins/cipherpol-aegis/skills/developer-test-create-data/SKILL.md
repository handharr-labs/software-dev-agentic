---
name: developer-test-create-data
description: Create unit tests for repository implementations and mappers.
user-invocable: false
knowledge_scope: engineering
---

Create data layer tests following the {platform} standard architecture, loaded from the KMS.

## Steps

1. **Load pattern** (fetch-by-topic — see `kms-conventions.md §Retrieval Protocol`):
   - `kms_list(discipline="engineering", artifact="standard-architecture", topic="testing", platform={platform})` — scan the testing TOC for the repository-test pattern slug (e.g. `repository_test`).
   - `kms_fetch(discipline="engineering", artifact="standard-architecture", topic="testing", pattern="<repository-test slug from list>", platform={platform})` — full content: naming, path convention, code pattern.
   - If the TOC has no repository-test pattern, STOP and report a KMS seed gap for `{platform}/engineering/standard-architecture` (testing topic) — do not guess.
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
