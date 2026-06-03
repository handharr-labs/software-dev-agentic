---
platform: ios
project: ios-talenta
discipline: engineering
topic: utilities
pattern: null_safety_extensions
---

## Theory

**Rule:** Never use raw null-fallback operators (e.g. `??`, `?:`, `!`) directly in domain, data, or presentation code. Always delegate to a named extension method or utility function.

**Why:** Raw operators scatter fallback semantics across the codebase — the intent (`orEmpty`, `orZero`) disappears into punctuation. Named methods make the fallback explicit, searchable, and consistently applied.

**Categories — every platform must implement all of these:**

| Category | Method name | Fallback |
|---|---|---|
| Nullable numeric | `orZero()` | `0` |
| Nullable string | `orEmpty()` | `""` |
| Nullable collection | `orEmpty()` | `[]` |
| Nullable bool (false) | `orFalse()` | `false` |
| Nullable bool (true) | `orTrue()` | `true` |
| Nullable with custom default | `orDefault(x)` | `x` |

**Invariant:** Raw null operators are allowed only inside the extension/utility implementations themselves — never in domain, data, or presentation artifacts.

---

## Null Safety Extensions

**Always use extension methods for optional unwrapping — never force-unwrap or inline `?? value`.**

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

// CRITICAL: Wrap optional chains in parentheses before calling extension methods
let title = ($0.dataState.data?.appBarTitle).orEmpty()     // ✅
let title = $0.dataState.data?.appBarTitle.orEmpty()       // ❌ compile error
```
