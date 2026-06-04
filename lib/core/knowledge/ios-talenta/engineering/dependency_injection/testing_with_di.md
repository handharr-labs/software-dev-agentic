---
platform: ios
project: ios-talenta
discipline: engineering
topic: dependency_injection
pattern: testing_with_di
---

## Theory

- Swap real implementations for test doubles at registration time — the caller never changes
- Each test gets its own container instance — never share container state across tests
- Verify that the container resolves the full dependency graph in an integration test — catches missing registrations before runtime

---

## Testing with DI Container

```swift
// TalentaTests/Module/TalentaTM/Presentation/ViewModel/CICOLocationViewModelTest.swift
final class CICOLocationViewModelTest: XCTestCase {

    var sut: CICOLocationViewModel!
    var mockNavigator: MockCICOLocationNavigator!
    var mockPostSubmitCICOUseCase: MockPostSubmitCICOUseCase!
    var mockLocationManager: MockLocationManager!

    override func setUp() {
        super.setUp()

        // Configure test environment
        SharedDIContainer.shared.configure(for: .testing)

        // Create mocks
        mockNavigator = MockCICOLocationNavigator()
        mockPostSubmitCICOUseCase = MockPostSubmitCICOUseCase()
        mockLocationManager = MockLocationManager()

        // Inject mocks via constructor
        sut = CICOLocationViewModel(
            navigator: mockNavigator,
            postSubmitCICOUseCase: mockPostSubmitCICOUseCase,
            getCICOLocationValidationUseCase: MockGetCICOLocationValidationUseCase(),
            locationManager: mockLocationManager,
            analyticsService: MockAnalyticsService()
        )
    }

    override func tearDown() {
        sut = nil
        mockNavigator = nil
        mockPostSubmitCICOUseCase = nil
        mockLocationManager = nil

        super.tearDown()
    }

    func testSubmitCICO_Success() {
        // Arrange
        let expectedResult: Result<RequestLiveAttendanceModel, BaseErrorModel> = .success(mockModel)
        mockPostSubmitCICOUseCase.executeResult = expectedResult

        // Act
        sut.handle(.submitCICO)

        // Assert
        XCTAssertEqual(mockPostSubmitCICOUseCase.executeCallCount, 1)
        XCTAssertTrue(mockNavigator.navigateToSuccessCalled)
    }
}
```

Configure the container for `.testing` environment, then inject mocks via constructor parameters — never let the test call `TalentaTMDIContainer.shared` to resolve real dependencies.

```swift
override func setUp() {
    super.setUp()

    // Switch shared container to test environment (swaps network monitor, location, analytics)
    SharedDIContainer.shared.configure(for: .testing)

    // Inject mocks directly — bypass the DI container for the unit under test
    sut = CICOLocationViewModel(
        navigator: MockCICOLocationNavigator(),
        postSubmitCICOUseCase: MockPostSubmitCICOUseCase(),
        locationManager: MockLocationManager(),
        analyticsService: MockAnalyticsService()
    )
}
```

Each test gets its own mock instances. Call `container.reset()` in `tearDown()` if shared container state could bleed between tests.

## Benefits of Manual DI Container

| Benefit | Description |
|---------|-------------|
| ✅ **Zero Framework Overhead** | No Needle/Swinject code generation or runtime reflection |
| ✅ **Explicit Dependencies** | All dependencies visible in one place per module |
| ✅ **Environment Switching** | Easy to swap prod/dev/test implementations |
| ✅ **Debuggable** | Step through container code, no magic |
| ✅ **Type-Safe** | Compile-time checks, no string-based lookups |
| ✅ **Testable** | Override specific dependencies in tests via constructor injection |
| ✅ **Modular** | Each feature module has own container, clear boundaries |
| ✅ **Lazy Initialization** | Dependencies created only when needed |
