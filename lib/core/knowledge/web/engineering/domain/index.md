# domain — web

| Pattern | Description |
|---|---|
| `dependency_rule` | Domain is the innermost layer — it imports nothing from outer layers. |
| `domain_error` | Typed domain errors using discriminated unions — repositories map `NetworkError` to `DomainError`. |
| `domain_service` | Pure business decisions — no I/O, no side effects, no async. |
| `entity` | Immutable TypeScript types representing business objects — no networking, persistence, or UI imports. |
| `repository_interface` | TypeScript interfaces defining the data contract — placed in the Domain layer. |
| `use_case` | Each UseCase has a `Params` type bundling all input parameters. |
