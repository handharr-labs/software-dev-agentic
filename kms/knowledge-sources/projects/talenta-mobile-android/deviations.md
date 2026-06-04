# Deviations from Standard Android Clean Architecture — talenta-mobile-android

## 1. All API interfaces in the `data/` shared module, not per-feature
**Standard:** Each feature module owns its Retrofit interface.
**Actual:** All 40+ `*Api.kt` interfaces live in `data/src/main/java/co/talenta/data/service/api/`. Feature modules consume them via DI from `data/`.
**Impact:** Feature modules cannot be fully self-contained. Adding a new feature requires modifying the shared `data/` module.

## 2. EndpointConstants as a single flat object
**Standard:** Endpoint strings are co-located with their API interface or in per-feature constants.
**Actual:** A single `EndpointConstants` object in the `data/` module (~260 lines) holds all endpoint paths for all features.
**Impact:** Merge conflicts when multiple features add endpoints simultaneously; no namespacing to prevent typos or naming collisions.

## 3. Mixed RxJava 3 and Kotlin Coroutines
**Standard:** Pick one async paradigm and apply it consistently.
**Actual:** RxJava 3 is the primary pattern. Coroutines exist selectively in some modules (`AGENTS.md` acknowledges: "Coroutines appear selectively—extend only when convention already exists").
**Impact:** Inconsistent mental model; coroutines-only features cannot trivially compose with RxJava-based use cases without bridging.

## 4. Domain module contains a Firebase API interface
**Standard:** Domain layer has no infrastructure dependencies.
**Actual:** `domain/src/main/java/co/talenta/domain/service/FeedbackFirebaseApi.kt` defines a Firebase-backed API interface directly in the domain layer.
**Impact:** Domain layer has a dependency on a Firebase data source, violating the Clean Architecture boundary (Presentation → Domain ← Data).

## 5. ViewModel usage mixed into MVP codebase
**Standard:** The codebase uses MVP (Presenter/View). ViewModel is an MVVM construct.
**Actual:** `FragmentViewModel` exists in `base/` and `lib_core_mekari_pixel` for ViewPager tab state. `showcase_app` uses ViewModel extensively (but is not production code). The `AGENTS.md` acknowledges "Use ViewModel only where established."
**Impact:** Inconsistent UI pattern; developers must know per-module which pattern applies.

## 6. Legacy presenter classes alongside modern base
**Standard:** One unified presenter base class.
**Actual:** `BaseLegacyPresenter`, `IBasePresenter`, and `IBaseView` in `app/src/main/java/co/talenta/base/` coexist alongside the modern `BasePresenter` and `MvpView` in the `base/` module.
**Impact:** Feature modules that haven't been migrated still reference the legacy interfaces; mixed patterns across features.

## 7. Offline portal mode duplicates CICO logic
**Standard:** CICO logic lives once in the live attendance domain.
**Actual:** `PortalApi` and `OfflinePortalApi` independently re-declare attendance-related endpoints (e.g., `postLiveAttendance`, `postLiveAttendanceV2`, `getDataLiveAttendance`) that overlap with `LiveAttendanceApi`.
**Impact:** Bug fixes to CICO logic may need to be applied in multiple API/repository implementations.

## 8. Custom header abuse as API versioning mechanism
**Standard:** API versioning via URL paths or `Accept` header with media type versioning.
**Actual:** Custom boolean headers (`V2`, `V3`, `IS_FULL_RESPONSE`, `IS_NEW_FORMAT`, `X-Feature-Version`) are used to select endpoint behavior or response shape.
**Impact:** Non-standard; interceptor must read and transform these fake headers before forwarding requests to the real API; increases hidden complexity in `TalentaRequestInterceptor`.

## 9. Kong gateway adds a second API routing layer
**Standard:** Single base URL for all API calls.
**Actual:** Some endpoints are routed through a Kong API gateway. Separate API interfaces exist for Kong-routed versions (`KongLiveAttendanceApi`, `KongLiveAttendanceLegacyApi`). A `DataConstants.IS_FROM_KONG` header and `SessionConstants.forceKongService` flag control routing.
**Impact:** Dual implementations for some features; developers must know per-endpoint whether Kong or direct routing is used.

## 10. Proguard rules in root `app/` module only
**Standard:** Each module ships its own consumer ProGuard rules.
**Actual:** A single `proguard-rules.pro` in `app/` covers all modules.
**Impact:** Library modules obfuscation rules are centrally managed; easy to miss rules when adding new SDK modules.
