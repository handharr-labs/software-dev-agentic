---
platform: flutter
discipline: engineering
topic: state_management
pattern: bloc
---

## Theory

A **StateHolder** is the single source of truth for a screen's UI state. Platform names vary (ViewModel, BLoC, Presenter) but the contract is identical across platforms.

**Invariants:**
- Owns no view imports — no UI framework, no widget, no component type
- Depends on use case interfaces only — never calls repositories or data sources directly
- Use cases are injected via DI — never instantiated directly inside the StateHolder
- Exposes state as a read-only stream or observable — UI observes, never mutates
- One StateHolder per screen — never shared across screens unless explicitly scoped

**State** is an immutable snapshot of what the UI should render. **Events** represent user intentions. **Actions** (Output) are one-shot side effects emitted after processing an event.

---

BLoC for event-driven state management. Widgets dispatch events, BLoC handles them via `on<Event>`, emits immutable states. Use cases are injected via constructor.

**Rules:**
- `@injectable` — created fresh per screen via DI, never `@lazySingleton`
- `on<Event>(_handler)` for each event type
- Each handler emits loading first, then result
- Always use `result.fold()` — never `result.getOrElse()` alone
- Never import from data layer — no DTOs, no `RepositoryImpl`

**BLoC vs Cubit:**

| Use BLoC | Use Cubit |
|---|---|
| Complex event-driven flows | Simple state toggles |
| Multiple event handlers | 1-3 method calls |
| Events with payloads | No input needed |
| Needs event replay | Immediate state updates |

## Code Pattern

```dart
// presentation/blocs/employee_event.dart
@freezed
sealed class EmployeeEvent with _$EmployeeEvent {
  const factory EmployeeEvent.loadEmployee({required String employeeId}) = LoadEmployee;
  const factory EmployeeEvent.refreshEmployee() = RefreshEmployee;
  const factory EmployeeEvent.updateEmployee({required String name, required String email}) = UpdateEmployee;
}
```

```dart
// presentation/blocs/employee_state.dart
@freezed
class EmployeeState with _$EmployeeState {
  const factory EmployeeState({
    required ViewDataState<EmployeeEntity> employeeState,
    required ViewDataState<void> updateState,
  }) = _EmployeeState;

  factory EmployeeState.initial() => EmployeeState(
        employeeState: ViewDataState.initial(),
        updateState: ViewDataState.initial(),
      );
}
```

```dart
// presentation/blocs/employee_bloc.dart
@injectable
class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  EmployeeBloc({required this.getEmployeeUseCase, required this.updateEmployeeUseCase})
      : super(EmployeeState.initial()) {
    on<LoadEmployee>(_onLoadEmployee);
    on<UpdateEmployee>(_onUpdateEmployee);
  }

  final GetEmployeeUseCase getEmployeeUseCase;
  final UpdateEmployeeUseCase updateEmployeeUseCase;

  Future<void> _onLoadEmployee(LoadEmployee event, Emitter<EmployeeState> emit) async {
    emit(state.copyWith(employeeState: ViewDataState.loading()));
    final result = await getEmployeeUseCase(event.employeeId);
    result.fold(
      (failure) => emit(state.copyWith(
        employeeState: ViewDataState.error(message: failure.message, failure: failure),
      )),
      (employee) => emit(state.copyWith(
        employeeState: ViewDataState.loaded(data: employee),
      )),
    );
  }
}
```

```dart
// presentation/states/view_data_state.dart
enum ViewState { initial, loading, loaded, error, empty }

class ViewDataState<T> extends Equatable {
  const ViewDataState._({required this.status, this.data, this.message, this.failure});

  final ViewState status;
  final T? data;
  final String? message;
  final Failure? failure;

  factory ViewDataState.initial() => const ViewDataState._(status: ViewState.initial);
  factory ViewDataState.loading({String? message}) =>
      ViewDataState._(status: ViewState.loading, message: message);
  factory ViewDataState.loaded({T? data}) => ViewDataState._(status: ViewState.loaded, data: data);
  factory ViewDataState.error({required String message, Failure? failure, T? data}) =>
      ViewDataState._(status: ViewState.error, message: message, failure: failure, data: data);
  factory ViewDataState.empty({String? message}) =>
      ViewDataState._(status: ViewState.empty, message: message);

  bool get isInitial => status == ViewState.initial;
  bool get isLoading => status == ViewState.loading;
  bool get isLoaded => status == ViewState.loaded;
  bool get hasError => status == ViewState.error;
  bool get isEmpty => status == ViewState.empty;

  @override
  List<Object?> get props => [status, data, message, failure];
}
```
