---
platform: android
project: android-talenta
discipline: engineering
topic: ui
pattern: creation_order
---

## Theory

```
Screen → Navigator/Coordinator (if navigation needed) → DI wiring
```

The StateHolder and its contract must exist before any UI layer file is written.

---

## Definition

```
Activity/Fragment (View contract) → NavigationImpl (if navigation needed) → Hilt module binding
```

The Presenter contract and View contract must exist before any UI layer file is written.

## Code Pattern

```
1. Define MVP Contract (View + Presenter interfaces)
2. Implement Presenter (StateHolder)
3. Write Activity/Fragment implementing View contract
4. Create NavigationImpl if cross-screen navigation needed
5. Wire DI module + ActivityBindingModule
```
