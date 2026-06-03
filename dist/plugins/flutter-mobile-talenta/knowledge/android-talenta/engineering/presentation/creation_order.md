---
platform: android
project: android-talenta
discipline: engineering
topic: presentation
pattern: creation_order
---

## Theory

```
Use Cases (from developer-backend-worker) → StateHolder → StateHolder contract → Screen (developer-ui-worker)
```

Never write the screen before the StateHolder contract exists.

---

## Definition

```
Use Cases → Presenter (StateHolder) → MVP Contract → StateHolder contract → Activity/Fragment (developer-ui-worker)
```

Never write the Activity/Fragment before the StateHolder contract exists.

## Code Pattern

Before `developer-ui-worker` writes the Activity/Fragment, `developer-feature-worker` produces `.claude/runs/<feature>/stateholder-contract.md` containing:
- Presenter class name and file path
- Contract.View interface methods (name, parameter types)
- Contract.Presenter interface methods (name, parameter types)
- Navigation interface name and methods (if navigation is involved)
- Dagger injection keys or module bindings
