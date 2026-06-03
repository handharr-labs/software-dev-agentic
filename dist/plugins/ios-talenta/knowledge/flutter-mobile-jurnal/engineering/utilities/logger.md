---
platform: flutter
project: flutter-mobile-jurnal
discipline: engineering
topic: utilities
pattern: logger
---

## Theory

Jurnal uses a multi-logger setup in `jurnal_core` — specialized loggers per concern rather than a single `AppLogger` service. No DI registration needed; loggers hook into BLoC observer and Dio interceptors.

**Deviation from `flutter/` base:** `flutter/` base has a single `AppLogger` interface registered via DI. Jurnal uses `Log.d/e/i/w` static calls + specialized `BlocLogger`/`NetworkLogger`/`RouteLogger`.

## Code Pattern

```dart
// Static API — use anywhere without injection
Log.d('Debug message');
Log.i('Info message');
Log.w('Warning message');
Log.e('Error message', error, stackTrace);
```

```dart
// BlocLogger — hooks into BLoC observer for state transition logging
// NetworkLogger — hooks into Dio interceptors for request/response logging
// RouteLogger — hooks into Navigator observer
// All live in: features/jurnal_core/lib/logger/
```
