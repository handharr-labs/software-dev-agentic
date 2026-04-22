---
name: test-update
description: Update existing Flutter tests — add new test cases for new events/methods, update fixtures, extend mock declarations.
user-invocable: false
---

Update existing tests following `.claude/reference/contract/builder/testing.md`.

## Steps

1. **Read** the test file being updated
2. **Read** the updated implementation (BLoC, UseCase, Repository) to identify what's new
3. **Update** `test/helpers/mocks/[feature]_mocks.dart` if new interfaces need mocking
4. **Update** `test/helpers/fixtures/[feature]_fixtures.dart` if new entities/models are needed
5. **Add** new test cases — one `group()` per new event or method; success + failure each

Rules:
- Extend `group()` blocks — don't scatter new tests at the file root
- New `blocTest` cases go inside the relevant event's `group()`
- Never delete existing tests unless the thing they test was explicitly removed
- After updating mocks, regenerate: `dart run build_runner build --delete-conflicting-outputs`

## Output

Confirm test file path, what new cases were added (grouped by event/method), and any fixture/mock additions.
