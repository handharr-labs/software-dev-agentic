# UI Layer — Android

Platform-specific UI layer patterns. Canonical definitions: `reference/code-architecture/ui-theory.md`.

---

## Dependency Rule <!-- 9 -->

UI depends on Presentation only — never imports Domain or Data directly.

Allowed imports: Presenter contract interfaces, View contract interfaces, Android framework primitives (`Activity`, `Fragment`, `View`).
Forbidden: use case interfaces, repository interfaces, DTOs, mappers, datasources, or Retrofit types.

---

## Screen <!-- 15 -->

A **Screen** is an `Activity` or `Fragment` that implements a View contract interface and delegates all logic to its `Presenter`. It renders UI from Presenter calls and forwards user events — it contains no business logic.

**Invariants:**
- Implements a `View` contract interface — Presenter calls methods on the interface, never on the concrete class
- Holds a Presenter reference injected by Hilt/Dagger — never `MyPresenter()` inline
- Forwards every user interaction to the Presenter — never computes results inline
- Renders all UI states declared in the View contract — no state method goes unimplemented
- Contains no business logic — all conditionals decide what to render, not what to compute

**When to create:** One Activity/Fragment per route destination. Created after the Presenter and View contract exist.

---

## Component / Sub-view <!-- 14 -->

A **Component** is a custom `View` subclass or self-contained `Fragment` smaller than a full screen.

**Invariants:**
- Stateless by default — configured via a setter or data binding; emits events via listener interfaces or callbacks
- If stateful, driven by a scoped Presenter — never manages business state inline
- No use case calls — all data passed in from the parent Activity/Fragment or a scoped Presenter
- Reuse check required before creating — search `presentation/common/views/` and shared modules first

**When to create:** When a UI element appears in ≥2 screens, or when an Activity/Fragment section is complex enough to isolate for readability.

---

## Navigator / Coordinator <!-- 14 -->

A **Navigator** is a `NavigationImpl` class implementing a navigation interface, injected into the Presenter.

**Invariants:**
- The Presenter holds the navigation interface — it never references `Activity` or `Intent` directly
- The Activity provides `Context` at navigation call time via `view?.getContext()` — never stored in Presenter
- Navigation interfaces live in `base/common` module — not in feature modules
- Each Activity exposes a `companion object { fun newIntent(...) }` factory for typed navigation

**When to create:** When a Presenter navigates to another screen. Navigation interface defined in `base/common` before the Presenter that uses it. See `navigation-impl.md` for full pattern.

---

## DI Wiring <!-- 13 -->

**DI wiring** registers the Presenter and its dependencies in a Hilt module.

**Invariants:**
- Presenter provided via `@Provides` or `@Binds` in a Hilt `@Module` — scope matches Activity/Fragment lifetime
- Use cases injected into the Presenter constructor — never instantiated inside the Presenter
- Navigation implementation bound to its interface in the Hilt module

**When to create:** After the Screen and Presenter exist. Required before the feature is navigable.

---

## Creation Order <!-- 10 -->

```
Activity/Fragment (View contract) → NavigationImpl (if navigation needed) → Hilt module binding
```

The Presenter contract and View contract must exist before any UI layer file is written.

---

## Layer Invariants <!-- 10 -->

- Activity/Fragment never holds business logic — delegates everything to Presenter
- Activity/Fragment never calls use cases directly — all interactions go through the Presenter
- Presenter instantiated via Hilt — never `MyPresenter()` inline in Activity
- Navigation delegated to NavigationImpl via interface — Presenter calls interface, not `startActivity` directly
- No data layer knowledge — no DTOs, no Retrofit types, no datasource references visible in UI files

---

## Planner Search Patterns <!-- 7 -->

When exploring the UI layer, glob for:
- `**/presentation/**/*Activity.kt` — screen Activity files
- `**/presentation/**/*Fragment.kt` — screen Fragment files
- `**/presentation/common/views/**/*.kt` — shared component files
- `**/navigation/**/*NavigationImpl.kt` — navigator implementation files
