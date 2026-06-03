---
platform: android
project: android-talenta
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

## Definition

Analytics event names and screen identifiers are declared as constants in the feature module — never as inline strings in ViewModel or Fragment code.

**Path pattern:** `feature_{feature}/src/main/java/co/talenta/{feature}/analytics/{Feature}AnalyticsConstants.kt`

Rules:
- ✅ `object` with `const val String` constants — no logic, no analytics SDK import
- ✅ snake_case string values matching the analytics platform convention
- ❌ Never inline event name strings in ViewModel or Fragment

**When to create:** Any feature that instruments user interactions or screen views. Optional — skip if the feature has no analytics events.

## Code Pattern

```kotlin
// feature_{feature}/src/main/java/co/talenta/{feature}/analytics/{Feature}AnalyticsConstants.kt

object {Feature}AnalyticsConstants {
    const val SCREEN_NAME = "{feature}_screen"
    const val EVENT_LOAD_DATA = "{feature}_load_data"
    const val EVENT_SUBMIT = "{feature}_submit"
    const val EVENT_ERROR = "{feature}_error"
}
```
