---
name: auditor-arch-check
description: Check Flutter/Dart-specific Clean Architecture rules for mobile-jurnal — layer import direction, BLoC patterns, get_it/manual DI usage, naming conventions. Called by auditor-arch-review-worker.
user-invocable: false
tools: Read, Glob, Grep
---

Check the provided files against flutter-mobile-jurnal architecture rules. Report violations with file path and fix.

## Layer Import Rules

- Presentation may import domain and jurnal_core — never data layer directly
- Domain must not import data or presentation
- Data imports domain (to implement repository interfaces) and jurnal_core — never presentation
- `jurnal_core` is imported as `package:jurnal_core/jurnal_core.dart` — never relative paths to core internals

## BLoC Rules

- BLoC state must use `ViewDataState<T>` from `jurnal_core` for async operations
- Event names follow verb-noun: `Get<Feature>s`, `GetMore<Feature>s`, `Create<Feature>`, `Delete<Feature>`
- Guard against duplicate in-flight events: `if (state.state is ViewDataLoading) return;`
- `result.when(success:, failure:)` — never `result.fold` (project uses `when`)
- BLoC constructor injects UseCases only — never repositories or datasources
- BLoCs are not registered in the injector — instantiated in `BlocProvider.create`

## DI Rules

- No `@injectable` / `@LazySingleton` annotations — manual `GetIt` registration only
- Registration order: Mappers → DataSources → Repositories → UseCases
- `registerSingletonIfAbsent` — never `registerSingleton` (would throw on re-init)
- `coreServiceLocator<T>()` for cross-module core deps; `find<T>()` for intra-feature deps
- BLoCs resolved via `Jurnal<Feature>Injector.find<T>()` in `BlocProvider.create` — never `GetIt.instance.get<T>()` directly in screen files

## Naming Conventions

- Entity: `<Feature>Entity` or domain noun (e.g. `ProductStock`, `ExpenseDetail`)
- Repository interface: `<Feature>RemoteRepository` or `<Feature>LocalRepository`
- Repository impl: `<Feature>RemoteRepositoryImpl`
- DataSource: `<Feature>RemoteDatasource` / `<Feature>RemoteDatasourceImpl`
- Mapper: `<Feature>Mapper`
- UseCase: `<Verb><Feature>UseCase`
- BLoC: `<Feature>Bloc`, State: `<Feature>State`, Event: `<Feature>Event`
- Route class: `Jurnal<Feature>RouteName`, factory: `getJurnal<Feature>RouteByName`
- Injector: `Jurnal<Feature>Injector`

## Data Layer Rules

- `catchError(() async { ... })` wraps every repository method — never manual try/catch
- `Result.success(null)` for nullable results when API returns nothing (not failure)
- Params map: `..removeWhere((_, v) => v == null)` before passing to `NetworkClient`
- Mapper `const` constructor — mappers must be stateless
- `fromJsonToResponse` handles null root key; `responseToEntity` provides defaults for nullable fields

## Test Rules

- Mocks declared with `@GenerateMocks` in same file as usage
- Mock at repository boundary for UseCase tests; at DataSource boundary for Repository tests; at UseCase boundary for BLoC tests
- `result.when(success:, failure:)` assertions — never pattern match directly
- Both success and failure paths for every tested method
