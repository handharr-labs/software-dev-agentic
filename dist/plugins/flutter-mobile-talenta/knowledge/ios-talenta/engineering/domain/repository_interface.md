---
platform: ios
project: ios-talenta
discipline: engineering
topic: domain
pattern: repository_interface
---

## Theory

A **Repository** is a contract that defines data access operations — *what* is needed, not *how* it is done.

**Invariants:**
- Lives in Domain as an interface/protocol/abstract class only — implementation lives in Data
- Returns domain Entities — never raw DTOs, API response types, or database records
- Method names follow the operation's intent: `get*`, `create*`, `update*`, `delete*`, `submit*`
- Parameters are domain objects — not raw dictionaries, JSON maps, or HTTP types
- Error type is the domain error type — never a networking or transport error

**When to create:** One repository per aggregate root or feature domain. Created before use cases — use cases depend on the repository interface.

---

## Repository Interfaces

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
- ✅ Always use `Result<Model, BaseErrorModel>` in completions
- ✅ Return domain entities (Models), never DTOs (Responses)
- ✅ Method names follow REST convention: `post*`, `get*`, `put*`, `delete*`
- ✅ Params are domain Param objects, not raw dictionaries
- ❌ No implementation details (no Moya, no network code)
