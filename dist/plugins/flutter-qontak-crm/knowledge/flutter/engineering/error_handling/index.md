# error_handling — flutter

| Pattern | Description |
|---|---|
| `app_exception` | Typed exceptions thrown inside datasources, converted to `Failure` in the repository. |
| `error_ui` | Inline `BlocBuilder` for blocking errors and `BlocListener` toast/snackbar for non-blocking errors. |
| `failure_types` | Error flow: HTTP → `AppException` → `Failure` → `ViewDataState.error`. |
| `validation_errors` | API validation errors (HTTP 422) handled as `ValidationFailure` with structured field keys. |
