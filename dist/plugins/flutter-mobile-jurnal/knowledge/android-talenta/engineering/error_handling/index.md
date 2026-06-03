# error_handling — android-talenta

| Pattern | Description |
|---|---|
| `error_flow` | DataSource → RepositoryImpl (maps to DomainException) → UseCase → Presenter (ErrorHandler) → View. |
| `error_handler` | Central `ErrorHandler` injected into Presenters — never call `view?.showError(error.message)` directly. |
| `error_interceptor` | OkHttp `ErrorInterceptor` converts non-2xx responses into `ApiException` before reaching Retrofit interface. |
| `error_mapping` | RepositoryImpl maps ApiException (401→Unauthorized, 404→NotFound) and IOException→NetworkError via `onErrorResumeNext`. |
| `error_response_models` | `ErrorResponse`, `ErrorDetail`, `FieldError` data classes with `@SerializedName` — all fields nullable. |
| `error_types` | ApiException (Data), IOException (Data), DomainException sealed class (Domain), BaseErrorModel (Presentation). |
| `layer_invariants` | DataSources throw; RepositoryImpl always maps; UseCases propagate unchanged; Presenters delegate to ErrorHandler; Views never inspect error codes. |
