---
platform: flutter
project: flutter-mobile-jurnal
discipline: engineering
topic: dependency_injection
pattern: feature_injector
---

## Theory

Jurnal uses `get_it` directly **without `injectable` annotations**. Each feature owns a static `Injector` class that registers all dependencies in a single `init()` method. No `@lazySingleton`, `@injectable`, or `@InjectableInit` — registration is explicit and manual.

BLoCs are **not** registered in the injector. They are instantiated in `BlocProvider.create` by calling `Injector.find<UseCase>()` and passing to the BLoC constructor.

**Deviation from `flutter/` base:** `flutter/` base uses `injectable` code-gen (`@lazySingleton`, `@LazySingleton(as:)`). Jurnal uses `registerSingletonIfAbsent` instead.

## Code Pattern

```dart
// features/{feature}/di/{feature}_injector.dart
class Jurnal{Feature}Injector {
  static final _container = GetIt.instance;

  static Future<void> init() async {
    // 1. Mappers (no dependencies — const constructors)
    _container
      ..registerSingletonIfAbsent<{Feature}Mapper>(
        () => const {Feature}Mapper(),
      );

    // 2. DataSources (depend on NetworkClient and mappers)
    _container
      ..registerSingletonIfAbsent<{Feature}RemoteDatasource>(
        () => {Feature}RemoteDatasourceImpl(
          coreServiceLocator<NetworkClient>(),
          find<{Feature}Mapper>(),
        ),
      );

    // 3. Repositories (depend on datasources and mappers)
    _container.registerSingletonIfAbsent<{Feature}RemoteRepository>(
      () => {Feature}RemoteRepositoryImpl(
        datasource: find<{Feature}RemoteDatasource>(),
        mapper: find<{Feature}Mapper>(),
      ),
    );

    // 4. Use Cases (depend on repositories)
    _container
      ..registerSingletonIfAbsent<Get{Feature}ListUseCase>(
        () => Get{Feature}ListUseCase(find<{Feature}RemoteRepository>()),
      );
  }

  static T find<T extends Object>({String? instanceName}) =>
      _container.get<T>(instanceName: instanceName);
}
```

## Definition

**Rules:**
- `registerSingletonIfAbsent<T>(() => impl)` — idempotent, safe to call multiple times
- `find<T>()` is the module-local resolver (delegates to `GetIt.instance.get<T>()`)
- `coreServiceLocator<NetworkClient>()` resolves cross-module core dependencies
- Named instances for multiple networks: `coreServiceLocator<NetworkClient>(instanceName: JurnalServiceLocatorKeys.networkScm)`
- BLoCs are never registered — pass use cases via `Injector.find<UseCase>()` into `BlocProvider.create`
