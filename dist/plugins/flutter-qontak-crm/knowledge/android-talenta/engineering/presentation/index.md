# presentation — android-talenta

| Pattern | Description |
|---|---|
| `component` | RecyclerView ViewHolder with UIModel data class — no Presenter awareness, use ViewBinding. |
| `creation_order` | Use Cases → Presenter → MVP Contract → StateHolder contract → Activity/Fragment. |
| `dependency_rule` | Presentation depends on Domain only — forbidden: RepositoryImpl, DataSource, DTO, mapper, Retrofit, Room. |
| `logging` | Log.d("DebugTest", "[MethodName] event — value") format — never log tokens, never commit DebugTest logs. |
| `mvp_contract` | Interface defining View and Presenter contracts per screen — View extends BaseMvpView, Presenter extends BaseMvpPresenter. |
| `presenter` | Extends `BasePresenter<View>` — `@Inject constructor`, `doOnSubscribe`/`doFinally` for loading, `addToDisposables()` for cleanup. |
| `screen_structure` | Extends `BaseMvpVbActivity<Presenter, View, Binding>` — `@Inject` presenter, `bindingInflater`, `onViewCreated`, `companion object { fun newIntent(...) }`. |
| `state_holder` | Presenter is the StateHolder — drives View interface imperatively via `view?.show*`/`view?.hide*`, scoped to Activity/Fragment lifecycle. |
| `state_management` | View interface is the state surface — discrete `show*`/`hide*` methods represent loading, data, error, and empty states. |
