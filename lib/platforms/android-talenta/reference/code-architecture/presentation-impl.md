# Android — Presentation Layer (MVP)

> Concepts and invariants: `reference/code-architecture/presentation-theory.md`. This file covers Android MVP patterns with Kotlin.

## Dependency Rule <!-- 8 -->

Presentation depends on Domain only — no Data layer imports. Presenter and Activity/Fragment may only import domain use case interfaces, domain entities, and Android/Kotlin primitives.

Forbidden: any `RepositoryImpl`, `DataSource`, `DTO`, mapper, `Retrofit` interface, or Room type inside the Presentation layer.

---

## StateHolder <!-- 12 -->

In Android (MVP), the StateHolder is the **Presenter** extending `BasePresenter<View>`. See `## Presenter` below for full implementation patterns.

Invariants:
- Receives use cases via `@Inject constructor` — Dagger provides all dependencies; never instantiate use cases directly
- Drives the View interface imperatively via `view?.show*` / `view?.hide*` calls — Activity/Fragment never mutates presenter state
- Calls navigation via an injected `Navigation` interface — never starts Activities directly from the Presenter
- One Presenter per screen — scoped to the Activity/Fragment lifecycle via `attachView`/`detachView`

---

## State <!-- 11 -->

In Android (MVP), **State** is expressed via the View interface — discrete `show*`/`hide*` methods on the Contract.View interface represent loading, data, error, and empty states. See `## State Management` and `## MVP Contract` below.

Invariants:
- Immutable from the Activity's perspective — Presenter drives view state; Activity only renders what it is told
- Covers all render cases: `showLoading`/`hideLoading`, `show*Data`, `showError`, `showEmptyState`
- No business logic in View methods — Activity/Fragment implements rendering only

---

## Events / Input <!-- 11 -->

In Android (MVP), Events/Input are **Presenter interface methods** defined in `[Feature]Contract.Presenter` and called by Activity/Fragment in response to user actions. See `## MVP Contract` below.

Invariants:
- Named after user actions — `loadTimeOffRequests`, `refreshData`, not `onButtonClick`
- Called by Activity/Fragment lifecycle methods or UI listeners — Presenter handles all business logic
- Carry only domain-level data — no raw `View`, `Context`, or `MotionEvent` objects in presenter methods

---

## Actions / Output <!-- 11 -->

In Android (MVP), Actions/Output are View interface methods that the Presenter calls for navigation and one-time effects. Navigation is injected as a `[Feature]Navigation` interface. See `## Navigation` below.

Invariants:
- One-shot — Presenter calls `view?.navigateTo*` or `navigation.navigateTo*` once per event outcome
- Named after the outcome — `navigateToTimeOffDetail`, `showError`, `showEmptyState`
- Navigation belongs to an injected `Navigation` interface — Presenter never calls `startActivity` directly

---

## StateHolder Contract <!-- 11 -->

Before `developer-ui-worker` writes the Activity/Fragment, `developer-feature-worker` produces `.claude/runs/<feature>/stateholder-contract.md` containing:
- Presenter class name and file path
- Contract.View interface methods (name, parameter types)
- Contract.Presenter interface methods (name, parameter types)
- Navigation interface name and methods (if navigation is involved)
- Dagger injection keys or module bindings

---

## Creation Order <!-- 10 -->

```
Use Cases → Presenter (StateHolder) → MVP Contract → StateHolder contract → Activity/Fragment (developer-ui-worker)
```

Never write the Activity/Fragment before the StateHolder contract exists.

---

## Layer Invariants <!-- 10 -->

- Presenter never imports from the data layer — no DTOs, no `RepositoryImpl`, no `DataSource`
- Use cases injected via `@Inject constructor` — never `GetTimeOffRequestsUseCase()` inside a Presenter
- State is driven by the Presenter — Activity implements View methods, never holds business state
- Navigation is one-shot — called via `Navigation` interface, never stored in presenter fields
- `view?` guard on all view calls — view may be null after `detachView()`

---

## State Management <!-- 18 -->

Android MVP has no explicit state container. The **View interface** is the state surface — the Presenter drives it imperatively via `view?.show*` / `view?.hide*` calls. Loading, success, and error states are expressed as discrete View methods rather than a sealed state class.

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

For screens that need richer state (e.g. multi-section loading), define a `ViewState` data class and expose it via a single `renderState(state: ViewState)` method on the View interface.

## Shared Component Paths <!-- 4 -->

> Android shared components are not yet catalogued. Add common widget paths here when established (e.g. `presentation/common/`, `base/ui/`).

## MVP Contract <!-- 28 -->

