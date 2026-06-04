# Architecture Deviations — ios-talenta

Platform: iOS (Swift/UIKit)
Scanned: 2026-06-04

This document records places where the codebase deviates from the intended Clean Architecture pattern, consistency standards, or documented conventions.

---

## 1. Dual Architecture Tracks (Legacy vs. Clean Arch)

**Severity: High**

The codebase has two parallel patterns coexisting:
- **Legacy pattern:** MVC-ish `Controllers/{Feature}/` with `ViewModel`, inline `NetworkMiddleware` calls, and flat file layout. No formal Domain/Data layer separation.
- **Clean Architecture pattern:** `Module/Talenta{Name}/` with `Data/DataSources`, `Data/RepositoriesImpl`, `Domain/UseCase`, `Domain/Repository`, `Presentation/ViewModel`, `Presentation/View`.

Active modules on Clean Arch: `TalentaDashboard`, `TalentaECM`, `TalentaTM` (partial), `TalentaInbox`, `TalentaPayslip`.
Most features (Overtime, TimeOff, ChangeShift, DirectReport, etc.) remain on the legacy track.

**Impact:** Inconsistent patterns across PRs; new features may be added to either track.

---

## 2. Redundant Announcement Implementation

**Severity: Medium**

`Announcement` exists in two places:
- `Controllers/Announcement/` — legacy MVC controllers with `AnnouncementListRequestService`
- `Module/TalentaECM/` — Clean Arch with `AnnouncementRepositoryImpl`, `FetchAnnouncementListUseCase`, `AnnouncementAPIService`

Both are active; `AnnouncementAPIService` (`CoreNetwork`) and legacy `AnnouncementRequest` (`NetworkMiddleware`) are separate call paths to the same backend resource. Feature flag `isEnableAnnouncementRevamp` controls which is shown.

---

## 3. Feature Flag V2 System Not Active

**Severity: Medium**

`Shared/Infrastructure/FeatureFlag/FeatureFlag.swift` contains a Firebase Remote Config-backed V2 system with per-user/company/OS validation rules. The file itself notes: **"NOT IN USE YET"**.

Active feature flags use `MekariFlagCustomProvider` + `MekariFlagResponse` (Flagsmith-based, from the `MekariFlag` private pod).

**Risk:** V2 system may be wired up incompletely; `FeatureFlagKey` only has `flagRevampDashboard`.

---

## 4. Flutter Module Embedded in Native App

**Severity: Medium (intentional but notable)**

`brick_house` Flutter module is embedded via `cocoapods-embed-flutter` (develop/talenta branch). Time Management features and others are delegated to Flutter via `TimeManagementManager`. This creates a dual-runtime dependency (Dart + Swift) and complicates build, update, and debugging workflows.

`BaseCoordinator` carries a `flutterTmManager: TimeManagementManagerProtocol` on every coordinator, coupling all coordinators to the Flutter bridge.

---

## 5. NetworkMiddleware Typed Networks Are Not TargetType Enums

**Severity: Low**

`AttendanceDataRequest`, `TimeOffDataRequest`, `OvertimeNetworkRequest` etc. are `Networks` protocol implementations used via `NetworkMiddleware<N>`. Their endpoint paths are defined inside these classes, not in publicly enumerable `TargetType` enums. This makes it impossible to enumerate attendance/overtime endpoints without reading the full class implementation.

---

## 6. `BaseCoordinator` Carries Non-Navigation Responsibilities

**Severity: Low**

`BaseCoordinator` includes: bottom sheet presentation logic (`presentBottomSheet`), `FloatingPanelController` instance, `ToggleViewModel`, `UserViewModel`, `MekariFlagCustomProvider`, and `TimeManagementManager`. This violates the single-responsibility principle for a coordinator.

---

## 7. `BaseViewController` Hard-codes VC Type Checks for Status Bar Style

**Severity: Low**

`BaseViewController.preferredStatusBarStyle` contains an explicit list of ViewController types checked with `is` operators. Adding a new VC that needs `.default` status bar requires editing this base class.

---

## 8. `OldDashboardRequest` Is Not Deleted Despite "Old" Prefix

**Severity: Low**

`Services/NetworkService/OldDashboardRequest.swift` (enum `OldDashboardRequest`) still exists alongside the Clean Arch `TalentaDashboard` module. It handles dashboard, inbox, and approval endpoints. It is unclear whether it is still called or can be deleted.

---

## 9. Two `RequestChangeShiftViewController` Files

**Severity: Low**

There are two files at:
- `Controllers/ChangeShift/Request/RequestChangeShiftViewController.swift`
- `Controllers/ChangeShift/Request/Views/RequestChangeShiftViewController.swift`

Likely a migration in progress; the older file should be removed.

---

## 10. Debug Tools Gated by Build Config but Not Removed from Binary Metadata

**Severity: Low**

`Wormholy` and `FLEX` are excluded from Release builds via `:configurations` in Podfile. `APICallTrackerViewController`, `DebugAPITracker`, and `UserDefaultsCacheViewController` are compiled into the main target without conditional compilation guards — they may be reachable if navigation is constructed at runtime.

---

## 11. `TalentaBaseViewController` and `BaseViewController` Both Exist

**Severity: Low**

Two base view controllers coexist:
- `BaseViewController` (older, 2019) — `CustomNavigationBar`, status bar, toggle/user VMs
- `TalentaBaseViewController` (newer, 2025) — RxSwift disposeBag, interactive pop gesture, left bar button observables

Migration to the newer base is incomplete; features use either one.

---

## 12. Cartfile + Podfile (Dual Dependency Managers)

**Severity: Low**

Both `Cartfile` and `Podfile` exist at the repo root. Carthage is present alongside CocoaPods. The main Podfile covers all major dependencies; it is unclear whether Carthage is still used for any active framework or is a historical artifact.
