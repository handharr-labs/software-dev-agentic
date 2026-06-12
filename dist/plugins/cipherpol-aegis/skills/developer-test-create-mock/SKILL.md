---
name: developer-test-create-mock
description: Generate mock classes for domain interfaces used in tests.
user-invocable: false
knowledge_scope: engineering
---

Create mocks following the {platform} standard architecture, loaded from the KMS.

## Steps

1. **Load pattern** (fetch-by-topic — see `kms-conventions.md §Retrieval Protocol`):
   - `kms_list(discipline="engineering", artifact="standard-architecture", topic="testing", platform={platform})` — scan the testing TOC for the mock-generation pattern slug (e.g. `mock_generation`).
   - `kms_fetch(discipline="engineering", artifact="standard-architecture", topic="testing", pattern="<mock-generation slug from list>", platform={platform})` — full content: naming, path convention, codegen vs manual approach.
   - If the TOC has no mock-generation pattern, STOP and report a KMS seed gap for `{platform}/engineering/standard-architecture` (testing topic) — do not guess.
2. **Identify** the interfaces that need mocking (repository, use case, service)
3. **Locate** path per the impl doc's mock directory convention
4. **Create** or generate the mock file(s) following the impl doc pattern

## Rules

- Mocks implement the domain interface — never mock concrete classes
- Follow the platform's mock generation approach (codegen vs manual per impl doc)

## Output

Confirm file path(s) and list all mocked interfaces.
