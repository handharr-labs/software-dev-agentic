---
platform: android
project: android-talenta
discipline: engineering
topic: utilities
pattern: date_service
---

## Theory

**DateService** is a centralized abstraction for all date and time operations — formatting, parsing, comparison, and timezone handling.

**Invariants:**
- All date formatting and parsing goes through `DateService` — never via inline format strings or `SimpleDateFormat`/`DateFormatter` at call sites
- Timezone handling is explicit — never assume device timezone in business logic
- The interface is injectable for testing — implementations can return fixed dates in tests

**When to use:** Any layer that formats, parses, or compares dates. Domain layer may define date-related value objects; `DateService` handles the conversion to/from display and wire formats.

---

## Definition

> Android DateService patterns not yet catalogued. Add date formatting/parsing utilities here (e.g. `SimpleDateFormat`, `DateTimeFormatter`) when established.

## Code Pattern

```kotlin
// Placeholder — add date formatting/parsing utility here
// Extension functions in DateExtensions.kt: .toDisplayDate(), .toApiDate(), .isToday(), .isPast()
```
