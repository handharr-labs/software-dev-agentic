---
platform: android
project: android-talenta
discipline: engineering
topic: ui
pattern: screen
---

## Theory

A **Screen** is a full-page view bound to a single StateHolder. It observes state and sends events — it contains no business logic.

**Invariants:**
- Bound to exactly one StateHolder — instantiated via DI, never with direct `new` / `init`
- Observes every State field declared in the StateHolder contract — no State field goes unhandled
- Sends events to the StateHolder for every user interaction — never mutates state directly
- Contains no business logic — conditionals exist only to decide what to render, not what to compute
- No use case calls — all data flows through the StateHolder

**When to create:** One screen per route/destination. Created after the StateHolder contract exists.

---

## Definition

A **Screen** is an `Activity` or `Fragment` that implements a View contract interface and delegates all logic to its `Presenter`. It renders UI from Presenter calls and forwards user events — it contains no business logic.

**Invariants:**
- Implements a `View` contract interface — Presenter calls methods on the interface, never on the concrete class
- Holds a Presenter reference injected by Hilt/Dagger — never `MyPresenter()` inline
- Forwards every user interaction to the Presenter — never computes results inline
- Renders all UI states declared in the View contract — no state method goes unimplemented
- Contains no business logic — all conditionals decide what to render, not what to compute

**When to create:** One Activity/Fragment per route destination. Created after the Presenter and View contract exist.

## Code Pattern

See `presentation/screen_structure.md` for the full Activity pattern.
