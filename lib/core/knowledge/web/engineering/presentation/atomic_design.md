---
platform: web
project: web
discipline: engineering
topic: presentation
pattern: atomic_design
---

## Theory

A **Component** (also called Sub-view, Widget, or View) is a reusable UI element smaller than a full screen.

**Invariants:**
- Stateless by default — receives data via props/parameters and emits callbacks
- If stateful, bound to a scoped StateHolder — never manages business state inline
- No use case calls — all data passed in from the parent screen or a scoped StateHolder
- Reuse check required before creating — search shared component directories first

**When to create:** When a UI element appears in ≥2 screens, or when a screen section is complex enough to isolate for readability.

---

## Atomic Design within the Presentation Layer

Clean Architecture owns the **vertical** slice (domain → data → presentation).
Atomic Design owns the **horizontal** slice (how components are structured *within* presentation).

| Atomic Level | Location | Description | Example |
|---|---|---|---|
| Atoms | `shared/presentation/common/atoms/` | Indivisible elements. No business logic, primitive props only | `ErrorBanner`, `ProgressBar`, `Badge` |
| Molecules | `shared/presentation/common/molecules/` | Small groups of atoms forming a meaningful unit | `PageHeader`, `PageShell` |
| Organisms | `features/{name}/presentation/organisms/` | Complex, feature-aware sections. May accept domain entities as props | `TransactionListItem`, `CategoryItemEditor` |
| Views (Pages) | `features/{name}/presentation/` | Connects ViewModel hook to organisms. No direct API calls | `TransactionsView`, `DashboardView` |

**Rules:**
1. Atoms and molecules accept only primitive props (`string`, `number`, `boolean`, `ReactNode`). No domain entities, no use case hooks.
2. Organisms may accept domain entities as props — they render, but do not fetch.
3. Only Views call `useDI()` and ViewModel hooks — they pass data down to organisms.
4. Shared atoms/molecules live in `src/shared/presentation/common/`. Feature-specific organisms live inside their own feature slice.
5. A component that is used in ≥2 features must be promoted to `shared/presentation/common/`.

## View Data Transformer Pattern

Domain objects return structured, semantic data. The presentation layer is responsible for converting that data into display-ready values like CSS class strings, labels, and icons. **Never put Tailwind class strings or locale-formatted display strings inside domain services or use cases.**

**Pattern: status enum → display config map**

```typescript
// domain/services/BudgetProgressService.ts — domain returns semantic status
export type BudgetStatus = 'on-track' | 'at-risk' | 'over';

export interface BudgetProgressData {
  readonly percent: number;
  readonly remaining: number;
  readonly isOverrun: boolean;
  readonly status: BudgetStatus;   // semantic, not visual
}
```

```typescript
// presentation/organisms/CategoryBreakdownSection.tsx — presentation maps to CSS
import type { BudgetStatus } from '@/features/dashboard/domain/services/BudgetProgressService';

const STATUS_COLOR: Record<BudgetStatus, string> = {
  'on-track': 'bg-emerald-400',
  'at-risk':  'bg-yellow-400',
  'over':     'bg-red-400',
};

const STATUS_TEXT: Record<BudgetStatus, string> = {
  'on-track': 'text-emerald-600 dark:text-emerald-300',
  'at-risk':  'text-yellow-600 dark:text-yellow-300',
  'over':     'text-red-600 dark:text-red-300',
};

// Usage in JSX:
<div className={STATUS_COLOR[progress.status]} />
<span className={STATUS_TEXT[progress.status]} />
```

**Domain vs presentation boundary:**

| Concern | Layer | Example |
|---------|-------|---------|
| Severity classification | Domain | `status: 'over' \| 'at-risk' \| 'on-track'` |
| CSS class strings | Presentation | `'bg-red-400'`, `'text-red-600 dark:text-red-300'` |
| Locale-formatted numbers | Presentation | `'Rp 1.2jt'` via `formatCompactCurrency` |
| Raw numbers / booleans | Domain | `remaining: number`, `isOverrun: boolean` |
| User-facing message strings | Presentation | `'The requested resource was not found.'` |

## Component

Reusable React component — ViewModel-unaware. Receives plain domain entities or primitives as props.

Placement follows Atomic Design:
- **Atom** → `shared/presentation/common/atoms/[ComponentName].tsx` — primitive props only
- **Molecule** → `shared/presentation/common/molecules/[ComponentName].tsx` — primitive props only
- **Organism** → `features/[feature]/presentation/organisms/[ComponentName].tsx` — may accept domain entities

```typescript
// Atom example
interface [ComponentName]Props {
  title: string;
  subtitle?: string;
  onClick?: () => void;
}

export function [ComponentName]({ title, subtitle, onClick }: [ComponentName]Props) {
  return (
    <div className="..." onClick={onClick}>
      <p className="...">{title}</p>
      {subtitle && <p className="...">{subtitle}</p>}
    </div>
  );
}
```

Rules:
- No `useDI()`, no ViewModel hooks inside a component
- Atoms and molecules accept only primitive props — no domain entities
- Organisms may accept domain entities as props — they render, but do not fetch
- A component used in ≥2 features must be promoted to `shared/presentation/common/`

## Shared Component Paths

When running a Component Reuse Check, search these locations for existing reusable components:

| Atomic level | Path | File pattern |
|---|---|---|
| Atoms (primitive, no business logic) | `shared/presentation/common/atoms/` | `*.tsx` |
| Molecules (small groups of atoms) | `shared/presentation/common/molecules/` | `*.tsx` |
| Organisms (feature-aware, accepts domain entities) | `features/*/presentation/organisms/` | `*.tsx` |
