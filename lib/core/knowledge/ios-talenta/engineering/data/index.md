# data — ios-talenta

| Pattern | Description |
|---|---|
| `data_source` | Abstract the data origin — remote API, local storage, or cache. |
| `dependency_rule` | Data depends on Domain only — never imports from Presentation or UI. |
| `dto` | Response Models (`*Response` structs) — raw API shape, all fields optional, `CodingKeys` for snake_case mapping. |
| `http_client` | Talenta iOS uses Moya for type-safe networking. |
| `mapper` | Mappers belong in the Data Layer — convert Response DTOs to Domain entities. |
| `repository_impl` | Repositories inject mappers and datasources and implement domain protocols. |
