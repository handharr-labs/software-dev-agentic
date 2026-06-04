Consolidated iOS Clean Architecture reference — covers all engineering layers, patterns, and cross-cutting concerns used across iOS projects. Source: lib/core/knowledge/ios-talenta/engineering/.

# Domain

## Creation Order

### Theory

When building a new feature's domain layer:

```
Entity → Repository Interface → Use Case(s) → Domain Service (only if needed)
```

Never create a use case before the repository interface it depends on.

---

### Creation Order

When building a new feature's domain layer, create files in this sequence:

```
1. Domain/Entities/[Feature]Model.swift          ← Entity (pure struct)
2. Domain/Repository/[Feature]Repository.swift   ← Repository protocol
3. Domain/UseCase/[Feature]/Get[Feature]UseCase.swift
   Domain/UseCase/[Feature]/Post[Feature]UseCase.swift
   ...                                            ← Use Case(s)
4. Domain/Services/[Feature]Service.swift        ← Domain Service (only if needed)
```

Never create a use case before the repository protocol it depends on.

## Dependency Rule

### Theory

Domain is the innermost layer. It imports nothing from outer layers.

```
UI  →  Presentation  →  Data  →  Domain
```

Allowed imports: language primitives and pure functional utilities only.
Forbidden: any framework, UI library, HTTP client, database driver, or data-layer type.

---

### Dependency Rule

Domain is the innermost layer — it imports nothing from outer layers.

**Allowed:** Swift standard library, `Foundation` primitives (`Date`, `UUID`, `Decimal`, `String`, `Int`, `Bool`).

**Forbidden:**
- `import UIKit` — any UIKit type signals a presentation leak into domain
- `import RxSwift` / `import Combine` — reactive frameworks belong in data or presentation
- `import Alamofire` / `import Moya` — networking belongs in data
- Any type defined in a `*RepositoryImpl`, `*DataSource`, or `*Response` file

## Domain Enum

### Domain Enums

```swift
// Domain/enum/CICOType.swift
enum CICOType {
    case clockIn
    case clockOut
    case breakStart
    case breakEnd
}

// Domain/enum/IPAddressStatus.swift
enum IPAddressStatus: String {
    case valid = "valid"
    case invalid = "invalid"
    case unknown = "unknown"
}

// Domain/enum/TimeOffMenuType.swift
enum TimeOffMenuType {
    case request
    case history
    case balance
}
```

**Enum Rules:**
- Define business-level constants and states
- Use meaningful names tied to business domain
- Prefer `String` raw values for API interop when needed
- Location: `Domain/enum/`

## Domain Error

### Theory

A **Domain Error** is the unified error type returned from all repository and use case operations. It decouples the domain from transport-layer error types (HTTP status codes, network errors).

**Invariants:**
- Domain operations return a Result/Either typed with the domain error — they never propagate raw network errors upward
- Repositories map transport errors to domain errors before returning
- Error codes are business-meaningful (`notFound`, `validationFailed`, `unauthorized`) — not HTTP status codes

---

### Domain Errors

```swift
// Shared/Domain/Entities/BaseErrorModel.swift
struct BaseErrorModel: Error {
    let status: Int?
    let message: String
    let errors: [String: [String]]?
}
```

`BaseErrorModel` is the canonical error type for all UseCase and Repository completions (`Result<Model, BaseErrorModel>`). Repositories map `NetworkError` → `BaseErrorModel` before propagating upward. See the Error Handling section for full error flow and mapping patterns.

## Domain Service

### Theory

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

### Domain Services

Pure business decisions — no I/O, no side effects, no async. Can be called by both UseCases and ViewModels.

### Service Patterns

Two service patterns are used depending on complexity:

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
- Stateless, value-type semantics
- Simple calculations and validations
- Default parameter injection for composition
- No shared state or dependencies

### Pattern 2: Protocol + Class Service (Recommended for Complex Logic)

For complex business logic that needs mocking, dependency injection, or shared infrastructure:

```swift
// Domain/Services/InboxApproveAllService.swift

/// Protocol defining the service contract
protocol InboxApproveAllService {
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

    func calculateDisplayProgress(
        serverCurrent: Int,
        serverMax: Int,
        storedTotal: Int
    ) -> InboxProgressDisplayValues

    func isProcessComplete(
        serverCurrent: Int,
        serverMax: Int
    ) -> Bool

    func pollingInterval(for inboxType: InboxType) -> TimeInterval
    func shouldStopPolling(errorCount: Int) -> Bool

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
- Protocol for contract, Class for implementation
- Singleton pattern with `sharedInstance`
- Dependency injection via init with defaults
- Result types (enums/structs) for complex return values
- Testable via protocol mocking
- Naming: `[Feature]Service` (protocol) + `[Feature]ServiceImpl` (class)

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
        guard balanceCalculator.isSufficient(
            entitlement: params.entitlement,
            requestedDays: params.days
        ) else {
            completion(.failure(BaseErrorModel(message: "Insufficient balance")))
            return
        }

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

ViewModels can call Services directly for pure business logic (no I/O).

**ViewModel → Service Pattern:**
- Call Services for pure logic (eligibility, validation, calculations)
- Call UseCases for I/O operations (API calls, storage)
- Services help ViewModels stay focused on orchestration
- Services never do I/O (that's UseCase territory)

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
| Simple calculations | Yes | No — over-engineering |
| Needs mocking for tests | No | Yes |
| Has dependencies (toggles, helpers) | No | Yes |
| Multiple implementations possible | No | Yes |
| Shared state or configuration | No | Yes |
| Complex multi-responsibility logic | No | Yes |

**Naming:** `[Feature][Verb/Noun]Service` — e.g., `InboxApproveAllService`, `LeaveBalanceCalculator`, `AttendanceScheduleResolver`

**Key Principle:** Services contain pure business logic. UseCases orchestrate I/O. ViewModels orchestrate UI.

## Entity

### Theory

An **Entity** is a pure data structure representing a business concept.

**Invariants:**
- No framework imports — value types or pure classes only
- No business logic — entities hold data; use cases execute logic
- No serialization annotations — no `@JsonKey`, no `Codable`, no `fromJson`
- Immutable — all properties are read-only; mutation produces a new instance (`copyWith`)
- Represent domain concepts, not API shapes — field names match the business domain, not the JSON payload

**When to create:** When the domain needs a named, typed concept with identified fields (e.g. `Employee`, `LeaveRequest`, `AttendanceRecord`).

---

### Entities

```swift
// Domain/Entities/CICO/RequestLiveAttendanceModel.swift
struct RequestLiveAttendanceModel {
    let actualBreakStart: String
    let isBreakStart: Bool
    let isBreakEnd: Bool
    let currentShiftDate: String
    let currentShiftName: String
    let actualCheckIn: String
    let actualCheckOut: String
    let faceRecogAccuracy: Double
    let serverTime: String
    let processedAsync: Bool
    let ipAddressStatus: Bool

    init(
        actualBreakStart: String = "",
        isBreakStart: Bool = false,
        isBreakEnd: Bool = false,
        currentShiftDate: String = "",
        currentShiftName: String = "",
        actualCheckIn: String = "",
        actualCheckOut: String = "",
        faceRecogAccuracy: Double = 0.0,
        serverTime: String = "",
        processedAsync: Bool = false,
        ipAddressStatus: Bool = false
    ) {
        self.actualBreakStart = actualBreakStart
        self.isBreakStart = isBreakStart
        self.isBreakEnd = isBreakEnd
        self.currentShiftDate = currentShiftDate
        self.currentShiftName = currentShiftName
        self.actualCheckIn = actualCheckIn
        self.actualCheckOut = actualCheckOut
        self.faceRecogAccuracy = faceRecogAccuracy
        self.serverTime = serverTime
        self.processedAsync = processedAsync
        self.ipAddressStatus = ipAddressStatus
    }
}

// copyWith for immutable updates
extension RequestLiveAttendanceModel {
    func copyWith(
        actualBreakStart: String? = nil,
        isBreakStart: Bool? = nil,
        serverTime: String? = nil
        // ... other parameters
    ) -> RequestLiveAttendanceModel {
        return RequestLiveAttendanceModel(
            actualBreakStart: actualBreakStart ?? self.actualBreakStart,
            isBreakStart: isBreakStart ?? self.isBreakStart,
            serverTime: serverTime ?? self.serverTime
            // ... other fields
        )
    }
}
```

**Entity Rules:**
- Structs (value types) preferred
- Default initializers with default values
- `copyWith` extension for immutable updates
- Equatable conformance for diffing/testing
- No `import UIKit` or heavy framework dependencies
- No business logic (pure data)

## Repository Interface

### Theory

A **Repository** is a contract that defines data access operations — *what* is needed, not *how* it is done.

**Invariants:**
- Lives in Domain as an interface/protocol/abstract class only — implementation lives in Data
- Returns domain Entities — never raw DTOs, API response types, or database records
- Method names follow the operation's intent: `get*`, `create*`, `update*`, `delete*`, `submit*`
- Parameters are domain objects — not raw dictionaries, JSON maps, or HTTP types
- Error type is the domain error type — never a networking or transport error

**When to create:** One repository per aggregate root or feature domain. Created before use cases — use cases depend on the repository interface.

---

### Repository Interfaces

```swift
// Domain/Repository/LiveAttendanceRepository.swift
protocol LiveAttendanceRepository {
    func postSubmitCico(
        params: PostSubmitCICOQueryParam,
        companyId: LiveAttendanceCICOPathParam,
        expected: @escaping (Result<RequestLiveAttendanceModel, BaseErrorModel>) -> Void
    )

    func getServerTime(
        params: GetServerTimeQueryParam,
        expected: @escaping (Result<LiveAttendanceServerTimeModel, BaseErrorModel>) -> Void
    )

    func postCicoValidateLocation(
        params: PostCICOValidateLocationQueryParam,
        companyId: LiveAttendanceCICOPathParam,
        expected: @escaping (Result<CICOLocationValidationModel, BaseErrorModel>) -> Void
    )
}
```

**Repository Protocol Rules:**
- Always use `Result<Model, BaseErrorModel>` in completions
- Return domain entities (Models), never DTOs (Responses)
- Method names follow REST convention: `post*`, `get*`, `put*`, `delete*`
- Params are domain Param objects, not raw dictionaries
- No implementation details (no Moya, no network code)

## Use Case

### Theory

A **UseCase** encapsulates a single business operation: one class, one public method, one responsibility.

**Invariants:**
- One business operation per class — never combine unrelated operations
- Depends only on repository interfaces — never on repository implementations or data-layer types
- No framework dependencies — no HTTP clients, no UI types
- Accepts typed input (Params/Request struct) — never raw dictionaries or loose primitives
- Returns domain entities or primitives — never DTOs or view models
- All I/O goes through the repository — use cases never call APIs or databases directly

**Mandatory call flow — no exceptions:**
```
Presentation → UseCase → Repository    ✅
Presentation → Repository              ❌  direct call is a CLEAN violation
```

**When to create:** One use case per business operation (e.g. `GetEmployeeUseCase`, `SubmitLeaveRequestUseCase`, `ApproveLeaveRequestUseCase`). Even thin pass-through use cases are mandatory — they preserve a stable indirection point for future validation, caching, or logging without touching the presentation layer.

---

### Use Cases

### Modern UseCase Protocol

```swift
// Shared/Domain/UseCaseType.swift

/// Base protocol for all UseCases.
/// Each UseCase defines its own nested Params struct.
/// For use cases without parameters, use `typealias Params = Void`
protocol UseCaseProtocol {
    associatedtype Params
    associatedtype Model

    func execute(
        params: Params,
        completion: @escaping (Result<Model, BaseErrorModel>) -> Void
    )
}
```

**Key Benefits:**
- Single protocol — no confusion between multiple protocol types
- No naming conflicts — `UseCaseProtocol` avoids clashes
- No param collisions — `GetEmployeeUseCase.Params` vs `UpdateEmployeeUseCase.Params`
- Discoverable — autocomplete shows params right from the UseCase type
- Colocated — params definition lives next to the code that uses it
- Self-documenting — all inputs clearly defined in one place
- Consistent API — all use cases have the same `execute(params:completion:)` signature

### UseCase Implementation Patterns

#### Pattern 1: GET with Single ID

```swift
// Domain/UseCase/Employee/GetEmployeeUseCase.swift

