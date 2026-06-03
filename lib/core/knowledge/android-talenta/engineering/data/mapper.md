---
platform: android
project: android-talenta
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

## Definition

Extend `BaseMapper<Response, Entity>` — map every entity field, use null-safety extensions.

Rules:
- **Every entity field must appear in the mapper call** — no silent defaults
- Use `.orEmpty()` for String/List, `.orZero()` for Int/Long/Double, `.orFalse()` or `.orTrue()` for Boolean
- Never use `?: ""` or `?: 0` — always the extension function
- Add `mapList(responses: List<Response>?)` helper for list mappings
- For nested objects: create a nested mapper class

## Code Pattern

```kotlin
// data/mapper/TimeOffRequestMapper.kt
import com.mekari.commons.extension.orEmpty
import com.mekari.commons.extension.orZero

class TimeOffRequestMapper : BaseMapper<TimeOffRequestResponse, TimeOffRequest> {
    override fun map(input: TimeOffRequestResponse): TimeOffRequest {
        return TimeOffRequest(
            id = input.id.orEmpty(),
            employeeId = input.employeeId.orEmpty(),
            startDate = input.startDate.orEmpty(),
            endDate = input.endDate.orEmpty(),
            reason = input.reason.orEmpty(),
            status = input.status.orEmpty(),
            totalDays = input.totalDays.orZero()
        )
    }

    fun mapList(responses: List<TimeOffRequestResponse>?): List<TimeOffRequest> {
        return responses?.map { map(it) } ?: emptyList()
    }
}
```
