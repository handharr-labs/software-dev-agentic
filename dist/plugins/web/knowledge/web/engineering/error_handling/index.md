# error_handling — web

| Pattern | Description |
|---|---|
| `error_flow` | `ErrorMapperImpl` converts `NetworkError` to `DomainError` — repositories inject `ErrorMapper` to propagate upward. |
