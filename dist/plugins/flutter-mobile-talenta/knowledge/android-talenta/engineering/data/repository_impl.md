---
platform: android
project: android-talenta
discipline: engineering
topic: data
pattern: repository_impl
---

## Theory

A **Repository Implementation** implements the domain repository interface using a DataSource and Mapper.

**Invariants:**
- Implements a domain repository interface — it is the bridge between Data and Domain
- Calls the DataSource for raw data, calls the Mapper to convert to domain entities
- Wraps all DataSource calls with error handling — maps transport errors to domain errors before returning
- Never lets raw HTTP errors, DB exceptions, or transport-layer types propagate to the domain
- Never calls another repository implementation directly

**When to create:** Last in the creation order — after DataSource interface and implementation exist.

---

## Definition

Implement domain repository interface — inject API and mapper via Dagger.

Rules:
- `@Inject constructor` — Dagger provides all dependencies
- Use `mapper.mapList(response.data)` for list responses
- Map `ApiException` to domain exceptions via `onErrorResumeNext`
- Never expose response types outside the data layer

## Code Pattern

```kotlin
// data/repoimpl/TimeOffRepositoryImpl.kt
class TimeOffRepositoryImpl @Inject constructor(
    private val api: TimeOffApi,
    private val mapper: TimeOffRequestMapper
) : TimeOffRepository {

    override fun getTimeOffRequests(page: Int, limit: Int): Single<List<TimeOffRequest>> {
        return api.getTimeOffRequests(page, limit)
            .map { response -> mapper.mapList(response.data) }
            .onErrorResumeNext { throwable ->
                when (throwable) {
                    is ApiException -> when (throwable.code) {
                        401 -> Single.error(UnauthorizedException())
                        404 -> Single.error(NotFoundException())
                        else -> Single.error(throwable)
                    }
                    is IOException -> Single.error(NetworkException())
                    else -> Single.error(throwable)
                }
            }
    }

    override fun deleteTimeOffRequest(id: String): Completable {
        return api.deleteTimeOffRequest(id)
    }
}
```
