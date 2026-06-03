---
platform: ios
project: ios-talenta
discipline: engineering
topic: data
pattern: mapper
---

## Theory

A **Mapper** converts between a DTO and a domain entity — always defined as an interface with a concrete implementation.

**Invariants:**
- Always interface + implementation — never a plain utility function or static helper
- One direction per method: `toDomain(dto)` converts inward; `toDTO(entity)` converts outward (if write operations exist)
- No I/O — pure transformation only; no network calls, no DB reads
- No business logic — field mapping only; validation belongs in domain use cases
- Null/missing fields handled defensively — never let a missing API field crash the mapper

**When to create:** One mapper per DTO ↔ entity pair. Created after the DTO, before the DataSource implementation.

---

## Mappers

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

**Correct:** Data layer imports Domain entities, uses Mappers to convert Response → Entity
**Wrong:** Domain layer imports Response models from Data layer (violates dependency rule!)

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
            isBreakEnd: model.isBreakEnd,
            currentShiftDate: model.currentShiftDate,
            currentShiftName: model.currentShiftName,
            actualCheckIn: model.actualCheckIn,
            actualCheckOut: model.actualCheckOut,
            faceRecogAccuracy: model.faceRecogAccuracy,
            serverTime: model.serverTime,
            processedAsync: model.processedAsync,
            ipAddressStatus: model.ipAddressStatus
        )
    }
}
```

### Composable Mappers

Mappers compose via injection — a parent mapper depends on child mappers for nested objects:

```swift
// Data/Mapper/EmployeeMapper.swift
protocol EmployeeMapping {
    func toDomain(_ dto: EmployeeDTO) -> Employee
    func toRequest(_ employee: Employee) -> UpdateEmployeeRequest
}

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
            department: departmentMapper.toDomain(dto.department), // delegates to child
            joinDate: ISO8601DateFormatter().date(from: dto.joinedAt) ?? .now
        )
    }

    func toRequest(_ employee: Employee) -> UpdateEmployeeRequest {
        UpdateEmployeeRequest(
            fullName: employee.name,
            emailAddress: employee.email,
            departmentId: employee.department.id
        )
    }
}
```

### When Business Logic Appears in Mapping

❌ **Wrong:** Complex validation in Mapper
```swift
// Data/Mapper/CustomFormMapper.swift
static func map(_ response: CustomFormResponse) -> CustomFormModel {
    // ❌ This is business logic, not just mapping!
    let isValid = response.fields.allSatisfy { $0.isRequired && !$0.value.isEmpty }
    let canSubmit = isValid && response.status == "draft"

    return CustomFormModel(id: response.id.orZero(), isValid: isValid, canSubmit: canSubmit)
}
```

✅ **Correct:** Extract business logic to Domain Service or UseCase
```swift
// Data/Mapper — Simple transformation only
static func map(_ response: CustomFormResponse) -> CustomFormModel {
    return CustomFormModel(
        id: response.id.orZero(),
        fields: response.fields.map { CustomFormFieldModel.from($0) }
    )
}

// Domain/Service — Business logic
class CustomFormValidator {
    func validate(_ form: CustomFormModel) -> Bool {
        return form.fields.allSatisfy { $0.isRequired && !$0.value.isEmpty }
    }

    func canSubmit(_ form: CustomFormModel) -> Bool {
        return validate(form) && form.status == .draft
    }
}
```

**Mapper Rules:**
- One mapper per Response-Model pair: `RequestLiveAttendanceModelMapper`, `AttendanceScheduleModelMapper`
- Protocol-based: `[Name]ModelMapperType` protocol + `[Name]ModelMapper` class
- Use safe unwrapping: `.orEmpty()`, `.orFalse()`, `.orZero()`, `.orDefault(with:)`
- Bidirectional when needed: `fromResponseToModel` and `fromModelToResponse`
- Injected into repositories for testability
- Default parameter injection: `init(childMapper: ChildMapping = ChildMapper())`
- **No business logic** — only data transformation

**Why Protocol-based?**

| Protocol-based (Talenta) | Static enum/struct |
|---------------------------|---------------------|
| ✅ Mock in repository tests — true isolation | Repository tests implicitly test mapper too |
| ✅ Swap mapping strategies (API versioning) | Fixed mapping logic |
| ✅ Composable via DI — inject child mappers | Tightly coupled static calls |
| ✅ Consistent with architecture (injectable) | Simpler for trivial mappers |
| ✅ Testable in isolation | More boilerplate |
