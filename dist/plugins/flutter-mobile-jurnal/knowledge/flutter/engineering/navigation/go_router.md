---
platform: flutter
discipline: engineering
topic: navigation
pattern: go_router
---

## Theory

**Route Constants** are named, centralized identifiers for every navigation destination in the app.

**Invariants:**
- All destination identifiers defined in a single constants file per feature or app — never hard-coded at the call site
- String paths (web/Flutter) or typed class references (Android/iOS) — platform dictates the form, the principle is the same
- Parameterised routes expose a typed helper function/method — callers never construct path strings inline
- Route constants exported from the feature or navigation module — consumers import the constant, not a string literal

**When to create:** Before any screen that navigates to a destination. Constants file created once per feature; entries added as destinations are added.

---

`go_router` is the standard Flutter navigation solution — declarative, deep-link ready. Define all route paths as constants. Never hard-code path strings.

## Code Pattern

```dart
// presentation/navigation/routes.dart
abstract class Routes {
  Routes._();
  static const String login = '/login';
  static const String employees = '/employees';
  static const String employeeDetail = '/employees/:id';
  static String employeeDetailPath(String id) => '/employees/$id';
}
```

```dart
// presentation/navigation/app_router.dart
@singleton
class AppRouter {
  AppRouter({required this.authCubit});
  final AuthCubit authCubit;

  late final router = GoRouter(
    initialLocation: Routes.employees,
    redirect: _guard,
    routes: [
      GoRoute(path: Routes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: Routes.employees,
        builder: (_, __) => const EmployeeListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) => EmployeeDetailScreen(
              employeeId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );

  String? _guard(BuildContext context, GoRouterState state) {
    final isAuthenticated = authCubit.state.isAuthenticated;
    final isOnLoginPage = state.matchedLocation == Routes.login;
    if (!isAuthenticated && !isOnLoginPage) return Routes.login;
    if (isAuthenticated && isOnLoginPage) return Routes.employees;
    return null;
  }
}
```

```dart
// app.dart
MaterialApp.router(routerConfig: getIt<AppRouter>().router)
```
