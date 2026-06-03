---
platform: ios
project: ios-talenta
discipline: engineering
topic: testing
pattern: test_pyramid
---

## Theory

```
         ┌──────────────────┐
         │   E2E Tests      │  few — critical user journeys only
         └────────┬─────────┘
         ┌────────┴─────────┐
         │ Integration Tests│  moderate — repository + datasource wiring
         └────────┬─────────┘
         ┌────────┴─────────┐
         │   Unit Tests     │  many — use cases, mappers, domain services
         └──────────────────┘
```

**Distribution target:** unit-heavy, integration-light, e2e-minimal. A test suite with more e2e than unit tests is inverted — slow, brittle, and expensive to maintain.

---

## Test Pyramid

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

## What to Test Per Layer

| Layer | What to test | What NOT to test |
|---|---|---|
| Domain (UseCases, Services) | Business rules, edge cases, error conditions | Implementation details of other layers |
| Data (Mappers, RepositoryImpl) | DTO → entity field mapping; error propagation to domain | Network stack, real server responses |
| Presentation (ViewModel) | State transitions per event; use case call count and params; action emissions | UIKit rendering, view layout |
| UI (XCUITest) | Critical happy-path user journeys only | Business logic, mapping logic |

## Service Tests

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

## Test Naming Convention

Pattern: `test_[unitUnderTest]_[scenario]_[expectedOutcome]`

Examples:

- `test_remainingBalance_noPending_returnsCorrectBalance`
- `test_remainingBalance_negativeBalance_cappedAtZero`
- `test_fromResponseToModel_mapsAllFields`
- `test_getEmployee_success_callsCompletion_withMappedModel`
- `test_emitEvent_viewDidLoad_shouldUpdateState`
