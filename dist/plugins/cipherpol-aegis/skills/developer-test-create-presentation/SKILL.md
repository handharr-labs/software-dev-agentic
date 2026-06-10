---
name: developer-test-create-presentation
description: Create unit tests for the StateHolder (BLoC / ViewModel / Presenter).
user-invocable: false
knowledge_scope: engineering
---

Create presentation tests following the {platform} standard architecture in `kms/knowledge-sources/engineering/{platform}-standard-architecture.md`.

## Steps

1. **Fetch pattern** — `kms_query(text="testing presentation bloc cubit test naming convention code pattern", platform={platform}, discipline="engineering", n_results=3)` for the canonical pattern and path convention. **Fallback** if no results: Read `kms/knowledge-sources/engineering/{platform}-standard-architecture.md` and locate the relevant section.
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
