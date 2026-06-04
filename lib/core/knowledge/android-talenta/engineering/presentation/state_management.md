---
platform: android
project: android-talenta
discipline: engineering
topic: presentation
pattern: state_management
---

## Theory

**State** is an immutable snapshot of what the UI should render at a given moment.

**Invariants:**
- Immutable — produced by the StateHolder, never mutated by the UI
- Covers all render cases: loading, data (success), error
- No view logic — no CSS classes, no display strings, no format calls; formatting happens in the UI layer
- Typed — each field has a declared type; avoid untyped `any` or `Object`

**Common shape:**

```
loading  →  no data yet; UI shows a spinner or skeleton
data     →  domain entities or view-ready primitives ready to render
error    →  domain error type; UI decides how to display it
```

---

## Definition

Android MVP has no explicit state container. The **View interface** is the state surface — the Presenter drives it imperatively via `view?.show*` / `view?.hide*` calls. Loading, success, and error states are expressed as discrete View methods rather than a sealed state class.

For screens that need richer state (e.g. multi-section loading), define a `ViewState` data class and expose it via a single `renderState(state: ViewState)` method on the View interface.

## Code Pattern

```kotlin
interface TimeOffRequestContract {
    interface View : BaseMvpView {
        fun showLoading()        // loading state
        fun hideLoading()        // loading cleared
        fun showTimeOffRequests(requests: List<TimeOffRequest>)  // success state
        fun showError(error: Throwable)   // error state
        fun showEmptyState()              // empty state
    }
}
```
