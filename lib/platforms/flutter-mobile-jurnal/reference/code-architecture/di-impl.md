## DI Principles

Dependency injection uses `get_it` directly without `injectable`. Each feature module owns a static `Injector` class that registers all dependencies for that feature in a single `init()` method.

**Registration order within `init()`:**
1. Mappers (no dependencies — `const` constructors)
2. DataSources (depend on `NetworkClient` and mappers)
3. Repositories (depend on datasources and mappers)
4. Use Cases (depend on repositories)

```dart
class Jurnal<Feature>Injector {
  static final _container = GetIt.instance;

  static Future<void> init() async {
    // 1. Mappers
    _container
      ..registerSingletonIfAbsent<<Feature>Mapper>(
        () => const <Feature>Mapper(),
      );

    // 2. DataSources
    _container
      ..registerSingletonIfAbsent<<Feature>RemoteDatasource>(
        () => <Feature>RemoteDatasourceImpl(
          coreServiceLocator<NetworkClient>(),
          find<<Feature>Mapper>(),
        ),
      );

    // 3. Repositories
    _container.registerSingletonIfAbsent<<Feature>RemoteRepository>(
      () => <Feature>RemoteRepositoryImpl(
        datasource: find<<Feature>RemoteDatasource>(),
        mapper: find<<Feature>Mapper>(),
      ),
    );

    // 4. Use Cases
    _container
      ..registerSingletonIfAbsent<Get<Feature>ListUseCase>(
        () => Get<Feature>ListUseCase(find<<Feature>RemoteRepository>()),
      );
  }

  static T find<T extends Object>({String? instanceName}) =>
      _container.get<T>(instanceName: instanceName);
}
```

**Key rules:**
- `registerSingletonIfAbsent<T>(() => impl)` — idempotent, safe to call multiple times
- `find<T>()` is the module-local resolver (delegates to `GetIt.instance.get<T>()`)
- `coreServiceLocator<NetworkClient>()` is used to resolve cross-module core dependencies
- `coreServiceLocator<NetworkClient>(instanceName: JurnalServiceLocatorKeys.networkScm)` for named instances (SCM, SCM Warehouse networks)
- BLoCs are **not** registered in the injector — they are instantiated in `BlocProvider.create` by calling `Injector.find<UseCase>()` and passing to the BLoC constructor
- No `@injectable` / `@LazySingleton` annotations — registration is manual and explicit
