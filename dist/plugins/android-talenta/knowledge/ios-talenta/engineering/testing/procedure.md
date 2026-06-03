---
platform: ios
project: ios-talenta
discipline: engineering
topic: testing
pattern: procedure
---

# iOS Talenta — Unit Test Procedure Implementation

Platform: `ios-talenta` · Language: Swift · Test framework: XCTest · Architecture: MVVM + RxSwift

---

## Test File Naming <!-- 11 -->

Pattern: `<SourceFileName>Test.swift`

Examples:
- `GetMyFilesUseCase.swift` → `GetMyFilesUseCaseTest.swift`
- `MyFileViewModel.swift` → `MyFileViewModelTest.swift`
- `AnnouncementRepositoryImpl.swift` → `AnnouncementRepositoryTest.swift`

---

## Test File Location <!-- 17 -->

Mirror the source path under `TalentaTests/Module/`:

```
Source:  Talenta/<Module>/<Layer>/<ClassName>.swift
Test:    TalentaTests/Module/<Module>/<Layer>/<ClassName>Test.swift
```

Examples:
- `Talenta/TalentaECM/Domain/UseCase/GetMyFilesUseCase.swift`
  → `TalentaTests/Module/TalentaECM/Domain/UseCase/GetMyFilesUseCaseTest.swift`
- `Talenta/TalentaTM/Presentation/ViewModel/MyFileViewModel.swift`
  → `TalentaTests/Module/TalentaTM/Presentation/ViewModel/MyFileViewModelTest.swift`

---

## Test File Scaffold <!-- 33 -->

```swift
import XCTest
#if PPE_ENV
@testable import Talenta_PPE
#elseif STAG_ENV
@testable import Talenta_Staging
#else
@testable import Talenta
#endif

final class <ClassName>Test: XCTestCase {
    private var sut: <ClassName>!
    // declare mock properties here

    override func setUpWithError() throws {
        try super.setUpWithError()
        // initialize mocks and sut
    }

    override func tearDownWithError() throws {
        sut = nil
        // nil out mocks
        try super.tearDownWithError()
    }

    // MARK: - Tests
}
```

---

## Mock Strategy <!-- 34 -->

Mocks are written by hand. Each mock implements the protocol of the dependency being replaced.

**Mock requirements:**
- Track calls: `var callCount = 0`, `var capturedParams: Params? = nil`
- Support sequential results: `var mockResult: [Result<Model, Error>] = []`
- Implement `reset()` to clear state between tests
- Access array results via `[safe:]` subscript to avoid index-out-of-bounds crashes

**Mock pattern:**
```swift
class <Protocol>Mock: <Protocol> {
    var mockResult: [Result<Model, BaseErrorModel>] = []
    var callCount = 0
    var capturedParams: Params? = nil

    func methodName(params: Params, completion: @escaping (Result<Model, BaseErrorModel>) -> Void) {
        callCount += 1
        capturedParams = params
        guard let result = mockResult[safe: callCount - 1] else { return }
        completion(result)
    }

    func reset() {
        mockResult = []
        callCount = 0
        capturedParams = nil
    }
}
```

---

## Mock Location <!-- 19 -->

Mocks are organized under `TalentaTests/Mock/` mirroring module + layer structure:

```
TalentaTests/Mock/Module/<Module>/<Layer>/<InterfaceName>Mock.swift
```

Examples:
- `TalentaTests/Mock/Module/TalentaECM/Domain/UseCase/GetMyFilesUseCaseMock.swift`
- `TalentaTests/Mock/Module/TalentaTM/Presentation/Navigator/CICOBottomSheetNavigatorMock.swift`

Shared utility mocks live in:
```
TalentaTests/Mock/Shared/Utils/<UtilityName>Mock.swift
```

---

## Mock Generation <!-- 14 -->

Mocks are **hand-written** — there is no code generation tool for Swift mocks in this project.

Steps to create a new mock:
1. Identify the protocol the class-under-test depends on.
2. Create a new file at the path described in `## Mock Location`.
3. Implement the protocol with the `callCount`, `mockResult`, and `reset()` pattern above.
4. Add the file to the `TalentaTests` target in Xcode (or confirm the target membership via `.xcodeproj` if editing programmatically).

**Note:** The project previously investigated `MockGen.sh` — this script was not found in the repository root. Manual mock writing is the confirmed approach.

---

## Test Naming Convention <!-- 18 -->

```
test[EventName]Event_[LogicOrMethodName]_[Condition]_[Outcome]
```

For use-case and repository tests use:
```
test_<method>_<condition>
```

Examples:
- `testSubmitButtonTappedEvent_ValidateForm_HasErrors_ShowsErrorAlert`
- `test_call_success`
- `test_call_error`

---

## Test Structure (Arrange-Act-Assert) <!-- 28 -->

```swift
func test_<method>_<condition>() {
    // GIVEN
    let expectedModel = <Model>(...)
    mockDependency.mockResult = [.success(expectedModel)]

    // WHEN
    let exp = expectation(description: "completion")
    sut.call(params: params) { result in
        // THEN
        switch result {
        case .success(let model):
            XCTAssertEqual(model.<field>, expectedModel.<field>)
        case .failure:
            XCTFail("Expected success")
        }
        exp.fulfill()
    }
    waitForExpectations(timeout: 1)
}
```

For ViewModel (RxSwift) tests, capture state via `stateDriver` / `actionDriver` and use `testScheduler.start()`.

---

## Test Runner <!-- 24 -->

Run all tests for the target:
```bash
xcodebuild test \
  -workspace Talenta.xcworkspace \
  -scheme Talenta \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -only-testing:TalentaTests/<TestClassName> \
  | xcpretty
```

For a single test method:
```bash
xcodebuild test \
  -workspace Talenta.xcworkspace \
  -scheme Talenta \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -only-testing:TalentaTests/<TestClassName>/<testMethodName> \
  | xcpretty
```

---

## Failure Patterns <!-- 8 -->

| Symptom | Diagnosis | Fix |
|---|---|---|
| `callCount == 0` | Guard condition not satisfied | Add missing mock setup before the guard |
| State field wrong | `.createMock()` default differs from expectation | Assert against actual `.createMock()` default or override it |
| Array index OOB (returns `.failure(.unknown)`) | `mockResult` has fewer entries than calls | Extend `mockResult` to match total call count |
| Compilation error — missing method on mock | Protocol changed | Add the new method to the mock class |
