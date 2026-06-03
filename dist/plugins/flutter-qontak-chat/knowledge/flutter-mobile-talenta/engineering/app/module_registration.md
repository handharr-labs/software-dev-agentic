---
platform: flutter
project: flutter-mobile-talenta
discipline: engineering
topic: app
pattern: module_registration
---

## Theory

Flutter features in Talenta are registered as explicit modules via `BaseModule` + `TalentaModuleManager`. Each feature owns one `BaseModule` subclass; the manager holds the registry. Route factories delegate all page construction.

## Code Pattern

```dart
// Step 1 — Create the route constants
// talenta/lib/src/features/{feature}/utils/navigation/{feature}_route.dart
abstract class {Feature}Route {
  static const String root = '/{feature}';
  static const String detail = '/{feature}/detail';
}
```

```dart
// Step 2 — Create the route factory
// talenta/lib/src/features/{feature}/utils/navigation/{feature}_route_factory.dart
class {Feature}RouteFactory {
  static Widget? getPageByName(String name, {Map<String, dynamic>? args}) {
    switch (name) {
      case {Feature}Route.root:
        return {Feature}Page();
      case {Feature}Route.detail:
        return {Feature}DetailPage(id: args?['id'] as String? ?? '');
      default:
        return null;
    }
  }

  static List<RouteProvider>? getListProviderByName(String name) {
    switch (name) {
      case {Feature}Route.root:
        return [{Feature}BlocProvider()];
      default:
        return null;
    }
  }
}
```

```dart
// Step 3 — Create the feature module
// talenta/lib/src/features/{feature}/{feature}.dart
import 'package:talenta_core/talenta_core.dart';

class {Feature}Module extends BaseModule {
  @override
  String get name => '{feature}';

  @override
  Widget? getPageByName(String name, {Map<String, dynamic>? args}) =>
      {Feature}RouteFactory.getPageByName(name, args: args);

  @override
  List<RouteProvider>? getListProviderByName(String name) =>
      {Feature}RouteFactory.getListProviderByName(name);
}
```

```dart
// Step 4 — Register in TalentaModuleManager
// talenta/lib/src/shared/core/module/module_manager.dart
class TalentaModuleManager {
  static final List<BaseModule> _modules = [
    // existing modules...
    {Feature}Module(),  // ← add here
  ];
}
```

## Definition

**Rules:**
- One `BaseModule` subclass per feature
- `name` must be unique across all modules — use feature's snake_case identifier
- Module delegates all routing to `{Feature}RouteFactory` — no inline page construction in the module
- Register in `TalentaModuleManager._modules` list — never elsewhere
- No lifecycle logic in the module (`onStart`/`onStop` hooks are not used in Talenta's `BaseModule`)
