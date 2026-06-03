---
platform: android
project: android-talenta
discipline: engineering
topic: testing
pattern: mock_vs_real
---

## Theory

| Use a mock/stub when… | Use a real implementation when… |
|---|---|
| The dependency has I/O (network, DB, file) | The dependency is pure (mappers, domain services) |
| The test must control exact return values | The test verifies the full integration path |
| Speed matters — unit test suite | Correctness of wiring matters — integration test |

**Never mock domain services or mappers in unit tests** — they are pure functions; test them with real inputs and outputs.

---

## Definition

| Use a mock/stub when… | Use a real implementation when… |
|---|---|
| The dependency has I/O (Retrofit API, DB) | The dependency is pure (Mapper, domain service) |
| The test must control exact return values | The test verifies full integration wiring |
| Unit test speed matters | Correctness of data transformation matters |

Use `@Mock` with `MockitoJUnitRunner` for all collaborators (Api, Mapper, Repository, SchedulerTransformers). Use `.blockingGet()` for synchronous assertion on RxJava Singles.

## Code Pattern

```kotlin
// ✅ Mock the API (has I/O)
@Mock lateinit var mockApi: TimeOffApi

// ✅ Use real mapper (pure function)
private val mapper = TimeOffRequestMapper()

// ❌ Never mock a Mapper
@Mock lateinit var mockMapper: TimeOffRequestMapper  // wrong — use real instance
```
