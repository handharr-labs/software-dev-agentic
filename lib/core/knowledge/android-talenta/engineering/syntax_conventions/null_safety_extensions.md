---
platform: android
project: android-talenta
discipline: engineering
topic: syntax_conventions
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

## Definition

All extensions live in `com.mekari.commons.extension`. Import only what you use.

Rules:
- Never use `?: ""`, `?: 0`, `?: false` inline in mappers — always use the extension function
- For nested optional chains: `response.nested?.field.orEmpty()`
- For list mapping: `response.items?.map { mapper.map(it) }.orEmpty()`

## Code Pattern

```kotlin
import com.mekari.commons.extension.orEmpty   // String?, List<T>?
import com.mekari.commons.extension.orZero    // Int?, Long?, Double?, Float?
import com.mekari.commons.extension.orFalse   // Boolean?
import com.mekari.commons.extension.orTrue    // Boolean?

// Usage:
val name: String  = response.name.orEmpty()          // null → ""
val items: List<T> = response.items.orEmpty()        // null → emptyList()
val count: Int    = response.count.orZero()          // null → 0
val isActive: Boolean = response.isActive.orFalse()  // null → false
val isEnabled: Boolean = response.isEnabled.orTrue() // null → true

// ❌ Never:
val name = response.name ?: ""    // use .orEmpty()
val count = response.count ?: 0   // use .orZero()
```
