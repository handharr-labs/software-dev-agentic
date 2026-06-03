---
platform: flutter
project: flutter-qontak-chat
discipline: engineering
topic: app
pattern: module_registrar
---

## Theory

Feature modules expose a `BaseModule` implementation. `ModuleRegistrar` aggregates all modules so the app runner has a single registration call. `BaseModule` is defined in `[prefix]_core`.

## Code Pattern

```dart
// shared/[prefix]_core/lib/src/base/base_module.dart
abstract class BaseModule {
  List<RouteBase> routes();
  LocalizationsDelegate<dynamic>? localizationsDelegate();
  List<CollectionSchema> collectionSchemas();
}
```

```dart
// features/[prefix]_auth/lib/src/configs/auth_module.dart
class AuthModule implements BaseModule {
  @override
  List<RouteBase> routes() => [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
      ];

  @override
  LocalizationsDelegate<dynamic>? localizationsDelegate() =>
      AuthLocalizations.delegate;

  @override
  List<CollectionSchema> collectionSchemas() => [];
}
```

```dart
// lib/configs/di/module_registrar.dart
class ModuleRegistrar {
  static final List<BaseModule> _modules = [
    AuthModule(),
    InboxModule(),
    // add new modules here
  ];

  static List<RouteBase> get routes =>
      _modules.expand((m) => m.routes()).toList();

  static List<LocalizationsDelegate<dynamic>> get localizationDelegates =>
      _modules
          .map((m) => m.localizationsDelegate())
          .whereType<LocalizationsDelegate<dynamic>>()
          .toList();

  static List<CollectionSchema> get collectionSchemas =>
      _modules.expand((m) => m.collectionSchemas()).toList();
}
```

```dart
// lib/src/runner.dart
void runApplication() {
  runApp(
    MaterialApp.router(
      routerConfig: GoRouter(routes: ModuleRegistrar.routes),
      localizationsDelegates: [
        ...ModuleRegistrar.localizationDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    ),
  );
}
```

## Definition

- Every feature module implements `BaseModule` exactly once in `src/configs/`
- Return `null` from `localizationsDelegate()` if the module has no translations
- Return `[]` from `collectionSchemas()` if the module has no local DB tables
- Feature packages declare only `[prefix]_dependencies` as a dependency — never individual packages it re-exports
