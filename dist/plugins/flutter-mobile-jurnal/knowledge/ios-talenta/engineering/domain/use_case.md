---
platform: ios
project: ios-talenta
discipline: engineering
topic: domain
pattern: use_case
---

## Theory

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

## Use Cases

### Legacy UseCase Pattern (Current — In Use)

The codebase uses a 3-parameter base class with separate query params, path params, and a completion callback:

```swift
// Shared/Domain/UseCase/UseCase.swift
typealias PostSubmitCICOUseCaseType = UseCase<PostSubmitCICOQueryParam, LiveAttendanceCICOPathParam, RequestLiveAttendanceModel>

// Usage in ViewModel:
useCase.call(
    queryParams: queryParam,
    pathParams: pathParam,
    expected: { result in /* handle Result<Model, BaseErrorModel> */ }
)
```

The use case type alias pattern: `typealias [Feature]UseCaseType = UseCase<QueryParam, PathParam, ResultModel>`.
`call(queryParams:pathParams:expected:)` is the call site signature.

---

### Modern UseCase Protocol (Target — V2)

Talenta iOS V2 target uses **ONE** clean protocol with nested Params (not yet adopted codebase-wide):

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
- ✅ **Single protocol** - No confusion between multiple protocol types
- ✅ **No naming conflicts** - `UseCaseProtocol` avoids clash with legacy `UseCase` protocol
- ✅ **No param collisions** - `GetEmployeeUseCase.Params` vs `UpdateEmployeeUseCase.Params`
- ✅ **Discoverable** - Autocomplete shows params right from UseCase type
- ✅ **Colocated** - Params definition lives next to the code that uses it
- ✅ **Self-documenting** - All inputs clearly defined in one place
- ✅ **Consistent API** - All use cases have the same `execute(params:completion:)` signature

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

**Usage in ViewModel:**
```swift
let params = GetEmployeeUseCase.Params(employeeId: "123")
getEmployeeUseCase.execute(params: params) { result in
    // Handle result
}
```

#### Pattern 2: GET with Multiple Query Parameters

```swift
// Domain/UseCase/Employee/GetEmployeesUseCase.swift

final class GetEmployeesUseCase: UseCaseProtocol {
    // MARK: - Params
    struct Params {
        let page: Int
        let limit: Int
        let departmentId: String?
        let searchQuery: String?

        // Provide default values for convenience
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

    // MARK: - Singleton
    private static var _sharedInstance: GetEmployeesUseCase?
    static var sharedInstance: GetEmployeesUseCase {
        if _sharedInstance == nil {
            _sharedInstance = GetEmployeesUseCase()
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
        completion: @escaping (Result<PaginatedResult<EmployeeModel>, BaseErrorModel>) -> Void
    ) {
        repository.getEmployees(
            page: params.page,
            limit: params.limit,
            departmentId: params.departmentId,
            searchQuery: params.searchQuery,
            completion: completion
        )
    }
}
```

**Usage:**
```swift
// With defaults
let params = GetEmployeesUseCase.Params()

// With custom values
let params = GetEmployeesUseCase.Params(page: 2, limit: 50, departmentId: "eng-001")

getEmployeesUseCase.execute(params: params) { result in ... }
```

#### Pattern 3: POST/PUT with Path ID + Body (Nested Payload)

**Key Pattern:** Separate path identifiers from payload body using nested structs.

```swift
// Domain/UseCase/CICO/PostSubmitCICOUseCase.swift

final class PostSubmitCICOUseCase: UseCaseProtocol {
    // MARK: - Params
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

            init(
                employeeId: Int,
                scheduleId: Int,
                actualCheckIn: String? = nil,
                actualCheckOut: String? = nil,
                latitude: Double? = nil,
                longitude: Double? = nil,
                media: Data? = nil,
                notes: String? = nil
            ) {
                self.employeeId = employeeId
                self.scheduleId = scheduleId
                self.actualCheckIn = actualCheckIn
                self.actualCheckOut = actualCheckOut
                self.latitude = latitude
                self.longitude = longitude
                self.media = media
                self.notes = notes
            }
        }
    }

    // MARK: - Singleton
    private static var _sharedInstance: PostSubmitCICOUseCase?
    static var sharedInstance: PostSubmitCICOUseCase {
        if _sharedInstance == nil {
            _sharedInstance = PostSubmitCICOUseCase()
        }
        return _sharedInstance!
    }

    // MARK: - Dependencies
    private let repository: LiveAttendanceRepository

    // MARK: - Init
    init(repository: LiveAttendanceRepository = LiveAttendanceRepositoryImpl.sharedInstance) {
        self.repository = repository
    }

    // MARK: - Execute
    func execute(
        params: Params,
        completion: @escaping (Result<RequestLiveAttendanceModel, BaseErrorModel>) -> Void
    ) {
        repository.postSubmitCico(
            companyId: params.companyId,
            employeeId: params.payload.employeeId,
            scheduleId: params.payload.scheduleId,
            actualCheckIn: params.payload.actualCheckIn,
            actualCheckOut: params.payload.actualCheckOut,
            latitude: params.payload.latitude,
            longitude: params.payload.longitude,
            media: params.payload.media,
            notes: params.payload.notes,
            completion: completion
        )
    }
}
```

**Usage in ViewModel:**
```swift
let payload = PostSubmitCICOUseCase.Params.Payload(
    employeeId: 123,
    scheduleId: 456,
    latitude: -6.2088,
    longitude: 106.8456,
    media: selfieImageData
)

let params = PostSubmitCICOUseCase.Params(
    companyId: userViewModel.companyId,
    payload: payload
)

postSubmitCICOUseCase.execute(params: params) { [weak self] result in
    switch result {
    case .success(let model):
        self?.emitAction(.navigateToSuccess)
    case .failure(let error):
        self?.emitAction(.showToast(message: error.message))
    }
}
```

#### Pattern 4: UseCase Without Parameters

**Key Pattern:** Use `typealias Params = Void` for use cases that don't need parameters.

```swift
// Domain/UseCase/Auth/GetCurrentUserUseCase.swift

final class GetCurrentUserUseCase: UseCaseProtocol {
    // MARK: - Params
    typealias Params = Void  // No parameters needed

    // MARK: - Singleton
    private static var _sharedInstance: GetCurrentUserUseCase?
    static var sharedInstance: GetCurrentUserUseCase {
        if _sharedInstance == nil {
            _sharedInstance = GetCurrentUserUseCase()
        }
        return _sharedInstance!
    }

    // MARK: - Dependencies
    private let repository: AuthRepository

    // MARK: - Init
    init(repository: AuthRepository = AuthRepositoryImpl.sharedInstance) {
        self.repository = repository
    }

    // MARK: - Execute
    func execute(
        params: Void,
        completion: @escaping (Result<UserModel, BaseErrorModel>) -> Void
    ) {
        repository.getCurrentUser(completion: completion)
    }
}
```

**Usage in ViewModel:**
```swift
// Simple call with unit literal ()
getCurrentUserUseCase.execute(params: ()) { [weak self] result in
    switch result {
    case .success(let user):
        self?.emitAction(.updateUser(user))
    case .failure(let error):
        self?.emitAction(.showError(error.message))
    }
}
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

**Why Nest Params Inside UseCase?**
- No name collisions — `GetEmployeeUseCase.Params` vs `UpdateEmployeeUseCase.Params`
- Discoverable — autocomplete shows params right from the UseCase type
- Colocated — params definition lives next to the code that uses it
