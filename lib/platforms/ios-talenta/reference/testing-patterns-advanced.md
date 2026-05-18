# ViewModel Testing Patterns

Shared patterns for creating, verifying, updating, and fixing ViewModel tests in the Talenta iOS project.

---

## Test Naming Convention <!-- 13 -->

```
test[EventName]Event_[LogicOrMethodName]_[Condition]_[Outcome]
```

Examples:
- `testSubmitButtonTappedEvent_ValidateForm_HasErrors_ShowsErrorAlert`
- `testLoadDataEvent_FetchUser_NetworkError_ShowsErrorToast`
- `testRefreshEvent_LoadSchedules_Success_UpdatesState`

---

## Mock Result Array Pattern <!-- 22 -->

Mocks return sequential results via array access using the `[safe:]` subscript:

```swift
// Mock stores results
var mockResult: [Result<Model, BaseErrorModel>] = []
var callCount = 0

func call(params: Params, completion: @escaping Completion) {
    callCount += 1
    completion(mockResult[safe: callCount - 1] ?? .failure(.unknown))
}
```

**Count ALL calls in the execution path** — if the same mock is called 3 times in a flow, supply 3 results:
```swift
mockUseCase.mockResult = [.success(data), .success(data), .success(data)]
```

---

## Navigator Mock Pattern <!-- 20 -->

Navigator mocks return `Observable` or `Driver` that the ViewModel subscribes to:

```swift
// Default: returns empty (no result emitted)
var openCICOCameraResult: Observable<CICOCameraResult> = .empty()

func openCICOCamera() -> Observable<CICOCameraResult> {
    return openCICOCameraResult
}
```

Set up before emitting the event:
```swift
navigatorMock.openCICOCameraResult = .just(CICOCameraResult(navigationType: .goToHome))
```

---

## `createViewModel` Init Mapping <!-- 27 -->

Use a helper that accepts optional overrides (matching ViewModel init param names):

```swift
@discardableResult
func createViewModel(
    displayMode: DisplayMode = .default,
    type: CICOType = .clockIn
) -> FeatureViewModel {
    viewModel = FeatureViewModel(
        displayMode: displayMode,
        type: type,
        useCase: useCaseMock,
        navigator: navigatorMock
    )
    return viewModel
}
```

Pass params to direct the branch under test:
```swift
createViewModel(displayMode: .actionWithForm, type: .clockIn)
```

---

## State Access Chain <!-- 24 -->

```swift
// Capture state emissions
var capturedStates: [State] = []
viewModel.stateDriver
    .drive(onNext: { capturedStates.append($0) })
    .disposed(by: disposeBag)

// Assert on last state
XCTAssertEqual(capturedStates.last?.dataState.data?.property, expectedValue)
XCTAssertTrue(capturedStates.last?.isLoading == false)
```

Also capture actions and commonActions:
```swift
var capturedActions: [Action] = []
viewModel.actionDriver
    .drive(onNext: { capturedActions.append($0) })
    .disposed(by: disposeBag)
```

---

## 5-Point Test Creation Process <!-- 38 -->

1. **Define execution path** — trace from event through private methods to terminal action
2. **Write test method** — Given/When/Then structure, follow naming convention
3. **Create ViewModel** — use `createViewModel()` helper with branch-directing params
4. **Set up mocks** — count all calls, satisfy all guard conditions in order
5. **Assert** — state fields, action emissions, mock call counts

```swift
func testEventName_Logic_Condition_Outcome() {
    // GIVEN
    let mockData = Entity.createMock()
    useCaseMock.mockResult = [.success(mockData)]
    createViewModel(param: .value)

    var capturedStates: [State] = []
    viewModel.stateDriver
        .drive(onNext: { capturedStates.append($0) })
        .disposed(by: disposeBag)

    // WHEN
    viewModel.emitEvent(.eventName)
    testScheduler.start()

    // THEN
    XCTAssertEqual(useCaseMock.callCount, 1)
    XCTAssertEqual(capturedStates.last?.property, expectedValue)
}
```

Always use `.createMock()` for entities — never direct initializers:
```swift
✅ let model = LiveAttendanceModel.createMock(checkInTime: "08:00")
❌ let model = LiveAttendanceModel(checkInTime: "08:00")
```

---

## Guard Clause Verification <!-- 26 -->

Satisfy ALL guards before the test point, in order:

```swift
// Guard 1: selectedLocation != nil — must pass ✅
viewModel.updateState { $0.selectedLocation = location.createMock() }

// Guard 2: hasInternetConnection() — must pass ✅
tmHelperMock.hasInternetConnectionResult = [true]

// Guard 3: validateInput() — this is the TEST POINT
validationMock.validateResult = [.failure(error)]
```

