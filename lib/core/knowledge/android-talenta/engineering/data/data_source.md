---
platform: android
project: android-talenta
discipline: engineering
topic: data
pattern: data_source
---

## Theory

A **DataSource** is an abstract interface for raw data access — remote (HTTP) or local (DB, cache).

**Invariants:**
- Interface only in the data layer — implementation is injected, never instantiated directly
- Methods return raw data (DTOs or primitives) — never domain entities
- One DataSource per data origin (remote API, local DB, cache) — do not mix sources in one interface
- Throws or returns transport-layer errors — the repository implementation maps these to domain errors

**When to create:** One DataSource interface per data origin per feature. Created after the DTO and mapper, before the repository implementation.

---

## Definition

Android implements the DataSource contract as a **Retrofit interface** (`*Api` suffix, placed in `service/`). The interface is the abstraction; Retrofit generates the implementation at runtime via Dagger injection — no separate `*Impl` class needed.

Rules:
- Return `Single<Response>` for endpoints with response body; `Completable` for DELETE/void endpoints
- Use `@Query` for URL params, `@Path` for path segments, `@Body` for request body
- One interface per feature module

## Code Pattern

```kotlin
// service/TimeOffApi.kt
interface TimeOffApi {
    @GET("v1/time-off/requests")
    fun getTimeOffRequests(
        @Query("page") page: Int,
        @Query("limit") limit: Int
    ): Single<TimeOffRequestListResponse>

    @POST("v1/time-off/requests")
    fun submitTimeOffRequest(
        @Body request: SubmitTimeOffRequest
    ): Single<TimeOffRequestResponse>

    @DELETE("v1/time-off/requests/{id}")
    fun deleteTimeOffRequest(@Path("id") id: String): Completable
}
```
