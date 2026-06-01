---
name: debugger-add-logs
description: Add structured debug logging to flutter-mobile-jurnal code — BLoC state changes, network calls, mapper inputs/outputs.
user-invocable: false
---

Add debug logging following the logging conventions in `.claude/reference/code-architecture/utilities-impl.md ## Logger section`.

## Steps

1. **Grep** `.claude/reference/code-architecture/utilities-impl.md` for `## Logger`
2. **Read** the file being instrumented
3. **Add** log statements at the identified probe points
4. **Confirm** no log statements are left in production code paths unintentionally

## Log Probe Points

**BLoC event handlers:**
```dart
Future<void> _onLoad(Get<Feature>s event, Emitter<<Feature>State> emit) async {
  Log.d('[<Feature>Bloc] _onLoad: searchKey=${event.searchKey}');
  // ... handler body
  result.when(
    success: (data) {
      Log.d('[<Feature>Bloc] _onLoad success: itemCount=${data?.items.length}');
      // ...
    },
    failure: (f) {
      Log.e('[<Feature>Bloc] _onLoad failure: ${f.message}', f, f.stackTrace);
      // ...
    },
  );
}
```

**Repository impl (pre/post datasource call):**
```dart
Future<Result<<Entity>?>> get<Entity>(int id) =>
    catchError(() async {
      Log.d('[<Feature>Repo] get<Entity>: id=$id');
      final response = await datasource.get<Entity>(id);
      Log.d('[<Feature>Repo] get<Entity> response: ${response?.runtimeType}');
      // ...
    });
```

**Mapper (for mapping errors):**
```dart
<Entity> responseToEntity(<Feature>Response response) {
  Log.d('[<Feature>Mapper] responseToEntity: id=${response.id}');
  return <Entity>(...);
}
```

## Log Methods

- `Log.d(message)` — debug (verbose, remove before merge)
- `Log.i(message)` — info (significant lifecycle events)
- `Log.w(message)` — warning (unexpected but recoverable)
- `Log.e(message, error, stackTrace)` — error (failures, exceptions)

## Output

List all files modified and all log statements added with their probe point descriptions.
