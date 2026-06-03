---
platform: android
project: android-talenta
discipline: engineering
topic: data
pattern: dto
---

## Theory

A **DTO (Data Transfer Object)** mirrors the raw API or database shape exactly.

**Invariants:**
- No domain logic — plain data container only
- No computed fields — no derived values, no formatting
- No domain entity types — DTOs use primitive types and nested DTOs
- Serialization annotations live here, not on domain entities (`@JsonKey`, `Codable`, `fromJson`)
- Field names match the API/DB schema — not the business domain vocabulary

**When to create:** One DTO per API response type or DB table row. Created before the mapper that consumes it.

---

## Definition

Android calls these **Response Models** (`*Response` suffix, placed in `data/response/`). Same contract as core — raw API shape, all fields nullable, `@SerializedName` for every field, no business logic. Never returned from repository — always mapped to an entity first.

Rules:
- All fields `val` and nullable (`?`) — server may omit any field
- Use `@SerializedName` for every field
- No business logic in response models
- Class suffix is `*Response`; file lives in `data/response/`

## Code Pattern

```kotlin
// data/response/TimeOffRequestListResponse.kt
data class TimeOffRequestListResponse(
    @SerializedName("data") val data: List<TimeOffRequestResponse>?,
    @SerializedName("meta") val meta: MetaResponse?
)

data class TimeOffRequestResponse(
    @SerializedName("id") val id: String?,
    @SerializedName("employee_id") val employeeId: String?,
    @SerializedName("start_date") val startDate: String?,
    @SerializedName("end_date") val endDate: String?,
    @SerializedName("reason") val reason: String?,
    @SerializedName("status") val status: String?,
    @SerializedName("total_days") val totalDays: Int?
)

data class MetaResponse(
    @SerializedName("total") val total: Int?,
    @SerializedName("page") val page: Int?,
    @SerializedName("limit") val limit: Int?
)
```