Guard failure = its own test case (the "noop" path):
```swift
func testSubmit_Guard_LocationNil_NoOp() {
    createViewModel() // location is nil by default
    viewModel.emitEvent(.submitButtonTapped)
    XCTAssertEqual(postCICOUseCaseMock.callCount, 0)
}
```

---

## Branch Tracing Rules <!-- 15 -->

1. Every `if/else`, `guard`, `switch`, ternary → separate branches
2. Trace INTO private methods recursively
3. Every async callback (`subscribe`, completion) → success + failure branches
4. Navigator `Observable`/`Driver` results → branches per emitted value
5. Every `guard` that can fail → its own "noop" test
6. Every enum case in a `switch` → separate test (4 cases = 4 tests)
7. `if/else if` chains → one test per branch + default
8. `setBinders()` reactive chains → traced as implicit events
9. `onError` closures → additional branch even if just logging
10. Method called from N places with M internal branches → N×M tests (unless caller context doesn't affect branching)

---

## Two-Phase Compilation Error Fix <!-- 18 -->

When new tests don't compile due to missing mocks/API changes:

**Phase 3A — Comment out to isolate**:
```swift
// Comment out failing test methods one by one until it compiles
// testMethod1() // ← commented out
```

**Phase 3B — Investigate and fix each**:
- Missing mock method → add to mock protocol
- Wrong return type → update mock return signature
- Changed UseCase params → update mock call site
- Removed state field → update assertion

---

## Failure Diagnosis Framework <!-- 27 -->

### 4 Failure Types

1. **Call count mismatch** — `XCTAssertEqual(mock.callCount, 1)` fails with `0`
   - Fix: ensure guard conditions pass, check mock result array not empty

2. **State property mismatch** — wrong value in `capturedStates.last?.field`
   - Fix: check `.createMock()` default vs test expectation, check state update path

3. **Wrong mock value** — mock returns wrong result for branch
   - Fix: extend `mockResult` array, ensure index matches call order

4. **Array index out of bounds** — `mockResult[safe: N]` returns nil (falls back to `.failure(.unknown)`)
   - Fix: add more entries to `mockResult` array to cover all calls

### Fix Patterns

| Symptom | Fix |
|---------|-----|
| `callCount == 0` | Guard not passing → add missing setup |
| State field wrong | Check `.createMock()` default vs assertion |
| Wrong result branch | Extend `mockResult` to correct call index |
| Assertion logic wrong | Align assertion with actual terminal action |

---

## Coverage Workflow <!-- 23 -->

### Get coverage data from xcresult:
```bash
xcresult_path=$(find ~/Library/Developer/Xcode/DerivedData -name "*.xcresult" | head -1)
xcrun xccov view --report --json "$xcresult_path" > /tmp/coverage_report.json
```

Parse: find ViewModel in targets array → extract functions with `executionCount: 0` → record line numbers.

### Map uncovered lines to test cases:
```
Event: .submitButtonTapped
  └─> validateForm()
        └─> Line 145: if hasErrors
              ├─> true → showErrorAlert()     ← covered?
              └─> false → submitToServer()    ← covered?
```

Target: **90% line coverage**. Priority: critical business logic > edge cases > error handling.

---

## Analysis Report Format <!-- 5 -->

```markdown
# ViewModel Test Analysis Report

## Executive Summary <!-- 5 -->
- ViewModel: [name]
- Events: [total] ([covered]/[uncovered])
- Action Required: [count] items

## Event Analysis <!-- 6 -->
### ✅ [EventName] — COVERED
### ⚠️ [EventName] — PARTIALLY COVERED
  Missing: [branches not covered]
### ❌ [EventName] — NOT COVERED

## Mock Compliance <!-- 4 -->
- ❌ [MockName]: Missing reset() method
- ✅ [MockName]: Compliant

## Prioritized Actions <!-- 9 -->
1. Critical — Fix/create missing mocks
2. Critical — Remove obsolete tests
3. High — Add tests for new events/branches
4. Medium — Update for changed logic
```

---

## Mock Requirements <!-- 10 -->

Every mock must:
- Track calls: `var callCount = 0`, `var capturedParams: Params? = nil`
- Support sequential results: `var mockResult: [Result<Model, Error>] = []`
- Implement `reset()` to clear state between tests
- Use `[safe:]` subscript for array access (avoids index OOB crashes)

---

## ViewModelTestGen Tool <!-- 9 -->

For bulk test generation from a ViewModel's full execution path:

```bash
scripts/viewmodel-testgen.sh [ViewModelName]
```

Outputs a JSON test case map to `temp-dir/ViewModelTestCases/[Name]TestCases.json` with branches, mock setups, and assertions. Use as input when creating a complete test file from scratch.
