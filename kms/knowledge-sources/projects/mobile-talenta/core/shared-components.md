---
scope: project/mobile-talenta
platform: flutter
discipline: engineering
artifact: shared-components
---
# Shared Components

All shared code lives in `talenta/lib/src/shared/core/`. Components are reused across all feature modules.

---

## Network Layer

**Path**: `shared/core/network/`

| Component | Description |
|---|---|
| `NetworkClient` | Abstract contract for HTTP operations. Methods: `get`, `post`, `put`, `delete`, `patch`, `getV2`, `postV2`, `patchV2`, `getV3`. |
| `NetworkBaseUrlFactory` | Abstract factory for resolving base URLs per environment and service. Concrete: `KongNetworkBaseUrlFactory`, `NonKongNetworkBaseUrlFactory`. |
| `TalentaService` (enum) | Identifies which micro-service to route to: `mobile`, `geolocation`, `timeOff`. |
| `NetworkErrorHandler` / `NetworkErrorHandlerProcessor` | Intercepts and transforms Dio errors into `TalentaException`. |
| `NetworkRefreshToken` | Token refresh logic integrated in the network interceptor chain. |
| `NetworkHeader` | Shared header constants and builder. |

---

## Data Models

**Path**: `shared/core/data/models/`

| Component | Description |
|---|---|
| `BaseResponse<T>` | Generic API response wrapper. Fields: `status`, `message`, `data`. Deserializes via `onDeserializedT` callback. |
| `UserResponse` | User entity model from `/dashboard/user`. |
| `ApprovalItemResponse` | Approval item with status, actor, and timestamp. |
| `FileInfoResponse` | File attachment metadata (name, URL, type). |
| `MockData` | Test/dev mock data helper. |

**Path**: `shared/core/data/models/generic/`

| Component | Description |
|---|---|
| `UserHostResponse` | Host-to-module handshake: user identity and org context. |
| `ToggleHostResponse` | Feature flag overrides passed from host to module on load. |

---

## Exception Handling

**Path**: `shared/core/data/api_exceptions/`

| Component | Description |
|---|---|
| `TalentaException<T>` | Typed exception. Factory constructors: `badRequestException`, `serverValidationException`, `genericException`. Carries `statusCode`, `message`, optional typed `errors`. |
| `ExceptionMapper` | Maps `DioException` to `TalentaException`. |

---

## Domain Entities (Shared)

**Path**: `shared/core/domain/entities/`

| Entity | Description |
|---|---|
| `Failure` | Base error type for functional result handling (used with `fpdart` `Either`). |
| `ApprovalStatus` | Enum-like class for approval states: pending, approved, rejected. |
| `ApprovalStatusReimbursement` | Reimbursement-specific approval status variant. |
| `BaseApprovalStatus` / `ApprovalStatuses` | Polymorphic approval status hierarchy. Sub-types: `TimeOffApprovalStatus`, `OvertimeApprovalStatus`, `ShiftChangeApprovalStatus`. |
| `PaginationState` | Generic pagination cursor state. |
| `NetworkStatus` | Connectivity state enum. |
| `DownloadProgress` | File download progress model. |
| `FileInfo` | Domain-level file info entity. |
| `Employee` | Shared employee entity (id, name, avatar). |
| `User` | Authenticated user entity. |
| `ApprovalItem` | Single approval line item with actor and status. |
| `ApprovalLine` | Sequence of approval items in a workflow. |
| `UserHeader` | Employee header display model (name, position, avatar). |
| `ItemSection` | Generic key-value section row. |
| `SectionListItem` | Wrapper for sectioned list rendering. |
| `OverviewItemModel` | Key-value model for overview cards. |

---

## Domain Use Cases (Shared)

**Path**: `shared/core/domain/usecases/`

| Use Case | Description |
|---|---|
| `UseCase<Type, Params>` | Abstract base class for all use cases. |
| `GetUserUseCase` | Retrieves current authenticated user from `UserRepository`. |

---

## Mappers (Shared)

**Path**: `shared/core/data/mappers/`

| Mapper | Description |
|---|---|
| `BaseMapper<I, O>` | Abstract bidirectional mapper contract. |
| `ReversibleMapper<I, O>` | Mapper that supports both directions. |
| `UserMapper` | Maps `UserResponse` to `User` entity. |
| `EmployeeMapper` | Maps employee response to `Employee` entity. |
| `ApprovalItemMapper` | Maps approval item response to entity. |
| `UserOrganizationMapper` | Maps user-org join data. |
| `UserJobMapper` | Maps user job/position data. |
| `RequestedEmployeeMapper` | Maps requested employee in approval flows. |
| `ExceptionMapper` | Converts `DioException` to `TalentaException`. |
| `MapToFormDataMapper` / `MapToFormDataMultiCompatible` | Converts domain payload maps to Dio `FormData`. |
| `FileInfoMapper` | Maps file metadata. |
| `DefaultHeaderMapper` | Builds default request headers. |

