## Null Safety Extensions

### Theory

**Rule:** Never use raw null-fallback operators (`??`) directly in domain, data, or presentation code. Always delegate to a named extension method.

**Why:** Raw operators scatter fallback semantics across the codebase — the intent (`orEmpty`, `orZero`) disappears into punctuation. Named methods make the fallback explicit, searchable, and consistently applied.

**Invariant:** Raw null operators are allowed only inside the extension implementations themselves — never in domain, data, or presentation artifacts.

| Category | Method | Fallback |
|---|---|---|
| Nullable int | `orZero()` | `0` |
| Nullable double | `orZero()` | `0.0` |
| Nullable string | `orEmpty()` | `""` |
| Nullable list | `orEmpty()` | `[]` |
| Nullable bool (false) | `orFalse()` | `false` |
| Nullable bool (true) | `orTrue()` | `true` |

Extensions live in `talenta/lib/src/shared/core/extensions/` and are exported via the barrel `extensions.dart`.

---

### Code Pattern

```dart
// talenta/lib/src/shared/core/extensions/string_extension.dart
extension NullableStringExtension on String? {
  String orEmpty() => this ?? '';
  bool get isBlank => this == null || (this?.isEmpty).orFalse();
  bool get isNotBlank => !isBlank;
  bool toBool() => this?.toLowerCase() == 'true';
}

extension StringExtensionHandler on String? {
  String? ifEmptyOrNullReturn(String? defaultValue) =>
      this == null || (this?.isEmpty).orFalse() ? defaultValue : this;
  String getOrBlankDash() => this?.isEmpty ?? true ? '-' : this!;
}

// talenta/lib/src/shared/core/extensions/int_extensions.dart
extension NullableIntExtension on int? {
  int orZero() => this ?? 0;
}

// talenta/lib/src/shared/core/extensions/double_extensions.dart
extension NullableDouobleExtension on double? {
  double orZero() => this ?? 0.0;
}

// talenta/lib/src/shared/core/extensions/bool_extensions.dart
extension NullableBoolExtensions on bool? {
  bool orFalse() => this ?? false;
  bool orTrue() => this ?? true;
  int toInt() => orFalse() ? 1 : 0;
}

// talenta/lib/src/shared/core/extensions/collection_extensions.dart
extension NullableCollection<T> on List<T>? {
  List<T> orEmpty() => this ?? <T>[];
}
```

**Usage — mapper pattern:**

```dart
InboxLiveAttendance(
  id: (response?.id).orZero(),
  checkTime: (response?.checkTime).orEmpty(),
  shiftChanged: (response?.shiftChanged).orFalse(),
  tags: (response?.tags).orEmpty(),
)
```

**Critical:** Wrap optional chains in parentheses before calling extension methods:

```dart
(response?.field).orEmpty()     // ✅
response?.field.orEmpty()       // ❌ compile error — orEmpty() called on String, not String?
```

---

## Helper Extensions

### Theory

**Helper Extensions** are stateless utility functions scoped to a specific type.

**Invariants:**
- Extensions contain no business logic and no side effects — pure transformations only
- No analytics SDK, storage, or network imports inside extension files
- Grouped by the type they extend — never a catch-all utilities file

Extension files live in `talenta/lib/src/shared/core/extensions/`.

---

### Code Pattern

| Helper | File | Key Methods |
|---|---|---|
| `String?` | `string_extension.dart` | `.orEmpty()`, `.isBlank`, `.isNotBlank`, `.toBool()`, `.getOrBlankDash()`, `.ifEmptyOrNullReturn()` |
| `int?` | `int_extensions.dart` | `.orZero()` |
| `double?` | `double_extensions.dart` | `.orZero()` |
| `double` | `double_extensions.dart` | `.toCleanString({fractionDigits})` |
| `bool?` | `bool_extensions.dart` | `.orFalse()`, `.orTrue()`, `.toInt()` |
| `List<T>?` | `collection_extensions.dart` | `.orEmpty()` |
