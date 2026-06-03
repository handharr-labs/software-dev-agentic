---
platform: web
project: web
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

Centralized date handling with timezone and formatting support. Wraps `date-fns` or the native `Intl` API.

```typescript
// core/date/DateService.ts
export type DateFormatStyle =
  | 'iso8601'        // "2024-01-15T14:30:00Z"
  | 'apiDate'        // "2024-01-15"
  | 'apiDateTime'    // "2024-01-15 14:30:00"
  | 'displayDate'    // "Jan 15, 2024"
  | 'displayDateTime'// "Jan 15, 2024, 2:30 PM"
  | 'displayTime'    // "2:30 PM"
  | 'relative'       // "2 days ago", "in 3 hours"
  | { custom: string }; // Custom Intl format

export interface DateService {
  now(): Date;
  format(date: Date, style: DateFormatStyle, locale?: string): string;
  parse(value: string, style: DateFormatStyle): Date | null;
  startOfDay(date: Date): Date;
  endOfDay(date: Date): Date;
  addDays(date: Date, days: number): Date;
  daysBetween(start: Date, end: Date): number;
  isSameDay(a: Date, b: Date): boolean;
  isToday(date: Date): boolean;
  isPast(date: Date): boolean;
  isFuture(date: Date): boolean;
}

export class DateServiceImpl implements DateService {
  now(): Date { return new Date(); }

  format(date: Date, style: DateFormatStyle, locale = 'en-US'): string {
    if (style === 'iso8601') return date.toISOString();
    if (style === 'apiDate') return date.toISOString().slice(0, 10);
    if (style === 'apiDateTime') return date.toISOString().slice(0, 19).replace('T', ' ');
    if (style === 'displayDate') {
      return new Intl.DateTimeFormat(locale, { dateStyle: 'medium' }).format(date);
    }
    if (style === 'displayDateTime') {
      return new Intl.DateTimeFormat(locale, { dateStyle: 'medium', timeStyle: 'short' }).format(date);
    }
    if (style === 'displayTime') {
      return new Intl.DateTimeFormat(locale, { timeStyle: 'short' }).format(date);
    }
    if (style === 'relative') {
      const rtf = new Intl.RelativeTimeFormat(locale, { numeric: 'auto' });
      const diffDays = this.daysBetween(date, this.now());
      return rtf.format(diffDays, 'day');
    }
    if (typeof style === 'object' && 'custom' in style) {
      // Use date-fns format() for custom patterns if available
      return date.toLocaleDateString(locale);
    }
    return date.toString();
  }

  parse(value: string, style: DateFormatStyle): Date | null {
    if (style === 'iso8601' || style === 'apiDateTime') {
      const d = new Date(value);
      return isNaN(d.getTime()) ? null : d;
    }
    if (style === 'apiDate') {
      const d = new Date(`${value}T00:00:00Z`);
      return isNaN(d.getTime()) ? null : d;
    }
    return null;
  }

  startOfDay(date: Date): Date {
    const d = new Date(date);
    d.setHours(0, 0, 0, 0);
    return d;
  }

  endOfDay(date: Date): Date {
    const d = new Date(date);
    d.setHours(23, 59, 59, 999);
    return d;
  }

  addDays(date: Date, days: number): Date {
    const d = new Date(date);
    d.setDate(d.getDate() + days);
    return d;
  }

  daysBetween(start: Date, end: Date): number {
    const msPerDay = 1000 * 60 * 60 * 24;
    return Math.round((end.getTime() - start.getTime()) / msPerDay);
  }

  isSameDay(a: Date, b: Date): boolean {
    return (
      a.getFullYear() === b.getFullYear() &&
      a.getMonth() === b.getMonth() &&
      a.getDate() === b.getDate()
    );
  }

  isToday(date: Date): boolean { return this.isSameDay(date, this.now()); }
  isPast(date: Date): boolean { return date < this.now(); }
  isFuture(date: Date): boolean { return date > this.now(); }
}
```
