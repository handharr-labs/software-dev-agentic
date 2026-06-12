---
name: developer-test-create-presentation
description: Create unit tests for the StateHolder (BLoC / ViewModel / Presenter).
user-invocable: false
knowledge_scope: engineering
---

Create presentation tests following the {platform} standard architecture, loaded from the KMS.

## Steps

1. **Load pattern** (fetch-by-topic — see `kms-conventions.md §Retrieval Protocol`):
   - `kms_list(discipline="engineering", artifact="standard-architecture", topic="testing", platform={platform})` — scan the testing TOC for the presenter/stateholder-test pattern slug (e.g. `presenter_test`).
   - `kms_fetch(discipline="engineering", artifact="standard-architecture", topic="testing", pattern="<presenter-test slug from list>", platform={platform})` — full content: naming, path convention, code pattern.
   - If the TOC has no presenter-test pattern, STOP and report a KMS seed gap for `{platform}/engineering/standard-architecture` (testing topic) — do not guess.
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
