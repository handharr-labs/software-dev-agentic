---
platform: flutter
project: flutter-qontak-chat
discipline: engineering
topic: app
pattern: module_communication
---

## Theory

Feature packages must NOT directly depend on each other. Two patterns for cross-feature sharing:
- **Typedef Callback Injection** — for UI/behavior (primary pattern in `mobile-qontak-chat`)
- **Module API** — for data sharing across features

## Code Pattern

### Typedef Callback Injection

Feature package declares a typedef for what it needs; the app wires the concrete implementation at DI registration:

```dart
// In chat_composer package — declares what it needs
typedef GetVideoViewerFn = Widget Function({required String videoPath});
typedef GetDocumentViewerFn = Widget Function({required String filePath});

// In chat_di.dart — the app provides implementations
ComposerDependency.registerComposer(
  getVideoViewer: _getVideoViewer,
  getDocumentViewerWidget: _getDocumentViewerWidget,
  getPreviewBubbleWidget: _getPreviewBubbleWidget,
);

static Widget _getVideoViewer({required String videoPath}) =>
    VideoViewer(videoPath: videoPath);
```

### Module API Pattern

For data sharing — Feature B exposes an abstract API in `[prefix]_core`; Feature A injects the abstraction:

```dart
// Step 1 — Abstract API in core
abstract class EmployeeModuleApi {
  Future<EmployeeDetail?> getEmployeeDetail(String empId);
  String getEmployeeIdFormat();
}

// Step 2 — Implementation in the owning feature
@LazySingleton(as: EmployeeModuleApi)
class EmployeeModuleApiImpl implements EmployeeModuleApi { ... }

// Step 3 — Consumer injects the abstraction (no direct dep on employee package)
@injectable
class PayslipBloc extends Bloc<PayslipEvent, PayslipState> {
  PayslipBloc(this._getPayslips, this._employeeApi) : super(...);
  final EmployeeModuleApi _employeeApi;
}
```

### Navigation Between Modules

Modules must not push routes from other modules directly — use an abstract navigation class in core:

```dart
abstract class AuthNavigationApi {
  void goToLogin(BuildContext context);
}

@LazySingleton(as: AuthNavigationApi)
class AuthNavigationApiImpl implements AuthNavigationApi {
  @override
  void goToLogin(BuildContext context) => context.goNamed('login');
}
```

## Definition

| Scenario | Approach |
|---|---|
| Pure utility / formatting logic | Move to `[prefix]_core` directly |
| Data from another feature's DB/API | Module API pattern |
| UI component shared between features | Shared Widget in `[prefix]_core` |
| Cross-feature navigation | Abstract navigation API in core |
| Two features share an entire domain | Merge into one feature module |
