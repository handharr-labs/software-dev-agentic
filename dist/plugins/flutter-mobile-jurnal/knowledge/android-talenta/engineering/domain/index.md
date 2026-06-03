# domain — android-talenta

| Pattern | Description |
|---|---|
| `creation_order` | When building a new feature's domain layer, create files in this sequence. |
| `dependency_rule` | Domain is the innermost layer — it imports nothing from outer layers. |
| `domain_error` | Sealed DomainException class mapped from transport errors; subtypes: Unauthorized, NotFound, NetworkError, Unknown. |
| `domain_service` | Pure Kotlin classes encapsulating business logic that spans multiple entities — no Android imports, no RxJava. |
| `entity` | Pure Kotlin data classes representing business concepts — no JSON annotations, no Android framework imports. |
| `repository_interface` | Kotlin interface in `domain/repository/` — returns RxJava3 Singles, params are domain types only. |
| `use_case` | Extends `SingleUseCase<Result, Params>` — one business operation per class, `@OpenForTesting`, `@Inject constructor`. |
