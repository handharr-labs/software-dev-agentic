---
platform: android
project: android-talenta
discipline: engineering
topic: data
pattern: layer_invariants
---

## Theory

- Imports from domain layer only — never from presentation or UI
- Raw transport errors never propagate upward — repository implementation maps them to domain errors
- DTOs and DB records never cross into the domain layer — mappers are the boundary

---

## Definition

Enforced constraints for all data layer artifacts.

## Code Pattern

- Import from domain layer only — never from Activity, Fragment, ViewModel, or Presenter files
- `ApiException` and `IOException` never propagate upward — `RepositoryImpl` maps them to `DomainException` subtypes via `onErrorResumeNext` before returning to the domain
- `*Response` classes never cross into the domain layer — `mapper.map()` or `mapper.mapList()` is the boundary
- Retrofit interfaces are registered in the Dagger module — the concrete Retrofit implementation is never referenced outside the data layer
- Room DAOs and OkHttp `Interceptor` live only in data layer infrastructure files — never in domain or presentation
