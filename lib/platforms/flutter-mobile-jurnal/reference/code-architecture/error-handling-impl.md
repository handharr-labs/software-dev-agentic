## Error Flow

```
NetworkClient (Dio)
    │ throws DioException / Exception
    ▼
<Feature>RemoteDatasourceImpl
    │ propagates exception (no catch)
    ▼
<Feature>RemoteRepositoryImpl.catchError()      ← BaseRemoteRepository
    │ catches all exceptions
    │ DioException → NetworkFailure(type from status code, trackMKRLog=false)
    │ Exception   → NetworkFailure(type=others, trackMKRLog=true)
    │ returns Result.failure(NetworkFailure)
    ▼
UseCase.call()
    │ passes Result<T> through unchanged
    ▼
BLoC._onLoad()
    │ result.when(failure: (f) => emit(ViewDataFailure(f.toFailure())))
    ▼
UI (BlocBuilder / BlocConsumer)
    │ reads state.state as ViewDataFailure
    │ surfaces failure.message or error widget
```

---

## Error Types

**`NetworkFailure`** (transport layer, `jurnal_core`):
```dart
class NetworkFailure {
  final String message;
  final StackTrace? stackTrace;
  final NetworkFailureType type; // notFound, unauthorized, forbidden, others, ...
}
```

**`Failure`** (domain layer, `jurnal_core`):
```dart
@freezed
abstract class Failure with _$Failure {
  factory Failure.serverFailure(String message, {StackTrace? stackTrace, int? statusCode, String? debugMessage}) = ServerFailure;
  factory Failure.localFailure(String message, {StackTrace? stackTrace, String? debugMessage}) = LocalFailure;
}
```

**`ViewDataFailure`** (presentation layer, `jurnal_core`):
```dart
ViewDataFailure(Failure failure)
```

---

## Error Mapping

- `BaseRemoteRepository.catchError()` catches exceptions and maps to `NetworkFailure` (transport → domain boundary).
- `NetworkFailure.toFailure()` / `Failure.toNetworkFailure()` bridge between the two types when needed.
- `int statusCode → NetworkFailureType` via `.failureStatus` extension: 401 → `unauthorized`, 403 → `forbidden`, 404 → `notFound`, etc.
- `DioException` is caught with `trackMKRLog: false` (expected network error); all other exceptions with `trackMKRLog: true` (unexpected, should be tracked).
- Optional `onError` callback in `catchError(process, onError: ...)` allows recovery (e.g. returning cached data).

---

## Error UI

BLoC state exposes `ViewDataState<T>`. In UI:

```dart
BlocBuilder<<Feature>Bloc, <Feature>State>(
  builder: (context, state) {
    if (state.state is ViewDataLoading) {
      return const CircularProgressIndicator();
    }
    if (state.state is ViewDataFailure) {
      final failure = (state.state as ViewDataFailure).failure;
      // Check access denial specifically:
      if (failure.hasNoAccess) return const NoAccessWidget();
      return ErrorWidget(message: failure.message);
    }
    if (state.state is ViewDataEmpty) return const EmptyWidget();
    if (state.state is ViewDataSuccess) {
      return ContentWidget(data: (state.state as ViewDataSuccess).data);
    }
    return const SizedBox.shrink();
  },
)
```

Pattern variants observed:
- `failure_body.dart` — standalone failure body widget (from `jurnal_report`)
- `error_bottom_sheet.dart` — bottom sheet for error display (from `jurnal_product`)
- `hasNoAccess` extension — used for 403/forbidden early exit to a no-access screen
