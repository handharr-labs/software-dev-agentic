---
platform: ios
project: ios-talenta
discipline: engineering
topic: domain
pattern: domain_enum
---

## Domain Enums

```swift
// Domain/enum/CICOType.swift
enum CICOType {
    case clockIn
    case clockOut
    case breakStart
    case breakEnd
}

// Domain/enum/IPAddressStatus.swift
enum IPAddressStatus: String {
    case valid = "valid"
    case invalid = "invalid"
    case unknown = "unknown"
}

// Domain/enum/TimeOffMenuType.swift
enum TimeOffMenuType {
    case request
    case history
    case balance
}
```

**Enum Rules:**
- Define business-level constants and states
- Use meaningful names tied to business domain
- Prefer `String` raw values for API interop when needed
- Location: `Domain/enum/`
