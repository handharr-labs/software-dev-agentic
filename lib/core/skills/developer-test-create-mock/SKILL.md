---
name: developer-test-create-mock
description: Generate mock classes for domain interfaces used in tests.
user-invocable: false
knowledge_scope: engineering
---

Create mocks following `lib/core/knowledge/{platform}/engineering/testing/mock_generation.md`.

## Steps

1. **Fetch pattern** — `kms_fetch(discipline="engineering", topic="testing", pattern="mock_generation", platform={platform}, project={project})` for the canonical pattern and path convention. **Fallback** if KMS unavailable: `Read lib/core/knowledge/{project}/engineering/testing/mock_generation.md` (project override) → `Read lib/core/knowledge/{platform}/engineering/testing/mock_generation.md` (platform-base).
2. **Identify** the interfaces that need mocking (repository, use case, service)
3. **Locate** path per the impl doc's mock directory convention
4. **Create** or generate the mock file(s) following the impl doc pattern

## Rules

- Mocks implement the domain interface — never mock concrete classes
- Follow the platform's mock generation approach (codegen vs manual per impl doc)

## Output

Confirm file path(s) and list all mocked interfaces.
