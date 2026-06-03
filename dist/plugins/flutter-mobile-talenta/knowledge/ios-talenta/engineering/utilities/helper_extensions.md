---
platform: ios
project: ios-talenta
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

**When to use:** Repetitive type-level transformations that would otherwise be inlined everywhere. If the transformation requires injected state, it belongs in a use case or service, not an extension.

---

## Helper Extensions

Extension files live in `Talenta/Shared/Extension/`.

| Helper | File | Key Methods |
|--------|------|-------------|
| `String?` | `Extension+String?.swift` | `.orEmpty()`, `.ifNullOrEmptyReturnDash()` |
| `Int?` | `Extension+Int?.swift` | `.orZero()`, `.orOne()` |
| `Double?` | `Extension+Double?.swift` | `.orZero()` |
| `Bool?` | `Extension+Bool?.swift` | `.orFalse()`, `.orTrue()` |
| `Array?` | `Extension+Array?.swift` | `.orEmpty()` |
| `Date` | `Date+Extensions.swift` | `.toDMYString()`, `.toHHMMString()`, `.toYMDString()`, `.isToday`, `.isPast`, `.startOfDay` |
| `String` → Date | `Date+Extensions.swift` | `.toDate(format:)`, `.toTimeDate()` |
| `Double/Int` (currency) | `Extension+Double.swift` | `.toRupiahString()`, `.toFormattedString()` |
| `String` utilities | `Extension+String.swift` | `.removeWhitespace`, `.capitalizeFirstLetter`, `.isNumeric`, `.truncate(length:)`, `.masked` |
| `UIView` | `UIView+Extensions.swift` | `.addSubviews(...)`, `.roundCorners(...)`, `.addShadow(...)`, `.shake()` |
| `UIViewController` | `UIViewController+Extensions.swift` | `.showAlert(...)`, `.showErrorAlert(message:)`, `.showConfirmation(...)`, `.hideKeyboardWhenTappedAround()` |
| `BaseErrorModel` | `BaseErrorModel+Extensions.swift` | `.createEmptyDataError()`, `.createNetworkError()`, `.from(error:)` |
| `Observable` | `Observable+Extensions.swift` | `.unwrap()`, `.mapToVoid()`, `.retryWithDelay(...)` |
