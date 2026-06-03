---
platform: flutter
discipline: engineering
topic: dependency_injection
pattern: get_it
---

## Theory

These rules apply regardless of framework (Next.js React Context, Swinject, get_it):

1. **Constructor injection** — dependencies are declared as constructor parameters, never fetched inside a class body
2. **Depend on interfaces, not implementations** — callers reference abstract types; the container resolves the concrete class
3. **No `new` inside business logic** — use cases, StateHolders, and repository implementations never instantiate their own dependencies
4. **Container owns lifecycle** — the DI container decides whether a dependency is a singleton, feature-scoped, or transient; callers never manage this
5. **One container per runtime boundary** — if your platform has multiple runtimes (e.g. server + client), each runtime gets its own container; never share a container across boundaries

---

`get_it` service locator + `injectable` annotation-driven code generation. One DI module per feature.

**Annotation lifecycle:**

| Annotation | Lifecycle | Use For |
|---|---|---|
| `@lazySingleton` | Singleton, created on first access | Repositories, use cases, mappers, datasources |
| `@singleton` | Singleton, created at startup | Core services (auth, analytics) |
| `@injectable` | New instance per `getIt.get()` call | BLoCs, Cubits |
| `@LazySingleton(as: Interface)` | Singleton bound to interface | Repository/datasource implementations |
| `@module` | Abstract class providing external dependencies | Dio, SharedPreferences |

**Never register a BLoC as `@lazySingleton`** — BLoC holds mutable state; every screen must get a fresh instance.

## Code Pattern

```dart
// di/injection.dart
final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
```

```dart
// di/app_module.dart — external dependencies
@module
abstract class AppModule {
  @lazySingleton
  Dio get dio => Dio(BaseOptions(
        baseUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.example.com'),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ))
        ..interceptors.addAll([ErrorInterceptor(), LogInterceptor()]);

  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
```

```dart
// Registration order (leaf nodes first):
// 1. External deps (@module)
// 2. DataSources
// 3. Mappers
// 4. Repositories (@LazySingleton(as: Interface))
// 5. Use Cases (@lazySingleton)
// 6. BLoCs (@injectable)
```

```bash
# Generate after adding/changing annotations
dart run build_runner build --delete-conflicting-outputs
```
