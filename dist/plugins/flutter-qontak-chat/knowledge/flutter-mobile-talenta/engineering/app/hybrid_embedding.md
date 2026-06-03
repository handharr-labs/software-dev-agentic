---
platform: flutter
project: flutter-mobile-talenta
discipline: engineering
topic: app
pattern: hybrid_embedding
---

## Theory

Talenta runs Flutter as a guest module embedded inside the native Android/iOS Talenta host. The `brick_way` package provides the MethodChannel abstraction — the guest never calls `MethodChannel` directly.

**Key files:**

| File | Role |
|---|---|
| `talenta/lib/src/brick/brick_module.dart` | `TalentaModule` — `BrickModule` impl, declares routes and DI bindings |
| `talenta/lib/src/brick/brick_router.dart` | `TalentaModuleRouter` — resolves `brick://` URI to a `BrickWidget` |
| `talenta/lib/src/brick/brick_executor.dart` | `TalentaModuleExecutor` — headless execution path, returns `ExecutorResponse` |
| `talenta/lib/src/brick/brick_constants.dart` | Module host constant (`moduleHost`) — must match host's engine config |
| `talenta/lib/src/brick/brick_app.dart` | `BrickApp` — root widget wrapping all guest content |
| `talenta/lib/src/shared/core/module/module_manager.dart` | `TalentaModuleManager` — maps base routes to sub-module handlers |

## Code Pattern

```dart
// Guest → Host: return data, error, or native action
BricksChannel.sendResponse(data: {...});
BricksChannel.sendResponse(error: {...});
BricksChannel.sendActionRequest(
  actionName: 'openPage',
  actionData: {'page': {'ios': 'NativeClassName', 'android': 'co.talenta.NativeActivity'}},
);
```

```dart
// Receiving HostParams (arrive as ?hostParam= in the URI)
final argument = getArgument(uri)['hostParam'] ?? '';
final Map<String, dynamic> hostJson = json.decode(argument); // synchronous

final authJson   = hostJson[Constants.authenticationJson];
final userJson   = hostJson[Constants.userJson];
final toggleJson = hostJson[Constants.toggleJson];
final flagJson   = hostJson[Constants.featureFlagJson];

// Required before rendering any feature screen
await ExternalDataSourceHelper.initializeConfig(
  externalDataSource: ...,
  prefHelper: ...,
  userJson: userJson,
  toggleJson: toggleJson,
  authenticationJson: authJson,
  featureFlagJson: flagJson,
  hostType: hostType,
  mekariLogManager: ...,
);
```

## Definition

**MethodChannel constants** (`com.mekari.module`):

| Message | Direction | Purpose |
|---|---|---|
| `open` | host → guest | render URI as full-screen page |
| `execute` | host → guest | run URI headlessly |
| `sendResponse` | guest → host | return data or error |
| `sendActionRequest` | guest → host | request native action |
| `is24HourFormat` | guest → host | query device locale format (sync) |

**Adding a new guest module:**
1. Create sub-module with routes, BLoC, and DI
2. Register routes in `getResolvingModule(baseRoute)` in module manager
3. Add DI init in `initializeModuleDependencies()` if sub-module has own DI
4. Declare routes in `TalentaModule.routes` getter (consumed by `BrickRouter`)
5. Ensure both `BrickRouter.getTarget()` and `BrickExecutor.execute()` call `ExternalDataSourceHelper.initializeConfig()`
6. Coordinate `moduleHost` value in `brick_constants.dart` with host team — must match host's `ENGINE_ID` exactly
