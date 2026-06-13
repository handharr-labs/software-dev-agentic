---
scope: project/flex-mobile
platform: flutter
discipline: engineering
artifact: third-party-integrations
---
# Third-Party Integrations

Platform: Flutter (Melos monorepo)
Last scanned: 2026-06-04

---

## Firebase

### firebase_core `3.9.0`
Bootstrap for all Firebase services.

### firebase_analytics `11.3.6`
Screen and event tracking. `FlexRouteObserver` fires analytics events on route changes.

### firebase_crashlytics `4.2.0`
Crash reporting. Integrated at app startup.

### firebase_performance `0.10.0+11`
`FirebasePerformanceInterceptor` is added to all `FlexNetworkClient` interceptor stacks to trace HTTP requests.

### firebase_remote_config `5.2.0`
Backs the `mekari_flag` feature-flag system. `FirebaseConfigHelper` / `FirebaseRemoteConfigHelper` fetch and cache flag values.

### firebase_database `11.3.5`
Firebase Realtime Database. Used exclusively for NPS and CSAT feedback submission (`user_feedback/csat|nps/{companyId}/{userId}`).

---

## MoEngage

### moengage_flutter `9.2.1`
Core MoEngage SDK. Powers push notifications and in-app messaging. `MoEngageHelper` / `TrackingHelper` wrap event tracking calls.

### moengage_inbox `8.2.1`
In-app inbox backed by MoEngage SDK. `InboxRepositoryImpl` reads from `MoEngageInbox` locally.

### mekari_log (git, `log-1.38.2`)
Internal Mekari logging module. `FlexMkrLogInterceptor` added to all network clients when `flag_mekari_log` is enabled.

---

## Mekari Internal Packages (git — `mobile-commons`)

### mekari_network `network-1.6.1`
Internal HTTP client library (`MKRNetwork`). All `FlexNetworkClient` instances wrap this. Provides retry, caching, and interceptor infrastructure.

### mekari_flag `flag-1.7.0`
Feature-flag SDK over Firebase Remote Config. `FlexFeature` enum is the app-level interface.

### mekari_pixel `v2.22.0`
Mekari design system. Provides Inter font family (weights 100–900) and core UI tokens.

### mekari_pixel_illustrations `illustrations-1.4.0`
Illustration asset library from the Mekari design system.

### mekari_qa_tools `qa_tools-1.0.4`
QA developer tooling: mock server activation, network inspector, device preview. Active only when `ENABLE_DEV_TOOLS` is true.

### auth_module `auth_module-1.41.0`
Mekari SSO authentication module. Manages the OAuth flow and token exchange.

---

## Brick-Way

### brick_way `v1.21.3` (git — `brick-way`)
Micro-frontend framework used by `modules/cashout`. Provides `BrickModule`, `BrickRouter`, `BrickApp`, and `BrickCallback` interfaces for isolated feature packaging.

---

## Networking

### dio `5.8.0+1`
HTTP client. Used directly inside all `FlexNetworkClient` subclasses.

### japx `2.2.0`
JSON:API serialiser/deserialiser. Used to decode JSONAPI-formatted responses from the lending, CKYC, referral, Flex Points, and other endpoints.

---

## State Management

### flutter_bloc `9.1.1`
BLoC/Cubit pattern. Every feature has at least one BLoC.

### bloc_concurrency `0.3.0`
`droppable()`, `restartable()`, `sequential()` event transformers for BLoC.

### bloc_event_transformers `2.0.0`
Additional event transformers.

### rxdart `0.27.7`
Used via `bloc_event_transformers` and `mekari_flag`; not used directly in app code.

---

## Local Storage

### hive `2.2.3` + hive_flutter `1.1.0`
Lightweight key-value store for caching products, profile, session, settings, and PPOB history.

### objectbox `4.1.0` + objectbox_flutter_libs `4.1.0`
High-performance embedded database. Activated via `flag_use_objectbox` feature flag as an alternative to Hive for some stores.

### flutter_secure_storage `9.2.4`
Encrypted secure storage for auth tokens and sensitive credentials.

---

## Biometrics

### local_auth `2.3.0`
Biometric authentication (fingerprint, face ID).

