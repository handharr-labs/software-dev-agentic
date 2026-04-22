---
name: test-fix
description: Diagnose and fix failing StateHolder or component tests. Never modifies production code — test/mock files only. Called by test-worker.
user-invocable: false
tools: Read, Edit, Glob
---

Fix failing tests following `reference/contract/builder/testing.md`.

## Critical Constraint

**Never modify production StateHolder or component code** to make tests pass. Fix only test files and mock files. If a failure reveals a genuine bug, report it to the user.

## Steps

1. **Get failure output** — ask user to paste `vitest` output if not provided:
   ```bash
   npx vitest run --reporter=verbose 2>&1 | grep -E "(FAIL|Error|Expected|Received)"
   ```
2. **Read** the failing test file and the production file it tests
3. **Diagnose** each failure using the failure types below
4. **Fix** in targeted edits

## Failure Types & Fixes

| Failure | Symptom | Fix |
|---------|---------|-----|
| Mock not returning data | query stays loading or returns undefined | Set up `mockResolvedValue` / `mockReturnValue` on the mock use case |
| Wrong query key | cache not invalidated after mutation | Align `queryKey` array in the test's `queryClient` setup |
| Missing `await` / `act` | state not updated after async action | Wrap trigger in `await act(async () => {...})` |
| Stale mock import | mock returns old shape | Update mock to match current entity/DTO shape |
| Component not finding element | `getByRole` / `getByText` throws | Check rendered output with `screen.debug()`, update selector |

## Two-Phase Compilation Fix

**Phase A — Isolate type errors:**
Comment out failing tests one by one until the file compiles cleanly.

**Phase B — Fix each commented-out test:**
- Missing mock method → add to mock
- Wrong type → update call site in test
- Removed field → update assertion

## Output

List each fixed test with the failure type, root cause, and fix applied. Flag any failures that indicate real production bugs.
