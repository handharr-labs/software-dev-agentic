---
name: developer-test-create-presentation
description: Create unit tests for the StateHolder (BLoC / ViewModel / Presenter).
user-invocable: false
knowledge_scope: engineering
---

Create presentation tests following `lib/core/knowledge/{platform}/engineering/testing/presenter_test.md`.

## Steps

1. **Fetch pattern** — `kms_fetch(discipline="engineering", topic="testing", pattern="presenter_test", platform={platform}, project={project})` for the canonical pattern and path convention. **Fallback** if KMS unavailable: `Read lib/core/knowledge/{project}/engineering/testing/presenter_test.md` (project override) → `Read lib/core/knowledge/{platform}/engineering/testing/presenter_test.md` (platform-base).
2. **Read** the StateHolder implementation and stateholder-contract.md completely
3. **Identify** all events/methods and resulting state transitions to cover
4. **Locate** path per the impl doc's test directory convention
5. **Create** the test file following the impl doc pattern

## Rules

- Mock all use cases — StateHolder tests are pure unit tests
- Test each event/method independently: verify state transitions and emitted actions
- Cover success, error, loading, and edge cases

## Output

Confirm file path and list all test cases by name.
