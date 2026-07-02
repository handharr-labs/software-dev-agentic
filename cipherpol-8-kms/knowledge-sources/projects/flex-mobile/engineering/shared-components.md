---
scope: project/flex-mobile
platform: flutter
discipline: engineering
artifact: shared-components
---
# Shared Components

Platform: Flutter (Melos monorepo)
Last scanned: 2026-06-04

Shared components live in two locations:
- `lib/shared/` — app-level shared layer
- `modules/flex_core/lib/shared/` — module-level shared layer (consumed by all melos packages)

---

## Networking

### FlexNetworkClient (`modules/flex_core`)
Base HTTP client wrapping `mekari_network` / `MKRNetwork` + Dio. Provides `get`, `post`, `put`, `patch`, `delete`, `putFormData`. All feature data sources depend on this.

### BenefitNetworkClient (`lib/shared/core/networking/benefit_network_client.dart`)
Extends `FlexNetworkClient` pointing to `BENEFIT_CMS_URL`. Used by campaigns, products, and CMS-backed features. Adds `Accept-Language` header from user preference.

### LendingNetworkClient (`lib/shared/core/networking/lending_network_client.dart`)
Extends `FlexNetworkClient` pointing to `LENDING_URL`. Used exclusively by the installment feature.

### SavingsNetworkClient (`modules/saving/`)
Separate network client for the Mekari Saving module, pointing to `SAVING_URL` with its own token management.

---

## Dependency Injection

### get_it Locator (`lib/configs/di/service_locator.dart`)
Manual `get_it` DI — no `injectable` code generation. Setup split across:
- `setupDILocator()` — networking clients, utils, helpers
- `setupDataLocator()` — repositories and data sources
- `setupDomainLocator()` — use cases
- `setupDatabaseLocator()` — Hive and ObjectBox helpers
- `bloc_factory.dart` — BLoC factory registrations

---

## State Management (BLoC)

### SessionBloc (`lib/shared/presentation/blocs/session/`)
Central session lifecycle bloc. Drives login/logout flows across the app.

### FeatureFlagBloc (`modules/flex_core/lib/shared/presentation/blocs/feature_flag/`)
Manages Firebase Remote Config feature flags. All features gate behaviour through `FlexFeature.xxx.isEnabled`.

### UserBloc (`modules/flex_core` — `UserRemoteDataSource`)
Cached user data bloc. `UserBloc.cached` is accessed statically for language preference in network interceptors.

### QA Notification Bloc / QA Credentials Bloc (`lib/shared/presentation/blocs/`)
Developer QA tooling blocs, active only when `ENABLE_DEV_TOOLS` is true.

---

## Local Storage

### Hive (`hive` + `hive_flutter`)
Used for lightweight persistence. Helpers:
- `HiveProfileHelper` — caches user/company profile data
- `HiveProductHelper` — caches PPOB product data and recent transactions
- `HiveSessionHelper` — session tokens and auth state
- `HiveSettingsHelper` — referral and settings preferences

### ObjectBox (`objectbox` + `objectbox_flutter_libs`)
Used as an alternative/replacement for some Hive stores (gated by `flag_use_objectbox`). `ObjectBoxDatabaseProvider` wraps the store lifecycle.

### FlutterSecureStorage
Used for sensitive data (auth tokens, PIN-related secrets).

---

## Widgets — flex_core (`modules/flex_core/lib/shared/presentation/widgets/`)

