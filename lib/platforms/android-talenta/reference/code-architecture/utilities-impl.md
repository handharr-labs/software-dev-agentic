# Android — Utilities & Extension Functions

## StorageService <!-- 4 -->

> Android StorageService patterns not yet catalogued. Add `SharedPreferences`/`EncryptedSharedPreferences` abstraction here when established.

## DateService <!-- 4 -->

> Android DateService patterns not yet catalogued. Add date formatting/parsing utilities here (e.g. `SimpleDateFormat`, `DateTimeFormatter`) when established.

## Logger <!-- 6 -->

> Android Logger patterns not yet catalogued. Add structured logging utility here (e.g. Timber wrapper) when established.

---

## Helper Extensions <!-- 12 -->

Extension functions live in `core/extensions/`.

| Helper | File | Key Functions |
|--------|------|---------------|
| `String?` | `StringExtensions.kt` | `.orEmpty()`, `.orDash()`, `.removeWhitespace()`, `.capitalizeFirst()`, `.isNumeric()` |
| `Int?` / `Double?` | `NumberExtensions.kt` | `.orZero()`, `.toCurrencyString()`, `.toFormattedString()` |
| `Date` / `Calendar` | `DateExtensions.kt` | `.toDisplayDate()`, `.toApiDate()`, `.isToday()`, `.isPast()` |
| `View` | `ViewExtensions.kt` | `.show()`, `.hide()`, `.gone()`, `.addRipple()` |
| `Activity` / `Fragment` | `ContextExtensions.kt` | `.showToast(msg)`, `.showSnackbar(msg)`, `.hideKeyboard()` |
| `Observable<T>` | `RxExtensions.kt` | `.applySchedulers()`, `.mapToVoid()`, `.retryWithDelay(n)` |
