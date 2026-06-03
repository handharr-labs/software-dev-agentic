# error_handling — ios-talenta

| Pattern | Description |
|---|---|
| `error_flow` | All UseCase/Repository completions use `Result<Model, BaseErrorModel>` — repositories map `NetworkError` upward. |
