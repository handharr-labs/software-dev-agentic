## Null Safety Extensions

### Theory

**Rule:** Never use raw null-fallback operators (`??`, `!`) directly in domain, data, or presentation code. Always delegate to a named extension method.

**Why:** Raw operators scatter fallback semantics across the codebase — the intent (`orEmpty`, `orZero`) disappears into punctuation. Named methods make the fallback explicit, searchable, and consistently applied.

**Invariant:** Raw null operators are allowed only inside the extension implementations themselves — never in domain, data, or presentation artifacts.

| Category | Method | Fallback |
|---|---|---|
| Nullable numeric | `orZero()` | `0` |
| Nullable string | `orEmpty()` | `""` |
| Nullable collection | `orEmpty()` | `[]` |
| Nullable bool (false) | `orFalse()` | `false` |
| Nullable bool (true) | `orTrue()` | `true` |
| Nullable with custom default | `orDefault(x)` | `x` |

---

### Code Pattern

```swift
// Core/Extensions/Optional+NullSafety.swift

extension Optional where Wrapped: Numeric {
    func orZero() -> Wrapped { self ?? 0 }
    func orDefault(_ defaultValue: Wrapped) -> Wrapped { self ?? defaultValue }
}

extension Optional where Wrapped == String {
    func orEmpty() -> String { self ?? "" }
    func orDefault(_ defaultValue: String) -> String {
        guard let self = self, !self.trimmingCharacters(in: .whitespaces).isEmpty else {
            return defaultValue
        }
        return self
    }
}

extension Optional where Wrapped: Collection {
    func orEmpty() -> Wrapped { self ?? [] as! Wrapped }
    var isNilOrEmpty: Bool { self?.isEmpty ?? true }
}

extension Optional where Wrapped == Bool {
    func orFalse() -> Bool { self ?? false }
    func orTrue() -> Bool { self ?? true }
}

extension Optional {
    func orDefault(_ factory: @autoclosure () -> Wrapped) -> Wrapped { self ?? factory() }
    @discardableResult
    func orElse(_ action: () -> Wrapped) -> Wrapped { self ?? action() }
}
```

**Usage:**

```swift
let name = employee.nickname.orEmpty()
let count = employees?.count.orZero()
let limit = params.limit.orDefault(20)
let isEnabled = featureFlags?.newUI.orFalse()
```

**Critical:** Wrap optional chains in parentheses before calling extension methods:

```swift
($0.dataState.data?.title).orEmpty()     // ✅
$0.dataState.data?.title.orEmpty()       // ❌ compile error
```

---

## Helper Extensions

### Theory

**Helper Extensions** are stateless utility functions scoped to a specific type.

**Invariants:**
- Extensions contain no business logic and no side effects — pure transformations only
- No analytics SDK, storage, or network imports inside extension files
- Grouped by the type they extend — never a catch-all utilities file

Extension files live in `Shared/Extension/`.

---

### Code Pattern

| Helper | File | Key Methods |
|---|---|---|
| `String?` | `Extension+String?.swift` | `.orEmpty()`, `.ifNullOrEmptyReturnDash()` |
| `Int?` | `Extension+Int?.swift` | `.orZero()`, `.orOne()` |
| `Double?` | `Extension+Double?.swift` | `.orZero()` |
| `Bool?` | `Extension+Bool?.swift` | `.orFalse()`, `.orTrue()` |
| `Array?` | `Extension+Array?.swift` | `.orEmpty()` |
| `Date` | `Date+Extensions.swift` | `.toDMYString()`, `.toHHMMString()`, `.isToday`, `.isPast`, `.startOfDay` |
| `String` → Date | `Date+Extensions.swift` | `.toDate(format:)`, `.toTimeDate()` |
| `Double/Int` (currency) | `Extension+Double.swift` | `.toFormattedString()` |
| `String` utilities | `Extension+String.swift` | `.removeWhitespace`, `.capitalizeFirstLetter`, `.isNumeric`, `.truncate(length:)`, `.masked` |
| `UIView` | `UIView+Extensions.swift` | `.addSubviews(...)`, `.roundCorners(...)`, `.addShadow(...)`, `.shake()` |
| `UIViewController` | `UIViewController+Extensions.swift` | `.showAlert(...)`, `.showErrorAlert(message:)`, `.showConfirmation(...)`, `.hideKeyboardWhenTappedAround()` |
| `BaseErrorModel` | `BaseErrorModel+Extensions.swift` | `.createEmptyDataError()`, `.createNetworkError()`, `.from(error:)` |
| `Observable` | `Observable+Extensions.swift` | `.unwrap()`, `.mapToVoid()`, `.retryWithDelay(...)` |

---

## Magic Constants

### Theory

**Rule:** Never hard-code a domain-meaningful string or number inline. Promote it to a named constant — scoped to `Shared/Constants/` if reused across features, or declared `private static let` on the type itself if it's local to one.

**Why:** A bare `30`, `"en_US"`, or `"v1/employees"` carries no intent at the call site and forces every reader to trace it back to its meaning. Naming it once makes the value searchable, makes its purpose explicit, and gives a single point of change.

**Invariant:**
- Shared, cross-feature constants live in `Shared/Constants/` grouped by domain (`NetworkConstants`, `FormatConstants`, ...)
- Constants used by a single type are declared `private static let` (or `fileprivate`) on that type — never duplicated as inline literals elsewhere in the same file
- Trivial sentinel values (`0`/`1`/`-1` for indices and comparisons, `true`/`false`, empty-string checks in guards) are exempt — naming these adds noise, not clarity
- Feature-scoped Analytics Constants follow their own dedicated convention (see standard architecture) — this rule covers everything else

| Scope | Where it lives | Example |
|---|---|---|
| Shared across features | `Shared/Constants/{Domain}Constants.swift` | API paths, timeouts, regex patterns, format strings |
| Local to one type | `private static let` on the type itself | Corner radius, animation duration, debounce thresholds specific to that view |

---

### Code Pattern

```swift
// Shared/Constants/NetworkConstants.swift
enum NetworkConstants {
    static let defaultTimeoutSeconds: TimeInterval = 30
    static let defaultLocale = "en_US"
    static let employeesEndpoint = "v1/employees"
}

// Usage — domain/data/presentation
var request = URLRequest(url: baseURL.appendingPathComponent(NetworkConstants.employeesEndpoint))
request.timeoutInterval = NetworkConstants.defaultTimeoutSeconds
```

**Local to a type:**

```swift
final class AttendanceCardView: UIView {
    private static let cardRadius: CGFloat = 12
    private static let expandAnimationDuration: TimeInterval = 0.25

    // ...uses Self.cardRadius and Self.expandAnimationDuration — never inline 12 or 0.25
}
```

**Critical:** if the same literal appears in two or more files, it has already outgrown "local" — promote it to `Shared/Constants/` instead of copying it.
