# Shared Components — talenta-mobile-android

## MVP Base Classes (`base/` module)

| Class | Package | Description |
|---|---|---|
| `BasePresenter<View : MvpView>` | `co.talenta.base.presenter` | Abstract presenter; manages CompositeDisposable, WeakReference view, ErrorHandler injection; provides `.withState()` RxJava operators for loading state |
| `MvpPresenter<View>` | `co.talenta.base.presenter` | Interface defining `attach`, `detach`, `view` |
| `MvpView` | `co.talenta.base.view` | Interface defining `showLoading()`, `hideLoading()` |
| `BaseLegacyPresenter` | `co.talenta.base` | Legacy presenter base (pre-RxJava 3 migration) |
| `IBasePresenter` | `co.talenta.base` | Legacy presenter interface |
| `IBaseView` | `co.talenta.base` | Legacy view interface |
| `BaseListAdapter` | `co.talenta.base.adapter` | RecyclerView adapter base |
| `BaseViewHolder` | `co.talenta.base.adapter` | ViewHolder base |
| `FragmentViewModel` | `co.talenta.base.view.viewpager` | ViewModel for ViewPager tab fragment management |

## Domain Use Case Base Classes (`domain/` module)

| Class | Description |
|---|---|
| `SingleUseCase<Response, Params>` | Abstract base for Single-returning use cases; applies `SingleTransformer` scheduler, logs success/error |
| `CompletableUseCase<Params>` | Base for fire-and-forget operations |
| `FlowableUseCase<Response, Params>` | Base for stream use cases |
| `MaybeUseCase<Response, Params>` | Base for optional-result use cases |
| `UseCase<T, Params>` | Root base class holding `build()` and `execute()` |

## Error Handling (`base/error/`)

| Class | Description |
|---|---|
| `ErrorHandler` | Interface for view-bound error handling |
| `DefaultErrorHandler` | Default implementation routing errors to view |
| `TalentaErrorHandler` | Talenta-specific error handler with network/auth error routing |
| `WebViewException` / `WebViewHttpException` | Custom exceptions for WebView error surfaces |
| `RapidMethodException` | Prevents double-tap submission |

## Helpers (`base/helper/`)

| Helper | Description |
|---|---|
| `BaseDateHelper` | Date formatting/parsing (JodaTime-based) |
| `PermissionHelper` | Runtime permission request abstraction |
| `NetworkHelper` | Network connectivity check |
| `NotificationHelper` | Local notification creation |
| `TSnackbarHelper` | Top Snackbar display helper |
| `FilterHelper` | Common list filter utilities |
| `ToggleHelper` | Feature toggle evaluation |
| `TimezoneHelper` | Timezone conversion |
| `ImageViewHelper` | Glide image loading wrapper |
| `OfflineCICOHelper` | Offline check-in/check-out storage |
| `MoEngageTrackerHelper` | MoEngage event tracking wrapper |
| `RedirectAppHelper` | Cross-app deep-link helper |
| `RapidCallViewDetector` | Detects rapid repeated UI taps |
| `FeatureTourHelper` | Feature onboarding tooltip management |

## Extensions (`base/extension/`)

| File | Description |
|---|---|
| `ActivityExtension.kt` | Activity-scoped extension functions |
| `FragmentExtension.kt` | Fragment-scoped extension functions |
| `ViewExtension.kt` | View visibility, animations |
| `ContextExtension.kt` | Context-scoped helpers |
| `PagingViewExtension.kt` | Paging3 list state UI helpers |
| `DrawableExtension.kt` | Tinting/drawable utilities |
| `IntExtension.kt` | Int conversion helpers |

## Navigation Abstractions (`base/navigation/`)

Each feature exposes a navigation interface registered via `base/navigation/`:

`AuthNavigation`, `EmployeeNavigation`, `FormNavigation`, `FrontdeskNavigation`, `IntegrationNavigation`, `MekariExpenseNavigation`, `MekariInsightNavigation`, `OvertimeNavigation`, `PayslipNavigation`, `PersonalInfoNavigation`, `PortalNavigation`, `ReprimandNavigation`, `ReviewsNavigation`, `TaskNavigation`, `TimeOffNavigation`, `CalendarNavigation`, `RequestChangeDataNavigation`

## Core Library Shared Utilities

| Component | Module | Description |
|---|---|---|
| `orEmpty()`, `orZero()`, `orFalse()`, `orTrue()` | `lib_core_helper` (`com.mekari.commons.extension`) | Null-safe mapper extensions |
| `NetworkManager` | `lib_core_network` | OkHttp client management, base URL switching |
| `UrlHelper` | `lib_core_network` | URL construction for dev/prod/kong |
| `TalentaGlideModule` | `base/library/glide` | Glide + OkHttp3 integration config |
| `KongToggleManager` | `base/manager/kongtoggle` | Kong feature toggle cache manager |
| `OfflineCICOManager` | `base/manager/offlinecico` | Offline CICO queue management |
| `IntegrityManager` | `base/manager` | Google Play Integrity API wrapper |
| `TalentaNotificationManager` / `TalentaNotificationBuilder` | `base/manager/fcm` | FCM notification construction |
| Mekari Pixel components | `lib_core_mekari_pixel` | Design system components — tabs, app bar, bottom navigation, buttons, dialogs, toasts |
| `ShimmerLoadingConfig` | `base/helper` | Facebook Shimmer config helper |

## Shared Feature Widgets (`feature_shared_live_attendance/`)

| Widget | Description |
|---|---|
| `FetchLocationBottomSheet` | GPS fetch UI (legacy) |
| `MpFetchLocationBottomSheet` | GPS fetch UI (Mekari Pixel) |
| `OutOfRadiusInformationBottomSheet` | Out-of-radius user info |
| `SuggestionBottomSheet` / `MpSuggestionBottomSheet` | Location suggestion selection |
| `LocationConfigManager` | Location accuracy/permission manager for attendance |
