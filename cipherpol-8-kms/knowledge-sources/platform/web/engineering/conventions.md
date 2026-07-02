---
scope: platform/web
discipline: engineering
artifact: conventions
---
## Null Safety Extensions

### Theory

**Rule:** Never use raw null-fallback operators (`??`, `||`, `?.`) directly in domain, data, or presentation code. Always delegate to a named utility function.

**Why:** Raw operators scatter fallback semantics across the codebase — the intent (`orEmpty`, `orZero`) disappears into punctuation. Named functions make the fallback explicit, searchable, and consistently applied.

**Invariant:** Raw null operators are allowed only inside the utility implementations themselves — never in domain, data, or presentation artifacts.

| Category | Function | Fallback |
|---|---|---|
| Nullable number | `orZero(v)` | `0` |
| Nullable string | `orEmpty(v)` | `""` |
| Nullable array | `orEmpty(v)` | `[]` |
| Nullable bool (false) | `orFalse(v)` | `false` |
| Nullable bool (true) | `orTrue(v)` | `true` |

Utilities live in `src/shared/core/utils/null-safety.ts` and are re-exported from the barrel `src/shared/core/utils/index.ts`.

---

### Code Pattern

```typescript
// src/shared/core/utils/null-safety.ts

export const orZero = (v: number | null | undefined): number => v ?? 0;
export const orEmpty = <T extends string | unknown[]>(v: T | null | undefined): T =>
  (v ?? (typeof v === 'string' ? '' : [])) as T;
export const orFalse = (v: boolean | null | undefined): boolean => v ?? false;
export const orTrue = (v: boolean | null | undefined): boolean => v ?? true;
export const orDefault = <T>(v: T | null | undefined, fallback: T): T => v ?? fallback;
```

**Usage — mapper pattern:**

```typescript
const employee = new EmployeeEntity({
  id: orZero(response?.id),
  name: orEmpty(response?.name),
  isActive: orFalse(response?.isActive),
  tags: orEmpty(response?.tags),
});
```

**Critical:** Never chain optional access past the call site without wrapping:

```typescript
orEmpty(response?.field)     // ✅
response?.field ?? ''        // ❌ — raw fallback at call site
```

---

## Helper Utilities

### Theory

**Helper Utilities** are stateless pure functions scoped to a specific type domain.

**Invariants:**
- No business logic, no side effects — pure transformations only
- No API, storage, or analytics imports inside utility files
- Grouped by the type they operate on — never a catch-all `utils.ts` file

Utility files live in `src/shared/core/utils/`.

---

### Code Pattern

| Helper | File | Key Exports |
|---|---|---|
| Null safety | `null-safety.ts` | `orZero`, `orEmpty`, `orFalse`, `orTrue`, `orDefault` |
| String | `string.ts` | `isBlank`, `isNotBlank`, `toBool`, `getOrDash` |
| Number | `number.ts` | `toCleanString`, `clamp`, `isFiniteNumber` |
| Array | `array.ts` | `uniqueBy`, `groupBy`, `partition`, `compact` |
| Date | `date.ts` | Delegates to `DateService` — no raw `Date` calls here |

---

## Magic Constants

### Theory

**Rule:** Never hard-code a domain-meaningful string or number inline. Promote it to a named constant — scoped to the shared `constants/` directory if reused across features, or declared as a `const` member on the class/file itself if local.

**Why:** A bare `30`, `'en-US'`, or `'/api/v1/employees'` carries no intent at the call site. Naming it makes the value searchable, the purpose explicit, and gives a single point of change.

**Invariant:**
- Shared, cross-feature constants live in `src/shared/core/constants/` and are re-exported via a barrel
- Constants used by a single module are declared `const` at the top of that file — never duplicated as inline literals elsewhere in the same file
- Trivial sentinel values (`0`/`1`/`-1` for indices, `true`/`false`, empty-string guards) are exempt — naming these adds noise

| Scope | Where it lives | Example |
|---|---|---|
| Shared across features | `shared/core/constants/{domain}.constants.ts` | API paths, timeouts, regex patterns |
| Local to one file/class | Top-level `const` in that file | Component animation durations, local retry counts |

---

### Code Pattern

```typescript
// src/shared/core/constants/network.constants.ts
export const NetworkConstants = {
  defaultTimeoutMs: 30_000,
  defaultLocale: 'en-US',
  employeesEndpoint: '/api/v1/employees',
} as const;

// Usage
const response = await httpClient.get(NetworkConstants.employeesEndpoint, {
  timeout: NetworkConstants.defaultTimeoutMs,
});
```

**Local to a component:**

```typescript
// EmployeeCard.tsx
const CARD_ANIMATION_MS = 250;
const MAX_TAG_DISPLAY = 3;
// never inline 250 or 3 elsewhere in this file
```

**Critical:** if the same literal appears in two or more files, it has already outgrown "local" — promote it to the shared `constants/` directory.

---

## TypeScript Strictness

### Theory

**Rule:** Never use `any`. TypeScript's type system is the first line of defence — bypassing it with `any` is a clean architecture violation because it removes the boundary that enforces layer contracts.

**Invariants:**
- `strict: true` in `tsconfig.json` — no exceptions
- `any` is banned — use `unknown` at trust boundaries (API responses, `JSON.parse`) and narrow immediately with a Zod schema
- `as Type` casting is banned outside of test fixtures — if you need a cast, the types are wrong
- `// @ts-ignore` / `// @ts-expect-error` requires a comment explaining the exact reason

---

### Code Pattern

```typescript
// ❌ Never
const data: any = await response.json();
const employee = data as EmployeeDto;

// ✅ Always — parse at the trust boundary
import { employeeDtoSchema } from '../models/employee.schema';

const raw: unknown = await response.json();
const dto = employeeDtoSchema.parse(raw);   // throws ZodError on invalid shape
```

**Strict tsconfig flags:**

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

---

## Import Barrel Rules

### Theory

Barrel files (`index.ts`) are the public API of a module. Importing across module boundaries must go through the barrel — never through deep internal paths.

**Invariants:**
- Cross-feature imports use the barrel: `import { EmployeeEntity } from '@features/employee'`
- Intra-feature imports use relative paths
- Circular barrel imports are banned — if two features import each other, extract the shared type to `src/shared/`

---

### Code Pattern

```typescript
// src/features/employee/index.ts  (barrel — public API)
export type { EmployeeEntity } from './domain/entities/employee.entity';
export { GetEmployeeUseCase } from './domain/usecases/get-employee.usecase';

// Another feature imports via barrel:
import type { EmployeeEntity } from '@features/employee';   // ✅

// Never:
import type { EmployeeEntity } from '@features/employee/domain/entities/employee.entity';  // ❌
```
