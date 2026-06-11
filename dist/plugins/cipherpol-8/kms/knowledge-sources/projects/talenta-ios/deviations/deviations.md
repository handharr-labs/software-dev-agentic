---
scope: project/talenta-ios
platform: ios
discipline: engineering
artifact: deviations
---
# Architecture Deviations

## Hybrid Architecture

**Standard:** iOS Clean Architecture projects organise all features in Data/Domain/Presentation layers (Module or Features directory).

**This project:** Two parallel architectures coexist. Legacy features live in `Talenta/Controllers/` as plain UIViewController subclasses backed by `Talenta/ViewModels/` singleton/shared ViewModels. New/migrated features (Dashboard, TM, ECM, Inbox, Payslip, Integration) follow full Clean Architecture in `Talenta/Module/` with separate Data/Domain/Presentation layers and Coordinators.

**Location:** Talenta/Controllers/ (legacy) vs Talenta/Module/ (Clean Architecture)

**Reason (if known):** Incremental migration strategy; legacy features have not yet been refactored.

## NeedleFoundation DI

**Standard:** iOS projects commonly use Swinject, or manual initializer injection through a Composition Root.

**This project:** Uses NeedleFoundation (Uber's compile-time safe DI framework) with `BootstrapComponent`, `Component`, and `Dependency` protocols. The root entry point is `RootComponent: BootstrapComponent`.

**Location:** Talenta/DIComponents/RootComponent.swift, Talenta/DIComponents/MainTab/

**Reason (if known):** NeedleFoundation provides compile-time safety and scales better for large modular apps.

## Flutter Module Embedding

**Standard:** Pure native iOS apps do not embed Flutter engines.

**This project:** A `BrickWrap` layer (`Talenta/BrickWrap/`) embeds a Flutter module (`brick_house`) via `FlutterEngineGroup`. Multiple features (Account, Auth, Calendar, Cashout, EXM, Inbox, Payslip, Performance, Task, TimeManagement) are implemented in Flutter and rendered inside native iOS via `FlutterEngine` and `FlutterViewController`. Method channel communication is handled by `BricksMethodChannel`.

**Location:** Talenta/BrickWrap/, Podfile (brick_house dependency)

**Reason (if known):** Code sharing with other Mekari platforms (Flutter-first features); reduces duplication across iOS/Android.

## Dual Base ViewControllers

**Standard:** Typically one base UIViewController in a project.

**This project:** Two base UIViewController classes exist in parallel: `BaseViewController` (used by legacy Controllers layer, conforms to `CustomNavigationBar`) and `TalentaBaseViewController` (used by Clean Architecture module VCs). `DraggableBottomSheetViewController` extends `TalentaBaseViewController`.

**Location:** Talenta/Shared/Presentation/Base/

**Reason (if known):** Result of incremental migration; legacy and new layers need different base behaviours.

## Moya Networking

**Standard:** iOS apps may use URLSession directly or Alamofire.

**This project:** Uses Moya (~15.0) with RxSwift/Moya integration as the network abstraction layer. All API endpoints are modelled as Swift enums conforming to `TargetType` in `Talenta/Middleware/Network/Interface/`. Reactive pipelines use `RxSwift` and `RxCocoa`.

**Location:** Talenta/Middleware/Network/Interface/, Podfile

**Reason (if known):** Moya provides type-safe endpoint definitions; RxSwift integration aligns with the reactive ViewModel pattern.

## Kong Legacy Endpoint Routing

**Standard:** A single base URL is used per environment.

**This project:** Multiple endpoints branch on `TalentaEnvironment.useKongService` at runtime, returning different paths (e.g., `v2/attendance/companies/...` for Kong vs `live-attendance/...` for legacy). This dual-routing pattern appears across at least 8 endpoints in Interface+Attendance.swift and LiveAttendanceRemoteDataSource.swift.

**Location:** Talenta/Middleware/Network/Interface/Interface+Attendance.swift, Talenta/Module/TalentaTM/Data/DataSource/Remote/LiveAttendanceRemoteDataSource.swift

**Reason (if known):** Gradual migration from a legacy API gateway to Kong API Gateway; both services run simultaneously during the transition period.
