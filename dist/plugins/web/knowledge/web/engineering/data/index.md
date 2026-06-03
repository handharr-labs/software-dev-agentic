# data — web

| Pattern | Description |
|---|---|
| `data_source` | Abstract the data origin — remote API, local storage, or cache. |
| `dependency_rule` | Data depends on Domain only — never imports from Presentation or UI. |
| `dto` | Network response models — separate from domain entities. |
| `http_client` | Uses Axios with axios-retry — `HTTPClient` interface decouples the Data layer from Axios internals. |
| `mapper` | Each DTO-Entity pair gets its own dedicated interface-based mapper, injectable for testability. |
| `repository_impl` | Repositories receive mappers through injection to isolate repository logic from mapping logic. |
