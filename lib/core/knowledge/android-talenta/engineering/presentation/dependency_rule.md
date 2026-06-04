---
platform: android
project: android-talenta
discipline: engineering
topic: presentation
pattern: dependency_rule
---

## Theory

Presentation depends on Domain only. It never imports from the Data layer.

```
Domain  ←  Presentation
```

Allowed imports: domain use case interfaces, domain entities, language primitives.
Forbidden: any DataSource, RepositoryImpl, DTO, mapper, HTTP client, or database type.

---

## Definition

Presentation depends on Domain only — no Data layer imports. Presenter and Activity/Fragment may only import domain use case interfaces, domain entities, and Android/Kotlin primitives.

Forbidden: any `RepositoryImpl`, `DataSource`, `DTO`, mapper, `Retrofit` interface, or Room type inside the Presentation layer.

## Code Pattern

```kotlin
// ✅ Allowed in presentation layer
import domain.usecase.GetTimeOffRequestsUseCase
import domain.entity.TimeOffRequest
import domain.exception.DomainException

// ❌ Never in presentation layer
// import data.repoimpl.TimeOffRepositoryImpl
// import data.response.TimeOffRequestResponse
// import service.TimeOffApi
```
