---
platform: flutter
discipline: engineering
topic: testing
pattern: test_pyramid
---

## Theory

```
         ┌──────────────────┐
         │   E2E Tests      │  few — critical user journeys only
         └────────┬─────────┘
         ┌────────┴─────────┐
         │ Integration Tests│  moderate — repository + datasource wiring
         └────────┬─────────┘
         ┌────────┴─────────┐
         │   Unit Tests     │  many — use cases, mappers, domain services
         └──────────────────┘
```

**Distribution target:** unit-heavy, integration-light, e2e-minimal. A test suite with more e2e than unit tests is inverted — slow, brittle, and expensive to maintain.

| Layer | Test targets | What to assert |
|---|---|---|
| Domain | Use cases, domain services | Business rules, edge cases, error conditions |
| Data | Mappers, repository implementations | DTO → entity mapping correctness; error mapping from transport to domain |
| Presentation | StateHolder (ViewModel/BLoC) | State transitions for each event; correct use case calls; action emissions |
| UI | Screen rendering | Correct state → UI binding; event dispatch on user interaction |

---

Tests mirror the feature's layer structure. Each layer has a dedicated subdirectory under `test/features/{feature}/`. Mocks live in `test/helpers/mocks/` as generated files; fixtures live in `test/helpers/fixtures/`.

## Code Pattern

```
test/
├── features/
│   └── employee/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── employee_remote_data_source_test.dart
│       │   ├── mappers/
│       │   │   └── employee_mapper_test.dart
│       │   └── repositories/
│       │       └── employee_repository_impl_test.dart
│       ├── domain/
│       │   └── usecases/
│       │       └── get_employee_usecase_test.dart
│       └── presentation/
│           └── blocs/
│               └── employee_bloc_test.dart
├── helpers/
│   ├── mocks/
│   │   └── employee_mocks.dart     ← @GenerateNiceMocks declarations
│   └── fixtures/
│       └── employee_fixture.json
└── test_helper.dart
```

## Definition

| Layer | What to test |
|---|---|
| DataSource | Correct HTTP call, response parsing, throws `AppException` on bad response |
| Mapper | `toEntity()` and `fromJson()` field mapping |
| Repository | `Either` return, exception → `Failure` conversion |
| UseCase | Delegates to repository, passes params correctly |
| BLoC | State transitions per event, correct use case calls |