Interface defining the View and Presenter contracts for a feature screen.

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

Rules:
- One Contract interface per screen
- `View` extends `BaseMvpView`; `Presenter` extends `BaseMvpPresenter<View>`
- View methods are UI commands: show/hide/navigate — no business logic
- Presenter methods correspond to user interactions and lifecycle events
- Name: `[Feature]Contract`

## Presenter <!-- 39 -->

Extends `BasePresenter<View>` — injects use case and `ErrorHandler` via Dagger.
Uses `doOnSubscribe`/`doFinally` for loading state, `addToDisposables()` for cleanup.

```kotlin
// presentation/[feature]/TimeOffRequestPresenter.kt
class TimeOffRequestPresenter @Inject constructor(
    private val getTimeOffRequestsUseCase: GetTimeOffRequestsUseCase,
    private val schedulerTransformers: SchedulerTransformers?,
    private val errorHandler: ErrorHandler
) : BasePresenter<TimeOffRequestContract.View>(), TimeOffRequestContract.Presenter {

    override fun loadTimeOffRequests(id: String) {
        val params = GetTimeOffRequestsUseCase.Params(id)
        getTimeOffRequestsUseCase.execute(params)
            .doOnSubscribe { view?.showLoading() }
            .doFinally { view?.hideLoading() }
            .subscribe(
                { requests -> view?.showTimeOffRequests(requests) },
                { error -> errorHandler.proceed(error) }
            )
            .addToDisposables()
    }

    override fun refreshData() {
        // re-invoke loadTimeOffRequests
    }
}
```

Rules:
- `@Inject constructor` — Dagger provides use cases, SchedulerTransformers, ErrorHandler
- `doOnSubscribe { view?.showLoading() }` / `doFinally { view?.hideLoading() }` — loading state always managed this way
- `errorHandler.proceed(error)` — delegates error display to the ErrorHandler; never call `view?.showError(error.message.orEmpty())` directly
- `addToDisposables()` — disposes on `detachView()`; never call `dispose()` manually
- `view?.` guard on all view calls — view may be null after `detachView()`
- One presenter per screen

## Activity / Fragment <!-- 56 -->

Extends `BaseMvpVbActivity<Presenter, View, Binding>` — three type params in order: Presenter contract, View contract, ViewBinding. ViewBinding via `bindingInflater`, presenter injected via `@Inject`.

```kotlin
// presentation/[feature]/TimeOffRequestActivity.kt
class TimeOffRequestActivity :
    BaseMvpVbActivity<TimeOffRequestPresenter, TimeOffRequestContract.View, ActivityTimeOffRequestBinding>(),
    TimeOffRequestContract.View {

    @Inject
    override lateinit var presenter: TimeOffRequestPresenter

    override val bindingInflater: (LayoutInflater) -> ActivityTimeOffRequestBinding
        get() = ActivityTimeOffRequestBinding::inflate

    override fun onViewCreated(savedInstanceState: Bundle?) {
        val featureId = intent.getStringExtra(EXTRA_FEATURE_ID)
        presenter.loadTimeOffRequests(featureId.orEmpty())

        binding.swipeRefresh.setOnRefreshListener {
            presenter.refreshData()
        }
    }

    override fun showTimeOffRequests(requests: List<TimeOffRequest>) {
        adapter.submitList(requests)
    }

    override fun showError(error: Throwable) {
        showToast(error.message.orEmpty())
    }

    override fun showEmptyState() {
        binding.emptyStateView.isVisible = true
    }

    companion object {
        private const val EXTRA_FEATURE_ID = "extra_feature_id"

        fun newIntent(context: Context, featureId: String) =
            Intent(context, TimeOffRequestActivity::class.java).apply {
                putExtra(EXTRA_FEATURE_ID, featureId)
            }
    }
}
```

Rules:
- Extends `BaseMvpVbActivity<Presenter, View, Binding>` — type param order is `<Presenter, View, Binding>`; handles `attachView`/`detachView` lifecycle automatically
- `@Inject override lateinit var presenter` — Dagger field injection for presenter
- `bindingInflater` property provides the ViewBinding — no `setContentView` needed
- Override `onViewCreated` (not `onCreate`) for setup logic
- Use `companion object { fun newIntent(...) }` for activity launch — not direct `startActivity`
- `BaseMvpVbFragment` for Fragment-based screens — same pattern

## Navigation <!-- 36 -->

Custom `NavigationImpl` classes — not Android Navigation Component. Each feature defines an interface and implements it.

```kotlin
// navigation/TimeOffNavigation.kt (in base/common module)
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
```

Inject navigation into presenter when cross-screen navigation is needed:
```kotlin
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