final class GetEmployeeUseCase: UseCaseProtocol {
    // MARK: - Params (Nested inside UseCase)
    struct Params {
        let employeeId: String
    }

    // MARK: - Singleton
    private static var _sharedInstance: GetEmployeeUseCase?
    static var sharedInstance: GetEmployeeUseCase {
        if _sharedInstance == nil {
            _sharedInstance = GetEmployeeUseCase()
        }
        return _sharedInstance!
    }

    // MARK: - Dependencies
    private let repository: EmployeeRepository

    // MARK: - Init
    init(repository: EmployeeRepository = EmployeeRepositoryImpl.sharedInstance) {
        self.repository = repository
    }

    // MARK: - Execute
    func execute(
        params: Params,
        completion: @escaping (Result<EmployeeModel, BaseErrorModel>) -> Void
    ) {
        repository.getEmployee(id: params.employeeId, completion: completion)
    }
}
```

#### Pattern 2: GET with Multiple Query Parameters

```swift
final class GetEmployeesUseCase: UseCaseProtocol {
    struct Params {
        let page: Int
        let limit: Int
        let departmentId: String?
        let searchQuery: String?

        init(
            page: Int = 1,
            limit: Int = 20,
            departmentId: String? = nil,
            searchQuery: String? = nil
        ) {
            self.page = page
            self.limit = limit
            self.departmentId = departmentId
            self.searchQuery = searchQuery
        }
    }

    // ... singleton, init, execute follow same pattern
}
```

#### Pattern 3: POST/PUT with Path ID + Body (Nested Payload)

**Key Pattern:** Separate path identifiers from payload body using nested structs.

```swift
final class PostSubmitCICOUseCase: UseCaseProtocol {
    struct Params {
        let companyId: Int          // Path parameter
        let payload: Payload        // Request body

        struct Payload {
            let employeeId: Int
            let scheduleId: Int
            let actualCheckIn: String?
            let actualCheckOut: String?
            let latitude: Double?
            let longitude: Double?
            let media: Data?
            let notes: String?
        }
    }

    // ... singleton, init, execute follow same pattern
}
```

#### Pattern 4: UseCase Without Parameters

**Key Pattern:** Use `typealias Params = Void` for use cases that don't need parameters.

```swift
final class GetCurrentUserUseCase: UseCaseProtocol {
    typealias Params = Void  // No parameters needed

    // ... singleton, init

    func execute(
        params: Void,
        completion: @escaping (Result<UserModel, BaseErrorModel>) -> Void
    ) {
        repository.getCurrentUser(completion: completion)
    }
}

// Usage in ViewModel:
getCurrentUserUseCase.execute(params: ()) { [weak self] result in ... }
```

### Params Pattern Summary

| Operation | Params Structure | Example |
|-----------|-----------------|---------|
| **No params** | `typealias Params = Void` | `useCase.execute(params: ())` |
| **GET (single)** | `Params { id }` | `GetEmployeeUseCase.Params(employeeId: "123")` |
| **GET (list)** | `Params { page, limit, filters... }` | `GetEmployeesUseCase.Params(page: 1, limit: 20)` |
| **POST** | `Params { payload: Payload { fields... } }` | `CreateEmployeeUseCase.Params(payload: ...)` |
| **PUT** | `Params { id, payload: Payload { fields... } }` | `UpdateEmployeeUseCase.Params(employeeId: "123", payload: ...)` |
| **DELETE** | `Params { id }` | `DeleteTaskUseCase.Params(taskId: "456")` |
| **POST (with path)** | `Params { pathId, payload: Payload { ... } }` | `PostSubmitCICOUseCase.Params(companyId: 1, payload: ...)` |

**Naming:** `[HttpMethod][Feature]UseCase`
- GET: `GetCustomFormUseCase`, `GetAttendanceHistoryUseCase`
- POST: `PostSubmitCICOUseCase`, `PostRequestOvertimeUseCase`
- PUT: `PutUpdateProfileUseCase`
- DELETE: `DeleteTaskUseCase`

---

# Data

## Data Source

### Theory

A **DataSource** is an abstract interface for raw data access — remote (HTTP) or local (DB, cache).

**Invariants:**
- Interface only in the data layer — implementation is injected, never instantiated directly
- Methods return raw data (DTOs or primitives) — never domain entities
- One DataSource per data origin (remote API, local DB, cache) — do not mix sources in one interface
- Throws or returns transport-layer errors — the repository implementation maps these to domain errors

**When to create:** One DataSource interface per data origin per feature. Created after the DTO and mapper, before the repository implementation.

---

### Data Sources

Abstract the data origin (remote API, local storage, cache).

```swift
// Data/DataSource/Remote/LiveAttendanceRemoteDataSource.swift
protocol LiveAttendanceRemoteDataSource {
    func postSubmitCico(
        params: [String: Any],
        companyId: Int,
        config: TMRequestConfig?,
        completion: @escaping (APIResult<RequestLiveAttendanceResponse>) -> Void
    )

    func getServerTime(
        params: [String: Any],
        config: TMRequestConfig?,
        completion: @escaping (APIResult<LiveAttendanceServerTimeResponse>) -> Void
    )
}

// Data/DataSource/Remote/LiveAttendanceRemoteDataSourceImpl.swift
class LiveAttendanceRemoteDataSourceImpl: LiveAttendanceRemoteDataSource {
    private let provider: MoyaProvider<TimeManagementAPI>

    init(provider: MoyaProvider<TimeManagementAPI> = MoyaProvider<TimeManagementAPI>()) {
        self.provider = provider
    }

    func postSubmitCico(
        params: [String: Any],
        companyId: Int,
        config: TMRequestConfig?,
        completion: @escaping (APIResult<RequestLiveAttendanceResponse>) -> Void
    ) {
        provider.request(.postSubmitCico(params: params, companyId: companyId, config: config)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(RequestLiveAttendanceResponse.self, from: response.data)
                    completion(.success(decoded))
                } catch {
                    completion(.error(BaseError(message: error.localizedDescription)))
                }
            case .failure(let error):
                completion(.error(BaseError(message: error.localizedDescription)))
            }
        }
    }
}
```

**DataSource Rules:**
- Protocol for abstraction, Impl for implementation
- Takes raw params as `[String: Any]` (converted from domain Params)
- Returns `APIResult<ResponseType>` (custom result enum)
- Uses Moya for HTTP requests
- Error handling: catch decode + network errors

## Dependency Rule

### Theory

Data depends on Domain only. It never imports from Presentation or UI.

```
Domain  ←  Data
```

Allowed imports: domain entities, repository interfaces, language primitives.
Forbidden: any presentation type, UI framework, StateHolder, or view import.

---

### Dependency Rule

Data depends on Domain only. It never imports from Presentation or UI.

**Allowed:** `Foundation`, Moya, `MoyaProvider`, `JSONDecoder`, `UserDefaults`, `CoreData`, `NWPathMonitor`, any persistence or networking library.

**Forbidden:**
- `import UIKit` — UI types must not appear in data layer files
- Any `ViewModel`, `ViewController`, `Coordinator`, or `Navigator` type
- Any presentation-layer import — data layer must not know how results are displayed

## DTO

### Theory

A **DTO (Data Transfer Object)** mirrors the raw API or database shape exactly.

**Invariants:**
- No domain logic — plain data container only
- No computed fields — no derived values, no formatting
- No domain entity types — DTOs use primitive types and nested DTOs
- Serialization annotations live here, not on domain entities (`Codable`, `CodingKeys`)
- Field names match the API/DB schema — not the business domain vocabulary

**When to create:** One DTO per API response type or DB table row. Created before the mapper that consumes it.

---

### DTOs

API response models — referred to as **Response Models** (`*Response` / `*ResponseData` structs). Raw API shape, all fields optional (`?`), `CodingKeys` for snake_case mapping, no business logic. Never escape the Data layer.

```swift
// Data/Models/LiveAttendance/RequestLiveAttendanceResponse.swift
struct RequestLiveAttendanceResponse: Decodable {
    let status: Bool?
    let message: String?
    let data: RequestLiveAttendanceResponseData?
}

struct RequestLiveAttendanceResponseData: Decodable {
    let actualBreakStart: String?
    let isBreakStart: Bool?
    let isBreakEnd: Bool?
    let currentShiftDate: String?
    let currentShiftName: String?
    let actualCheckIn: String?
    let actualCheckOut: String?
    let faceRecogAccuracy: Double?
    let serverTime: String?
    let processedAsync: Bool?
    let ipAddressStatus: Bool?

    enum CodingKeys: String, CodingKey {
        case actualBreakStart = "actual_break_start"
        case isBreakStart = "is_break_start"
        case isBreakEnd = "is_break_end"
        case currentShiftDate = "current_shift_date"
        case currentShiftName = "current_shift_name"
        case actualCheckIn = "actual_check_in"
        case actualCheckOut = "actual_check_out"
        case faceRecogAccuracy = "face_recog_accuracy"
        case serverTime = "server_time"
        case processedAsync = "processed_async"
        case ipAddressStatus = "ip_address_status"
    }
}
```

**Response Model Rules:**
- Only conform to `Decodable` (or `Encodable` for POST bodies)
- Field names match API JSON keys via `CodingKeys`
- All fields optional (`?`) — gracefully handle missing data
- Nested API objects get their own Response struct
- Response models never escape Data layer
- Standard wrapper: `status`, `message`, `data` structure

## HTTP Client

### HTTP Client

Uses **Moya** for type-safe networking.

```swift
// Shared/Network/API/TimeManagementAPI.swift
enum TimeManagementAPI {
    case postSubmitCico(params: [String: Any], companyId: Int, config: TMRequestConfig?)
    case getServerTime(params: [String: Any], config: TMRequestConfig?)
    case postCicoValidateLocation(params: [String: Any], companyId: Int, config: TMRequestConfig?)
}

extension TimeManagementAPI: TargetType {
    var baseURL: URL {
        return URL(string: AppEnvironment.shared.baseURL)!
    }

    var path: String {
        switch self {
        case .postSubmitCico(_, let companyId, _):
            return "/api/v1/companies/\(companyId)/live-attendance"
        case .getServerTime:
            return "/api/v1/server-time"
        case .postCicoValidateLocation(_, let companyId, _):
            return "/api/v1/companies/\(companyId)/live-attendance/validate-location"
        }
    }

    var method: Moya.Method {
        switch self {
        case .postSubmitCico, .postCicoValidateLocation:
            return .post
        case .getServerTime:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .postSubmitCico(let params, _, _), .postCicoValidateLocation(let params, _, _):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .getServerTime(let params, _):
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }

    var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(StorageHelper.getStringValue(key: .accessToken).orEmpty())"
        ]
    }
}
```

**Moya Pattern:**
- Enum cases for endpoints
- Conform to `TargetType` protocol
- Use `.requestParameters` for body/query
- Headers include auth tokens from storage
- MoyaProvider handles HTTP requests

## Mapper

### Theory

A **Mapper** converts between a DTO and a domain entity — always defined as an interface with a concrete implementation.

**Invariants:**
- Always interface + implementation — never a plain utility function or static helper
- One direction per method: `toDomain(dto)` converts inward; `toDTO(entity)` converts outward (if write operations exist)
- No I/O — pure transformation only; no network calls, no DB reads
- No business logic — field mapping only; validation belongs in domain use cases
- Null/missing fields handled defensively — never let a missing API field crash the mapper

**When to create:** One mapper per DTO ↔ entity pair. Created after the DTO, before the DataSource implementation.

---

### Mappers

**CRITICAL:** Mappers belong in the **Data Layer**, not Domain Layer.

### Why Mappers Are in Data Layer

Mappers transform API Response models (Data Layer DTOs) into Domain Entities (Domain Layer models).

| Principle | Explanation |
|-----------|-------------|
| **Dependency Rule** | Data layer depends on Domain, not vice versa. Mappers convert `Response` → `Entity`, so they live in Data layer where both types are visible. |
| **Implementation Detail** | How we convert API JSON to domain models is an implementation detail, not business logic. |
| **Framework Dependency** | Mappers use `Codable`, optional unwrapping extensions (`.orEmpty()`, `.orZero()`), and API-specific parsing — these are infrastructure concerns. |
| **Domain Independence** | Domain layer must be pure Swift with zero framework dependencies. Domain shouldn't know about Response models or JSON parsing. |

### Clean Architecture Flow

```
API Response (Data) ──Mapper (Data)──> Domain Entity (Domain) ──> UseCase (Domain)
```

### Basic Mapper Pattern

```swift
// Data/Mapper/RequestLiveAttendanceModelMapper.swift
protocol RequestLiveAttendanceModelMapperType {
    func fromResponseToModel(from response: RequestLiveAttendanceResponseData) -> RequestLiveAttendanceModel
    func fromModelToResponse(from model: RequestLiveAttendanceModel) -> RequestLiveAttendanceResponseData
}

