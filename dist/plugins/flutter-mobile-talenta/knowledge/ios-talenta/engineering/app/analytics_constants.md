---
platform: ios
project: ios-talenta
discipline: engineering
topic: app
pattern: analytics_constants
---

## Theory

**Analytics Constants** are feature-scoped files that declare the event names, screen names, or tracking identifiers reported to the analytics service.

**Invariants:**
- One constants file per feature — never share event names across features in a single file
- Constants are plain string literals — no logic, no SDK imports
- Analytics SDK calls are made in the Presentation layer (ViewModel/BLoC) — these files only declare the identifiers they reference

**When to create:** Any feature that instruments user interactions or screen views. Optional — skip if the feature has no analytics events.

---

## Analytics Constants

Event names and screen identifiers are declared as a Swift struct in the feature's `Constants/` directory.

```swift
// Talenta/Module/{Feature}/Constants/{Feature}FirebaseName.swift
struct {Feature}FirebaseName {
    static let screenName  = "{feature}_screen"
    static let tapEvent    = "{feature}_tap"
    static let submitEvent = "{feature}_submit"
}
```

**Path:** `Talenta/Module/{Feature}/Constants/{Feature}FirebaseName.swift`

**Rules:**
- ✅ One `struct` per feature — no shared analytics constants file
- ✅ `static let` string constants only — no logic, no SDK imports
- ✅ snake_case values match Firebase naming convention
- ❌ Never import the Analytics SDK in this constants file
- ❌ Never use inline string literals in ViewModels — always reference these constants

**When to create:** Any feature that instruments user interactions or screen views. Optional — skip if the feature has no analytics events.