---

## Section Widgets

**Path**: `shared/core/presentation/widgets/`

| Widget | Description |
|---|---|
| `UserHeader` | Employee header card with avatar, name, position. |
| `ItemSectionView` | Labeled row for detail sections. |
| `AccordionSectionView` | Collapsible section container. |
| `AttachmentSection` | File attachments list with thumbnail previews. |
| `AttachmentThumbnail` | Single attachment preview thumbnail. |
| `ApprovalLineView` | Renders approval workflow chain. |
| `ApprovalViews` | Combined approval status and line display. |
| `ApprovalStatusCard` | Status badge card (approved/rejected/pending). |
| `ApprovalStatusBottomSheet` | Bottom sheet for approval status details. |

---

## Generic Widgets

**Path**: `shared/core/presentation/widgets/`

| Widget | Description |
|---|---|
| `BaseBottomSheet` | Reusable bottom sheet scaffold. |
| `ListPaginationWidget` | Scrollable paginated list with load-more. |
| `SectionedListPaginationWidget` | Paginated list with sectioned header grouping. |
| `LoadmoreListTileWidget` | Inline load-more list tile. |
| `ActionButtonWidget` | Primary/secondary action button pair. |
| `BannerInfoWidget` | Informational top banner. |
| `FilterSectionWidget` | Horizontal filter chip row. |
| `StatusFilterBottomSheet` | Bottom sheet with status filter options. |
| `FilterIconWidget` | Filter icon with active-state badge. |
| `SectionWidget` | Titled section container. |
| `ColoredHeaderCardWidget` | Card with colored header region. |
| `TopBottomCurveContainer` / `TopBottomInwardCurveContainer` | Decorative curve layout containers. |
| `AppBarDateFilter` | App bar with integrated date range filter. |
| `MpYearPickerAppBar` | App bar with year picker widget. |
| `LoadingFromHostContainer` | Loading state container during host initialization. |
| `RequestListTileWidget` | Standard request item list tile. |
| `OverviewItemCard` | Card for overview metric display. |

---

## Attachment Input

**Path**: `shared/core/presentation/widgets/`

| Widget | Description |
|---|---|
| `AttachmentInput` | Multi-source file input (camera, gallery, file picker). |
| `AttachmentField` (`AttachmentData`) | Attachment data model with path, file name. |
| `AttachmentThumbnail` | Thumbnail preview for selected attachment. |
| `AvatarField` | Avatar/image picker input field. |
| `FileSourceBottomSheet` | Bottom sheet for choosing camera vs file picker. |

---

## Bottom Sheets

**Path**: `shared/core/presentation/widgets/`

| Widget | Description |
|---|---|
| `EmployeeInfoBottomSheet` | Employee profile summary sheet. |
| `RadioButtonBottomSheet` | Single-select radio option sheet. |
| `CancelRequestConfirmationBottomsheet` | Confirm cancel action sheet. |
| `OtpRequestErrorBottomSheet` | OTP request failure sheet. |

---

## WebView

**Path**: `shared/core/presentation/widgets/`

| Widget | Description |
|---|---|
| `TalentaWebview` | Core WebView wrapper with JS channel support. |
| `TalentaWebviewScreen` | Full-screen WebView screen. |
| `GenericWebviewScreen` | Simple URL-based WebView screen. |
| `WebviewWithAppBarScreen` | WebView with custom app bar. |
| `BaseWebviewChannel` | Abstract JS message channel. |
| `LmsWebviewChannel` | LMS-specific WebView JS bridge. |

---

## Media Viewer

**Path**: `shared/core/presentation/widgets/`

| Widget | Description |
|---|---|
| `Viewer` | Orchestrator for image/video/document viewing. |
| `MediaViewerScreen` | Full-screen media viewer (image, video). |
| `DocumentViewerScreen` | PDF document viewer screen. |
| `MediaViewerPreviewWidget` | Main preview panel. |
| `MediaViewerThumbnailWheelWidget` | Horizontal thumbnail strip. |
| `MediaViewerVideoControlWidget` | Video playback controls. |
| `ViewerAppBarWidget` / `ViewerMenuWidget` / `ViewerErrorWidget` | Viewer chrome components. |

---

## Utility Widgets

**Path**: `shared/core/presentation/widgets/`

| Widget | Description |
|---|---|
| `NetworkAwareWidget` | Wraps child with offline-state overlay. |
| `TimeWithTimezoneWidget` | Displays time with timezone label. |
| `HtmlContentView` | Renders HTML string via `flutter_widget_from_html_core`. |
| `MapPictureWidget` | Static Google Maps snapshot widget. |
| `SelectList` | Generic selectable list component. |
| `DashedDot` | Dashed line/dot separator decorator. |

---

## Presentation BLoCs (Shared)

**Path**: `shared/core/presentation/blocs/`

