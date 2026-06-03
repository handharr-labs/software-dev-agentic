---
platform: android
project: android-talenta
discipline: engineering
topic: domain
pattern: use_case
---

## Theory

A **UseCase** encapsulates a single business operation: one class, one public method, one responsibility.

**Invariants:**
- One business operation per class — never combine unrelated operations
- Depends only on repository interfaces — never on repository implementations or data-layer types
- No framework dependencies — no HTTP clients, no UI types
- Accepts typed input (Params/Request struct) — never raw dictionaries or loose primitives
- Returns domain entities or primitives — never DTOs or view models
- All I/O goes through the repository — use cases never call APIs or databases directly

**Mandatory call flow — no exceptions:**
```
Presentation → UseCase → Repository    ✅
Presentation → Repository              ❌  direct call is a CLEAN violation
```

**When to create:** One use case per business operation (e.g. `GetEmployeeUseCase`, `SubmitLeaveRequestUseCase`, `ApproveLeaveRequestUseCase`). Even thin pass-through use cases are mandatory — they preserve a stable indirection point for future validation, caching, or logging without touching the presentation layer.

**Naming:** `[Verb][Feature]UseCase` — verb names the business operation, not the HTTP method.

**Params pattern by operation:**

| Operation | Params structure |
|-----------|-----------------|
| GET (single) | `id` or typed identifier |
| GET (list) | `{ page, limit, filters... }` |
| POST | `{ payload: { fields... } }` |
| PUT | `{ id, payload: { fields... } }` |
| DELETE | `id` |
| No input | platform `NoParams` / `Void` equivalent |

---

## Definition

Extend `SingleUseCase<Result, Params>` from `domain/usecase/base/`.

Rules:
- Annotate with `@OpenForTesting` to allow mocking in tests
- Use `@Inject constructor` — never instantiate directly
- Inject `SchedulerTransformers` and `Logger` with nullable defaults (test-friendly)
- `Params` is a nested data class inside the use case
- Return type wraps the domain entity — never raw response types
- Name: `[Action][Entity]UseCase` (e.g. `GetTimeOffRequestsUseCase`, `SubmitTimeOffUseCase`)

## Code Pattern

```kotlin
// domain/usecase/GetTimeOffRequestsUseCase.kt
@OpenForTesting
class GetTimeOffRequestsUseCase @Inject constructor(
    private val timeOffRepository: TimeOffRepository,
    schedulerTransformer: SchedulerTransformers? = null,
    logger: Logger? = null
) : SingleUseCase<List<TimeOffRequest>, GetTimeOffRequestsUseCase.Params>(
    schedulerTransformer?.applySingleIoSchedulers(),
    logger
) {

    override fun build(params: Params?): Single<List<TimeOffRequest>> = params!!.run {
        timeOffRepository.getTimeOffRequests(page, limit)
    }

    data class Params(
        val page: Int,
        val limit: Int
    )
}
```
