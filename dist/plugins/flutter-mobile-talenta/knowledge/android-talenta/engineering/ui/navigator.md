---
platform: android
project: android-talenta
discipline: engineering
topic: ui
pattern: navigator
---

## Theory

A **Navigator** (web/Flutter) or **Coordinator** (iOS) owns all navigation logic for a feature or flow.

**Invariants:**
- The Screen delegates navigation intent to the Navigator — it never hard-codes a destination
- The StateHolder emits a navigation Action — the Navigator/Coordinator decides the implementation
- Knows route constants or destination types — the Screen does not
- One coordinator/navigator per feature flow — not per screen

**When to create:** When a screen navigates to another screen. Created after the screen that triggers navigation.

---

## Definition

A **Navigator** is a `NavigationImpl` class implementing a navigation interface, injected into the Presenter.

**Invariants:**
- The Presenter holds the navigation interface — it never references `Activity` or `Intent` directly
- The Activity provides `Context` at navigation call time via `view?.getContext()` — never stored in Presenter
- Navigation interfaces live in `base/common` module — not in feature modules
- Each Activity exposes a `companion object { fun newIntent(...) }` factory for typed navigation

**When to create:** When a Presenter navigates to another screen. Navigation interface defined in `base/common` before the Presenter that uses it. See `navigation-impl.md` for full pattern.

## Code Pattern

See `navigation/navigator.md` for the full NavigationImpl pattern.
