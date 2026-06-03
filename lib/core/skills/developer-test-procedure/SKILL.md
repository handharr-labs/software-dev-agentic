---
name: developer-test-procedure
description: Four-step unit test creation procedure — create or extend a test file, determine if mocks are needed, generate missing mocks using the platform-specific procedure, then verify correctness of all test cases.
user-invocable: false
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

## Inputs

Required — caller must supply all three:

| Parameter | Description |
|---|---|
| `target` | Absolute path to the source artifact under test |
| `platform` | `ios-talenta` / `android-talenta` / `flutter-mobile-talenta` / `flutter-qontak-crm` / `flutter-qontak-chat` |
| `layer` | `domain` / `data` / `presentation` |

Return `MISSING INPUT: <param>` immediately if any are absent.

## Scope Boundary

Unit tests only. No UI/integration tests. No modifications to production source files.

## Platform Reference

Before executing any step, load the platform implementation guide:

```
lib/core/knowledge/{platform}/engineering/testing/procedure.md
```

Grep `^## ` to list all headings. Read only the sections relevant to the current step — do not read the full file upfront.

All variable details (file naming, mock location, mock generation command, test runner) come from this file. The steps below are the fixed procedure; the platform file fills in the variables.

---

## Step 1 — Resolve Test File

1. Derive the test file path from `target` using the naming convention in the platform reference (`## Test File Naming`).
2. `Glob` for the test file path.
   - **Not found** → create the test file with the correct scaffold (class declaration, imports, `setUp`/`tearDown` or equivalent).
   - **Found** → open and read the existing test file — add the new test cases without removing existing ones.

## Step 2 — Determine Mock Need

Inspect `target` via `Grep` for its direct dependencies (constructor params, injected interfaces).

Consult the layer-to-mock table from `developer-test-worker`:

| Layer | Mock needed |
|---|---|
| Domain entity / service | None — pure data or pure functions |
| Use case | Repository interface |
| Mapper | None — pure transformation |
| DataSource impl | Network/DB client |
| Repository impl | DataSource + Mapper |
| StateHolder / BLoC / ViewModel | Use case interfaces |

If no mocks are needed, skip to Step 4.

## Step 3 — Resolve Mocks

For each required mock:

1. Derive the expected mock path using `## Mock Location` from the platform reference.
2. `Glob` for the mock file.
   - **Found** → reuse. Note the path for Step 4.
   - **Not found** → create or generate the mock:
     - Read `## Mock Strategy` and `## Mock Generation` from the platform reference.
     - If the platform uses code generation (e.g., `build_runner`, `MockGen.sh`): add the mock spec annotation to the appropriate helper file, then run the generation command via `Bash`.
     - If the platform uses manual mocks: write the mock class file following the platform's mock pattern.

## Step 4 — Verify Test Cases

1. Re-read the test file (or read it for the first time if just created).
2. For each test case, verify:
   - Follows Arrange-Act-Assert structure.
   - Covers the happy path.
   - Covers all error paths and relevant edge cases (one branch = one test).
   - Mock setup matches the expected call count for the execution path.
   - Assertions target the correct output field or state.
3. Fix any incorrect test cases inline via `Edit`.
4. Run the test suite using the command from `## Test Runner` in the platform reference.
5. If tests fail, diagnose using the platform reference's failure patterns and fix — repeat until green.

## Output

```
## Output
- <path/to/test/file>
- <path/to/mock/file-if-created>
```
