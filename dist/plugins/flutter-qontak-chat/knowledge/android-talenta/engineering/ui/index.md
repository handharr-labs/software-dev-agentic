# ui — android-talenta

| Pattern | Description |
|---|---|
| `component` | Custom View subclass or Fragment smaller than a screen — stateless, no use case calls, reuse check required. |
| `creation_order` | View contract → NavigationImpl (if needed) → Hilt module binding. Presenter contract must exist first. |
| `dependency_rule` | UI depends on Presentation only — forbidden: use case interfaces, DTOs, mappers, Retrofit types. |
| `di_wiring` | Presenter registered via `@Provides`/`@Binds` with Activity/Fragment scope — use cases never instantiated inside Presenter. |
| `layer_invariants` | Activity/Fragment never holds business logic; never calls use cases directly; Presenter via Dagger; navigation via interface. |
| `navigator` | `NavigationImpl` implementing navigation interface — Presenter holds interface, Activity provides Context. |
| `planner_search_patterns` | Glob patterns for finding Activity, Fragment, shared component, and NavigationImpl files. |
| `screen` | Activity/Fragment implementing View contract — delegates all logic to Presenter, no business logic. |
