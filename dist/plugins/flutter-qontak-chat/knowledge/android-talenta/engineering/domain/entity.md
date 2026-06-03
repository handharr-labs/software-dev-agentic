---
platform: android
project: android-talenta
discipline: engineering
topic: domain
pattern: entity
---

## Theory

An **Entity** is a pure data structure representing a business concept.

**Invariants:**
- No framework imports — value types or pure classes only
- No business logic — entities hold data; use cases execute logic
- No serialization annotations — no `@JsonKey`, no `Codable`, no `fromJson`
- Immutable — all properties are read-only; mutation produces a new instance (`copyWith`)
- Represent domain concepts, not API shapes — field names match the business domain, not the JSON payload

**When to create:** When the domain needs a named, typed concept with identified fields (e.g. `Employee`, `LeaveRequest`, `AttendanceRecord`).

---

## Definition

Pure Kotlin data classes — no JSON annotations, no Android framework imports.

Rules:
- Pure Kotlin data class — no `@SerializedName`, no `@Json`, no Android imports
- All properties non-optional at the domain boundary (use sensible defaults in mapper)
- Field names use domain terminology, not API field names
- Immutable — use `val` for all properties

## Code Pattern

```kotlin
// domain/entity/TimeOffRequest.kt
data class TimeOffRequest(
    val id: String,
    val employeeId: String,
    val startDate: String,
    val endDate: String,
    val reason: String,
    val status: String,
    val totalDays: Int
)
```
