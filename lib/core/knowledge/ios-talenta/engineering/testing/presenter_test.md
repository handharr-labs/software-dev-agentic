---
platform: ios
project: ios-talenta
discipline: engineering
topic: testing
pattern: presenter_test
---

## Theory

| Use a mock/stub when… | Use a real implementation when… |
|---|---|
| The dependency has I/O (network, DB, file) | The dependency is pure (mappers, domain services) |
| The test must control exact return values | The test verifies the full integration path |
| Speed matters — unit test suite | Correctness of wiring matters — integration test |

**Never mock domain services or mappers in unit tests** — they are pure functions; test them with real inputs and outputs.

---

## Presenter Tests

```swift
final class CICOLocationViewModelTest: XCTestCase {
    var sut: CICOLocationViewModel!
    var mockNavigator: CICOLocationNavigatorMock!
    var mockPostSubmitCICOUseCase: PostSubmitCICOUseCaseMock!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        mockNavigator = CICOLocationNavigatorMock()
        mockPostSubmitCICOUseCase = PostSubmitCICOUseCaseMock()
        disposeBag = DisposeBag()

        sut = CICOLocationViewModel(
            navigator: mockNavigator,
            displayMode: .fullScreen,
            type: .clockIn,
            scheduleData: nil,
            currentLocation: nil,
            postSubmitCICOUseCase: mockPostSubmitCICOUseCase
        )
    }

    override func tearDown() {
        sut = nil
        mockNavigator = nil
        mockPostSubmitCICOUseCase = nil
        disposeBag = nil
        super.tearDown()
    }

    func test_emitEvent_viewDidLoad_shouldUpdateState() {
        // Arrange
        var receivedStates: [CICOLocationViewModelState] = []

        sut.stateDriver
            .drive(onNext: { state in
                receivedStates.append(state)
            })
            .disposed(by: disposeBag)

        // Act
        sut.emitEvent(.viewDidLoad)

        // Assert
        XCTAssertEqual(receivedStates.last?.appBarTitle, "Check In")
    }

    func test_emitEvent_submitButtonTapped_success_shouldNavigateToSuccess() {
        // Arrange
        let model = RequestLiveAttendanceModel()
        mockPostSubmitCICOUseCase.resultToReturn = .success(model)

        // Act
        sut.emitEvent(.submitButtonTapped)

        // Assert
        XCTAssertEqual(mockPostSubmitCICOUseCase.callCount, 1)
        XCTAssertNotNil(mockPostSubmitCICOUseCase.paramsReceived)
        XCTAssertEqual(mockPostSubmitCICOUseCase.paramsReceived?.companyId, expectedCompanyId)
    }
}
```

## Mock Pattern

```swift
// TalentaTests/Mock/Module/TalentaTM/Domain/UseCase/PostSubmitCICOUseCaseMock.swift
class PostSubmitCICOUseCaseMock: UseCaseProtocol {
    typealias Params = PostSubmitCICOUseCase.Params
    typealias Model = RequestLiveAttendanceModel

    var callCount = 0
    var paramsReceived: Params?
    var resultToReturn: Result<RequestLiveAttendanceModel, BaseErrorModel>?

    func execute(
        params: Params,
        completion: @escaping (Result<RequestLiveAttendanceModel, BaseErrorModel>) -> Void
    ) {
        callCount += 1
        paramsReceived = params

        if let result = resultToReturn {
            completion(result)
        }
    }

    func reset() {
        callCount = 0
        paramsReceived = nil
        resultToReturn = nil
    }
}
```

**Testing Pattern:**
- Arrange-Act-Assert structure
- Mock all dependencies
- Track call counts and parameters
- Reset mocks in `tearDown()`
- Test state changes via `stateDriver`
- Test actions via `actionDriver`
