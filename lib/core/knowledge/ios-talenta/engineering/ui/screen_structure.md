---
platform: ios
project: ios-talenta
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

UI depends on Presentation only — never imports Domain or Data directly.

Allowed imports: `ViewModel` protocol types, `State`/`Action` types, UIKit primitives.
Forbidden: use case interfaces, repository interfaces, DTOs, mappers, datasources.

## Screen

A **Screen** is a `UIViewController` bound to a single `ViewModel` (protocol). It observes state via RxSwift bindings and sends actions — it contains no business logic.

**Invariants:**
- Bound to exactly one `ViewModel` protocol — injected via Coordinator, never `init`-ed directly
- Observes every state field emitted by the ViewModel — no state goes unhandled
- Sends user actions to the ViewModel for every user interaction — never mutates state directly
- Contains no business logic — `if`/`switch` only decides what to render
- No use case calls — all data flows through the ViewModel

**When to create:** One `UIViewController` per route. Created after the ViewModel protocol exists.

## Component / Sub-view

A **Component** is a reusable `UIView` or self-contained view class smaller than a full screen.

**Invariants:**
- Stateless by default — configured via a `configure(with:)` method or `UIModel` struct
- If stateful, driven by a scoped ViewModel — never manages business state inline
- No use case calls — all data passed in from the parent ViewController or a scoped ViewModel
- Reuse check required before creating — search `Presentation/Common/Views/` and shared component targets first

**When to create:** When a UI element appears in ≥2 screens, or when a ViewController section is complex enough to isolate.

## Navigator / Coordinator

A **Coordinator** (inheriting `BaseCoordinator<T>`) owns all navigation logic for a feature or flow.

**Invariants:**
- The ViewController delegates navigation intent to the Coordinator via the Navigator protocol — it never hard-codes a destination
- The ViewModel emits a navigation `Action` — the Coordinator decides the implementation
- Navigator protocol defines all navigation methods — the ViewController holds only the protocol reference
- One Coordinator per feature flow — not per ViewController

**When to create:** When a ViewController navigates to another screen. Created after the ViewController that triggers navigation. See `navigation-impl.md` for full Coordinator pattern.

## DI Wiring

**DI wiring** wires the ViewModel's dependencies at the call site in the Coordinator.

**Invariants:**
- ViewModel instantiated directly by the Coordinator via constructor injection — `let viewModel = MyViewModel(navigator: self, useCase: ...)` 
- Dependencies default to shared singletons in the `init` signature — enabling test overrides without a container
- Use cases and services never instantiated inside the ViewModel body — always injected via `init`

**When to create:** After the ViewController and ViewModel exist. The Coordinator owns construction. See `di-impl.md` for the target DIContainer pattern.

## Creation Order

```
UIViewController → Coordinator (if navigation needed) → DIContainer factory method
```

The `ViewModel` protocol and its concrete implementation must exist before any UI layer file is written.

## Layer Invariants

- ViewController never mutates state directly — observes RxSwift streams only
- ViewController never calls use cases directly — all interactions go through the ViewModel
- ViewModel instantiated by the Coordinator via constructor injection — never `MyViewModel()` with no dependencies
- Navigation delegated to Coordinator — ViewController emits intent via Navigator protocol, not destination
- No data layer knowledge — no DTOs, no datasources, no network types visible in UI files

## Planner Search Patterns

When exploring the UI layer, glob for:
- `**/Presentation/**/*ViewController.swift` — screen files
- `**/Presentation/Common/Views/**/*.swift` — shared component files
- `**/Presentation/Coordinator/**/*Coordinator.swift` — coordinator files
- `**/Presentation/Coordinator/**/*Navigator.swift` — navigator protocol files