class RequestLiveAttendanceModelMapper: RequestLiveAttendanceModelMapperType {

    func fromResponseToModel(from response: RequestLiveAttendanceResponseData) -> RequestLiveAttendanceModel {
        return RequestLiveAttendanceModel(
            actualBreakStart: response.actualBreakStart.orEmpty(),
            isBreakStart: response.isBreakStart.orFalse(),
            isBreakEnd: response.isBreakEnd.orFalse(),
            currentShiftDate: response.currentShiftDate.orEmpty(),
            currentShiftName: response.currentShiftName.orEmpty(),
            actualCheckIn: response.actualCheckIn.orEmpty(),
            actualCheckOut: response.actualCheckOut.orEmpty(),
            faceRecogAccuracy: response.faceRecogAccuracy.orDefault(with: -1),
            serverTime: response.serverTime.orEmpty(),
            processedAsync: response.processedAsync.orFalse(),
            ipAddressStatus: response.ipAddressStatus.orFalse()
        )
    }

    func fromModelToResponse(from model: RequestLiveAttendanceModel) -> RequestLiveAttendanceResponseData {
        return RequestLiveAttendanceResponseData(
            actualBreakStart: model.actualBreakStart,
            isBreakStart: model.isBreakStart,
            // ... other fields
        )
    }
}
```

### Composable Mappers

Mappers compose via injection — a parent mapper depends on child mappers for nested objects:

```swift
class EmployeeMapper: EmployeeMapping {
    private let departmentMapper: DepartmentMapping

    init(departmentMapper: DepartmentMapping = DepartmentMapper()) {
        self.departmentMapper = departmentMapper
    }

    func toDomain(_ dto: EmployeeDTO) -> Employee {
        Employee(
            id: dto.id,
            name: dto.fullName,
            email: dto.emailAddress,
            department: departmentMapper.toDomain(dto.department),
            joinDate: ISO8601DateFormatter().date(from: dto.joinedAt) ?? .now
        )
    }
}
```

**Mapper Rules:**
- One mapper per Response-Model pair
- Protocol-based: `[Name]ModelMapperType` protocol + `[Name]ModelMapper` class
- Use safe unwrapping: `.orEmpty()`, `.orFalse()`, `.orZero()`, `.orDefault(with:)`
- Bidirectional when needed: `fromResponseToModel` and `fromModelToResponse`
- Injected into repositories for testability
- **No business logic** — only data transformation

## Repository Implementation

### Theory

A **Repository Implementation** implements the domain repository interface using a DataSource and Mapper.

**Invariants:**
- Implements a domain repository interface — it is the bridge between Data and Domain
- Calls the DataSource for raw data, calls the Mapper to convert to domain entities
- Wraps all DataSource calls with error handling — maps transport errors to domain errors before returning
- Never lets raw HTTP errors, DB exceptions, or transport-layer types propagate to the domain
- Never calls another repository implementation directly

**When to create:** Last in the creation order — after DataSource interface and implementation exist.

---

### Repository Implementation

Repositories inject **mappers** and **datasources**, implement **domain protocols**.

```swift
// Data/RepositoriesImpl/LiveAttendanceRepositoryImpl.swift
class LiveAttendanceRepositoryImpl: LiveAttendanceRepository {
    // Singleton
    private static var _sharedInstance: LiveAttendanceRepositoryImpl?
    static var sharedInstance: LiveAttendanceRepositoryImpl {
        if _sharedInstance == nil {
            _sharedInstance = LiveAttendanceRepositoryImpl()
        }
        return _sharedInstance!
    }

    // Dependencies
    private let remoteDataSource: any LiveAttendanceRemoteDataSource
    private let requestLiveAttendanceMapper: any RequestLiveAttendanceModelMapperType
    private let baseErrorModelMapper: BaseErrorModelMapper

    init(
        remoteDataSource: any LiveAttendanceRemoteDataSource = LiveAttendanceRemoteDataSourceImpl(),
        requestLiveAttendanceMapper: any RequestLiveAttendanceModelMapperType = RequestLiveAttendanceModelMapper(),
        baseErrorModelMapper: BaseErrorModelMapper = BaseErrorModelMapper()
    ) {
        self.remoteDataSource = remoteDataSource
        self.requestLiveAttendanceMapper = requestLiveAttendanceMapper
        self.baseErrorModelMapper = baseErrorModelMapper
    }

    func postSubmitCico(
        params: PostSubmitCICOQueryParam,
        companyId: LiveAttendanceCICOPathParam,
        expected: @escaping (Result<RequestLiveAttendanceModel, BaseErrorModel>) -> Void
    ) {
        remoteDataSource.postSubmitCico(
            params: params.toDictionary().orEmpty(),
            companyId: companyId.companyId.orZero(),
            config: nil
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                if let data = response.data {
                    let model = self.requestLiveAttendanceMapper.fromResponseToModel(from: data)
                    expected(.success(model))
                } else {
                    expected(.failure(BaseErrorModel(message: "No data available")))
                }
            case .error(let error):
                expected(.failure(self.baseErrorModelMapper.fromResponseToModel(from: error)))
            }
        }
    }
}
```

### Advanced Repository Patterns

#### Offline Support with Cache Fallback

```swift
func getSchedule(
    param: GetAttendanceScheduleParam?,
    completion: @escaping (Result<ScheduleModel, BaseErrorModel>) -> Void
) {
    guard networkMonitor.isConnected else {
        if let cached = cacheManager.loadCachedSchedule() {
            completion(.success(cached))
        } else {
            completion(.failure(BaseErrorModel(message: "No internet connection.")))
        }
        return
    }

    dataSource.getSchedule(params: param?.toDictionary()) { [weak self] result in
        // ... fetch, map, cache, and return
    }
}
```

#### Parallel Requests with DispatchGroup

```swift
func getDashboardData(
    completion: @escaping (Result<DashboardDataModel, BaseErrorModel>) -> Void
) {
    var attendance: AttendanceModel?
    var announcements: [AnnouncementModel] = []
    var firstError: BaseErrorModel?
    let group = DispatchGroup()

    group.enter()
    attendanceDataSource.getToday { result in
        defer { group.leave() }
        switch result {
        case .success(let r): attendance = r.data.map { self.attendanceMapper.map(from: $0) }
        case .error(let e): firstError = self.baseErrorMapper.fromResponseToModel(from: e)
        }
    }

    group.enter()
    announcementDataSource.getList { result in
        defer { group.leave() }
        if case .success(let r) = result {
            announcements = (r.data ?? []).map { self.announcementMapper.map(from: $0) }
        }
    }

    group.notify(queue: .main) {
        if let error = firstError, attendance == nil {
            completion(.failure(error))
        } else {
            completion(.success(DashboardDataModel(attendance: attendance, announcements: announcements)))
        }
    }
}
```

### Creation Order

```
1. Data/Models/[Feature]/[Feature]Response.swift           ← DTO
2. Data/Mapper/[Feature]ModelMapper.swift                  ← Mapper
3. Data/DataSource/Remote/[Feature]RemoteDataSource.swift  ← DataSource protocol
   Data/DataSource/Remote/[Feature]RemoteDataSourceImpl.swift ← DataSource implementation
4. Data/RepositoriesImpl/[Feature]RepositoryImpl.swift     ← Repository implementation
```

### Layer Invariants

- Import from domain layer only — never from presentation, ViewController, ViewModel, or Navigator files
- Raw transport errors never propagate upward — `RepositoryImpl` maps them to `BaseErrorModel`
- `*Response` and `*ResponseData` structs never cross into the domain layer
- All `*RepositoryImpl` files conform to a domain protocol
- `MoyaProvider` and `JSONDecoder` live only in DataSource implementations

---

# Presentation

## Component

### Theory

A **Component** (also called Sub-view, Widget, or View) is a reusable UI element smaller than a full screen.

**Invariants:**
- Stateless by default — receives data via props/parameters and emits callbacks
- If stateful, bound to a scoped StateHolder — never manages business state inline
- No use case calls — all data passed in from the parent screen or a scoped StateHolder
- Reuse check required before creating — search shared component directories first

**When to create:** When a UI element appears in ≥2 screens, or when a screen section is complex enough to isolate for readability.

---

### Component

Reusable cell or view — UIModel pattern, no ViewModel awareness. Receives a plain `UIModel` struct via `configure(with:)`.

```swift
final class FeatureTableViewCell: UITableViewCell {
    static let reuseIdentifier = "FeatureTableViewCell"

    struct UIModel {
        let title: String
        let subtitle: String
    }

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
    }

    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        // SnapKit layout constraints...
    }

    func configure(with model: UIModel) {
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
    }
}
```

Rules:
- `UIModel` is a nested struct — pure display data, no business logic
- `prepareForReuse()` must clear all displayed values (and reset `disposeBag` if RxSwift is used)
- SnapKit for layout — no storyboards
- Use design system tokens for spacing/colors
- Mark class `final`

## Logging

### Logging

Log format: `print("[DebugTest][ClassName.methodName] <event> — <value>")`.

```swift
print("[DebugTest][methodName] entry — param: \(param)")
print("[DebugTest][methodName] state — before: \(before), after: \(after)")
print("[DebugTest][methodName] error — \(error)")
```

Rules:
- Use `[DebugTest]` prefix on every log — filter in Xcode console with `Cmd+K` then search `[DebugTest]`
- Never log passwords or tokens — log `.count` instead
- Never commit `[DebugTest]` logs

## Screen Structure

### Theory

A **Screen** is a full-page view bound to a single StateHolder. It observes state and sends events — it contains no business logic.

**Invariants:**
- Bound to exactly one StateHolder — instantiated via DI, never with direct `new` / `init`
- Observes every State field declared in the StateHolder contract — no State field goes unhandled
- Sends events to the StateHolder for every user interaction — never mutates state directly
- Contains no business logic — conditionals exist only to decide what to render, not what to compute
- No use case calls — all data flows through the StateHolder

**When to create:** One screen per route/destination. Created after the StateHolder contract exists.

---

### Screen Structure

```swift
// Presentation/View/CICOLocation/CICOLocationViewController.swift
class CICOLocationViewController: BaseViewController {

    // MARK: - UI
    private let mapView: MapView = {
        return MapView()
    }()

    private let submitButton: Button = {
        let button = Button()
        button.setTitle("Submit", for: .normal)
        return button
    }()

    // MARK: - ViewModel
    private let viewModel: CICOLocationViewModel

    // MARK: - Init
    init(viewModel: CICOLocationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.emitEvent(.viewDidLoad)
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(mapView)
        view.addSubview(submitButton)
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
    }

    private func bindViewModel() {
        viewModel.stateDriver
            .drive(onNext: { [weak self] state in
                self?.render(state: state)
            })
            .disposed(by: disposeBag)

        viewModel.actionDriver
            .drive(onNext: { [weak self] action in
                self?.handle(action: action)
            })
            .disposed(by: disposeBag)
    }

    private func render(state: CICOLocationViewModelState) {
        title = state.appBarTitle
        submitButton.setTitle(state.submitButtonTitle, for: .normal)
        submitButton.isEnabled = state.nextButtonIsEnable
    }

    private func handle(action: CICOLocationViewModelAction) {
        switch action {
        case .showToast(let message):
            showToast(message: message)
        case .showLoading:
            showLoading()
        case .hideLoading:
            hideLoading()
        case .openCamera:
            openCamera()
        default:
            break
        }
    }

