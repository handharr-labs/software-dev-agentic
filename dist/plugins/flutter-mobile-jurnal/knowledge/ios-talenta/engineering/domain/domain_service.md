---
platform: ios
project: ios-talenta
discipline: engineering
topic: domain
pattern: domain_service
---

## Theory

A **Domain Service** contains pure business logic that spans multiple entities or is reused across multiple use cases.

**Invariants:**
- No I/O — no async, no network, no database, no file system
- No side effects — pure functions; same input always produces the same output
- No framework imports
- Returns structured data — never formatted strings, CSS classes, or display labels (presentation formats output)

**When to extract to a service:**

| Scenario | Decision |
|----------|----------|
| 1–3 line condition | Keep inline in use case |
| Complex multi-step validation | Extract to service |
| Logic reused across ≥ 2 use cases | Extract to service |
| Needs independent unit testing | Extract to service |

**Naming:** `[Feature][Noun]` — e.g. `LeaveBalanceCalculator`, `AttendanceScheduleResolver`

---

## Domain Services

Pure business decisions — no I/O, no side effects, no async. Can be called by both UseCases and ViewModels. 

### Service Patterns

Talenta iOS uses **two service patterns** depending on complexity:

| Pattern | When to Use | Example |
|---------|-------------|---------|
| **Struct-based** | Simple, stateless calculations | `LeaveBalanceCalculator` |
| **Protocol + Class** | Complex logic, needs mocking, shared state | `InboxApproveAllService` |

### Pattern 1: Simple Struct-Based Service

For straightforward calculations and validations:

```swift
// Domain/Services/LeaveBalanceCalculator.swift
struct LeaveBalanceCalculator {
    func remainingBalance(for entitlement: LeaveEntitlement) -> Int {
        let pendingDays = entitlement.pendingRequests
            .filter { $0.status == .pending }
            .reduce(0) { $0 + $1.days }

        let remaining = entitlement.annualDays - entitlement.usedDays - pendingDays
        return max(0, remaining)
    }

    func isSufficient(entitlement: LeaveEntitlement, requestedDays: Int) -> Bool {
        remainingBalance(for: entitlement) >= requestedDays
    }
}
```

**Struct Service Rules:**
- ✅ Stateless, value-type semantics
- ✅ Simple calculations and validations
- ✅ Default parameter injection for composition
- ❌ No shared state or dependencies

### Pattern 2: Protocol + Class Service (Recommended for Complex Logic)

For complex business logic that needs mocking, dependency injection, or shared infrastructure:

```swift
// Domain/Services/InboxApproveAllService.swift

/// Protocol defining the service contract
protocol InboxApproveAllService {
    // Eligibility checking
    func shouldShowApproveAllButton(
        inboxType: InboxType,
        selectedStatus: Int,
        isInProgress: Bool
    ) -> Bool

    func validateApproveAllEligibility(
        inboxType: InboxType,
        selectedStatus: Int,
        isInProgress: Bool
    ) -> InboxApproveAllEligibilityResult

    // Progress calculation
    func calculateDisplayProgress(
        serverCurrent: Int,
        serverMax: Int,
        storedTotal: Int
    ) -> InboxProgressDisplayValues

    func isProcessComplete(
        serverCurrent: Int,
        serverMax: Int
    ) -> Bool

    // State recovery
    func determineRecoveryAction(
        inboxType: InboxType,
        currentStatus: Int
    ) -> InboxRecoveryAction

    // Selection mode coordination
    func handleSelectAllToggle(
        currentMode: BulkSelectionMode,
        totalItemCount: Int
    ) -> InboxSelectAllToggleResult

    func calculateSelectedCount(mode: BulkSelectionMode) -> Int

    // Error detection
    func detectErrorType(_ error: BaseErrorModel) -> InboxApproveAllErrorType
    func shouldRecoverAsInProgress(_ error: BaseErrorModel) -> Bool

    // Polling policy
    func pollingInterval(for inboxType: InboxType) -> TimeInterval
    func shouldStopPolling(errorCount: Int) -> Bool

    // Contract building
    func buildApproveAllParameters(
        inboxType: InboxType,
        excludedIds: [Int]
    ) -> [String: Any]
}

/// Implementation with Singleton pattern
final class InboxApproveAllServiceImpl: InboxApproveAllService {

    // MARK: - Singleton
    private static var _sharedInstance: InboxApproveAllServiceImpl?
    static var sharedInstance: InboxApproveAllServiceImpl {
        if _sharedInstance == nil {
            _sharedInstance = InboxApproveAllServiceImpl()
        }
        return _sharedInstance!
    }

    // MARK: - Dependencies
    private let toggleViewModel: ToggleModel
    private let inboxHelper: InboxHelperProtocol

    // MARK: - Configuration
    private let standardPollingInterval: TimeInterval = 5.0
    private let maxConsecutiveErrors: Int = 3

    // MARK: - Init
    init(
        toggleViewModel: ToggleModel = ToggleViewModel(),
        inboxHelper: InboxHelperProtocol = InboxHelper()
    ) {
        self.toggleViewModel = toggleViewModel
        self.inboxHelper = inboxHelper
    }

    // MARK: - Implementation

    func shouldShowApproveAllButton(
        inboxType: InboxType,
        selectedStatus: Int,
        isInProgress: Bool
    ) -> Bool {
        guard inboxType.asyncApprovalWorker > 0 else { return false }
        guard selectedStatus == Constants.NotificationStatusId.pending else { return false }
        guard !isInProgress else { return false }

        let isOnGoingInStorage = inboxHelper.getApproveAllStatus(
            for: inboxType,
            statusId: Constants.NotificationStatusId.pending
        )
        return !isOnGoingInStorage
    }

    func calculateDisplayProgress(
        serverCurrent: Int,
        serverMax: Int,
        storedTotal: Int
    ) -> InboxProgressDisplayValues {
        let displayTotal = serverMax > 0 ? serverMax : storedTotal
        let displayCurrent = min(serverCurrent, displayTotal)
        let percentage = displayTotal > 0 ? Double(displayCurrent) / Double(displayTotal) : 0.0

        return InboxProgressDisplayValues(
            currentCount: displayCurrent,
            totalCount: displayTotal,
            percentage: percentage,
            isServerInitialized: serverMax > 0
        )
    }

    // ... other methods
}

// MARK: - Result Types

enum InboxApproveAllEligibilityResult: Equatable {
    case eligible
    case alreadyInProgress
    case featureDisabled
    case requiresPendingStatus

    var isEligible: Bool { self == .eligible }
}

struct InboxProgressDisplayValues {
    let currentCount: Int
    let totalCount: Int
    let percentage: Double
    let isServerInitialized: Bool
}
```

**Protocol-Based Service Rules:**
- ✅ Protocol for contract, Class for implementation
- ✅ Singleton pattern with `sharedInstance`
- ✅ Dependency injection via init with defaults
- ✅ Result types (enums/structs) for complex return values
- ✅ Testable via protocol mocking
- ✅ Naming: `[Feature]Service` (protocol) + `[Feature]ServiceImpl` (class)

### Services Called from UseCases

```swift
// Domain/UseCases/Leave/SubmitLeaveRequestUseCase.swift
final class SubmitLeaveRequestUseCase: UseCaseProtocol {
    struct Params {
        let entitlement: LeaveEntitlement
        let leaveTypeId: String
        let days: Int
        let startDate: Date
    }

    private let repository: LeaveRepository
    private let balanceCalculator: LeaveBalanceCalculator

    init(
        repository: LeaveRepository = LeaveRepositoryImpl.sharedInstance,
        balanceCalculator: LeaveBalanceCalculator = LeaveBalanceCalculator()
    ) {
        self.repository = repository
        self.balanceCalculator = balanceCalculator
    }

    func execute(params: Params, completion: @escaping (Result<LeaveModel, BaseErrorModel>) -> Void) {
        // Use Service for business logic
        guard balanceCalculator.isSufficient(
            entitlement: params.entitlement,
            requestedDays: params.days
        ) else {
            completion(.failure(BaseErrorModel(message: "Insufficient balance")))
            return
        }

        // Business logic passed, delegate to repository
        repository.submitLeaveRequest(
            leaveTypeId: params.leaveTypeId,
            startDate: params.startDate,
            days: params.days,
            completion: completion
        )
    }
}
```