| BLoC | Description |
|---|---|
| `UserBloc` | Manages currently logged-in user state across the app. |
| `ViewDataState<T>` | Generic state class for async data: `initial`, `loading`, `success(data)`, `error(message)`. Used by most feature BLoCs. |

---

## MQTT

**Path**: `shared/core/mqtt/`

| Component | Description |
|---|---|
| `MqttClientService` (abstract) | Contract for MQTT connect/subscribe/publish/disconnect. |
| `MqttClientServiceImpl` | Concrete implementation using `mqtt_client` package. |
| `MqttConfigFactory` | Builds MQTT broker config from auth credentials. |

---

## Services

**Path**: `shared/core/service/`

| Service | Description |
|---|---|
| `NetworkConnectivityService` | Monitors network status via `connectivity_plus` and `internet_connection_checker_plus`. |
| `FirebaseService` | Initializes Firebase and exposes `FirebaseCrashlytics`, `FirebaseAnalytics`, `FirebasePerformance`, `FirebaseRemoteConfig`. |

---

## Utilities

**Path**: `shared/core/utils/`

| Utility | Description |
|---|---|
| `DateUtil` | Date parsing and formatting helpers. |
| `CurrencyHelper` | IDR currency formatting. |
| `UrlHelper` | URL validation and launch helpers. |
| `VersionHelper` | App version comparison. |
| `StringValidatorHelper` | Regex-based string validators. |
| `PermissionHelper` | Runtime permission request wrappers. |
| `OtpHelper` | Builds challenge-OTP request headers (`X-OTP-*`). |
| `DateHelper` | Domain-level date helpers. |
| `ArgumentHelper` | Type-safe route argument extractor. |
| `BricksHelper` | Brick-Way logger accessor. |
| `DownloadHelper` / `DownloadChannel` | File download orchestration with `flutter_downloader`. |
| `RedirectionChannel` | Native method channel for host-app navigation callbacks. |
| `WebviewHelper` | Constructs WebView-safe URLs and cookie injection. |
| `NativeNavigationHelper` | Triggers native navigation from Flutter. |
| `UrlWhitelistHandler` | Validates URLs against a configurable whitelist. |
| `CustomTextInputFormatter` | Base class for custom text formatters. |
| `ErrorReportUtil` | Filters and reports errors to Crashlytics. |
| `MapUtil` | Safe map access helpers. |
| `ClipboardUtil` | Copy-to-clipboard wrapper. |

### Feature Flags

| Component | Description |
|---|---|
| `MekariFlagExtensions` | Extensions on `MKRFlagFeature` for JSON serialization. |
| `FeatureFlagDefaultInitialization` | Seeds default flag values on startup. |
| `TalentaFlagsmithProvider` | Flagsmith-based feature flag provider. |
| `TalentaFlagsmithStorage` | Local storage for Flagsmith flag cache. |
| `TalentaFlagsmithSeed` | Default flag seed values. |

### Firebase Utilities

| Component | Description |
|---|---|
| `FirebaseRemoteConfigKeys` | Typed constants for all Remote Config keys. |
| `FirebaseRemoteConfigHelper` | Singleton accessor for Remote Config values (FAQ URL, help center URL, privacy policy URL, etc.). |

---

## Extensions

**Path**: `shared/core/extensions/`

| Extension | Target |
|---|---|
| `StringExtension` | Null/blank checks, formatting, URL encoding. |
| `DateTimeExtension` | Date formatting, comparison, timezone conversion. |
| `DoubleExtensions` | Rounding, currency display. |
| `IntExtensions` | Zero-fallback, ordinal formatting. |
| `DurationExtensions` | Duration to human-readable string. |
| `CollectionExtensions` / `ListExtension` | Safe access, groupBy, flatMap. |
| `BoolExtensions` | `orFalse()` null-safe helper. |
| `ContextExtensions` | Theme, locale, navigator shortcuts from `BuildContext`. |
| `SpacingExtension` | `SizedBox` spacing shorthand from numeric values. |
| `WidgetExtensions` | Padding, margin, visibility modifiers. |
| `ColorExtensions` | Hex parsing, opacity helpers. |
| `FileExtensions` | MIME type, size formatting. |

---

## Module Infrastructure

**Path**: `shared/core/module/`

| Component | Description |
|---|---|
| `BaseModule` | Abstract contract all feature modules implement. Methods: `getContent()`, `executeService()`, `getPageByName()`, `getProvidersByName()`, `initializeDependencies()`, `onCompleteHostLoading()`. |
| `ModuleManager` | Registry for all `BaseModule` instances; routes URIs to the correct module. |

---

## Brick-Way Content Components

**Path**: `brick/content/`

| Component | Description |
|---|---|
| `BrickPageScreen` | Full-page Brick-Way content renderer. |
| `BrickBottomSheetScreen` | Bottom sheet Brick-Way renderer. |
| `BrickDialogScreen` | Dialog Brick-Way renderer. |
| `BrickHostLoadingHelper` | Manages the loading state during host handshake. |
