---
platform: android
project: android-talenta
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

---

## Definition

| Layer | Type | Tool | Target ratio |
|---|---|---|---|
| Domain (use cases, services) | Unit | JUnit4 + Mockito | Heavy — fast, isolated |
| Data (mappers, repository impl) | Unit | JUnit4 + Mockito | Heavy |
| Presentation (presenters) | Unit | JUnit4 + Mockito + RxJava test schedulers | Medium |
| UI (activity/fragment) | Instrumented | Espresso | Light — slow, avoid |

Run `./gradlew test` for unit tests; `./gradlew connectedAndroidTest` for instrumented.

## Code Pattern

```bash
# Unit tests
./gradlew test

# Instrumented tests
./gradlew connectedAndroidTest
```