    // MARK: - Actions
    @objc private func submitButtonTapped() {
        viewModel.emitEvent(.submitButtonTapped)
    }
}
```

**ViewController Pattern:**
- Inject ViewModel via constructor
- Call `viewModel.emitEvent(.viewDidLoad)` in `viewDidLoad()`
- Bind `stateDriver` → render UI
- Bind `actionDriver` → handle actions
- UI events call `viewModel.emitEvent(...)`
- Pure UI logic stays in ViewController
- Business logic stays in ViewModel

## Shared Component Paths

### Shared Component Paths

When running a Component Reuse Check, search these locations for existing reusable views:

| Scope | Path | File pattern |
|---|---|---|
| Shared across all modules | `Shared/Presentation/View/` | `*View.swift` |
| Shared shimmer/loading views | `Shared/Presentation/ShimmerView/` | `*View.swift` |
| Shared table view components | `Shared/Presentation/CustomTableView/` | `*View.swift` |
| Module-local views (cross-feature reuse candidate) | `Module/*/Presentation/View/` | `*View.swift` |

**Search strategy:** Grep for the component concept (e.g. `"Card"`, `"Avatar"`, `"EmptyState"`, `"ListItem"`) across these paths before creating a new view. A `UIView` or `UIViewController` subclass found here is a reuse candidate.

## View Model

### Theory

A **StateHolder** is the single source of truth for a screen's UI state. Platform names vary (ViewModel, BLoC, Presenter) but the contract is identical across platforms.

**Invariants:**
- Owns no view imports — no UI framework, no widget, no component type
- Depends on use case interfaces only — never calls repositories or data sources directly
- Use cases are injected via DI — never instantiated directly inside the StateHolder
- Exposes state as a read-only stream or observable — UI observes, never mutates
- One StateHolder per screen — never shared across screens unless explicitly scoped

**When to create:** One StateHolder per screen. Created before the screen that observes it.

---

### StateHolder (ViewModel)

The StateHolder is implemented as a **ViewModel** extending `BaseViewModelV2`.

Invariants:
- Receives use cases via constructor injection — default singleton parameters are acceptable; prefer protocol types
- Exposes state via `stateDriver: Driver<State>` — ViewController observes, never mutates
- Emits navigation as an `Action` — never calls navigator directly from event handlers without routing through `emitAction`
- One ViewModel per screen — scoped to the screen's lifecycle

### State

State is a `struct` conforming to `ViewModelState` — a plain value type with an `initial` factory.

```swift
struct CICOLocationViewModelState: ViewModelState {
    var nextButtonIsEnable: Bool
    var mapViewCameraPosition: CLLocation?
    var submitButtonTitle: String
    var appBarTitle: String
    var isLoading: Bool

    static var initial: CICOLocationViewModelState {
        return CICOLocationViewModelState(
            nextButtonIsEnable: false,
            mapViewCameraPosition: nil,
            submitButtonTitle: "",
            appBarTitle: "",
            isLoading: false
        )
    }
}
```

### Events

Events are `enum` cases conforming to `ViewModelEvent`. ViewController calls `viewModel.emitEvent(.caseName)` for every user interaction.

```swift
enum CICOLocationViewModelEvent: ViewModelEvent {
    case viewDidLoad
    case submitButtonTapped
    case reloadLocationTapped
    case backButtonTapped
    case openCameraForSelfie
}
```

### Actions

Actions are `enum` cases conforming to `ViewModelAction`, emitted via `emitAction(_:)`. ViewController observes `actionDriver` and responds.

```swift
enum CICOLocationViewModelAction: ViewModelAction {
    case showToast(message: String)
    case showLoading
    case hideLoading
    case openCamera
    case navigateToSuccess
}
```

### BaseViewModelV2

Generic base class for all ViewModels with reactive state management.

```swift
class BaseViewModelV2<State: ViewModelState, Event: ViewModelEvent, Action: ViewModelAction> {

    // MARK: - State Management
    let stateRelay = BehaviorRelay<State>(value: State.initial)

    // MARK: - Lifecycle
    let disposeBag = DisposeBag()

    // MARK: - Action Management
    let actionSubject = PublishSubject<Action>()
    let commonActionSubject = PublishSubject<CommonViewModelAction>()

    // MARK: - Public Reactive Interfaces
    lazy var stateDriver: Driver<State> = { return stateRelay.asDriver() }()
    lazy var actionDriver: Driver<Action> = { return actionSubject.asDriverOnErrorJustComplete() }()
    lazy var commonActionDriver: Driver<CommonViewModelAction> = { return commonActionSubject.asDriverOnErrorJustComplete() }()

    func emitEvent(_ event: Event) { /* Subclasses override */ }
    func setBinders() { /* Subclasses override */ }

    func updateDataState(builder: (inout State) -> Void) {
        var state = stateRelay.value
        builder(&state)
        stateRelay.accept(state)
    }

    func emitAction(_ action: Action) {
        actionSubject.onNext(action)
    }

    func emitCommonAction(_ action: CommonViewModelAction) {
        commonActionSubject.onNext(action)
    }
}
```

### Concrete ViewModel

```swift
class CICOLocationViewModel: BaseViewModelV2<
    CICOLocationViewModelState,
    CICOLocationViewModelEvent,
    CICOLocationViewModelAction
