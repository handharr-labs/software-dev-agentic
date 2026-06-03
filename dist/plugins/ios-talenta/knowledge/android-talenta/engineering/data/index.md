# data — android-talenta

| Pattern | Description |
|---|---|
| `creation_order` | When building a new feature's data layer, create files in this sequence. |
| `data_source` | Retrofit interface (`*Api` suffix) in `service/` — Retrofit generates the implementation; no separate `*Impl` class. |
| `dependency_rule` | Data depends on Domain only — forbidden: Activity, Fragment, ViewModel, Presenter imports. |
| `dto` | Response models (`*Response` suffix) in `data/response/` — all fields nullable, `@SerializedName` required, no business logic. |
| `layer_invariants` | Enforced constraints: no presentation imports, ApiException/IOException never propagate, Response classes never cross into domain. |
| `mapper` | Extends `BaseMapper<Response, Entity>` — every entity field mapped, null-safety extensions required, no `?: ""` or `?: 0`. |
| `repository_impl` | Implements domain repository interface via `@Inject constructor` — maps ApiException to DomainException via `onErrorResumeNext`. |
