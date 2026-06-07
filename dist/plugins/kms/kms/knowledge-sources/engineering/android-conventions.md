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
