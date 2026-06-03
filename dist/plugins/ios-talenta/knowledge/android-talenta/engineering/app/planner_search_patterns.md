---
platform: android
project: android-talenta
discipline: engineering
topic: app
pattern: planner_search_patterns
---

## Theory

When exploring the app layer, use these glob patterns to find relevant files.

---

## Definition

Consumed by `developer-app-planner`. `{Feature}` = PascalCase, `{feature}` = snake_case per Android convention.

## Code Pattern

| Scope key | Glob / Path | Grep hint |
|---|---|---|
| `di` | `*Feature{Feature}Module.kt`, `*{Feature}ActivityBindingModule.kt`, `*MainComponent.kt` under `app/di/` | `{Feature}ActivityBindingModule` in `app/di/MainComponent.kt` |
| `route` | `*{Feature}Navigation.kt` under `base/navigation/`, `*{Feature}NavigationImpl.kt` under `app/navigator/`, `*NavigationModule.kt` under `app/di/` | `{Feature}Navigation` in `app/di/NavigationModule.kt` |
| `module` | `settings.gradle`, `app/build.gradle`, `*MainComponent.kt` under `app/di/` | `feature_{feature}` in `settings.gradle` |
| `analytics` | `*{Feature}AnalyticsConstants.kt` under `feature_{feature}/src/main/java/` | — |
| `feature_flag` | `domain/featureflag/Feature.kt`, `*FlagsmithFeatureFlag.kt` | `ENABLE_{FEATURE}` enum entry |
| `hybrid_embedding` | `bricks-talenta/*/module/*`, `app/*/brickhelper/*` | `## Hybrid Embedding` section |
