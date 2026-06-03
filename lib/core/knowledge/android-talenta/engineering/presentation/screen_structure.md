---
platform: android
project: android-talenta
discipline: engineering
topic: presentation
pattern: screen_structure
---

## Theory

A **Screen** is a full-page view bound to a single StateHolder. It observes state and sends events — it contains no business logic.

**Invariants:**
- Bound to exactly one StateHolder — instantiated via DI, never with direct `new` / `init`
- Observes every State field declared in the StateHolder contract — no State field goes unhandled
- Sends events to the StateHolder for every user interaction — never mutates state directly
- Contains no business logic — conditionals exist only to decide what to render, not what to compute
- No use case calls — all data flows through the StateHolder

---

## Definition

Extends `BaseMvpVbActivity<Presenter, View, Binding>` — three type params in order: Presenter contract, View contract, ViewBinding. ViewBinding via `bindingInflater`, presenter injected via `@Inject`.

Rules:
- Extends `BaseMvpVbActivity<Presenter, View, Binding>` — type param order is `<Presenter, View, Binding>`; handles `attachView`/`detachView` lifecycle automatically
- `@Inject override lateinit var presenter` — Dagger field injection for presenter
- `bindingInflater` property provides the ViewBinding — no `setContentView` needed
- Override `onViewCreated` (not `onCreate`) for setup logic
- Use `companion object { fun newIntent(...) }` for activity launch — not direct `startActivity`
- `BaseMvpVbFragment` for Fragment-based screens — same pattern

## Code Pattern

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
