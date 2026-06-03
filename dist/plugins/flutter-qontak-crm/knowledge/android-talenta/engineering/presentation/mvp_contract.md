---
platform: android
project: android-talenta
discipline: engineering
topic: presentation
pattern: mvp_contract
---

## Theory

**Events** (also called Input or Intent) represent user intentions flowing into the StateHolder.
**Actions** (also called Output or SideEffects) represent one-time side effects the StateHolder emits after processing an event.

---

## Definition

Interface defining the View and Presenter contracts for a feature screen.

Rules:
- One Contract interface per screen
- `View` extends `BaseMvpView`; `Presenter` extends `BaseMvpPresenter<View>`
- View methods are UI commands: show/hide/navigate — no business logic
- Presenter methods correspond to user interactions and lifecycle events
- Name: `[Feature]Contract`

## Code Pattern

```kotlin
// presentation/[feature]/TimeOffRequestContract.kt
interface TimeOffRequestContract {

    interface View : BaseMvpView {
        fun showTimeOffRequests(requests: List<TimeOffRequest>)
        fun showError(error: Throwable)
        fun showEmptyState()
    }

    interface Presenter : BaseMvpPresenter<View> {
        fun loadTimeOffRequests(id: String)
        fun refreshData()
    }
}
```
