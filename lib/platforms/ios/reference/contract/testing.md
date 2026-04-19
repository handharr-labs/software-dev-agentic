# Talenta iOS — Architecture V2: 10. Testing Strategy

## 10. Testing Strategy

### 10.1 Test Pyramid

```
          ┌───────────┐
          │  UI Tests  │  Minimal — happy path only
          │ (XCUITest) │
         ─┼───────────┼─
         │ Integration │  Repository + DataSource
         │   Tests     │  ViewModel + UseCase
        ─┼─────────────┼─
        │  Unit Tests   │  Services (highest coverage)
        │               │  UseCases, Mappers, ViewModels
        └───────────────┘
```

### 10.2 Service Tests

Highest priority. Pure input → output, no mocks needed.

```swift
final class LeaveBalanceCalculatorTests: XCTestCase {
    private var sut: LeaveBalanceCalculator!

    override func setUp() {
        super.setUp()
        sut = LeaveBalanceCalculator()
    }

    func test_remainingBalance_noPending_returnsCorrectBalance() {
        let entitlement = LeaveEntitlement(
            annualDays: 12, usedDays: 5, pendingRequests: []
        )
        XCTAssertEqual(sut.remainingBalance(for: entitlement), 7)
    }

    func test_remainingBalance_negativeBalance_cappedAtZero() {
        let entitlement = LeaveEntitlement(
            annualDays: 12,
            usedDays: 10,
            pendingRequests: Array(repeating: PendingLeaveRequest(days: 1, status: .pending), count: 5)
        )
        XCTAssertEqual(sut.remainingBalance(for: entitlement), 0)
    }
}
```

### 10.3 ViewModel Tests

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

### 10.4 Mock Pattern

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
