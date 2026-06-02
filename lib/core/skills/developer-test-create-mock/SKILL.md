---
name: developer-test-create-mock
description: Generate mock classes for domain interfaces used in tests.
user-invocable: false
---

Create mocks following `.claude/reference/code-architecture/testing-impl.md ## Mock Generation`.

## Steps

1. **Read** `.claude/reference/code-architecture/testing-impl.md` — locate `## Mock Generation` for the canonical mock pattern and generation approach
2. **Identify** the interfaces that need mocking (repository, use case, service)
3. **Locate** path per the impl doc's mock directory convention
4. **Create** or generate the mock file(s) following the impl doc pattern

## Rules

- Mocks implement the domain interface — never mock concrete classes
- Follow the platform's mock generation approach (codegen vs manual per impl doc)

## Output

Confirm file path(s) and list all mocked interfaces.
