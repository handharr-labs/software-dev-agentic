---
platform: flutter
discipline: engineering
topic: utilities
pattern: logger
---

## Theory

**Logger** is the centralized logging abstraction with severity levels. All log output goes through this interface.

**Invariants:**
- Severity levels: `debug`, `info`, `warning`, `error` — each with distinct routing (debug stripped in production)
- No `print` / `console.log` / `Log.d` calls at call sites — always use the Logger interface
- Sensitive data (tokens, PII) must never appear in log output
- The implementation routes to Crashlytics or the platform crash reporter for `error`-level events

**When to use:** Any layer that needs diagnostic output. Inject `Logger` — never call the platform logging API directly.

---

Structured logging using the `logger` package. Interface-based so implementation can be swapped per environment. Debug level in development, warning+ in release. Registered via `@LazySingleton(as: AppLogger)`.

## Code Pattern

```dart
// core/logger/app_logger.dart
abstract class AppLogger {
  void debug(String message, {Object? error, StackTrace? stackTrace});
  void info(String message, {Object? error, StackTrace? stackTrace});
  void warning(String message, {Object? error, StackTrace? stackTrace});
  void error(String message, {Object? error, StackTrace? stackTrace});
}

@LazySingleton(as: AppLogger)
class AppLoggerImpl implements AppLogger {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
    level: kReleaseMode ? Level.warning : Level.debug,
  );

  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
```

```dart
// Usage via constructor injection
class EmployeeRepositoryImpl implements EmployeeRepository {
  final AppLogger _logger;
  EmployeeRepositoryImpl(this._logger);

  @override
  Future<Either<Failure, Employee>> getEmployee(String id) async {
    try {
      // ...
    } catch (e, stack) {
      _logger.error('getEmployee failed', error: e, stackTrace: stack);
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
}
```
