---
platform: android
project: android-talenta
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

## Definition

Defined in `domain/repository/` — platform-agnostic contracts only.

Rules:
- Interface only — no implementation in domain layer
- Return `Single<T>` (RxJava 3) for all async operations
- Params are domain types — never response/DTO types
- Name: `[Module]Repository` (one interface per feature module)

## Code Pattern

```kotlin
// domain/repository/TimeOffRepository.kt
interface TimeOffRepository {
    fun getTimeOffRequests(page: Int, limit: Int): Single<List<TimeOffRequest>>
    fun submitTimeOffRequest(request: SubmitTimeOffRequest): Single<TimeOffRequest>
}
```
