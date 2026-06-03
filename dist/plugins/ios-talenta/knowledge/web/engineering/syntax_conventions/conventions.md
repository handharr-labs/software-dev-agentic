---
platform: web
project: web
discipline: engineering
topic: syntax_conventions
pattern: conventions
---

## Theory

**Rule:** Never use raw null-fallback operators (e.g. `??`, `?:`, `!`) directly in domain, data, or presentation code. Always delegate to a named extension method or utility function.

**Why:** Raw operators scatter fallback semantics across the codebase — the intent (`orEmpty`, `orZero`) disappears into punctuation. Named methods make the fallback explicit, searchable, and consistently applied.

**Categories — every platform must implement all of these:**

| Category | Method name | Fallback |
|---|---|---|
| Nullable numeric | `orZero()` | `0` |
| Nullable string | `orEmpty()` | `""` |
| Nullable collection | `orEmpty()` | `[]` |
| Nullable bool (false) | `orFalse()` | `false` |
| Nullable bool (true) | `orTrue()` | `true` |
| Nullable with custom default | `orDefault(x)` | `x` |

**Invariant:** Raw null operators are allowed only inside the extension/utility implementations themselves — never in domain, data, or presentation artifacts.

---

## Null Safety Extensions

Cross-cutting coding rules applied to every artifact the builder worker creates, regardless of layer.

```typescript
// core/utils/nullSafety.ts

/** Returns the value or 0 if null/undefined */
export function orZero(value: number | null | undefined): number {
  return value ?? 0;
}

/** Returns the value or empty string if null/undefined */
export function orEmpty(value: string | null | undefined): string {
  return value ?? '';
}

/** Returns the value or empty array if null/undefined */
export function orEmptyArray<T>(value: T[] | null | undefined): T[] {
  return value ?? [];
}

/** Returns the value or the provided default */
export function orDefault<T>(value: T | null | undefined, defaultValue: T): T {
  return value ?? defaultValue;
}

/** Filters null/undefined values from an array */
export function compact<T>(array: (T | null | undefined)[]): T[] {
  return array.filter((item): item is T => item != null);
}

/** Returns first non-null value */
export function firstNonNull<T>(...values: (T | null | undefined)[]): T | null {
  return values.find((v) => v != null) ?? null;
}
```

Raw `??` is allowed only in infrastructure/utility implementations themselves, not in domain, data, or presentation code.
