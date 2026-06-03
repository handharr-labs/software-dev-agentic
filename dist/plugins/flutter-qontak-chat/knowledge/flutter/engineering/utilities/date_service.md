---
platform: flutter
discipline: engineering
topic: utilities
pattern: date_service
---

## Theory

**DateService** is a centralized abstraction for all date and time operations — formatting, parsing, comparison, and timezone handling.

**Invariants:**
- All date formatting and parsing goes through `DateService` — never via inline format strings or `SimpleDateFormat`/`DateFormatter` at call sites
- Timezone handling is explicit — never assume device timezone in business logic
- The interface is injectable for testing — implementations can return fixed dates in tests

**When to use:** Any layer that formats, parses, or compares dates. Domain layer may define date-related value objects; `DateService` handles the conversion to/from display and wire formats.

---

Centralized date handling with timezone and formatting. Interface-based for testability. Uses `intl` package. Registered via `@LazySingleton(as: DateService)`.

## Code Pattern

```dart
// core/date/date_service.dart
abstract class DateService {
  DateTime get now;
  String format(DateTime date, DateFormatStyle style, {String locale});
  DateTime? parse(String value, DateFormatStyle style);
  DateTime startOfDay(DateTime date);
  DateTime endOfDay(DateTime date);
  DateTime addDays(DateTime date, int days);
  int daysBetween(DateTime start, DateTime end);
  bool isSameDay(DateTime a, DateTime b);
  bool isToday(DateTime date);
  bool isPast(DateTime date);
  bool isFuture(DateTime date);
}

enum DateFormatStyle {
  iso8601,        // "2024-01-15T14:30:00Z"
  apiDate,        // "2024-01-15"
  apiDateTime,    // "2024-01-15 14:30:00"
  displayDate,    // "Jan 15, 2024"
  displayDateTime,// "Jan 15, 2024, 2:30 PM"
  displayTime,    // "2:30 PM"
  relative,       // "2 days ago"
}
```

```dart
// core/date/date_service_impl.dart
@LazySingleton(as: DateService)
class DateServiceImpl implements DateService {
  @override
  DateTime get now => DateTime.now();

  @override
  String format(DateTime date, DateFormatStyle style, {String locale = 'en_US'}) {
    return switch (style) {
      DateFormatStyle.iso8601 => date.toIso8601String(),
      DateFormatStyle.apiDate => DateFormat('yyyy-MM-dd').format(date),
      DateFormatStyle.apiDateTime => DateFormat('yyyy-MM-dd HH:mm:ss').format(date),
      DateFormatStyle.displayDate => DateFormat.yMMMd(locale).format(date),
      DateFormatStyle.displayDateTime => DateFormat.yMMMd(locale).add_jm().format(date),
      DateFormatStyle.displayTime => DateFormat.jm(locale).format(date),
      DateFormatStyle.relative => _relative(date),
    };
  }

  String _relative(DateTime date) {
    final diff = now.difference(date);
    if (diff.inDays.abs() > 0)
      return '${diff.inDays.abs()} day${diff.inDays.abs() == 1 ? '' : 's'} ${diff.isNegative ? 'from now' : 'ago'}';
    if (diff.inHours.abs() > 0)
      return '${diff.inHours.abs()} hour${diff.inHours.abs() == 1 ? '' : 's'} ${diff.isNegative ? 'from now' : 'ago'}';
    return 'just now';
  }

  @override
  DateTime? parse(String value, DateFormatStyle style) {
    try {
      return switch (style) {
        DateFormatStyle.iso8601 => DateTime.parse(value),
        DateFormatStyle.apiDate => DateFormat('yyyy-MM-dd').parse(value),
        DateFormatStyle.apiDateTime => DateFormat('yyyy-MM-dd HH:mm:ss').parse(value),
        _ => DateTime.tryParse(value),
      };
    } catch (_) { return null; }
  }

  @override
  DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);
  @override
  DateTime endOfDay(DateTime date) => DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  @override
  DateTime addDays(DateTime date, int days) => date.add(Duration(days: days));
  @override
  int daysBetween(DateTime start, DateTime end) => end.difference(start).inDays;
  @override
  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  @override
  bool isToday(DateTime date) => isSameDay(date, now);
  @override
  bool isPast(DateTime date) => date.isBefore(now);
  @override
  bool isFuture(DateTime date) => date.isAfter(now);
}
```
