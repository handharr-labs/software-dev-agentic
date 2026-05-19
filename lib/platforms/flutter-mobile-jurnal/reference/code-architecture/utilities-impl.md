## StorageService

<!-- MISSING_PATTERN: no dedicated StorageService abstraction found at utils/helpers level — local storage is accessed via BaseLocalRepository (jurnal_core) and Hive/ObjectBox-based local datasources -->

Local storage is abstracted through `BaseLocalRepository` and `BaseStorage` in `jurnal_core`. Feature-specific local datasources extend these base classes.

```dart
// jurnal_core/lib/repository/local/base_local_repository.dart
abstract class BaseLocalRepository { ... }

// jurnal_core/lib/repository/storage/base_storage.dart
abstract class BaseStorage { ... }
```

For key-value or simple persistence, follow the pattern in `jurnal_core/lib/repository/` — extend `BaseStorage` or `BaseLocalRepository`.

---

## DateService

<!-- MISSING_PATTERN: no DateService class found — date formatting is handled via DateTimeExtension -->

Date utilities are in `features/jurnal_core/lib/extensions/date_time_extension.dart`:

```dart
extension DateTimeExtension on DateTime {
  // Extension methods for formatting and parsing
  // e.g. .toApiFormat(), .toDisplayString(), ...
}
```

Use `DateTimeExtension` methods directly on `DateTime` instances. Do not create free-standing date formatting functions.

---

## Logger

Logging utilities live in `jurnal_core` under:
- `features/jurnal_core/lib/logger/` — `NetworkLogger`, `BlocLogger`, `RouteLogger`, `Log`

```dart
// Example usage
Log.d('Debug message');
Log.e('Error message', error, stackTrace);
```

`BlocLogger` hooks into BLoC observer for state transition logging. `NetworkLogger` hooks into Dio interceptors for request/response logging. `RouteLogger` hooks into Navigator observer.

---

## Null Safety

`JsonParser` in `jurnal_core/lib/utils/json_parser.dart` provides safe coercion utilities for JSON deserialization:

```dart
// Safe int parsing from String, int, or num:
@JsonKey(fromJson: JsonParser.parseIntOrNull)
int? count

// Safe double parsing:
@JsonKey(fromJson: JsonParser.parseDoubleOrNull)
double? amount

// Pagination key variance (total_page vs total_pages):
@JsonKey(readValue: JsonParser.readTotalPages, fromJson: JsonParser.parseIntOrNull)
int? totalPages
```

Use these in all `@freezed` response models where the API may return numbers as strings or use inconsistent key names.

---

## Other Utilities

**`Debounce`** (`jurnal_core/lib/utils/debounce.dart`) — debounce search/input callbacks.

**`Throttle`** (`jurnal_core/lib/utils/throttle.dart`) — throttle rapid user actions.

**`CurrencyInputFormatter`** (`jurnal_core/lib/utils/currency_input_formatter.dart`) — `TextInputFormatter` for currency fields.

**`CurrencyFormatter`** (`features/jurnal_product/lib/src/utils/currency_formatter.dart`) — feature-level currency display formatting.

**`StringExtension`** (`jurnal_core/lib/extensions/string_extension.dart`) — string utilities.

**`ContextExtension`** (`jurnal_core/lib/extensions/context_extension.dart`) — `BuildContext` helpers (theme, localization shortcuts).

**`TransactionTypeExtension`** (`jurnal_core/lib/extensions/transaction_type_extension.dart`) — domain-enum display helpers.
