---
platform: android
project: android-talenta
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

## Definition

Domain services encapsulate business logic that spans multiple entities or does not naturally belong to a single use case. In Android MVP, these are plain Kotlin classes with no Android framework dependencies.

Rules:
- Pure Kotlin — no Android imports, no RxJava, no framework dependencies
- Injected into use cases via `@Inject constructor`, never into presenters directly
- Name: `[Domain][Concept]Service`

## Code Pattern

```kotlin
// domain/service/TimeOffEligibilityService.kt
class TimeOffEligibilityService @Inject constructor() {
    fun isEligible(employee: Employee, requestDays: Int): Boolean {
        return employee.remainingLeave >= requestDays && !employee.isProbation
    }
}
```
