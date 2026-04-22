---
name: test-fix
description: Fix failing Flutter tests — diagnose failures, update mocks/stubs, align test expectations with changed implementations.
user-invocable: false
---

Fix failing tests following patterns in `.claude/reference/contract/builder/testing.md`.

## Steps

1. **Read** the failing test file and the implementation it tests
2. **Identify** the failure type:
   - **Mock stub mismatch** — implementation signature changed, stub needs updating
   - **State expectation mismatch** — BLoC emits different states than expected
   - **Generated mocks stale** — run `dart run build_runner build --delete-conflicting-outputs`
   - **Missing mock spec** — new dependency not added to `@GenerateNiceMocks`
   - **Fixture out of date** — entity/model structure changed
3. **Fix** in the correct file — never weaken assertions to make tests pass

## Common Fixes

**Stale generated mocks:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

**Missing MockSpec:**
- Open `test/helpers/mocks/[feature]_mocks.dart`
- Add `MockSpec<NewDependency>()` to `@GenerateNiceMocks`
- Regenerate

**Stub signature changed:**
- Update `when(mock.newMethod(any))...` to match new signature
- Update `verify(mock.newMethod(...))` if params changed

**blocTest expect mismatch:**
- Read the BLoC handler — trace exactly which states are emitted
- Update `expect:` list to match actual emission order

Rules:
- Never suppress an assertion — find the root cause
- Never change the code under test to pass the test — fix the test or the code, not both
- Prefer `predicate<State>()` over exact state comparison when only shape matters

## Output

Confirm which test file was fixed, what the root cause was, and what changed.
