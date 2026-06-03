---
platform: android
project: android-talenta
discipline: engineering
topic: navigation
pattern: navigator
---

## Theory

A **Navigator** (web/Flutter/Android) or **Coordinator** (iOS) is the single owner of navigation logic for a feature or flow.

**Invariants:**
- Defined as an interface/protocol — the Screen or Presenter holds only the interface, never the concrete type
- Implemented in a separate class that knows how to resolve the destination (push a controller, call `context.go`, start an Activity)
- The StateHolder (ViewModel/Bloc/Presenter) emits a navigation intent — the Navigator/Coordinator decides the implementation
- Knows route constants or destination types — the Screen does not
- One Navigator/Coordinator per feature flow — not per screen
- Injected into the StateHolder — never instantiated by the Screen or StateHolder directly

**When to create:** When a screen navigates to another screen. Created after the Screen that triggers navigation.

---

## Definition

Each feature defines a navigation interface and implementation. The presenter holds the interface; the Activity/Fragment provides the `Context`.

Android does not use the Navigation Component. Navigation is handled via custom `NavigationImpl` classes injected into presenters.

Rules:
- Navigation interfaces live in `base/common` module — not in feature modules
- Inject `Navigation` interface into Presenter, not Activity
- Activity provides `Context` via `view?.getContext()` — never store Activity reference in Presenter
- Each Activity exposes a `companion object { fun newIntent(...) }` factory

## Code Pattern

```kotlin
// navigation/TimeOffNavigation.kt (base/common module)
interface TimeOffNavigation {
    fun navigateToTimeOffDetail(context: Context, requestId: String)
    fun navigateToSubmitTimeOff(context: Context)
}

// navigation/TimeOffNavigationImpl.kt
class TimeOffNavigationImpl @Inject constructor() : TimeOffNavigation {
    override fun navigateToTimeOffDetail(context: Context, requestId: String) {
        context.startActivity(TimeOffDetailActivity.newIntent(context, requestId))
    }

    override fun navigateToSubmitTimeOff(context: Context) {
        context.startActivity(SubmitTimeOffActivity.newIntent(context))
    }
}

// Inject navigation into presenter when cross-screen navigation is needed:
class TimeOffPresenter @Inject constructor(
    private val useCase: GetTimeOffRequestsUseCase,
    private val navigation: TimeOffNavigation,
    private val errorHandler: ErrorHandler
) : BasePresenter<TimeOffContract.View>(), TimeOffContract.Presenter {

    override fun onRequestSelected(requestId: String) {
        view?.let { navigation.navigateToTimeOffDetail(it.getContext(), requestId) }
    }
}
```