### Services Called from ViewModels

**IMPORTANT:** ViewModels can call Services directly for pure business logic (no I/O).

```swift
// Presentation/ViewModel/InboxApprovalListViewModel.swift
class InboxApprovalListViewModel: BaseViewModelV2<State, Event, Action> {

    // MARK: - Dependencies
    private let approveAllService: InboxApproveAllService
    private let submitBulkApprovalUseCase: SubmitBulkApprovalUseCase

    init(
        navigator: InboxApprovalListNavigator,
        submitBulkApprovalUseCase: SubmitBulkApprovalUseCase = SubmitBulkApprovalUseCase.sharedInstance,
        approveAllService: InboxApproveAllService = InboxApproveAllServiceImpl.sharedInstance
    ) {
        self.navigator = navigator
        self.submitBulkApprovalUseCase = submitBulkApprovalUseCase
        self.approveAllService = approveAllService
        super.init()
    }

    override func emitEvent(_ event: InboxApprovalListViewModelEvent) {
        switch event {
        case .viewDidLoad:
            handleViewDidLoad()
        case .approveAllButtonTapped:
            handleApproveAll()
        }
    }

    private func handleViewDidLoad() {
        // ViewModel calls Service for UI state decisions
        let shouldShow = approveAllService.shouldShowApproveAllButton(
            inboxType: inboxType,
            selectedStatus: currentStatus,
            isInProgress: isApprovalInProgress
        )

        updateDataState { state in
            state.showApproveAllButton = shouldShow
        }
    }

    private func handleApproveAll() {
        // ViewModel calls Service for eligibility check
        let eligibility = approveAllService.validateApproveAllEligibility(
            inboxType: inboxType,
            selectedStatus: currentStatus,
            isInProgress: isApprovalInProgress
        )

        guard eligibility.isEligible else {
            emitAction(.showToast(message: eligibility.userMessage ?? "Cannot approve"))
            return
        }

        // After validation, call UseCase for I/O
        let params = SubmitBulkApprovalUseCase.Params(
            type: inboxType,
            param: approveAllService.buildApproveAllParameters(
                inboxType: inboxType,
                excludedIds: []
            )
        )

        submitBulkApprovalUseCase.execute(params: params) { [weak self] result in
            // Handle result...
        }
    }
}
```

**ViewModel → Service Pattern:**
- ✅ Call Services for pure logic (eligibility, validation, calculations)
- ✅ Call UseCases for I/O operations (API calls, storage)
- ✅ Services help ViewModels stay focused on orchestration
- ❌ Services never do I/O (that's UseCase territory)

### When to Use Services

| Scenario | Approach |
|----------|----------|
| Simple condition (1-3 lines) | Keep inline in UseCase/ViewModel |
| Complex multi-step validation | Extract to Service |
| Reused across multiple UseCases/ViewModels | Extract to Service |
| Needs independent unit testing | Extract to Service |
| Pure calculation/decision logic | Extract to Service |
| Shared configuration/policies | Extract to Service |

### Service Pattern Decision Matrix

| Requirement | Use Struct | Use Protocol + Class |
|-------------|------------|----------------------|
| Simple calculations | ✅ | ❌ Over-engineering |
| Needs mocking for tests | ❌ | ✅ |
| Has dependencies (toggles, helpers) | ❌ | ✅ |
| Multiple implementations possible | ❌ | ✅ |
| Shared state or configuration | ❌ | ✅ |
| Complex multi-responsibility logic | ❌ | ✅ |

**Naming:** `[Feature][Verb/Noun]Service` — e.g., `InboxApproveAllService`, `LeaveBalanceCalculator`, `AttendanceScheduleResolver`

**Key Principle:** Services contain pure business logic. UseCases orchestrate I/O. ViewModels orchestrate UI.
