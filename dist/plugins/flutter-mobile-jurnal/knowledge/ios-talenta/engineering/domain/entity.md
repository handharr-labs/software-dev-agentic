---
platform: ios
project: ios-talenta
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

## Entities

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
- ✅ Structs (value types) preferred
- ✅ Default initializers with default values
- ✅ `copyWith` extension for immutable updates
- ✅ Equatable conformance for diffing/testing
- ❌ No `import UIKit` or heavy framework dependencies
- ❌ No business logic (pure data)
