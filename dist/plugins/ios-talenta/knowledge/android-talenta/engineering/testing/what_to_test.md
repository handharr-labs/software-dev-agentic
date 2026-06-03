---
platform: android
project: android-talenta
discipline: engineering
topic: testing
pattern: what_to_test
---

## Theory

| Layer | Test targets | What to assert |
|---|---|---|
| Domain | Use cases, domain services | Business rules, edge cases, error conditions |
| Data | Mappers, repository implementations | DTO → entity mapping correctness; error mapping from transport to domain |
| Presentation | StateHolder (ViewModel/BLoC) | State transitions for each event; correct use case calls; action emissions |
| UI | Screen rendering | Correct state → UI binding; event dispatch on user interaction |

---

## Definition

| Layer | What to test | What NOT to test |
|---|---|---|
| Domain (UseCases, Services) | Business rules, edge cases, error conditions | Implementation details of other layers |
| Data (Mappers, RepositoryImpl) | Response → entity field mapping; ApiException → DomainException propagation | Real HTTP responses, network stack |
| Presentation (Presenter) | View method call order; use case invocations; detached-view safety | Activity/Fragment lifecycle internals |
| UI (Espresso) | Critical happy-path journeys only | Business logic, mapping logic |

## Code Pattern

```kotlin
// ✅ Test what matters per layer:

// Domain: business rule
@Test
fun test_givenValidParams_whenExecute_thenRepositoryShouldGetRequests() { ... }

// Data: mapping correctness
@Test
fun test_givenValidResponse_whenMap_thenEntityIsCorrect() { ... }

// Presentation: view method call order
@Test
fun test_givenViewAttached_whenLoadData_thenShowLoadingThenData() { ... }
```
