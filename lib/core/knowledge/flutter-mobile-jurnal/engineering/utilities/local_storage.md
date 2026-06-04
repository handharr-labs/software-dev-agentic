---
platform: flutter
project: flutter-mobile-jurnal
discipline: engineering
topic: utilities
pattern: local_storage
---

## Theory

Jurnal has no dedicated `StorageService` abstraction (unlike flutter base). Local storage is abstracted through `BaseLocalRepository` and `BaseStorage` in `jurnal_core`. Feature-specific local datasources extend these base classes.

**Deviation from `flutter/` base:** `flutter/` base uses `SharedPreferences`-backed `StorageService`. Jurnal uses `BaseLocalRepository`/`BaseStorage` with Hive/ObjectBox-based local datasources.

## Code Pattern

```dart
// jurnal_core/lib/repository/local/base_local_repository.dart
abstract class BaseLocalRepository { ... }

// jurnal_core/lib/repository/storage/base_storage.dart
abstract class BaseStorage { ... }
```

For key-value or simple persistence, extend `BaseStorage` or `BaseLocalRepository` from `jurnal_core`. Do not create standalone key-value wrappers.

## Definition

**`JsonParser`** — safe JSON coercion utilities for `@freezed` response models where the API may return numbers as strings or use inconsistent key names:

```dart
// jurnal_core/lib/utils/json_parser.dart
@JsonKey(fromJson: JsonParser.parseIntOrNull)
int? count

@JsonKey(fromJson: JsonParser.parseDoubleOrNull)
double? amount

// Pagination key variance (total_page vs total_pages):
@JsonKey(readValue: JsonParser.readTotalPages, fromJson: JsonParser.parseIntOrNull)
int? totalPages
```
