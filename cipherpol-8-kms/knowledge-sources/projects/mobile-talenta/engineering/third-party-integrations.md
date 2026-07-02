---
scope: project/mobile-talenta
platform: flutter
discipline: engineering
artifact: third-party-integrations
---
# Third-Party Integrations

Platform: Flutter | Package manager: pub (managed via Melos mono-repo)

---

## Internal / Mekari-owned Packages (Private git dependencies)

### mekari_network
- **Repo**: `git@bitbucket.org:mid-kelola-indonesia/mobile-commons.git` (path: `mekari_network`)
- **Ref**: `network-1.6.1`
- **Purpose**: Core HTTP client layer. Provides `NetworkClient` (Dio wrapper), interceptors, error handling, `FormData` utilities. Used by every feature module for all API calls.

### mekari_log
- **Repo**: `mobile-commons` (path: `mekari_log`, ref: `log-1.38.2`)
- **Purpose**: Internal structured logging. Accessed via `BricksHelper.getBricklogger()`. Used in data sources for debug logging of request payloads.

### network_inspector
- **Repo**: `mobile-commons` (path: `mekari_network/plugins/network_inspector`, ref: `network_inspector-1.3.3` / `network_inspector-1.4.0`)
- **Purpose**: In-app network request inspector overlay for debugging. Dev/QA tool.

### auth_module
- **Repo**: `mobile-commons` (path: `auth_module`, ref: `auth_module-1.41.0`)
- **Purpose**: Authentication helpers, token management, OTP challenge header utilities. Provides `getChallengeOtpHeaders()` used in payslip and change-data flows.

### mekari_flag
- **Repo**: `mobile-commons` (path: `mekari_flag`, ref: `flag-1.7.0`)
- **Purpose**: Feature flag SDK. `MKRFlagFeature` is the flag entity. Integrates with Flagsmith backend. Used in `TalentaFlagsmithProvider` for A/B flags and kill switches.

### mekari_pixel
- **Repo**: `git@bitbucket.org:mid-kelola-indonesia/mekari-pixel.git` (path: `mekari-pixel`, ref: `v2.22.0`)
- **Purpose**: Mekari design system component library. Provides all UI components used across the app (buttons, text fields, cards, icons, typography, colors). Replaces Flutter Material widgets at the UI layer.

### mekari_pixel_illustrations
- **Repo**: `mekari-pixel` (path: `mekari_pixel_illustrations`, ref: `illustrations-1.4.0`)
- **Purpose**: Illustration assets from the Mekari Pixel design system. Used in empty states and error screens (e.g., inbox invalid shift, edit history empty state).

### mekari_qa_tools
- **Repo**: `mobile-commons` (path: `mekari_qa_tools`, ref: `qa_tools-1.0.5`)
- **Purpose**: QA overlay tools — shake-to-debug, environment switcher, network inspector toggle. Not shipped in production builds.

### brick_way
- **Repo**: `git@bitbucket.org:mid-kelola-indonesia/brick-way.git` (path: `brick-way`, ref: `v1.21.3`)
- **Purpose**: Micro-frontend routing/communication framework. Provides `BaseModule` contract, `ExecutorResponse`, `HostType`, `BrickWay` navigation primitives. Defines the entire module-loading architecture.

---

## Firebase

All Firebase packages are pinned to exact versions via `dependency_overrides`.

| Package | Version | Usage |
|---|---|---|
| `firebase_core` | 3.9.0 | Firebase initialization, required by all other Firebase packages. |
| `firebase_analytics` | 11.3.6 | Event tracking. `FirebaseAnalytics` instance exposed via `FirebaseService`. |
| `firebase_crashlytics` | 4.2.0 | Crash reporting. `ErrorReportUtil` filters and forwards errors. Active in production. |
| `firebase_performance` | 0.10.0+11 | Network trace performance monitoring. Integrated via `mekari_network` interceptors. |
| `firebase_remote_config` | 5.2.0 | Dynamic configuration. `FirebaseRemoteConfigHelper` singleton exposes: FAQ URL, help center URL, privacy policy URL, Kong toggle, and custom feature flags. |

---

## Location & Tracking

| Package | Version | Usage |
|---|---|---|
| `google_maps_flutter` | 2.2.5 | Map display in attendance inbox detail, live location tracking, attendance log detail. |
| `google_maps_flutter_ios` | 2.3.6 | iOS-specific Maps SDK bridge. |
| `flutter_background_geolocation` | 4.18.0 | Background GPS tracking for live location tracking feature. Powers `LocationTrackingHeadlessTrigger` and `LocationDetailsScreen`. |
| `flutter_background_service` | 5.1.0 | Background service host for MQTT live-location worker. Keeps MQTT connection alive when app is backgrounded. |

---

## MQTT

| Package | Version | Usage |
|---|---|---|
| `mqtt_client` | 10.5.1 | MQTT broker connection for real-time live location updates. `MqttClientServiceImpl` wraps it. Auth credentials fetched via `/companies/{id}/vernemq/generate-auth`. |

---

## Media & Files

