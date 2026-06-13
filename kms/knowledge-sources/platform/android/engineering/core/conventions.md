---
scope: platform/android
discipline: engineering
artifact: conventions
---
## Null Safety Extensions

### Theory

**Rule:** Never use raw null-fallback operators (`?: null`, `!!`) directly in domain, data, or presentation code. Always delegate to a named extension method.

**Why:** Raw operators scatter fallback semantics across the codebase — the intent (`orEmpty`, `orZero`) disappears into punctuation. Named methods make the fallback explicit, searchable, and consistently applied.

**Invariant:** Raw null operators are allowed only inside the extension implementations themselves — never in domain, data, or presentation artifacts.

**Source:** Core null safety extensions (`orEmpty`, `orZero`, `orFalse`, `orTrue`) are provided by the internal **Mekari Commons** library — not defined locally.

```kotlin
import com.mekari.commons.extension.orEmpty
import com.mekari.commons.extension.orZero
import com.mekari.commons.extension.orFalse
import com.mekari.commons.extension.orTrue
```

| Category | Method | Fallback |
|---|---|---|
| Nullable string | `orEmpty()` | `""` |
| Nullable int | `orZero()` | `0` |
| Nullable double | `orZero()` | `0.0` |
| Nullable bool (false) | `orFalse()` | `false` |
| Nullable bool (true) | `orTrue()` | `true` |

---

### Code Pattern

**Usage — domain and presentation layers:**

```kotlin
// SessionPreferenceImpl.kt
"${ParamKey.TLParamHeadToken} ${getToken().orEmpty()}"
shared.valueFrom(SharedHelper.login, false).orFalse()
getUser()?.companyId.orZero()

// LoginUseCase.kt
authRepository.loginSSO(params.orEmpty())

// LiveAttendanceFragment.kt
val location = LatLng(latitude.orZero(), longitude.orZero())
toggle?.isSelfieMandatory.orFalse()
```

---

## Helper Extensions

### Theory

**Helper Extensions** are stateless utility functions scoped to a specific type. Local extensions in `lib_core_helper` extend the Mekari Commons catalog for project-specific needs.

**Invariants:**
- Extensions contain no business logic and no side effects — pure transformations only
- No analytics SDK, storage, or network imports inside extension files
- Grouped by the type they extend

Extension files live in `lib_core_helper/src/main/java/co/talenta/lib_core_helper/extension/`.

---

### Code Pattern

| Helper | File | Key Methods |
|---|---|---|
| `CharSequence?` | `CharSequenceExtension.kt` | `.orEmptyChar()`, `.lowercaseFirstChar()` |
| `String?` | `StringExtension.kt` | `.toIntOrZero()`, `.truncateTextWithEllipsis(maxChar)` |
| `Int?` | `IntExtension.kt` | `.boolean` (property), `.isNegative()` |
| `Boolean` | `BooleanExtension.kt` | `.toInt()` |
| `Double` | `DoubleExtension.kt` | `.isNotZero()`, `.isZero()`, `.changeIfZero { }` |
| `List<T>` | `ListExtension.kt` | `.isIndexExists(index)`, `.isSingleSize()`, `.isMultipleSize()` |
| `Map<K, V?>` | `MapExtension.kt` | `.toBundle()`, `.filterNotNullValues()` |
| `Date?` | `EducationHelper.kt` | `.orEmptyDate()` → `DateUtil.today()` |

---

## Magic Constants

### Theory

**Rule:** Never hard-code a domain-meaningful string or number inline. Promote it to a named constant — scoped to a shared `constants` package if reused across modules, or declared as a `const val` in the class's `companion object` if it's local to one.

**Why:** A bare `30`, `"en_US"`, or `"v1/employees"` carries no intent at the call site and forces every reader to trace it back to its meaning. Naming it once makes the value searchable, makes its purpose explicit, and gives a single point of change.

**Invariant:**
- Shared, cross-module constants live in `lib_core_helper/.../constants/` as `object` namespaces grouped by domain
- Constants used by a single class are declared in that class's `companion object` as `const val` — never duplicated as inline literals elsewhere in the same file
- Trivial sentinel values (`0`/`1`/`-1` for indices and comparisons, `true`/`false`, empty-string checks in guards) are exempt — naming these adds noise, not clarity
- Feature-scoped Analytics Constants and Route Constants follow their own dedicated conventions (see standard architecture) — this rule covers everything else

| Scope | Where it lives | Example |
|---|---|---|
| Shared across modules | `lib_core_helper/.../constants/{Domain}Constants.kt` | API paths, timeouts, regex patterns, format strings |
| Local to one class | `companion object { const val ... }` on the class itself | Debounce thresholds, animation durations, page sizes specific to that screen |

---

### Code Pattern

```kotlin
// lib_core_helper/src/main/java/co/talenta/lib_core_helper/constants/NetworkConstants.kt
object NetworkConstants {
    const val DEFAULT_TIMEOUT_SECONDS = 30L
    const val DEFAULT_LOCALE = "en_US"
    const val EMPLOYEES_ENDPOINT = "v1/employees"
}

// Usage — domain/data/presentation
client.newCall(request)
    .timeout(NetworkConstants.DEFAULT_TIMEOUT_SECONDS, TimeUnit.SECONDS)
```

**Local to a class:**

```kotlin
class AttendanceCardViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
    companion object {
        private const val CARD_RADIUS_DP = 12
        private const val EXPAND_ANIMATION_DURATION_MS = 250L
    }

    // ...uses CARD_RADIUS_DP and EXPAND_ANIMATION_DURATION_MS — never inline 12 or 250
}
```

**Critical:** if the same literal appears in two or more files, it has already outgrown "local" — promote it to the shared `constants` package instead of copying it.
