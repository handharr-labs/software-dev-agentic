---
platform: web
project: web
discipline: engineering
topic: utilities
pattern: helper_extensions
---

## Theory

**Helper Extensions** are stateless utility functions scoped to a specific type — they extend built-in types with domain-safe convenience without introducing service dependencies.

**Invariants:**
- Extensions contain no business logic and no side effects — pure transformations only
- No analytics SDK, storage, or network imports inside extension files
- Grouped by the type they extend (e.g. `String+Formatting`, `Date+Helpers`) — never a catch-all utilities file

**When to use:** Repetitive type-level transformations that would otherwise be inlined everywhere. If the transformation requires injected state, it belongs in a use case or service, not an extension.

---

## Helper Extensions

Utility functions live in `presentation/common/utils/` or `core/utils/`, grouped by the type they transform.

| Helper | File | Key Functions |
|--------|------|---------------|
| `string` | `stringUtils.ts` | `removeWhitespace`, `capitalizeFirst`, `isNumeric`, `truncate(length)`, `maskEmail` |
| `Date` | `dateUtils.ts` | `toDisplayDate(date)`, `toApiDate(date)`, `isToday(date)`, `isPast(date)` |
| `number` | `numberUtils.ts` | `toCurrencyString(n, currency)`, `toFormattedString(n, decimals)` |
| `Array<T>` | `arrayUtils.ts` | `groupBy(arr, key)`, `uniqueBy(arr, key)`, `chunkArray(arr, size)` |
| `URL / query` | `queryUtils.ts` | `buildQueryString(params)`, `parseQueryString(search)` |
