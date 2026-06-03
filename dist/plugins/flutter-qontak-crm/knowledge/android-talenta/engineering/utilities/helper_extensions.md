---
platform: android
project: android-talenta
discipline: engineering
topic: utilities
pattern: helper_extensions
---

## Theory

**Helper Extensions** are stateless utility functions scoped to a specific type — they extend built-in types with domain-safe convenience without introducing service dependencies.

**Invariants:**
- Extensions contain no business logic and no side effects — pure transformations only
- No analytics SDK, storage, or network imports inside extension files
- Grouped by the type they extend (e.g. `String+Formatting`, `Date+Helpers`) — never a catch-all utilities file
- Platform implementations live in `lib/core/knowledge/{platform}/engineering/utilities/` per platform

**When to use:** Repetitive type-level transformations that would otherwise be inlined everywhere. If the transformation requires injected state, it belongs in a use case or service, not an extension.

---

## Definition

Extension functions live in `core/extensions/`.

## Code Pattern

```kotlin
// core/extensions/StringExtensions.kt
// .orEmpty(), .orDash(), .removeWhitespace(), .capitalizeFirst(), .isNumeric()

// core/extensions/NumberExtensions.kt
// .orZero(), .toCurrencyString(), .toFormattedString()

// core/extensions/DateExtensions.kt
// .toDisplayDate(), .toApiDate(), .isToday(), .isPast()

// core/extensions/ViewExtensions.kt
// .show(), .hide(), .gone(), .addRipple()

// core/extensions/ContextExtensions.kt
// .showToast(msg), .showSnackbar(msg), .hideKeyboard()

// core/extensions/RxExtensions.kt
// .applySchedulers(), .mapToVoid(), .retryWithDelay(n)
```

| Helper | File | Key Functions |
|--------|------|---------------|
| `String?` | `StringExtensions.kt` | `.orEmpty()`, `.orDash()`, `.removeWhitespace()`, `.capitalizeFirst()`, `.isNumeric()` |
| `Int?` / `Double?` | `NumberExtensions.kt` | `.orZero()`, `.toCurrencyString()`, `.toFormattedString()` |
| `Date` / `Calendar` | `DateExtensions.kt` | `.toDisplayDate()`, `.toApiDate()`, `.isToday()`, `.isPast()` |
| `View` | `ViewExtensions.kt` | `.show()`, `.hide()`, `.gone()`, `.addRipple()` |
| `Activity` / `Fragment` | `ContextExtensions.kt` | `.showToast(msg)`, `.showSnackbar(msg)`, `.hideKeyboard()` |
| `Observable<T>` | `RxExtensions.kt` | `.applySchedulers()`, `.mapToVoid()`, `.retryWithDelay(n)` |
