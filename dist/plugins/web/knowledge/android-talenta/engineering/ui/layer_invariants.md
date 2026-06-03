---
platform: android
project: android-talenta
discipline: engineering
topic: ui
pattern: layer_invariants
---

## Theory

- UI never mutates state directly — observes only
- UI never calls use cases directly — all interactions go through the StateHolder
- StateHolder instantiated via DI — never `new ViewModel()` / `MyViewModel()` inline
- Navigation delegated to navigator/coordinator — UI emits intent, not destination
- No data layer knowledge — no DTOs, no datasources, no HTTP types visible in UI files

---

## Definition

Enforced constraints for all UI layer artifacts.

## Code Pattern

- Activity/Fragment never holds business logic — delegates everything to Presenter
- Activity/Fragment never calls use cases directly — all interactions go through the Presenter
- Presenter instantiated via Hilt — never `MyPresenter()` inline in Activity
- Navigation delegated to NavigationImpl via interface — Presenter calls interface, not `startActivity` directly
- No data layer knowledge — no DTOs, no Retrofit types, no datasource references visible in UI files
