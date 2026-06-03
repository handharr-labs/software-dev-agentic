---
platform: flutter
discipline: engineering
topic: dependency_injection
pattern: external_dependencies
---

## Theory

| Scope | Use for | Lifetime |
|---|---|---|
| Singleton | Shared infrastructure — HTTP client, token store, logger | App lifetime |
| Feature-scoped | StateHolders and use cases for a single feature | Screen/route lifetime |
| Transient | Stateless helpers, mappers, pure services | Per-resolution |

**Never register a StateHolder as a singleton** — it holds mutable UI state that must be reset when the screen is destroyed.

---

Third-party instances (Dio, SharedPreferences) registered via `@module` abstract class. `@preResolve` tells injectable to await async futures before resolving dependents.

## Code Pattern

```dart
// di/app_module.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class AppModule {
  @lazySingleton
  Dio get dio => Dio(BaseOptions(
        baseUrl: const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://api.example.com',
        ),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ))
        ..interceptors.addAll([
          ErrorInterceptor(),
          LogInterceptor(logPrint: (obj) => debugPrint(obj.toString())),
        ]);

  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
```

```dart
// Environment-based registration (prod vs dev)
@module
abstract class NetworkModule {
  @lazySingleton
  @prod
  Dio get prodDio => Dio(BaseOptions(baseUrl: 'https://api.example.com'));

  @lazySingleton
  @dev
  Dio get devDio => Dio(BaseOptions(baseUrl: 'https://api.staging.example.com'));
}
```

```dart
// main.dart — configure environment at startup
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies(
    environment: const String.fromEnvironment('ENV', defaultValue: 'prod'),
  );
  runApp(const App());
}
```
