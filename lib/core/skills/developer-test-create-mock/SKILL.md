---
name: developer-test-create-mock
description: Generate mock classes for domain interfaces used in tests.
user-invocable: false
knowledge_scope: engineering/testing
---

Create mocks following `lib/core/knowledge/{platform}/engineering/testing/mock_generation.md`.

## Steps

1. **Read** `lib/core/knowledge/{platform}/engineering/testing/mock_generation.md` for the canonical mock pattern and generation approach. Check `lib/core/knowledge/{project}/engineering/testing/mock_generation.md` first (project-specific override), fall back to `lib/core/knowledge/{platform}/engineering/testing/mock_generation.md` (platform-base).
2. **Identify** the interfaces that need mocking (repository, use case, service)
3. **Locate** path per the impl doc's mock directory convention
4. **Create** or generate the mock file(s) following the impl doc pattern

## Rules

- Mocks implement the domain interface — never mock concrete classes
- Follow the platform's mock generation approach (codegen vs manual per impl doc)

## Output

Confirm file path(s) and list all mocked interfaces.
