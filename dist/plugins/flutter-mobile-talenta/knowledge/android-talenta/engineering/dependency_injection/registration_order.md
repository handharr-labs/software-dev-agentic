---
platform: android
project: android-talenta
discipline: engineering
topic: dependency_injection
pattern: registration_order
---

## Theory

Dependencies must be registered before they are resolved. The correct registration order mirrors the dependency graph:

```
Infrastructure (HTTP client, DB driver)
  → DataSources
  → Mappers
  → Repository Implementations
  → Use Cases
  → StateHolders
```

Register leaf nodes (no dependencies) first. Register consumers after their dependencies.

---

## Definition

Dagger resolves the dependency graph at compile time, but module declarations must follow leaf-first order to keep the graph readable.

## Code Pattern

```kotlin
// TimeOffModule.kt — leaf-first registration
@Module
class TimeOffModule {
    // 1. Infrastructure — no app dependencies
    @Provides fun provideTimeOffApi(retrofit: Retrofit): TimeOffApi = retrofit.create(TimeOffApi::class.java)

    // 2. Mappers — no dependencies
    @Provides fun provideTimeOffRequestMapper(): TimeOffRequestMapper = TimeOffRequestMapper()

    // 3. Repository — depends on Api + Mapper
    @Provides fun provideTimeOffRepository(api: TimeOffApi, mapper: TimeOffRequestMapper): TimeOffRepository =
        TimeOffRepositoryImpl(api, mapper)

    // 4. Use Case — depends on Repository (provided via @Inject constructor in UseCase class)
}
```
