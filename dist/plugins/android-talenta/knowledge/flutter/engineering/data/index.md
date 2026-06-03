# data — flutter

| Pattern | Description |
|---|---|
| `creation_order` | When building a new feature's data layer, create files in this sequence. |
| `data_source` | Separate remote and local data sources via abstract interface + implementation. |
| `dto` | DTO classes for API responses — always have `fromJson`, entities never do. |
| `exception` | Typed exceptions thrown by DataSources, converted to `Failure` in the repository. |
| `http_client` | `ErrorInterceptor` translates Dio errors to `AppException` before reaching the repository. |
| `local_data_source` | Cache-first pattern: try local cache first, fall back to remote, then cache the result. |
| `mapper` | Convert Models to Entities — one mapper per aggregate root, handle nulls with explicit defaults. |
| `payload` | Separate class for write request bodies, keeping read DTOs clean. |
| `repository_impl` | Implements domain repository interface — orchestrates datasource, mapper, and Either result. |
