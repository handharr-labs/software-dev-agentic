---
platform: ios
project: ios-talenta
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

## DTOs

iOS calls these **Response Models** (`*Response` / `*ResponseData` structs). Same contract as core — raw API shape, all fields optional (`?`), `CodingKeys` for snake_case mapping, no business logic. Never escape the Data layer.

API response models. Separate from domain entities.

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
    let currentShiftLabel: String?
    let currentShiftScIn: String?
    let currentShiftScOut: String?
    let actualCheckIn: String?
    let actualCheckOut: String?
    let faceRecogAccuracy: Double?
    let livenessAccuracy: Double?
    let serverTime: String?
    let useGracePeriod: Bool?
    let clockInDispensationDuration: Int?
    let clockOutDispensationDuration: Int?
    let processedAsync: Bool?
    let errorCase: String?
    let ipAddressStatus: Bool?
    let validIpAddress: Bool?

    enum CodingKeys: String, CodingKey {
        case actualBreakStart = "actual_break_start"
        case isBreakStart = "is_break_start"
        case isBreakEnd = "is_break_end"
        case currentShiftDate = "current_shift_date"
        case currentShiftName = "current_shift_name"
        case currentShiftLabel = "current_shift_label"
        case currentShiftScIn = "current_shift_sc_in"
        case currentShiftScOut = "current_shift_sc_out"
        case actualCheckIn = "actual_check_in"
        case actualCheckOut = "actual_check_out"
        case faceRecogAccuracy = "face_recog_accuracy"
        case livenessAccuracy = "liveness_accuracy"
        case serverTime = "server_time"
        case useGracePeriod = "use_grace_period"
        case clockInDispensationDuration = "clock_in_dispensation_duration"
        case clockOutDispensationDuration = "clock_out_dispensation_duration"
        case processedAsync = "processed_async"
        case errorCase = "error_case"
        case ipAddressStatus = "ip_address_status"
        case validIpAddress = "valid_ip_address"
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
