---
platform: android
project: android-talenta
discipline: engineering
topic: ui
pattern: component
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

## Definition

A **Component** is a custom `View` subclass or self-contained `Fragment` smaller than a full screen.

**Invariants:**
- Stateless by default — configured via a setter or data binding; emits events via listener interfaces or callbacks
- If stateful, driven by a scoped Presenter — never manages business state inline
- No use case calls — all data passed in from the parent Activity/Fragment or a scoped Presenter
- Reuse check required before creating — search `presentation/common/views/` and shared modules first

**When to create:** When a UI element appears in ≥2 screens, or when an Activity/Fragment section is complex enough to isolate for readability.

## Code Pattern

```kotlin
// Shared component search paths:
// **/presentation/common/views/**/*.kt
// **/presentation/common/**/*View.kt
```
