---
platform: android
project: android-talenta
discipline: engineering
topic: dependency_injection
pattern: di_module
---

## Theory

Each feature owns its own registration unit (component, module, or file) — one file per feature.

---

## Definition

Feature DI module containing all `@Provides` bindings for a feature.

## Code Pattern

```kotlin
// di/TimeOffModule.kt
@Module
class TimeOffModule {

    @Provides
    fun provideTimeOffApi(retrofit: Retrofit): TimeOffApi {
        return retrofit.create(TimeOffApi::class.java)
    }

    @Provides
    fun provideTimeOffRequestMapper(): TimeOffRequestMapper {
        return TimeOffRequestMapper()
    }

    @Provides
    fun provideTimeOffRepository(
        api: TimeOffApi,
        mapper: TimeOffRequestMapper
    ): TimeOffRepository {
        return TimeOffRepositoryImpl(api, mapper)
    }
}
```
