---
platform: web
project: web
discipline: engineering
topic: ui
pattern: screen_structure
---

## Theory

UI depends on Presentation only. It never imports from Domain or Data directly.

```
Presentation  ←  UI
```

Allowed imports: StateHolder contract types, State/Event/Action types, platform UI framework primitives.
Forbidden: use case interfaces, repository interfaces, DTOs, mappers, datasources, or any domain/data type instantiated directly.

**Screen invariants:**
- Bound to exactly one StateHolder — instantiated via DI, never with direct `new` / `init`
- Observes every State field declared in the StateHolder contract — no State field goes unhandled
- Sends events to the StateHolder for every user interaction — never mutates state directly
- Contains no business logic — conditionals exist only to decide what to render, not what to compute

---

## Dependency Rule

UI depends on Presentation only — never imports from Domain or Data directly.

Allowed imports: ViewModel hook return types, State/Action types, `react`, `next/navigation`, and UI library primitives (e.g. shadcn/ui, Tailwind classes).
Forbidden: use case interfaces, repository interfaces, DTOs, mappers, datasources, or direct fetch calls.

## Screen

A **Screen** is a Next.js Page component (`app/**/page.tsx`) that composes a single View component bound to a ViewModel hook. It renders layout structure and delegates data/interaction to the View — it contains no business logic.

**Invariants:**
- Page component is thin — delegates all state and event handling to the View + ViewModel hook
- View component bound to exactly one ViewModel hook — hook resolved via DI context, never constructed inline
- Observes every state field returned by the ViewModel hook — no state field goes unhandled
- Calls ViewModel hook action functions for every user interaction — never mutates state directly
- Contains no business logic — ternary/conditionals only decide what to render

**When to create:** One Page file per route. Created after the ViewModel hook contract exists.

## Component / Sub-view

A **Component** is a reusable React component (atomic design: atom, molecule, organism) smaller than a full screen view.

**Invariants:**
- Stateless by default — receives data via props and emits callbacks via `onX` props
- If stateful, binds to a scoped ViewModel hook or Zustand store slice — never manages business state inline
- No use case calls — all data passed in from the parent View or a scoped hook
- Reuse check required before creating — search `presentation/common/` and `components/` directories first

**When to create:** When a UI element appears in ≥2 screens, or when a View section is complex enough to isolate. Follow atomic design granularity.

## Navigator / Coordinator

A **Navigator** is the `useAppRouter` hook wrapping `next/navigation`, plus the `ROUTES` constants object.

**Invariants:**
- The View delegates navigation intent to the ViewModel hook — it never calls `router.push()` directly in event handlers without going through the hook
- The ViewModel hook calls `useAppRouter()` methods (e.g. `goToEmployeeDetail`) — never constructs path strings inline
- Route constants defined in `ROUTES` object — View never constructs path strings
- One `useAppRouter` hook per app — page-specific navigation helpers live in the ViewModel hook

**When to create:** When a View navigates to another page. `ROUTES` entry and `useAppRouter` method added before the View that triggers navigation. See `navigation-impl.md` for full router pattern.

## DI Wiring

**DI wiring** registers use cases and repositories in the `DIContext` provider, resolved by ViewModel hooks.

**Invariants:**
- Use cases registered in the DI container at the page/layout level via `DIProvider`
- ViewModel hook resolves dependencies via `useDI()` or equivalent context hook — never `new UseCase()` inline
- DI scope matches page or layout boundary — not global unless explicitly shared

**When to create:** After the Page and ViewModel hook exist. Required before the route is navigable.

## Creation Order

```
Page component → View component + ViewModel hook → ROUTES entry + useAppRouter method (if navigation needed) → DI registration
```

The ViewModel hook contract must exist before any UI layer file is written.

## Layer Invariants

- View never mutates state directly — reads from ViewModel hook return values only
- View never calls use cases directly — all interactions invoke ViewModel hook action functions
- Use cases resolved via DI context — never `new MyUseCase()` inside a component or hook
- Navigation delegated to `useAppRouter` via ViewModel hook — View emits intent, not path strings
- No data layer knowledge — no DTOs, no fetch calls, no HTTP types visible in component files

## Planner Search Patterns

When exploring the UI layer, glob for:
- `**/app/**/(page|layout).tsx` — Next.js page and layout files
- `**/presentation/features/**/*View.tsx` — feature view components
- `**/presentation/common/**/*.tsx` — shared component files
- `**/presentation/navigation/routes.ts` — route constants
