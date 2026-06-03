---
platform: ios
project: ios-talenta
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

## DateService

Centralized date handling with timezone/formatting.

```swift
// Core/Date/DateService.swift
protocol DateService {
    var now: Date { get }
    var currentTimeZone: TimeZone { get }

    func format(_ date: Date, style: DateFormatStyle) -> String
    func parse(_ string: String, format: DateFormatStyle) -> Date?
    func startOfDay(_ date: Date) -> Date
    func endOfDay(_ date: Date) -> Date
    func addDays(_ days: Int, to date: Date) -> Date
    func daysBetween(_ start: Date, _ end: Date) -> Int
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool
}

enum DateFormatStyle {
    case iso8601              // "2024-01-15T14:30:00Z"
    case apiDate              // "2024-01-15"
    case apiDateTime          // "2024-01-15 14:30:00"
    case displayDate          // "Jan 15, 2024"
    case displayDateTime      // "Jan 15, 2024 at 2:30 PM"
    case displayTime          // "2:30 PM"
    case relative             // "2 days ago"
    case custom(String)
}

final class DateServiceImpl: DateService {
    private let calendar: Calendar
    private let locale: Locale

    init(calendar: Calendar = .current, locale: Locale = .current) {
        self.calendar = calendar
        self.locale = locale
    }

    var now: Date { Date() }
    var currentTimeZone: TimeZone { calendar.timeZone }

    func format(_ date: Date, style: DateFormatStyle) -> String {
        switch style {
        case .iso8601: return ISO8601DateFormatter().string(from: date)
        case .apiDate: return formatWith("yyyy-MM-dd", date)
        case .displayDate:
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            formatter.locale = locale
            return formatter.string(from: date)
        case .custom(let format): return formatWith(format, date)
        default: return formatWith("yyyy-MM-dd HH:mm:ss", date)
        }
    }
}

extension DateService {
    func toAPIDate(_ date: Date) -> String { format(date, style: .apiDate) }
    func fromAPIDate(_ string: String) -> Date? { parse(string, format: .apiDate) }
    func isToday(_ date: Date) -> Bool { isSameDay(date, now) }
    func isPast(_ date: Date) -> Bool { date < now }
    func isFuture(_ date: Date) -> Bool { date > now }
}
```

**Usage:** For simple formatting use `Date+Extensions.swift` helpers. Use `DateService` for injectable, testable components.
