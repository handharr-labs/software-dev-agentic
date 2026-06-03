# domain — flutter

| Pattern | Description |
|---|---|
| `creation_order` | When building a new feature's domain layer, create files in this sequence. |
| `dependency_rule` | Domain is the innermost layer — it imports nothing from outer layers. |
| `domain_enum` | Business-level constants placed in `domain/enums/`. |
| `domain_error` | The unified error type returned from all repository and use case calls. |
| `domain_service` | Pure synchronous functions — no I/O, no async, no side effects. |
| `entity` | Immutable business objects — `@freezed` recommended for `copyWith` and pattern matching. |
| `repository_interface` | Abstract contract that the data layer must implement — domain never knows how data is fetched. |
| `use_case` | Single-responsibility units of business logic — each calls exactly one repository method. |