| Package | Version | Usage |
|---|---|---|
| `image_picker` | ^1.0.1 | Camera and gallery image selection. Used in `AttachmentInput`, avatar upload. |
| `file_picker` | ^5.2.6 | Generic file picking (PDF, documents). Used in attachment fields across time-off, reimbursement, change-data. |
| `heif_converter` | ^1.0.0 | Converts HEIF/HEIC iPhone photos to JPEG before upload. |
| `image_cropper` | 10.0.0+1 | Image crop UI before avatar/photo upload. |
| `video_player` | ^2.7.2 | Video playback in `MediaViewerScreen`. |
| `video_thumbnail` | ^0.5.3 | Generates video thumbnail previews in media viewer. |
| `photo_view` | ^0.15.0 | Pinch-zoom image viewer. Used in `MediaViewerPreviewWidget`. |
| `pdfx` | ^2.5.0 | PDF rendering in `DocumentViewerScreen`. |
| `cached_network_image` | ^3.3.1 | Network image caching. Used throughout for employee avatars, attachment thumbnails. |
| `flutter_downloader` | ^1.11.7 | Background file download manager. Powers `DownloadHelper` for payslip and attachment downloads. |
| `path_provider` | ^2.1.2 | File system path resolution for downloads and temporary files. |
| `carousel_slider` | ^5.0.0 | Carousel widget used in media viewer thumbnail strip. |

---

## Notifications

| Package | Version | Usage |
|---|---|---|
| `flutter_local_notifications` | 17.2.4 | Local push notifications from MQTT events and background service. |

---

## Network Connectivity

| Package | Version | Usage |
|---|---|---|
| `connectivity_plus` | 6.0.5 | Network connectivity change detection. |
| `internet_connection_checker_plus` | 2.5.2 | Actual internet reachability check (beyond just connected state). Used in `NetworkConnectivityService`. |

---

## WebView

| Package | Version | Usage |
|---|---|---|
| `webview_flutter` | 4.8.0 | In-app WebView for Performance portal, LMS, FAQ, help center, privacy policy, BPJS portal (Officeless). `TalentaWebview` wraps it with JS channels. |

---

## Serialization & Code Generation

| Package | Version | Usage |
|---|---|---|
| `freezed_annotation` | 2.4.4 | Immutable data classes with `copyWith`, `==`, `toString`. Used for most domain entities and models. |
| `json_annotation` | 4.9.0 | `@JsonSerializable` for API model deserialization. |
| `freezed` (dev) | 2.5.2 | Code generator for `@freezed` classes. |
| `json_serializable` (dev) | 6.8.0 | Code generator for `@JsonSerializable` models. |
| `build_runner` (dev) | 2.4.9 | Dart code generation runner. |
| `injectable_generator` (dev) | 2.4.2 | Code generator for `@injectable` DI annotations. |

---

## Dependency Injection

| Package | Version | Usage |
|---|---|---|
| `injectable` | 2.5.1 | Annotation-based DI (`@injectable`, `@LazySingleton`, `@Singleton`). Each feature module generates its own `*.config.dart` via `injectable_generator`. |
| `get_it` | (transitive) | Service locator. Each feature has its own `GetIt` instance. |

---

## Functional Programming

| Package | Version | Usage |
|---|---|---|
| `fpdart` | 0.5.0 | Functional types: `Either`, `TaskEither`. Used only in `talenta_inbox` repository layer (see Deviations D5). |

---

## UI & Utilities

| Package | Version | Usage |
|---|---|---|
| `flutter_bloc` | 9.1.1 | BLoC state management. All features use `Bloc<Event, State>` pattern exclusively. |
| `equatable` | 2.0.5 | Value equality for BLoC events/states and domain entities. |
| `table_calendar` | 3.2.0 | Calendar widget in `CalendarScreen`. |
| `dotted_border` | ^2.1.0 | Dashed/dotted border decoration. Used in attachment fields and section separators. |
| `html` | 0.15.4 | HTML parsing utility. Supports `HtmlContentView` and rich description widgets in inbox. |
| `flutter_widget_from_html_core` | 0.15.2 | Renders HTML to Flutter widgets. Used in inbox description sections and announcement detail. |
| `app_settings` | 5.1.1 | Opens device settings from within the app. Used in permission handling flows. |
| `regexpattern` | ^2.5.0 | Pre-built regex patterns for validation (email, phone, etc.). |

---

## Security

| Package | Version | Usage |
|---|---|---|
| `flutter_secure_storage` | 9.2.4 | Encrypted key-value storage. Stores auth tokens and session data. Used in `AuthTokenLocalDataSource`. |
| `envied` | 0.3.0+3 | Compile-time obfuscation of `.env` values. Prevents API keys from appearing as plain strings in compiled binaries. |
| `envied_generator` (dev) | 0.3.0+3 | Code generator for `@Envied` annotated classes. |

---

## Testing

| Package | Version | Usage |
|---|---|---|
| `bloc_test` | 10.0.0 | BLoC unit test helpers (`blocTest`, `MockBloc`). |
| `mockito` (dev) | 5.4.4 | Mock generation for unit tests. |
| `mock_data` | 2.0.1 | Random test data generators. |
| `http_mock_adapter` | 0.6.1 | Dio mock adapter for in-package HTTP testing. |

---

## Dev / QA

| Package | Version | Usage |
|---|---|---|
| `device_preview` | 1.2.0 | Device frame preview in development builds. Pinned via override due to `mekari_qa_tools` compatibility. |
| `flutter_lints` | 2.0.0 | Dart lint rules. Analysis options extend from this. |