### local_auth_android `1.0.42` / local_auth_darwin `1.4.1`
Platform-specific biometric implementations.

---

## Media Capture

### camera `0.11.0+2`
Camera capture for KTP photo during CKYC flow.

### image_picker `1.1.2`
Image selection from gallery (KYC document upload).

---

## File Handling

### file_picker `5.5.0`
Generic file selection (payslip upload).

### pdfx `2.8.0`
PDF viewer and renderer using native APIs. Used in `FileViewerScreen`.

### flutter_svg `2.0.10+1`
SVG rendering for design system assets.

---

## WebView

### webview_flutter `4.8.0`
In-app WebView used for insurance, help center, FAQ, terms, privacy policy, and savings webview feature (when `flag_savings_render_webview` is enabled).

---

## Deep Linking

### app_links `3.5.1`
Deep link / universal link handling for incoming URLs.

---

## Notifications

### flutter_local_notifications `17.2.4`
Local notification scheduling and display.

### flutter_ringtone_player `4.0.0+4`
Plays ringtone on notification receipt.

### sound_mode `3.1.1`
Reads device sound mode (silent/vibrate/ring) to adjust notification behaviour.

---

## E-Wallets

No direct SDK integration. All e-wallet top-ups (GoPay, OVO, ShopeePay, DANA) are server-mediated via the credit transactions API. The app does not embed any e-wallet SDK.

---

## Device Tracking

### advertising_id `2.7.1`
Reads GAID/IDFA for ad tracking.

### android_id `0.4.0`
Reads Android device ID for tracking info (`UserTrackingInfo`).

### package_info_plus `8.2.0`
App version and build number for `AppTrackingInfo`.

---

## Contacts

### fluttercontactpicker `5.0.0`
Native contact picker. Used in savings transfer (pre-fill recipient from contacts).

---

## Charts

### pie_chart `5.4.0`
Pie chart widget used in balance breakdown views.

### barcode `2.2.9`
QR code and barcode generation.

---

## Utilities

### freezed_annotation `2.4.4` + freezed `2.5.2`
Immutable data class and union type generation. Used extensively for domain entities and remote models.

### json_annotation `4.9.0` + json_serializable `6.8.0`
JSON serialisation code generation for response models.

### equatable `2.0.5`
Value equality for domain entities and BLoC states.

### either_dart `1.0.0`
`Either<Failure, T>` functional error handling in repositories.

### collection `1.19.0`
Extended collection utilities.

### intl `0.19.0`
Internationalisation and date/number formatting.

### timezone `0.9.4`
Time zone database for notification scheduling.

### share_plus `7.2.2`
Share sheet for sharing referral codes and transaction receipts.

### url_launcher `6.3.1`
Launches browser, mailto, and tel URLs.

### html `0.15.4`
HTML parsing for inbox message bodies.

### mime `1.0.6`
MIME type resolution for file uploads.

### path `1.9.0` / path_provider `2.1.5`
File system path utilities.

### vibration `3.1.4`
Haptic feedback on payment confirmation.

### async `2.11.0`
`StreamGroup`, `Completer`, and other async utilities.

### crypto `3.0.3`
Cryptographic hashing utilities.

### sliver_tools `0.2.12`
Extended sliver widgets.

### device_preview `1.2.0`
Multi-device preview for development (QA tools only).

---

## Build / Code Generation

### build_runner `2.4.9`
Drives `freezed`, `json_serializable`, `objectbox_generator`, `envied_generator`, `hive_generator`, `flutter_gen_runner`.

### envied `0.3.0+3` + envied_generator `0.3.0+3`
Obfuscated `.env.*` variable injection at build time. Environment files: `.env.production`, `.env.staging`, `.env.sandbox`.

### flutter_gen_runner `5.8.0`
Generates `FlexMobileAssets` typed asset class.

### melos `6.3.2`
Monorepo task runner for multi-package builds, tests, and localisation generation.

---

## Testing

### bloc_test `10.0.0`
BLoC unit test helpers.

### mockito `5.4.4`
Mock generation for unit tests.

### http_mock_adapter `0.6.1`
Dio HTTP mock adapter for data source tests.

### flutter_driver (sdk)
Integration test driver.
