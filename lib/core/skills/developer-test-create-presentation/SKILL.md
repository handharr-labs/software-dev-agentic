---
name: developer-test-create-presentation
description: Create unit tests for the StateHolder (BLoC / ViewModel / Presenter).
user-invocable: false
---

Create presentation tests following `.claude/reference/code-architecture/testing-impl.md ## Presenter Tests`.

## Steps

1. **Read** `.claude/reference/code-architecture/testing-impl.md` — locate `## Presenter Tests` for the canonical pattern
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