> {
    // MARK: - INJECTED
    private weak var navigator: (any CICOLocationNavigator)?

    // MARK: - DEPENDENCIES
    private let locationManager: LocationManager
    private let postSubmitCICOUseCase: PostSubmitCICOUseCase

    // MARK: - DATA
    private let currentLocationRelay = BehaviorRelay<CLLocation?>(value: nil)

    // MARK: - INIT
    init(
        navigator: any CICOLocationNavigator,
        locationManager: LocationManager = LocationManager(),
        postSubmitCICOUseCase: PostSubmitCICOUseCase = PostSubmitCICOUseCase.sharedInstance
    ) {
        self.navigator = navigator
        self.locationManager = locationManager
        self.postSubmitCICOUseCase = postSubmitCICOUseCase
        super.init()
    }

    override func emitEvent(_ event: CICOLocationViewModelEvent) {
        switch event {
        case .viewDidLoad:
            handleViewDidLoad()
        case .submitButtonTapped:
            handleSubmit()
        case .backButtonTapped:
            navigator?.back()
        }
    }

    private func handleSubmit() {
        guard let location = currentLocationRelay.value else { return }
        emitAction(.showLoading)

        let params = PostSubmitCICOUseCase.Params(
            companyId: userCompanyId,
            payload: PostSubmitCICOUseCase.Params.Payload(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        )

        postSubmitCICOUseCase.execute(params: params) { [weak self] result in
            self?.emitAction(.hideLoading)
            switch result {
            case .success:
                self?.emitAction(.navigateToSuccess)
            case .failure(let error):
                self?.emitAction(.showToast(message: error.message.orEmpty()))
            }
        }
    }
}
```

### Navigator Protocol Pattern

ViewModels never perform navigation directly. Use Navigator protocol with weak reference:

```swift
protocol CICOLocationNavigator: AnyObject {
    func back(result: CICOLocationResult)
    func showLocationFraudSheet() -> Observable<Void>
}

// In ViewModel
private weak var navigator: (any CICOLocationNavigator)?
```

### Advanced RxSwift Patterns

#### Observable.zip for Parallel Requests

```swift
private func loadInitialData() -> Observable<Action> {
    return Observable.zip(
        getActiveScheduleUseCase.execute(param: nil),
        getLiveAttendanceSettingUseCase.execute(param: nil)
    )
    .map { [weak self] (schedules, liveSetting) -> Action in
        guard let self = self else { return .empty }
        return .dataLoaded(schedule: schedules.first)
    }
    .catch { error in .just(.showError(error.toBaseError())) }
}
```

#### Background Processing with Scheduler

```swift
private func processSchedules(_ schedules: [ScheduleModel]) -> Observable<Action> {
    return Observable.just(schedules)
        .observe(on: backgroundScheduler)
        .compactMap { [weak self] schedules in self?.findDefaultShift(schedules: schedules) }
        .flatMap { $0 }
        .observe(on: mainScheduler)
        .map { index in Action.defaultShiftFound(index: index) }
}
```

### Advanced State Management

```swift
// When to use what:
// State (DataState): Main UI state (loading, success, error)
// BehaviorRelay: Values that change over time, need current value
// PublishSubject: One-time events or commands (navigation, user actions)
// Driver: Safe UI binding (never errors, on main thread)
```

### Memory Management

Always implement `deinit` to clean up resources:

```swift
deinit {
    print("deinit:: \(String(describing: Self.self))")
    locationManager.stopUpdatingLocation()
    locationManager.delegate = nil
    backEventSubject.onCompleted()
    timerDisposable?.dispose()
}
```

### Layer Invariants

- ViewModel never imports from the data layer — no DTOs, no `RepositoryImpl`, no `DataSource`
- Use cases injected via constructor — never `UseCase()` inside a ViewModel body
- State is read-only from ViewController's perspective
- Actions are one-shot — emitted through `PublishSubject`, never stored in `stateRelay`
- Navigation belongs to a Navigator/Coordinator — ViewModel emits the intent, never pushes a ViewController

---

# Dependency Injection

## DI Setup

### Theory

Core rules regardless of DI framework:

1. **Constructor injection** — dependencies are declared as constructor parameters, never fetched inside a class body
2. **Depend on interfaces, not implementations** — callers reference abstract types; the container resolves the concrete class
3. **No `new` inside business logic** — use cases, StateHolders, and repository implementations never instantiate their own dependencies
4. **Container owns lifecycle** — the DI container decides whether a dependency is a singleton, feature-scoped, or transient
5. **One container per runtime boundary** — each runtime gets its own container; never share a container across boundaries

---

### Architecture Overview

Constructor Injection with defaults is the current pattern — dependencies are injected via `init` parameters that default to shared singletons. The Manual DI Container pattern is the target architecture.

### Manual DI Container Pattern

```swift
// Shared/DI/SharedDIContainer.swift
final class SharedDIContainer {

    static let shared = SharedDIContainer()
    private init() {}

    enum Environment {
        case production
        case development
        case testing
    }

    private(set) var environment: Environment = .production

    func configure(for environment: Environment) {
        self.environment = environment
    }

    lazy var baseErrorMapper: BaseErrorModelMapper = { BaseErrorModelMapper() }()

    lazy var networkMonitor: NetworkMonitoring = {
        switch environment {
        case .production, .development:
            return NetworkMonitor.shared
        case .testing:
            return MockNetworkMonitor()
        }
    }()

    lazy var analyticsService: AnalyticsService = {
        switch environment {
        case .production:
            return FirebaseAnalyticsService.shared
        case .development:
            return DebugAnalyticsService()
        case .testing:
            return MockAnalyticsService()
        }
    }()
}
```

### Feature Module DI Container

```swift
final class FeatureDIContainer {

    static let shared = FeatureDIContainer()
    private init() {}

    private let sharedContainer = SharedDIContainer.shared

    // Data Layer - DataSources
    lazy var liveAttendanceRemoteDataSource: LiveAttendanceRemoteDataSource = {
        LiveAttendanceRemoteDataSourceImpl()
    }()

    // Data Layer - Repositories
    lazy var liveAttendanceRepository: LiveAttendanceRepository = {
        LiveAttendanceRepositoryImpl(
            remoteDataSource: liveAttendanceRemoteDataSource,
            baseErrorModelMapper: sharedContainer.baseErrorMapper
        )
    }()

    // Domain Layer - UseCases
    lazy var postSubmitCICOUseCase: PostSubmitCICOUseCaseType = {
        PostSubmitCICOUseCase(repository: liveAttendanceRepository)
    }()

    // Factory Methods (for ViewModels — never singletons)
    func makeCICOLocationViewModel(navigator: CICOLocationNavigator) -> CICOLocationViewModel {
        CICOLocationViewModel(
            navigator: navigator,
            postSubmitCICOUseCase: postSubmitCICOUseCase,
            locationManager: sharedContainer.locationManager
        )
    }
}
```

### DI Principles

| Component | Lifecycle | Managed By |
|-----------|-----------|------------|
| **Repositories** | Singleton (lazy) | DI Container |
| **Mappers** | Singleton (lazy) | DI Container |
| **UseCases** | Singleton (lazy) | DI Container |
| **Services** | Singleton (lazy) | DI Container |
| **ViewModels** | Factory (new instance) | DI Container `make*()` methods |
| **Coordinators** | Factory (new instance) | Parent coordinator |
| **ViewControllers** | Factory (new instance) | Coordinator |

## Registration Order

### Theory

Dependencies must be registered before they are resolved. The correct registration order mirrors the dependency graph:

```
Infrastructure (HTTP client, DB driver)
  → DataSources
  → Mappers
  → Repository Implementations
  → Use Cases
  → StateHolders
```

Register leaf nodes (no dependencies) first. Register consumers after their dependencies.

---

### Registration Order

```swift
// SharedDIContainer.swift — infrastructure first
lazy var networkMonitor: NetworkMonitoring = NetworkMonitor.shared
lazy var locationManager: LocationManager = LocationManager()
lazy var baseErrorMapper: BaseErrorModelMapper = BaseErrorModelMapper()

// Feature DI Container — data layer
lazy var liveAttendanceRemoteDataSource: LiveAttendanceRemoteDataSource = LiveAttendanceRemoteDataSourceImpl()
lazy var liveAttendanceRepository: LiveAttendanceRepository = LiveAttendanceRepositoryImpl(
    remoteDataSource: liveAttendanceRemoteDataSource
)

// Domain layer — use cases depend on repositories
lazy var postSubmitCICOUseCase: PostSubmitCICOUseCaseType = PostSubmitCICOUseCase(repository: liveAttendanceRepository)

// Presentation — ViewModels created via factory methods, never as singletons
func makeCICOLocationViewModel(navigator: CICOLocationNavigator) -> CICOLocationViewModel { ... }
```

### Scope Rules

| Scope | Swift pattern | Use for |
|---|---|---|
| Singleton (lazy) | `lazy var` on the container | Repositories, use cases, mappers, data sources — stateless, shared |
| Factory | `func make*()` on the container | ViewModels — stateful, must be fresh per screen |
| Per-coordinator | Stored on the `Coordinator` instance | Coordinators — owned by their parent coordinator |

**Never register a ViewModel as a `lazy var` singleton** — it holds mutable UI state that must reset when the screen is destroyed. Always use `make*()` factory methods.

## Testing with DI

### Theory

- Swap real implementations for test doubles at registration time — the caller never changes
- Each test gets its own container instance — never share container state across tests
- Verify that the container resolves the full dependency graph in an integration test — catches missing registrations before runtime

---

### Testing with DI Container

```swift
final class CICOLocationViewModelTest: XCTestCase {

    var sut: CICOLocationViewModel!
    var mockNavigator: MockCICOLocationNavigator!
    var mockPostSubmitCICOUseCase: MockPostSubmitCICOUseCase!

    override func setUp() {
        super.setUp()

        // Configure test environment
        SharedDIContainer.shared.configure(for: .testing)

        // Create mocks
        mockNavigator = MockCICOLocationNavigator()
        mockPostSubmitCICOUseCase = MockPostSubmitCICOUseCase()

        // Inject mocks via constructor
        sut = CICOLocationViewModel(
            navigator: mockNavigator,
            postSubmitCICOUseCase: mockPostSubmitCICOUseCase,
            locationManager: MockLocationManager()
        )
    }

    override func tearDown() {
        sut = nil
        mockNavigator = nil
        mockPostSubmitCICOUseCase = nil
        super.tearDown()
    }
}
```

Configure the container for `.testing` environment, then inject mocks via constructor parameters — never let the test resolve real dependencies from the shared container.

### Benefits of Manual DI Container

| Benefit | Description |
|---------|-------------|
| Zero Framework Overhead | No code generation or runtime reflection |
| Explicit Dependencies | All dependencies visible in one place per module |
| Environment Switching | Easy to swap prod/dev/test implementations |
| Debuggable | Step through container code, no magic |
| Type-Safe | Compile-time checks, no string-based lookups |
| Testable | Override specific dependencies in tests via constructor injection |
| Modular | Each feature module has own container, clear boundaries |
| Lazy Initialization | Dependencies created only when needed |

---

# Navigation

## Coordinator

### Theory

A **Navigator** / **Coordinator** is the single owner of navigation logic for a feature or flow.

**Invariants:**
- Defined as an interface/protocol — the Screen or Presenter holds only the interface, never the concrete type
- Implemented in a separate class that knows how to resolve the destination
- The StateHolder (ViewModel) emits a navigation intent — the Coordinator decides the implementation
- Knows route constants or destination types — the Screen does not
- One Coordinator per feature flow — not per screen
- Injected into the StateHolder — never instantiated by the Screen or StateHolder directly

**When to create:** When a screen navigates to another screen. Created after the Screen that triggers navigation.

---

### Navigator Protocol

Define navigation methods as a protocol that the coordinator implements:

```swift
// Presentation/Coordinator/DashboardNavigator.swift
protocol DashboardNavigator: AnyObject {
    // Simple navigation (no result)
    func openTimeOff()
    func openPayslip()

    // Navigation with return value (Observable)
    func openLiveAttendance(isShowCSAT: Bool) -> Observable<LiveAttendanceResult>
    func showAllReimbursement() -> Observable<ReimbursementBottomSheetResult>

    // Navigation with parameters
    func openReimbursementIndex(requestReimbursementId: Int?)
    func showAnnouncementDetails(id: Int)
}
```

**Navigator Rules:**
- Methods that need results return `Observable<Result>`
- Methods with simple navigation return `Void`
- All methods take necessary parameters (IDs, flags, models)

### Coordinator Pattern

```swift
// Presentation/Coordinator/DashboardCoordinator.swift
final class DashboardCoordinator: BaseCoordinator<Void> {

    private let container = DashboardDIContainer.shared

    init(navigationController: UINavigationController?) {
        super.init()
        self.defaultNavigationController = navigationController
    }

    override func createController() -> UIViewController {
        let viewModel = container.makeDashboardViewModel(navigator: self)
        let viewController = DashboardViewController(viewModel: viewModel)
        self.defaultController = viewController
        return viewController
    }
}

extension DashboardCoordinator: DashboardNavigator {

    func openTimeOff() {
        guard let navVc = self.defaultNavigationController else { return }
        // Navigate to time off
    }

    func openLiveAttendance(isShowCSAT: Bool) -> Observable<LiveAttendanceResult> {
        let coordinator = LiveAttendanceCoordinator(
            navigationController: self.defaultNavigationController,
            isShowCSAT: isShowCSAT
        )
        return self.coordinate(to: coordinator)
    }
}
```

### Coordinator Lifecycle Management

```swift
// Start child coordinator with result
func openSomeFeature() -> Observable<FeatureResult> {
    let coordinator = FeatureCoordinator(navigationController: self.defaultNavigationController)
    // coordinate(to:) automatically:
    // 1. Adds child to childCoordinators array
    // 2. Calls coordinator.start()
    // 3. Returns Observable<Result>
    // 4. Removes child when Observable completes
    return self.coordinate(to: coordinator)
}

// Start child coordinator without result
func openAnotherFeature() {
    let coordinator = AnotherFeatureCoordinator(navigationController: self.defaultNavigationController)
    self.coordinate(to: coordinator)
        .subscribe()
        .disposed(by: disposeBag)
}
```

### Coordinator Patterns Summary

| Pattern | When to Use | Example |
|---------|-------------|---------|
| **Simple push** | Direct ViewController push | `navigationController?.pushViewController(vc, animated: true)` |
| **Child coordinator (no result)** | Feature with own navigation flow | `coordinate(to: FeatureCoordinator()).subscribe()` |
| **Child coordinator (with result)** | Need callback from child | `coordinate(to: FeatureCoordinator()) -> Observable<Result>` |
| **Bottom sheet** | Modal presentation with custom view | `presentBottomSheet(view: customView, ...)` |

**Coordinator Pattern Rules:**
- Inherit from `BaseCoordinator<ResultType>`
- Define `Navigator` protocol for all navigation methods
- Implement protocol in extension
- Use DI Container factory methods for ViewModel creation
- Use `coordinate(to:)` for child coordinator management
- Dispose subscriptions with `disposeBag`

---

# Error Handling

## Error Flow

### Theory

Errors travel inward-to-outward, mapped at each layer boundary:

```
DataSource throws transport error (NetworkError, HTTP 4xx/5xx, DB exception)
    ↓ caught and mapped by
Repository Implementation → DomainError
    ↓ returned to
Use Case → propagates DomainError unchanged
    ↓ received by
StateHolder → maps to UI error State
    ↓ observed by
Screen → renders error UI
```

**Rule:** Each layer catches the error type from the layer below it and converts it to the type its consumers expect. No raw transport errors escape the Data layer. No domain errors escape the Presentation layer uncaught.

---

### Error Flow

```
DataSource throws NetworkError
    ↓ caught by
Repository transforms to BaseErrorModel
    ↓ propagated via
UseCase (passes through or enriches)
    ↓ caught by
ViewModel maps to user message → Action
    ↓ rendered by
ViewController shows error UI
```

### Error Types

```swift
// Shared/Domain/Entities/BaseErrorModel.swift
struct BaseErrorModel: Error {
    let status: Int?
    let message: String
    let errors: [String: [String]]?

    init(
        status: Int? = nil,
        message: String = "An error occurred",
        errors: [String: [String]]? = nil
    ) {
        self.status = status
        self.message = message
        self.errors = errors
    }
}
```

### Result Type

```swift
Result<Model, BaseErrorModel>

// Success
expected(.success(model))

// Failure
expected(.failure(BaseErrorModel(message: "Network error")))
```

All UseCase/Repository completions use `Result<Model, BaseErrorModel>`.

### Error Mapping

```swift
// Shared/Data/Mapper/BaseErrorModelMapper.swift
class BaseErrorModelMapper {
    func fromResponseToModel(from error: BaseError) -> BaseErrorModel {
        return BaseErrorModel(
            status: error.status,
            message: error.message.orEmpty(),
            errors: error.errors
        )
    }
}
```

### Error UI

ViewController observes ViewModel actions to surface errors:

```swift
viewModel.actionDriver
    .drive(onNext: { [weak self] action in
        switch action {
        case .showError(let message):
            self?.showErrorAlert(message: message)
        case .showToast(let message):
            self?.showToast(message)
        case .showFieldErrors(let errors):
            self?.showValidationErrors(errors)
        default:
            break
        }
    })
    .disposed(by: disposeBag)
```

### Layer Invariants

- DataSources throw `NetworkError` — they never return `nil` or a partial `Result` to signal failure
- Repository implementations always catch and map to `BaseErrorModel` — no `NetworkError` propagates to use cases
- Use cases propagate `Result<Model, BaseErrorModel>` unchanged — they do not re-map errors
- ViewModels catch all results from use cases — no unhandled `Result.failure` reaches the ViewController
- ViewControllers never inspect `BaseErrorModel` codes directly — they render the `Action` the ViewModel emits

---

# Testing

## Test Pyramid

### Theory

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

**Distribution target:** unit-heavy, integration-light, e2e-minimal.

---

### Test Pyramid

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

### What to Test Per Layer

| Layer | What to test | What NOT to test |
|---|---|---|
| Domain (UseCases, Services) | Business rules, edge cases, error conditions | Implementation details of other layers |
| Data (Mappers, RepositoryImpl) | DTO → entity field mapping; error propagation to domain | Network stack, real server responses |
| Presentation (ViewModel) | State transitions per event; use case call count and params; action emissions | UIKit rendering, view layout |
| UI (XCUITest) | Critical happy-path user journeys only | Business logic, mapping logic |

### Service Tests

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

### Test Naming Convention

Pattern: `test_[unitUnderTest]_[scenario]_[expectedOutcome]`

Examples:
- `test_remainingBalance_noPending_returnsCorrectBalance`
- `test_fromResponseToModel_mapsAllFields`
- `test_getEmployee_success_callsCompletion_withMappedModel`
- `test_emitEvent_viewDidLoad_shouldUpdateState`

## Mapper Test

### Theory

Mapper tests are pure input → output assertions — the simplest tests to write:

- Provide a fully-populated DTO → assert every field maps to the correct entity field
- Provide a DTO with missing/null optional fields → assert safe defaults or null handling
- No mocks needed — mappers have no dependencies

---

### Mapper Tests

```swift
class EmployeeModelMapperTests: XCTestCase {
    var sut: EmployeeModelMapper!

    override func setUp() {
        super.setUp()
        sut = EmployeeModelMapper()
    }

    func test_fromResponseToModel_mapsAllFields() {
        let response = EmployeeResponse(id: 1, name: "John Doe", isActive: true)

        let model = sut.fromResponseToModel(from: response)

        XCTAssertEqual(model.id, 1)
        XCTAssertEqual(model.name, "John Doe")
        XCTAssertTrue(model.isActive)
    }

    func test_fromResponseToModel_handlesNilFields() {
        let response = EmployeeResponse(id: nil, name: nil, isActive: nil)

        let model = sut.fromResponseToModel(from: response)

        XCTAssertEqual(model.id, 0)    // .orZero()
        XCTAssertEqual(model.name, "") // .orEmpty()
        XCTAssertFalse(model.isActive) // .orFalse()
    }
}
```

**Rules:**
- One test for the happy path (all fields present)
- One test for nil handling — verify `.orZero()`, `.orEmpty()`, `.orFalse()` defaults
- Every Entity field must appear in at least one assertion

### Mock vs Real

| Use a mock/stub when… | Use a real implementation when… |
|---|---|
| The dependency has I/O (network, HTTP, DB) | The dependency is pure (Mapper, Domain Service) |
| The test must control exact return values | The test verifies the full integration path |
| Unit test speed matters | Correctness of full wiring matters — integration test |

**Never mock Mappers or Domain Services** — they are pure functions.

## Presenter Test

### Theory

| Use a mock/stub when… | Use a real implementation when… |
|---|---|
| The dependency has I/O (network, DB, file) | The dependency is pure (mappers, domain services) |
| The test must control exact return values | The test verifies the full integration path |
| Speed matters — unit test suite | Correctness of wiring matters — integration test |

---

### Presenter Tests

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
        var receivedStates: [CICOLocationViewModelState] = []

        sut.stateDriver
            .drive(onNext: { state in receivedStates.append(state) })
            .disposed(by: disposeBag)

        sut.emitEvent(.viewDidLoad)

        XCTAssertEqual(receivedStates.last?.appBarTitle, "Check In")
    }
}
```

### Mock Pattern

```swift
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
        if let result = resultToReturn { completion(result) }
    }

    func reset() {
        callCount = 0
        paramsReceived = nil
        resultToReturn = nil
    }
}
```

## Repository Test

### Theory

Repository implementation tests verify the bridge between DataSource and Domain:

- Use a test double (mock/stub) for the DataSource — not a real network or DB
- Assert that the repository maps DataSource output to the correct domain entity
- Assert that DataSource errors are caught and mapped to the correct domain error type
- One test per operation (get, create, update, delete)

---

### Repository Tests

```swift
class EmployeeRepositoryImplTests: XCTestCase {
    var sut: EmployeeRepositoryImpl!
    var dataSourceMock: EmployeeDataSourceMock!
    var mapperMock: EmployeeModelMapperMock!

    override func setUp() {
        super.setUp()
        dataSourceMock = EmployeeDataSourceMock()
        mapperMock = EmployeeModelMapperMock()
        sut = EmployeeRepositoryImpl(dataSource: dataSourceMock, mapper: mapperMock)
    }

    func test_getEmployee_success_callsCompletion_withMappedModel() {
        let response = EmployeeResponse(id: 1, name: "John")
        let expectedModel = EmployeeModel(id: 1, name: "John")
        dataSourceMock.resultToReturn = .success(response)
        mapperMock.modelToReturn = expectedModel

        var receivedResult: Result<EmployeeModel, BaseErrorModel>?
        sut.getEmployee(params: .init(id: "1")) { receivedResult = $0 }

        XCTAssertEqual(try? receivedResult?.get().id, 1)
        XCTAssertEqual(mapperMock.fromResponseCallCount, 1)
    }

    func test_getEmployee_failure_propagatesError() {
        let error = BaseErrorModel(message: "Not found")
        dataSourceMock.resultToReturn = .failure(error)

        var receivedResult: Result<EmployeeModel, BaseErrorModel>?
        sut.getEmployee(params: .init(id: "99")) { receivedResult = $0 }

        if case .failure(let e) = receivedResult {
            XCTAssertEqual(e.message, "Not found")
        } else {
            XCTFail("Expected failure")
        }
    }
}
```

## Procedure

### Test File Naming

Pattern: `<SourceFileName>Test.swift`

Examples:
- `GetMyFilesUseCase.swift` → `GetMyFilesUseCaseTest.swift`
- `MyFileViewModel.swift` → `MyFileViewModelTest.swift`
- `AnnouncementRepositoryImpl.swift` → `AnnouncementRepositoryTest.swift`

### Test File Location

Mirror the source path under `AppTests/Module/`:

```
Source:  App/<Module>/<Layer>/<ClassName>.swift
Test:    AppTests/Module/<Module>/<Layer>/<ClassName>Test.swift
```

### Test File Scaffold

```swift
import XCTest
@testable import MyApp

final class ClassNameTest: XCTestCase {
    private var sut: ClassName!
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

### Mock Strategy

Mocks are written by hand. Each mock implements the protocol of the dependency being replaced.

**Mock requirements:**
- Track calls: `var callCount = 0`, `var capturedParams: Params? = nil`
- Support sequential results: `var mockResult: [Result<Model, Error>] = []`
- Implement `reset()` to clear state between tests
- Access array results via `[safe:]` subscript to avoid index-out-of-bounds crashes

**Mock pattern:**
```swift
class ProtocolMock: Protocol {
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

### Test Naming Convention

```
test[EventName]Event_[LogicOrMethodName]_[Condition]_[Outcome]
```

For use-case and repository tests:
```
test_<method>_<condition>
```

### Test Structure (Arrange-Act-Assert)

```swift
func test_<method>_<condition>() {
    // GIVEN
    let expectedModel = Model(...)
    mockDependency.mockResult = [.success(expectedModel)]

    // WHEN
    let exp = expectation(description: "completion")
    sut.call(params: params) { result in
        // THEN
        switch result {
        case .success(let model):
            XCTAssertEqual(model.field, expectedModel.field)
        case .failure:
            XCTFail("Expected success")
        }
        exp.fulfill()
    }
    waitForExpectations(timeout: 1)
}
```

### Failure Patterns

| Symptom | Diagnosis | Fix |
|---|---|---|
| `callCount == 0` | Guard condition not satisfied | Add missing mock setup before the guard |
| State field wrong | Mock default differs from expectation | Assert against actual default or override it |
| Array index OOB | `mockResult` has fewer entries than calls | Extend `mockResult` to match total call count |
| Compilation error — missing method on mock | Protocol changed | Add the new method to the mock class |

---

# App

## Analytics Constants

### Theory

**Analytics Constants** are feature-scoped files that declare the event names, screen names, or tracking identifiers reported to the analytics service.

**Invariants:**
- One constants file per feature — never share event names across features in a single file
- Constants are plain string literals — no logic, no SDK imports
- Analytics SDK calls are made in the Presentation layer (ViewModel) — these files only declare the identifiers

**When to create:** Any feature that instruments user interactions or screen views.

---

### Analytics Constants

Event names and screen identifiers are declared as a Swift struct in the feature's `Constants/` directory.

```swift
// Module/{Feature}/Constants/{Feature}FirebaseName.swift
struct FeatureFirebaseName {
    static let screenName  = "feature_screen"
    static let tapEvent    = "feature_tap"
    static let submitEvent = "feature_submit"
}
```

**Rules:**
- One `struct` per feature — no shared analytics constants file
- `static let` string constants only — no logic, no SDK imports
- snake_case values match Firebase naming convention
- Never import the Analytics SDK in this constants file
- Never use inline string literals in ViewModels — always reference these constants

## Deeplink Registration

### Theory

**Deeplink Registration** is the act of mapping incoming URLs and notification taps to screens or flows within the app.

**Invariants:**
- Mappings live at the app shell — never inside individual feature modules
- URL parsing is separated from routing — the parser produces a route identifier, the router acts on it
- Each feature declares its own deeplink paths; the app shell assembles the complete registry
- Deeplinks arriving while the app is backgrounded or unauthenticated must be queued and replayed after auth completes

**When to add:** Any feature reachable from a push notification tap, an external URL, or a cross-app link.

---

### Deeplink Registration

All deeplink sources — push notification taps, URL schemes, universal links, and home screen quick actions — converge on a single `DeeplinkStream` singleton. Coordinators subscribe to the stream; they never parse URLs or payloads directly.

**Step 1 — Register the path in `DeeplinkPath`:**

```swift
enum DeeplinkPath: String {
    // ... existing cases
    case feature = "feature-url-path"  // ← raw value = URL path
}
```

**Step 2 — Add a routing method to `DeeplinkComponent`:**

```swift
extension DeeplinkComponent {
    func coordinateFeature() -> Observable<Void> {
        let component = FeatureComponent(parent: self)
        let coordinator = FeatureCoordinator(
            navigationController: rootNavigationController,
            component: component
        )
        return coordinate(to: coordinator).map { _ in }
    }
}
```

**Step 3 — Subscribe in the consuming coordinator:**

```swift
deeplinkStream?.deeplinkData
    .subscribe(onNext: { [weak self] data in
        guard let data = data else { return }
        switch data.link {
        case .feature:
            self?.coordinateFeature()
        default: break
        }
    })
    .disposed(by: disposeBag)
```

**Rules:**
- `DeeplinkPath` raw value is the URL path string — confirm with backend/web team
- After handling, clear the stream: `deeplinkStream?.set(deeplink: nil)`
- Never parse URLs or push payloads directly in coordinators or ViewModels
- Never add a second deeplink dispatch path — all sources must write to the same shared stream

## Dependency Registration

### Theory

**Dependency Registration** is the act of binding concrete implementations to their interfaces in the app's DI container.

**Invariants:**
- Bindings live at the app shell — never inside a CLEAN layer
- Each feature owns its own registration unit — one file per feature
- Use cases and repositories are registered, not constructed inline at call sites
- Registration order follows the dependency graph: data sources → repositories → use cases

**When to add:** Any time a new use case, repository implementation, or data source is introduced.

---

### Dependency Registration

Uses a compile-time, hierarchical component tree. Each feature has its own `Component<DependencyType>`.

**Component hierarchy:**
```
RootComponent
  └── MainTabComponent
        └── {Feature}Component (child component per feature)
```

**Step 1 — Define the Dependency protocol:**

```swift
// DIComponents/{Feature}/{Feature}Dependency.swift
protocol FeatureDependency: Dependency {
    var getFeatureUseCase: GetFeatureUseCase { get }
    var featureRepository: FeatureRepository { get }
}
```

**Step 2 — Implement the Component:**

```swift
// DIComponents/{Feature}/{Feature}Component.swift
final class FeatureComponent: Component<FeatureDependency> {
    var getFeatureUseCase: GetFeatureUseCase {
        GetFeatureUseCase(repository: dependency.featureRepository)
    }

    var featureRepository: FeatureRepository {
        FeatureRepositoryImpl.sharedInstance
    }
}
```

**Rules:**
- One `Component` per feature
- Declare dependencies in the `Dependency` protocol — never access sibling components directly
- No service locators or singletons except `sharedInstance` on `*Impl` types

## Feature Flag Registration

### Theory

**Feature Flag Registration** is the act of declaring a new feature-gating key in the app's centralized flag registry.

**Invariants:**
- Flag keys live in a centralized registry — never as inline string literals at call sites
- One key per feature toggle — never reuse an existing flag for a different purpose
- Default values are explicit — the flag's behavior when unset must be defined in the registry

**When to add:** Any feature that requires remote gating, gradual rollout, or a kill switch.

---

### Feature Flag Registration

Add a new case to the feature identity enum — the case name is the flag key.

```swift
enum FeatureIdentity: String {
    // ... existing cases
    case isEnableFeature  // ← add here — case name = feature flag key
}
```

**Read the flag value:**

```swift
// In ViewModel — inject the flag provider protocol
let isEnabled = flagProvider.getBoolValue(forFeature: FeatureIdentity.isEnableFeature.rawValue)
```

**Rules:**
- Case name must exactly match the flag key string configured in the feature flag service
- Inject `FlagCustomProtocol` — never access the provider directly in business logic
- Never use raw string literals for flag keys — always reference the enum

## Push Notification Registration

### Theory

**Push Notification Registration** is the act of wiring the app to receive push notifications — fetching the device token, delivering it to the server, and removing it on logout.

**Invariants:**
- Registration is owned by the infrastructure layer — never by an individual feature
- The notification manager is wired once at the app shell, not inside feature modules
- Payload routing is declared separately from payload receipt
- Silent push notifications must route through domain use cases

**When to add:** Once per app. Token lifecycle is tied to the auth flow.

---

### Push Notification Registration

Push notifications and deeplinks share the same delivery path — both ultimately write to the shared deeplink stream. No per-feature notification registration is needed; the infrastructure is wired once in `AppDelegate`.

**Token lifecycle:**
- `AppDelegate.messaging(_:didReceiveRegistrationToken:)` receives new FCM tokens → stores locally and posts to server via use case
- On logout: delete token from server, clear local storage, and remove from the Messaging SDK
- Token lifecycle is **not** automatic — the auth flow must explicitly call `postToken()` on login and `deletePostToken()` on logout

**Notification tap → deeplink routing:**

`AppDelegate` receives the notification tap → delegates to `FCMManager.handlePushNotification(userInfo:)` which parses the payload by `navigation_type` and writes to the shared deeplink stream.

**When a new notification type must route to a new screen:** add a `DeeplinkPath` case and ensure the push payload includes the screen path with that case's rawValue.

## Route Registration

### Theory

**Route Registration** is the act of declaring how the app navigates to a feature's screen.

**Invariants:**
- Routes live at the app shell or navigation coordinator — never inside a CLEAN layer
- Each feature owns one route declaration unit (coordinator class)
- Route identifiers are stable typed values — not view instances
- Deep link destinations must be registered in the same place as regular routes

**When to add:** Any time a new screen is introduced.

---

### Route Registration

Uses the **Coordinator pattern** with `BaseCoordinator<ResultType>`.

**Step 1 — Create the Feature Coordinator:**

```swift
// Controllers/{Feature}/{Feature}Coordinator.swift
final class FeatureCoordinator: BaseCoordinator<FeatureResult> {

    private let navigationController: UINavigationController
    private let component: FeatureComponent

    init(
        navigationController: UINavigationController,
        component: FeatureComponent
    ) {
        self.navigationController = navigationController
        self.component = component
    }

    override func start() -> Observable<FeatureResult> {
        let viewModel = FeatureViewModel(
            navigator: self,
            getFeatureUseCase: component.getFeatureUseCase
        )
        let viewController = FeatureViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)

        return viewModel.result
            .take(1)
            .do(onNext: { [weak self] _ in
                self?.navigationController.popViewController(animated: true)
            })
    }
}
```

**Step 2 — Register deep link (if applicable):**

```swift
extension DeeplinkComponent {
    func coordinateFeature(path: String) -> Observable<Void> {
        let component = FeatureComponent(parent: self)
        let coordinator = FeatureCoordinator(
            navigationController: rootNavigationController,
            component: component
        )
        return coordinate(to: coordinator).map { _ in }
    }
}
```

**Rules:**
- One coordinator per feature flow
- `BaseCoordinator<ResultType>` — result type models what the coordinator returns to its parent
- Rx lifecycle: `start()` returns `Observable<ResultType>` — parent subscribes
- No `UIViewController` subclasses performing navigation directly

---

# UI

## Screen Structure

### Theory

UI depends on Presentation only. It never imports from Domain or Data directly.

```
Presentation  ←  UI
```

Allowed imports: StateHolder contract types, State/Event/Action types, platform UI framework primitives.
Forbidden: use case interfaces, repository interfaces, DTOs, mappers, datasources, or any domain/data type instantiated directly.

---

### Dependency Rule

UI depends on Presentation only — never imports Domain or Data directly.

Allowed imports: `ViewModel` protocol types, `State`/`Action` types, UIKit primitives.
Forbidden: use case interfaces, repository interfaces, DTOs, mappers, datasources.

### Screen

A **Screen** is a `UIViewController` bound to a single `ViewModel` (protocol). It observes state via RxSwift bindings and sends actions — it contains no business logic.

**Invariants:**
- Bound to exactly one `ViewModel` protocol — injected via Coordinator, never `init`-ed directly
- Observes every state field emitted by the ViewModel — no state goes unhandled
- Sends user actions to the ViewModel for every user interaction — never mutates state directly
- Contains no business logic — `if`/`switch` only decides what to render
- No use case calls — all data flows through the ViewModel

### Component / Sub-view

A **Component** is a reusable `UIView` or self-contained view class smaller than a full screen.

**Invariants:**
- Stateless by default — configured via a `configure(with:)` method or `UIModel` struct
- If stateful, driven by a scoped ViewModel
- No use case calls — all data passed in from the parent ViewController or a scoped ViewModel
- Reuse check required before creating — search shared component targets first

### Navigator / Coordinator

A **Coordinator** (inheriting `BaseCoordinator<T>`) owns all navigation logic for a feature or flow.

**Invariants:**
- The ViewController delegates navigation intent to the Coordinator via the Navigator protocol
- The ViewModel emits a navigation `Action` — the Coordinator decides the implementation
- Navigator protocol defines all navigation methods — the ViewController holds only the protocol reference
- One Coordinator per feature flow — not per ViewController

### Creation Order

```
UIViewController → Coordinator (if navigation needed) → DIContainer factory method
```

The ViewModel protocol and its concrete implementation must exist before any UI layer file is written.

### Layer Invariants

- ViewController never mutates state directly — observes RxSwift streams only
- ViewController never calls use cases directly — all interactions go through the ViewModel
- ViewModel instantiated by the Coordinator via constructor injection
- Navigation delegated to Coordinator — ViewController emits intent via Navigator protocol
- No data layer knowledge — no DTOs, no datasources, no network types visible in UI files

### Glob Patterns for Exploration

- `**/Presentation/**/*ViewController.swift` — screen files
- `**/Presentation/Common/Views/**/*.swift` — shared component files
- `**/Presentation/Coordinator/**/*Coordinator.swift` — coordinator files
- `**/Presentation/Coordinator/**/*Navigator.swift` — navigator protocol files

---

# Project Structure

## Project Structure

### Modular Architecture (Feature-Based)

```
App/Module/
├── FeatureA/                          # e.g. Time Management
│   ├── DI/                            # DI Container
│   │   └── FeatureADIContainer.swift
│   ├── Data/
│   │   ├── Models/                    # API response models (DTOs)
│   │   ├── Mapper/                    # Response → Domain Entity mappers
│   │   ├── DataSource/                # Remote/Local data sources
│   │   │   ├── Remote/
│   │   │   └── Local/
│   │   └── RepositoriesImpl/          # Repository implementations
│   ├── Domain/
│   │   ├── Entities/                  # Business models
│   │   ├── Repository/                # Repository protocols
│   │   ├── UseCase/                   # UseCases (with nested Params)
│   │   ├── Services/                  # Business logic services (optional)
│   │   └── enum/                      # Domain enums
│   └── Presentation/
│       ├── Coordinator/               # Navigation coordinators
│       ├── ViewModel/                 # ViewModels (State/Event/Action)
│       ├── View/                      # ViewControllers
│       └── Views/                     # Custom UI components
```

**Key:** Params live **inside** each UseCase as nested structs — no separate `Param/Query/` directories.

### App Shell (AppLayer)

The outermost ring that wires everything together — OS entry points, composition root, and platform event routing.

```
App/AppLayer/
├── AppDelegate.swift                  # Process-level setup
├── SceneDelegate.swift                # Scene lifecycle + window setup
└── Deeplink/
    └── DeeplinkManager.swift          # URL / universal link / shortcut → DeeplinkStream
```

**Rules:**
- Can depend on everything: `Module/`, `Shared/`, `DIComponents/`
- Nothing else depends on `AppLayer/`
- No business logic — only OS event translation and wiring

### Shared Layer

```
App/Shared/
├── DI/                                # Shared DI Container
├── Data/
│   ├── Models/                        # Shared response models
│   ├── Mapper/                        # BaseErrorModelMapper, shared mappers
│   ├── DataSource/                    # Shared data sources
│   └── RepositoryImpl/                # Shared repository implementations
├── Domain/
│   ├── Base/                          # BaseViewModelV2
│   ├── Entities/                      # BaseErrorModel, shared entities
│   ├── Repository/                    # Shared repository protocols
│   ├── UseCase/                       # Shared use cases
│   └── UseCaseType.swift              # UseCase protocol definitions
├── Presentation/
│   ├── Base/                          # BaseViewController
│   └── Components/                    # Shared UI components
├── Infrastructure/                    # Platform/SDK adapters
│   ├── Notifications/                 # FCMManager
│   ├── Analytics/                     # Analytics managers
│   ├── Location/                      # LocationManager
│   └── FeatureFlag/                   # FeatureFlagManager
├── Extension/                         # orEmpty(), orFalse(), etc.
└── Network/                           # Moya API definitions
```

**Infrastructure Rules:**
- Platform/SDK adapters — have side effects, wrap external frameworks
- Can depend on `Shared/Domain/`, `Shared/Data/`, external SDKs
- Cannot depend on `AppLayer/` or any `Module/`
- Distinguished from `Domain/Services/` which must be pure (no I/O)

### File Naming Conventions

| Component | Naming | Example |
|-----------|--------|---------|
| Entity | `[Feature]Model` | `RequestLiveAttendanceModel` |
| Response | `[Feature]Response` | `RequestLiveAttendanceResponse` |
| Mapper | `[Feature]ModelMapper` | `RequestLiveAttendanceModelMapper` |
| Mapper Protocol | `[Feature]ModelMapperType` | `RequestLiveAttendanceModelMapperType` |
| UseCase | `[HttpMethod][Feature]UseCase` | `PostSubmitCICOUseCase` |
| UseCase Protocol | `[UseCase]Type` | `PostSubmitCICOUseCaseType` |
| Repository Protocol | `[Feature]Repository` | `LiveAttendanceRepository` |
| Repository Impl | `[Feature]RepositoryImpl` | `LiveAttendanceRepositoryImpl` |
| DataSource Protocol | `[Feature]RemoteDataSource` | `LiveAttendanceRemoteDataSource` |
| DataSource Impl | `[Feature]RemoteDataSourceImpl` | `LiveAttendanceRemoteDataSourceImpl` |
| ViewModel | `[Feature]ViewModel` | `CICOLocationViewModel` |
| ViewModel State | `[Feature]ViewModelState` | `CICOLocationViewModelState` |
| ViewModel Event | `[Feature]ViewModelEvent` | `CICOLocationViewModelEvent` |
| ViewModel Action | `[Feature]ViewModelAction` | `CICOLocationViewModelAction` |
| ViewController | `[Feature]ViewController` | `CICOLocationViewController` |
| Coordinator | `[Feature]Coordinator` | `CICOLocationCoordinator` |
| Navigator Protocol | `[Feature]Navigator` | `CICOLocationNavigator` |
| Service | `[Feature][Verb/Noun]` | `LeaveBalanceCalculator` |
| Mock | `[OriginalClassName]Mock` | `PostSubmitCICOUseCaseMock` |

### HTTP Method Prefix

| HTTP | UseCase Prefix | Example |
|------|---------------|---------|
| GET | `Get` | `GetAttendanceHistoryUseCase` |
| POST | `Post` | `PostSubmitCICOUseCase` |
| PUT | `Put` | `PutUpdateProfileUseCase` |
| PATCH | `Patch` | `PatchUpdateStatusUseCase` |
| DELETE | `Delete` | `DeleteTaskUseCase` |

### Code Style

- **Indentation**: 4 spaces
- **Line length**: No strict limit (readable)
- **Braces**: Opening on same line
- **Comments**: Only when logic is non-obvious
- **Access control**: Explicit (`private`, `internal`, `public`)
- **Optionals**: Use extensions (`.orEmpty()`, `.orFalse()`)

### Design Decisions

**Why UIKit?** Maturity, fine-grained control, broad third-party library support.

**Why RxSwift?** Mature ecosystem, existing codebase investment, broad operator support.

**Why Moya?** Type safety via enum-based API definitions, testability via protocol-based mocking, centralized endpoint declarations.

**Why Singleton + Constructor Injection?** Simplicity — no DI framework overhead; constructor injection enables test overrides without a container.

**Why Mappers in Data Layer?** Dependency rule compliance — Data depends on Domain, not vice versa. Mappers convert `Response` → `Entity`, so they live where both types are visible. Keeps Domain pure Swift.

**Why UseCase mandatory?** Single Responsibility, testability (ViewModels don't mock repositories), reusability across ViewModels, business logic isolation.

---

# Syntax Conventions

## Conventions

### Theory

**Rule:** Never use raw null-fallback operators (e.g. `??`, `?:`, `!`) directly in domain, data, or presentation code. Always delegate to a named extension method or utility function.

**Why:** Raw operators scatter fallback semantics across the codebase — the intent (`orEmpty`, `orZero`) disappears into punctuation. Named methods make the fallback explicit, searchable, and consistently applied.

**Categories — every platform must implement all of these:**

| Category | Method name | Fallback |
|---|---|---|
| Nullable numeric | `orZero()` | `0` |
| Nullable string | `orEmpty()` | `""` |
| Nullable collection | `orEmpty()` | `[]` |
| Nullable bool (false) | `orFalse()` | `false` |
| Nullable bool (true) | `orTrue()` | `true` |
| Nullable with custom default | `orDefault(x)` | `x` |

**Invariant:** Raw null operators are allowed only inside the extension/utility implementations themselves — never in domain, data, or presentation artifacts.

---

### Null Safety Extensions

```swift
// Core/Extensions/Optional+NullSafety.swift

extension Optional where Wrapped: Numeric {
    func orZero() -> Wrapped { self ?? 0 }
    func orDefault(_ defaultValue: Wrapped) -> Wrapped { self ?? defaultValue }
}

extension Optional where Wrapped == String {
    func orEmpty() -> String { self ?? "" }
    func orDefault(_ defaultValue: String) -> String {
        guard let self = self, !self.trimmingCharacters(in: .whitespaces).isEmpty else {
            return defaultValue
        }
        return self
    }
}

extension Optional where Wrapped: Collection {
    func orEmpty() -> Wrapped { self ?? [] as! Wrapped }
    var isNilOrEmpty: Bool { self?.isEmpty ?? true }
}

extension Optional where Wrapped == Bool {
    func orFalse() -> Bool { self ?? false }
    func orTrue() -> Bool { self ?? true }
}

extension Optional {
    func orDefault(_ factory: @autoclosure () -> Wrapped) -> Wrapped { self ?? factory() }
    @discardableResult
    func orElse(_ action: () -> Wrapped) -> Wrapped { self ?? action() }
}
```

**Critical:** Wrap optional chains in parentheses before calling extension methods:
```swift
($0.dataState.data?.title).orEmpty()     // ✅
$0.dataState.data?.title.orEmpty()       // ❌ compile error
```

---

# Utilities

## Date Service

### Theory

**DateService** is a centralized abstraction for all date and time operations — formatting, parsing, comparison, and timezone handling.

**Invariants:**
- All date formatting and parsing goes through `DateService` — never via inline format strings
- Timezone handling is explicit — never assume device timezone in business logic
- The interface is injectable for testing — implementations can return fixed dates in tests

**When to use:** Any layer that formats, parses, or compares dates.

---

### DateService

```swift
// Core/Date/DateService.swift
protocol DateService {
    var now: Date { get }
    var currentTimeZone: TimeZone { get }

    func format(_ date: Date, style: DateFormatStyle) -> String
    func parse(_ string: String, format: DateFormatStyle) -> Date?
    func startOfDay(_ date: Date) -> Date
    func endOfDay(_ date: Date) -> Date
    func addDays(_ days: Int, to date: Date) -> Date
    func daysBetween(_ start: Date, _ end: Date) -> Int
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool
}

enum DateFormatStyle {
    case iso8601              // "2024-01-15T14:30:00Z"
    case apiDate              // "2024-01-15"
    case apiDateTime          // "2024-01-15 14:30:00"
    case displayDate          // "Jan 15, 2024"
    case displayDateTime      // "Jan 15, 2024 at 2:30 PM"
    case displayTime          // "2:30 PM"
    case relative             // "2 days ago"
    case custom(String)
}

extension DateService {
    func toAPIDate(_ date: Date) -> String { format(date, style: .apiDate) }
    func fromAPIDate(_ string: String) -> Date? { parse(string, format: .apiDate) }
    func isToday(_ date: Date) -> Bool { isSameDay(date, now) }
    func isPast(_ date: Date) -> Bool { date < now }
    func isFuture(_ date: Date) -> Bool { date > now }
}
```

## Helper Extensions

### Theory

**Helper Extensions** are stateless utility functions scoped to a specific type.

**Invariants:**
- Extensions contain no business logic and no side effects — pure transformations only
- No analytics SDK, storage, or network imports inside extension files
- Grouped by the type they extend — never a catch-all utilities file

---

### Helper Extensions

Extension files live in `Shared/Extension/`.

| Helper | File | Key Methods |
|--------|------|-------------|
| `String?` | `Extension+String?.swift` | `.orEmpty()`, `.ifNullOrEmptyReturnDash()` |
| `Int?` | `Extension+Int?.swift` | `.orZero()`, `.orOne()` |
| `Double?` | `Extension+Double?.swift` | `.orZero()` |
| `Bool?` | `Extension+Bool?.swift` | `.orFalse()`, `.orTrue()` |
| `Array?` | `Extension+Array?.swift` | `.orEmpty()` |
| `Date` | `Date+Extensions.swift` | `.toDMYString()`, `.toHHMMString()`, `.isToday`, `.isPast`, `.startOfDay` |
| `String` → Date | `Date+Extensions.swift` | `.toDate(format:)`, `.toTimeDate()` |
| `Double/Int` (currency) | `Extension+Double.swift` | `.toFormattedString()` |
| `String` utilities | `Extension+String.swift` | `.removeWhitespace`, `.capitalizeFirstLetter`, `.isNumeric`, `.truncate(length:)`, `.masked` |
| `UIView` | `UIView+Extensions.swift` | `.addSubviews(...)`, `.roundCorners(...)`, `.addShadow(...)`, `.shake()` |
| `UIViewController` | `UIViewController+Extensions.swift` | `.showAlert(...)`, `.showErrorAlert(message:)`, `.showConfirmation(...)`, `.hideKeyboardWhenTappedAround()` |
| `BaseErrorModel` | `BaseErrorModel+Extensions.swift` | `.createEmptyDataError()`, `.createNetworkError()`, `.from(error:)` |
| `Observable` | `Observable+Extensions.swift` | `.unwrap()`, `.mapToVoid()`, `.retryWithDelay(...)` |

## Logger

### Theory

**Logger** is the centralized logging abstraction with severity levels.

**Invariants:**
- Severity levels: `debug`, `info`, `warning`, `error` — each with distinct routing (debug stripped in production)
- No `print` / `console.log` calls at call sites — always use the Logger interface
- Sensitive data (tokens, PII) must never appear in log output
- The implementation routes to the crash reporter for `error`-level events

---

### Logger

```swift
// Core/Logger/Logger.swift
import OSLog

enum LogLevel: Int, Comparable {
    case verbose = 0, debug = 1, info = 2, warning = 3, error = 4
    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool { lhs.rawValue < rhs.rawValue }
}

protocol Logger {
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int)
}

extension Logger {
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
}

enum Log {
    nonisolated(unsafe) static var shared: Logger = ConsoleLogger()
    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) { shared.debug(message, file: file, function: function, line: line) }
    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) { shared.info(message, file: file, function: function, line: line) }
    static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) { shared.warning(message, file: file, function: function, line: line) }
    static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) { shared.error(message, file: file, function: function, line: line) }
}
```

## Null Safety Extensions

### Theory

**Rule:** Never use raw null-fallback operators (e.g. `??`, `?:`, `!`) directly in domain, data, or presentation code. Always delegate to a named extension method or utility function.

**Why:** Raw operators scatter fallback semantics across the codebase — the intent (`orEmpty`, `orZero`) disappears into punctuation. Named methods make the fallback explicit, searchable, and consistently applied.

---

### Null Safety Extensions

**Always use extension methods for optional unwrapping — never force-unwrap or inline `?? value`.**

```swift
extension Optional where Wrapped: Numeric {
    func orZero() -> Wrapped { self ?? 0 }
    func orDefault(_ defaultValue: Wrapped) -> Wrapped { self ?? defaultValue }
}

extension Optional where Wrapped == String {
    func orEmpty() -> String { self ?? "" }
}

extension Optional where Wrapped: Collection {
    func orEmpty() -> Wrapped { self ?? [] as! Wrapped }
    var isNilOrEmpty: Bool { self?.isEmpty ?? true }
}

extension Optional where Wrapped == Bool {
    func orFalse() -> Bool { self ?? false }
    func orTrue() -> Bool { self ?? true }
}
```

**Usage:**

```swift
let name = employee.nickname.orEmpty()
let count = employees?.count.orZero()
let limit = params.limit.orDefault(20)
let isEnabled = featureFlags?.newUI.orFalse()

// CRITICAL: Wrap optional chains in parentheses before calling extension methods
let title = ($0.dataState.data?.appBarTitle).orEmpty()     // ✅
let title = $0.dataState.data?.appBarTitle.orEmpty()       // ❌ compile error
```

## Storage Service

### Theory

**StorageService** is an interface-based key-value store for persisting tokens, user preferences, and cached data across app sessions.

**Invariants:**
- The interface lives in the infrastructure layer — never in domain or data
- All keys are typed constants (enum) — never raw strings at call sites
- Implementations are swappable per environment
- `clearAll()` is only called on logout

---

### StorageService

```swift
// Core/Storage/StorageService.swift
protocol StorageService: Sendable {
    func get<T: Codable>(_ key: StorageKey) -> T?
    func set<T: Codable>(_ value: T, for key: StorageKey)
    func remove(_ key: StorageKey)
    func clearAll()
    func contains(_ key: StorageKey) -> Bool
}

enum StorageKey: String, Sendable {
    // Auth
    case accessToken
    case refreshToken
    case tokenExpiration

    // User
    case userId
    case userEmail
    case lastSyncDate

    // App State
    case onboardingCompleted
    case lastSelectedTab
}

// UserDefaults Implementation
final class UserDefaultsStorageService: StorageService {
    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        defaults: UserDefaults = .standard,
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init()
    ) {
        self.defaults = defaults
        self.encoder = encoder
        self.decoder = decoder
    }

    func get<T: Codable>(_ key: StorageKey) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    func set<T: Codable>(_ value: T, for key: StorageKey) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key.rawValue)
    }

    func remove(_ key: StorageKey) {
        defaults.removeObject(forKey: key.rawValue)
    }

    func clearAll() {
        StorageKey.allCases.forEach { remove($0) }
    }

    func contains(_ key: StorageKey) -> Bool {
        defaults.object(forKey: key.rawValue) != nil
    }
}

// Composite (Keychain + UserDefaults) for sensitive data routing
final class SecureStorageService: StorageService {
    private let keychain = KeychainStorageService()
    private let userDefaults = UserDefaultsStorageService()

    private let sensitiveKeys: Set<StorageKey> = [.accessToken, .refreshToken]

    private func service(for key: StorageKey) -> StorageService {
        sensitiveKeys.contains(key) ? keychain : userDefaults
    }

    func get<T: Codable>(_ key: StorageKey) -> T? { service(for: key).get(key) }
    func set<T: Codable>(_ value: T, for key: StorageKey) { service(for: key).set(value, for: key) }
    func remove(_ key: StorageKey) { service(for: key).remove(key) }
    func clearAll() { keychain.clearAll(); userDefaults.clearAll() }
    func contains(_ key: StorageKey) -> Bool { service(for: key).contains(key) }
}
```
