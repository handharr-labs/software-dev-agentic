# Deviations — mobile-talenta

This document records patterns that deviate from Clean Architecture + BLoC conventions, architectural inconsistencies, and notable technical debt.

---

## D1 — `talenta_officeless` data source is a stub

**Location**: `talenta/lib/src/features/talenta_officeless/data/datasources/remote/officeless_remote_data_source.dart`

**Deviation**: `OfficelessRemoteDataSource` and its implementation are empty classes with no methods. The feature only renders a WebView at a URL sourced from the host JSON handshake. There are no domain use cases, no entities, and no repository for this feature.

**Impact**: Any developer assuming the Officeless feature follows Clean Architecture will find no data layer to extend.

---

## D2 — Mixed mapper directory naming (`mapper` vs `mappers`)

**Location**: `talenta_inbox/data/mapper/` and `talenta_inbox/data/mappers/`

**Deviation**: The inbox feature has two mapper directories with different plural forms — both contain real mapper classes. Some features use `mapper/` (singular), others use `mappers/` (plural). The `talenta_tm` feature uses `mappers/` consistently; `talenta_inbox` has both.

**Impact**: Makes scanning for mapper classes inconsistent. New mappers may be placed in either directory.

---

## D3 — Mixed `screen` vs `screens` directory naming

**Location**: `talenta_account/presentation/screen/` (singular) vs `talenta_tm/presentation/screens/` (plural) vs `talenta_performance/presentation/screens/` (plural)

**Deviation**: No consistent convention for the screen directory name across features. `talenta_account` uses `screen/`, while most other features use `screens/`. Within account, there is also `presentation/screens/lms/` (plural) alongside `presentation/screen/`.

**Impact**: Cross-feature navigation or tooling that scans for screens by directory path must handle both names.

---

## D4 — Feature DI containers are separate `GetIt` instances

**Location**: Each feature's `configs/di/` — e.g., `talenta_tm/configs/di/tm_dependencies.dart`

**Deviation**: Each feature module creates its own `GetIt` instance (`GetIt.instance` for TM resolves to `tmDependency`, etc.). Dependencies are not registered in a single shared container. The root app has its own `TalentaDependencies` setup.

**Impact**: A dependency registered in one module is not directly accessible from another. Cross-module dependency sharing requires explicit injection via `BaseModule.initializeDependencies()` or `NetworkClient` constructor passing.

---

## D5 — `fpdart` `Either`/`TaskEither` used only in `talenta_inbox` repositories

**Location**: `talenta_inbox/data/repositories/inbox_details/inbox_details_repository.dart`

**Deviation**: `fpdart` is a declared dependency but functional patterns (`Either`, `TaskEither`) are used only in the inbox feature's repositories. All other features use try/catch with thrown `TalentaException` directly in data sources and no `Either` wrapping at the domain boundary.

**Impact**: `fpdart` is installed but its use is isolated. A developer following the inbox pattern elsewhere will produce inconsistent code. The domain `Failure` entity exists but is only used in inbox.

---

## D6 — Payslip uses three different `NetworkClient` method versions

**Location**: `talenta_payslip/data/datasources/remote/payslip_remote_data_sources.dart`

**Deviation**: The payslip data source calls `networkClient.get()` (v1), `networkClient.get(isV2: true)`, and `networkClient.getV3()` with a `version: 2` parameter — three different versioning mechanisms for what is logically the same payslip endpoint. The v3 approach uses an explicit version parameter; the `isV2` flag is an older boolean toggle.

**Impact**: New payslip-related endpoints require understanding which versioning approach to use. No clear deprecation path is documented.

---

## D7 — `talenta_tnt` has two separate data source directory structures

**Location**: `talenta_tnt/data/data_source/` (singular) and `talenta_tnt/data/data_sources/` (plural)

**Deviation**: TNT has `data/data_source/remote/tnt_remote_data_source.dart` (task CRUD) and separately `data/data_sources/remote/assignee_list_remote_datasource.dart` and `data/data_sources/remote/project/project_remote_datasource.dart`.

**Impact**: The feature's data layer is split across two non-standard directories. Any new data source addition requires a judgment call on which directory to use.

---

## D8 — `ViewDataState` is a generic BLoC state but used inconsistently

**Location**: `shared/core/presentation/blocs/view_data_state.dart`

**Deviation**: `ViewDataState<T>` provides a standard `initial/loading/success/error` pattern, but many feature BLoCs define their own state classes from scratch (e.g., `GetIndexState`, `GetInboxDetailsState`, `GetProjectDetailState`) rather than using or extending `ViewDataState`.

**Impact**: BLoC state shape is inconsistent across features. Some use the shared generic, others define local variants with the same semantics but different class names.

---

## D9 — `talenta_inbox` has legacy `data/mapper/` alongside new `data/mappers/`

**Location**: `talenta_inbox/data/mapper/` (attendance, inbox details mappers) and `talenta_inbox/data/mappers/` (index, post approval, reimbursement, updated form submission mappers)

**Deviation**: Same as D2 but worth noting they coexist within the same feature. The `mapper/` directory appears to contain older mapper files that were not migrated when `mappers/` was introduced.

---

## D10 — `TextInputFormatter` directory uses PascalCase subdirectory name

**Location**: `shared/core/utils/TextInputFormatter/`

**Deviation**: All other directories use snake_case. `TextInputFormatter/` uses PascalCase, which is the Dart class name rather than a directory naming convention.

**Impact**: Minor tooling/linting inconsistency. New formatter files placed here follow a non-standard path.

---

## D11 — `Bloc` is used everywhere — no `Cubit` usage found

**Location**: All feature presentation blocs

**Deviation**: The project imports `flutter_bloc` but exclusively uses the `Bloc<Event, State>` pattern. `Cubit` (which eliminates the event boilerplate for simple state machines) is not used anywhere, even for cases with a single trigger (e.g., simple GET requests).

**Impact**: Adds boilerplate (event class per action) even for simple async fetch operations. No functional consequence, but increases file count significantly.
