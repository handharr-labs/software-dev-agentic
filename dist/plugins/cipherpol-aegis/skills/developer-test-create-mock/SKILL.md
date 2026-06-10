---
name: developer-test-create-mock
description: Generate mock classes for domain interfaces used in tests.
user-invocable: false
knowledge_scope: engineering
---

Create mocks following the {platform} standard architecture in `kms/knowledge-sources/engineering/{platform}-standard-architecture.md`.

## Steps

1. **Fetch pattern** — `kms_query(text="testing mock generation naming convention code pattern", platform={platform}, discipline="engineering", n_results=3)` for the canonical pattern and path convention. **Fallback** if no results: Read `kms/knowledge-sources/engineering/{platform}-standard-architecture.md` and locate the relevant section.
2. **Identify** the interfaces that need mocking (repository, use case, service)
3. **Locate** path per the impl doc's mock directory convention
4. **Create** or generate the mock file(s) following the impl doc pattern

## Rules

- Mocks implement the domain interface — never mock concrete classes
- Follow the platform's mock generation approach (codegen vs manual per impl doc)

## Output

Confirm file path(s) and list all mocked interfaces.
