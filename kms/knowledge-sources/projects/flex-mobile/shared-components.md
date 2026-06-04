# Shared Components — flex-mobile (Flutter)

Scanned: 2026-06-04

## Architecture

flex-mobile uses three internal packages as shared foundations:

1. **flex_core** (`modules/flex_core`) — shipped to all features in the main app
2. **cashout** (`modules/cashout`) — EWA cashout module
3. **saving** (`modules/saving`) — Mekari Saving product module

External shared design system: **mekari_pixel** (Mekari's internal component library, git dependency from Bitbucket).

---

## flex_core Shared Components

### Networking

| Class                           | Purpose                                              |
|---------------------------------|------------------------------------------------------|
| `FlexNetworkClient`             | Dio wrapper; base HTTP client for all API calls      |
| `CreditNetworkClient`           | Configured client for credit API base URL            |
| `BenefitNetworkClient`          | Configured client for benefit CMS base URL           |
| `LendingNetworkClient`          | Configured client for lending API base URL           |
| `FlexNetworkAuthInterceptor`    | Attaches auth tokens to requests                     |
| `FirebasePerformanceInterceptor`| Logs request performance to Firebase                 |
| `FlexMkrLogInterceptor`         | mekari_log request logging                           |
| `NetworkCacheInterceptor`       | In-memory + disk HTTP response caching               |

### Storage / Database

| Class                | Purpose                                              |
|----------------------|------------------------------------------------------|
| `HiveSessionHelper`  | Local auth session (flutter_secure_storage + Hive)   |
| `HiveProfileHelper`  | Cached user profile data                             |
| `HiveSettingsHelper` | Feature settings flags (e.g., first-time referral)   |
| `HiveProductHelper`  | Cached PPOB product catalog, recent transactions     |
| `HiveApptourHelper`  | Coachmark/app tour state                             |
| `HiveFeedbackHelper` | NPS/feedback state                                   |
| `HiveNetworkHelper`  | Network response cache storage                       |
| `ObjectBoxHelper`    | ObjectBox DB for high-performance local storage      |

### Feature Flags / Remote Config

| Class                        | Purpose                                         |
|------------------------------|-------------------------------------------------|
| `FeatureFlagHelper`          | Wraps Firebase Remote Config feature gates      |
| `FirebaseConfigHelper`       | Firebase Remote Config initialization           |
| `FirebaseRemoteConfigHelper` | Remote config value reader                      |
| `HiveRemoteConfigHelper`     | Fallback local remote config (Hive-backed)      |

### Analytics / Tracking

| Class              | Purpose                                              |
|--------------------|------------------------------------------------------|
| `TrackingHelper`   | Abstract tracking interface                          |
| `MoEngageHelper`   | MoEngage event tracking implementation               |
| `FirebaseHelper`   | Firebase Analytics integration                       |
| `FlexRouteObserver`| Navigator observer for screen tracking               |

### Helpers

| Class                     | Purpose                                              |
|---------------------------|------------------------------------------------------|
| `CurrencyInputFormatter`  | IDR currency text field formatter                    |
| `TextFormatter`           | Generic text input formatting                        |
| `ImageProcessingHelper`   | Camera/image utilities for KYC                       |
| `DownloadHelper`          | File download utilities                              |
| `PermissionsHelper`       | Runtime permission handling                          |
| `PixelHelper`             | mekari_pixel design system helpers                   |
| `PendingIntentManager`    | Push notification pending intent routing             |
| `LocalNotificationHelper` | flutter_local_notifications wrapper                  |
| `BrickHelper`             | brick_way module integration helper                  |

### DI (get_it)

| File                   | Registers                                          |
|------------------------|----------------------------------------------------|
| `service_locator.dart` | Top-level DI wiring (network clients, utils, MoEngage) |
| `data_locator.dart`    | All repositories                                   |
| `domain_locator.dart`  | All use cases                                      |
| `database_locator.dart`| Hive/ObjectBox helpers                             |
| `bloc_factory.dart`    | BLoC factories                                     |

### Extensions

`ColorExtension`, `DateTimeExtension`, `DioExtension`, `KeyExtension`, `ListExtension`, `MapExtension`, `NumberExtension`, `StringExtension`, `UriExtension`, `WidgetExtension`

### Base Entities / Contracts

| Entity/Interface       | Purpose                                             |
|------------------------|-----------------------------------------------------|
| `FlexEnvironmentData`  | Abstract environment config (URLs, SSO config)      |
| `FlexNetworkError`     | Typed network error model                           |
| `PagedResponse<T>`     | Generic paginated API response wrapper              |
| `UrlWrapper`           | Typed URL response wrapper                          |

---

## mekari_pixel (External Design System)

Git dependency at `ref: v2.22.0`. Provides:
- Typography: Inter font family (100–900 weight)
- Color tokens
- UI components (buttons, inputs, cards, etc.)
- Illustrations library (`mekari_pixel_illustrations`)

---

## Shared Module: cashout

Public API exported via `lib/cashout.dart`. Used by main app for:
- `BrickModule` / `BrickRouter` / `BrickApp` (brick_way deep-link module system)
- Localization delegates (ID/EN)
- All domain entities and use cases

## Shared Module: saving

Public API exported per feature. Provides:
- Savings authentication (linkage, token flow)
- Savings balance and transaction views
- Full KYC sub-flow for savings account
- Separate environment URL config (`SavingsEnvironmentData`)

---

## Component Count: ~35 shared infrastructure components
