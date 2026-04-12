---
name: test-update
description: |
  Update existing StateHolder tests after StateHolder *(iOS: ViewModel)* code changes — add missing tests, remove obsolete ones, update changed logic.
user-invocable: false
---

Update existing tests following patterns in `.claude/reference/testing-patterns-advanced.md`.

## Steps

1. **Grep** `.claude/reference/testing-patterns-advanced.md` for the relevant pattern keyword; only **Read** the full file if the section cannot be located
2. **Read** the updated ViewModel completely
3. **Read** the existing test file completely
4. **Generate analysis report** comparing ViewModel vs tests
5. **Execute updates** in priority order

## Analysis Report Format

```markdown
# Analysis: [ViewModel] vs [TestFile]

## Executive Summary
- Events in ViewModel: N
- Events covered by tests: M
- Action required: K items

## Event-by-Event
### ✅ [EventName] — Covered
### ⚠️ [EventName] — Partially Covered
  Missing: success path / error path / [branch]
### ❌ [EventName] — Not Covered

## Mock Compliance
- ❌ [MockName]: missing reset()
- ✅ [MockName]: compliant
```

## Execution Priority

1. **Critical**: Fix/create missing mocks (protocol compliance)
2. **Critical**: Remove tests for removed Events/methods
3. **High**: Add tests for new Events/branches
4. **Medium**: Update tests for changed logic
5. **Low**: Rename tests to follow current naming convention

## Test Naming Convention

```
test[EventName]Event_[LogicOrMethodName]_[Condition]_[Outcome]
```

## Rules

- New code → V2 patterns. Existing code → keep its pattern.
- Do not rewrite passing tests — only update what changed
- Use `[safe:]` subscript for mock result arrays
- `[weak self]` in all new closures
- After removing an Event from ViewModel, delete its tests + update mocks

## Output

Show the analysis report, then list all changes made with file paths and line numbers.
