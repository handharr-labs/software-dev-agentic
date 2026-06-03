# domain — ios-talenta

| Pattern | Description |
|---|---|
| `creation_order` | When building a new feature's domain layer, create files in this sequence. |
| `dependency_rule` | Domain is the innermost layer — it imports nothing from outer layers. |
| `domain_enum` | Business-level Swift enums with explicit raw values and unknown fallback cases. |
| `domain_error` | `BaseErrorModel` is the canonical error type for all UseCase and Repository completions. |
| `domain_service` | Pure business decisions — no I/O, no side effects, no async; callable from both UseCases and ViewModels. |
| `entity` | Immutable Swift structs representing business objects — no networking, persistence, or UI imports. |
| `repository_interface` | Swift protocols defining the data contract — one per aggregate root, placed in the Domain layer. |
| `use_case` | 3-parameter base class with separate query params, path params, and a completion callback. |