| Widget | Description |
|---|---|
| `FlexFormField` | Custom text input field |
| `FlexRoundedButton` | Standard rounded CTA button |
| `NumpadKeyboard` | Custom numeric keypad (for PIN, amount entry) |
| `FlexNavigationBar` | Bottom navigation bar |
| `FlexWebview` | In-app WebView wrapper (`webview_flutter`) |
| `FlexCamera` | Camera capture widget (`camera` package) |
| `FlexImageHolder` | Image display with fallback/loading |
| `ImageFromNetwork` | Network image with caching |
| `ErrorHandlerWidget` | Standard error state display |
| `ErrorMessageContent` | Inline error message body |
| `CommonErrorSheet` | Bottom sheet for common error states |
| `PullToRefresh` | Scroll-refresh wrapper |
| `TopSnackbar` | Custom top-positioned snackbar |
| `SliverToolbarComponent` | Collapsible sliver app bar |
| `StepperAppBar` | Multi-step flow app bar with progress |
| `LinearProgressBar` | Horizontal step progress bar |
| `FlexTimeline` | Vertical timeline component |
| `ExpansionField` | Expandable form section |
| `FlexScrollIndicator` | Page scroll indicator dots |
| `FlexSingleScrollView` | Single-child scroll view wrapper |
| `FlexPageTransition` | Custom page route transition |
| `KeyboardDismissDetector` | GestureDetector to dismiss keyboard |
| `KeyboardActionDone` | Done button above keyboard |
| `AcronymText` | Displays initials/acronym avatar text |
| `Hyperlink` | Tappable text link |
| `ShowMoreOrLess` | Expandable text with show more/less |
| `AutoResizeText` | Text that auto-shrinks to fit |
| `MeasureSize` | RenderObject size measurement callback |
| `ReachedBottomFooter` | Pagination end-of-list indicator |
| `CircleBackIcon` | Circular back navigation button |
| `SliverExpansionTile` | Sliver-compatible expansion tile |
| `StickyHeaderDelegate` | Sliver sticky header delegate |
| `MeterNumberInput` | Specialised input for PLN meter numbers |
| `AmountShortcut` | Quick-amount selection chips |
| `RestrictHandler` | Widget to gate restricted actions |
| `LightAppbar` | Light-theme app bar |
| `FlexMenuMenuItem` | Menu list item with icon and trailing |
| `FlexTrailingField` | Trailing accessory field row |
| `FlexMultilineTextField` | Multi-line text input |
| `Consumer` | BLoC-aware consumer widget wrapper |

---

## Widgets — App-level (`lib/shared/presentation/widgets/`)

| Widget | Description |
|---|---|
| `ShimmerCampaignsOverview` | Shimmer skeleton for campaign overview |
| `ShimmerVoucherList` | Shimmer skeleton for voucher list |
| `AppTour` / `tours.dart` | Onboarding coachmark tour definitions |

---

## Screens — App-level (`lib/shared/presentation/screens/`)

| Screen | Description |
|---|---|
| `SplashScreen` | Initial app loading screen |
| `MainScreen` | Root scaffold with bottom navigation |
| `WalkthroughScreen` | First-run onboarding walkthrough |
| `FaqScreen` | FAQ WebView |
| `PrivacyPolicyScreen` | Privacy policy WebView |
| `TermsOfUseScreen` | Terms of use WebView |
| `MekariFlexProductScreen` | Product marketing WebView |
| `LoanHelpCenterScreen` | Loan help center WebView |

---

## Screens — flex_core (`modules/flex_core/lib/shared/presentation/screens/`)

| Screen | Description |
|---|---|
| `FileViewerScreen` | PDF/file viewer (`pdfx`) |
| `UpdateAppScreen` | Force-update interstitial |
| `PageNotFoundScreen` | 404 / deep-link not found |
| `ProductNotFoundScreen` | Product unavailable state |

---

## Utilities

### FlexRouteObserver (`lib/shared/core/utils/flex_route_observer.dart`)
`RouteObserver` that fires MoEngage and Firebase screen tracking events.

### FlexLocalization (`lib/shared/core/utils/localization/`)
Manages locale switching; wraps Flutter's `AppLocalizations`.

### MoengageNavigation (`lib/shared/core/utils/moengage_navigation.dart`)
Handles deep links from MoEngage push notifications.

### MethodChannels (`lib/shared/core/utils/method_channels/`)
- `SecureUtilChannel` — native secure utilities
- `NotificationCounterChannel` — badge count management
- `AppLauncherChannel` — launch other Mekari apps

### QATestingTools (`lib/shared/core/utils/qa_testing_tools/`)
Developer shortcuts gated by `ENABLE_DEV_TOOLS`: feature flag toggle, push notification trigger, pop route, clear coachmarks.

---

## Feature Flags

### FlexFeatureFlagHelper / FirebaseConfigHelper
`mekari_flag` wraps Firebase Remote Config. Flags cached in Hive (`HiveRemoteConfigHelper`) for offline access. `FlexFeature` enum is the single access point across the app.

---

## Localisation

Multi-package localisation via Melos scripts fetching strings from a remote endpoint. Generated `AppLocalizations` files live in:
- `lib/shared/core/gen/` (app)
- `modules/flex_core/lib/.../gen/` (core)
- `modules/saving/lib/.../gen/` (saving)
- `modules/cashout/lib/.../gen/` (cashout)

Supported locales: `id` (Indonesian), `en` (English).

---

## Design System

`mekari_pixel` (git package `v2.22.0`) provides the Mekari design system. Font family: **Inter** (weights 100–900, loaded from the package).
`mekari_pixel_illustrations` provides illustration assets.

---

## Asset Generation

`flutter_gen` generates typed `FlexMobileAssets` class from `assets/animations/`, `assets/images/`, `assets/icons/`, `assets/audios/`.
