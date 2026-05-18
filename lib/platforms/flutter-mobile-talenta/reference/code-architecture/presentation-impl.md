# Flutter — Presentation Layer

> Concepts and invariants: `reference/code-architecture/presentation-theory.md`. This file covers Dart syntax and Flutter-specific patterns.

BLoC pattern for state management. Widgets are dumb — they react to state and dispatch events. Business logic lives in BLoCs via use cases.

---

## Dependency Rule <!-- 8 -->

Presentation depends on Domain only — no Data layer imports. BLoC and Screen widgets may only import domain use case interfaces, domain entities, and Dart/Flutter primitives.

Forbidden: any `RepositoryImpl`, `DataSourceImpl`, `DTO`, mapper, `http`/`dio` import, or database type inside the Presentation layer.

---

## StateHolder <!-- 12 -->

In Flutter, the StateHolder is implemented as a **BLoC** (for event-driven flows) or **Cubit** (for simpler state). See `## BLoC` and `## Cubit (Simpler Alternative)` below for full implementation patterns.

Invariants:
- Receives use cases via constructor injection — annotated `@injectable`, created fresh per screen via `getIt`
- Emits immutable `State` objects — never mutates state in place; use `emit(state.copyWith(...))`
- Handles navigation as a side effect via `BlocListener` — not as a direct `Navigator.push` call inside the BLoC
- One BLoC/Cubit per screen — scoped to the screen's `BlocProvider`

---

## State <!-- 11 -->

In Flutter, **State** is an immutable `@freezed` class with a `ViewDataState<T>` field per async operation. See `## States` below for the full pattern.

Invariants:
- Immutable — produced by the BLoC via `emit`; widgets observe, never mutate
- One `ViewDataState<T>` per distinct async operation — no raw `isLoading` booleans
- No widget types — no `Color`, `Widget`, `BuildContext` in state classes

---

## Events / Input <!-- 11 -->

In Flutter (BLoC), Events are `@freezed sealed class` cases dispatched by the widget via `context.read<XBloc>().add(XEvent.loadX())`. In Cubit, they are direct method calls. See `## Events` below.

Invariants:
- Named after user actions using verb + noun — `loadEmployee`, `submitForm`, not `buttonTapped`
- Carry only the data needed — no `BuildContext`, no raw widget references
- Processed by the BLoC's `on<Event>` handler — widgets never act on events directly

---

## Actions / Output <!-- 11 -->

In Flutter, Actions/Output are navigation and one-time side effects handled via `BlocListener`. See `## BlocListener (Side Effects)` below.

Invariants:
- One-shot — triggered by a state transition (e.g. `updateState.isLoaded`), consumed once in `BlocListener`
- Named after the outcome — navigate, show snackbar, close dialog
- Navigation targets are abstract — the BLoC transitions state; the `BlocListener` in the widget decides *how* to navigate

---

## StateHolder Contract <!-- 11 -->

Before `builder-ui-worker` writes the Screen, `builder-feature-worker` produces `.claude/runs/<feature>/stateholder-contract.md` containing:
- BLoC/Cubit class name and file path
- `State` fields (name, type, purpose)
- `Event` cases or Cubit method signatures (name, payload if any)
- Navigation side-effect triggers (which state transition causes navigation)
- DI factory (`@injectable` or `@lazySingleton`)

---

## Creation Order <!-- 10 -->

```
Use Cases → BLoC/Cubit (StateHolder) → StateHolder contract → Screen (builder-ui-worker)
```

Never write the Screen before the StateHolder contract exists.

---

## Layer Invariants <!-- 10 -->

- BLoC/Cubit never imports from the data layer — no DTOs, no `RepositoryImpl`, no `DataSource`
- Use cases injected via constructor — never `GetEmployeeUseCase()` inside a BLoC body
- State is read-only from widgets' perspective — widgets observe via `BlocBuilder`, never mutate
- Navigation side effects are one-shot — triggered via `BlocListener`, not stored in persistent state
- Navigation decisions belong to the widget layer — BLoC transitions state; the listener navigates

---

## State Management <!-- 63 -->

A generic state wrapper for async data operations. Used in every BLoC state that holds fetched or submitted data.

```dart
// presentation/states/view_data_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/errors/failure.dart';

enum ViewState { initial, loading, loaded, error, empty }

class ViewDataState<T> extends Equatable {
  const ViewDataState._({
    required this.status,
    this.data,
    this.message,
    this.failure,
  });

  final ViewState status;
  final T? data;
  final String? message;
  final Failure? failure;

  // Factory constructors
  factory ViewDataState.initial() =>
      const ViewDataState._(status: ViewState.initial);

  factory ViewDataState.loading({String? message}) =>
      ViewDataState._(status: ViewState.loading, message: message);

  factory ViewDataState.loaded({T? data}) =>
      ViewDataState._(status: ViewState.loaded, data: data);

  factory ViewDataState.error({
    required String message,
    Failure? failure,
    T? data,
  }) =>
      ViewDataState._(
        status: ViewState.error,
        message: message,
        failure: failure,
        data: data,
      );

  factory ViewDataState.empty({String? message}) =>
      ViewDataState._(status: ViewState.empty, message: message);

  // Convenience getters
  bool get isInitial => status == ViewState.initial;
  bool get isLoading => status == ViewState.loading;
  bool get isLoaded => status == ViewState.loaded;
  bool get hasError => status == ViewState.error;
  bool get isEmpty => status == ViewState.empty;

  @override
  List<Object?> get props => [status, data, message, failure];
}
```

---

## Events <!-- 37 -->

Sealed classes with freezed. Name with **verb + noun** pattern.

```dart
// presentation/blocs/employee_event.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee_event.freezed.dart';

@freezed
sealed class EmployeeEvent with _$EmployeeEvent {
  const factory EmployeeEvent.loadEmployee({
    required String employeeId,
  }) = LoadEmployee;

  const factory EmployeeEvent.refreshEmployee() = RefreshEmployee;

  const factory EmployeeEvent.updateEmployee({
    required String name,
    required String email,
  }) = UpdateEmployee;

  const factory EmployeeEvent.deleteEmployee({
    required String employeeId,
  }) = DeleteEmployee;
}
```

**Event naming:**
- `loadXxx` — initial data fetch
- `refreshXxx` — user-triggered reload
- `submitXxx` / `updateXxx` / `deleteXxx` — mutations
- `selectXxx` / `filterXxx` / `searchXxx` — UI state changes

---

## States <!-- 33 -->

Single immutable state class per BLoC. Use `ViewDataState<T>` for each async operation.

```dart
// presentation/blocs/employee_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/employee_entity.dart';
import '../states/view_data_state.dart';

part 'employee_state.freezed.dart';

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

**State rules:**
- One `ViewDataState<T>` per distinct async operation
- `copyWith` for partial updates (provided by freezed)
- No raw booleans like `isLoading` / `hasError` — use `ViewDataState`

---

## BLoC <!-- 88 -->

```dart
// presentation/blocs/employee_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/employee/get_employee_usecase.dart';
import '../../domain/usecases/employee/update_employee_usecase.dart';
import '../states/view_data_state.dart';
import 'employee_event.dart';
import 'employee_state.dart';

@injectable
class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  EmployeeBloc({
    required this.getEmployeeUseCase,
    required this.updateEmployeeUseCase,
  }) : super(EmployeeState.initial()) {
    on<LoadEmployee>(_onLoadEmployee);
    on<UpdateEmployee>(_onUpdateEmployee);
  }

  final GetEmployeeUseCase getEmployeeUseCase;
  final UpdateEmployeeUseCase updateEmployeeUseCase;

  Future<void> _onLoadEmployee(
    LoadEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(employeeState: ViewDataState.loading()));

    final result = await getEmployeeUseCase(event.employeeId);

    result.fold(
      (failure) => emit(state.copyWith(
        employeeState: ViewDataState.error(
          message: failure.message,
          failure: failure,
        ),
      )),
      (employee) => emit(state.copyWith(
        employeeState: ViewDataState.loaded(data: employee),
      )),
    );
  }

  Future<void> _onUpdateEmployee(
    UpdateEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(updateState: ViewDataState.loading()));

    final currentEmployee = state.employeeState.data;
    if (currentEmployee == null) return;

    final params = UpdateEmployeeParams(
      id: currentEmployee.id,
      name: event.name,
      email: event.email,
    );

    final result = await updateEmployeeUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        updateState: ViewDataState.error(
          message: failure.message,
          failure: failure,
        ),
      )),
      (updated) => emit(state.copyWith(
        employeeState: ViewDataState.loaded(data: updated),
        updateState: ViewDataState.loaded(),
      )),
    );
  }
}
```

**BLoC rules:**
- `@injectable` — created fresh per screen via DI
- `on<Event>(_handler)` for each event
- Each handler emits loading first, then result
- Always use `result.fold()` — never `result.getOrElse()` alone
- Use `Emitter<State>` parameter — never call `emit()` directly after `await` in closed blocs

---

## Cubit (Simpler Alternative) <!-- 32 -->

Use Cubit when there are no events — only method calls.

```dart
// presentation/cubits/theme_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  void setLight() => emit(ThemeMode.light);
  void setDark() => emit(ThemeMode.dark);
  void toggle() => emit(
        state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
      );
}
```

**BLoC vs Cubit decision:**

| Use BLoC | Use Cubit |
|----------|-----------|
| Complex event-driven flows | Simple state toggles |
| Multiple event handlers | 1-3 method calls |
| Events with payloads | No input needed |
| Needs event replay/transformation | Immediate state updates |

---

## Screen Structure <!-- 59 -->

```dart
// presentation/screens/employee_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../di/injection.dart';
import '../blocs/employee_bloc.dart';
import '../blocs/employee_event.dart';
import '../blocs/employee_state.dart';
import '../widgets/employee_content.dart';

class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({super.key, required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // getIt creates a fresh BLoC instance
      create: (_) => getIt<EmployeeBloc>()
        ..add(EmployeeEvent.loadEmployee(employeeId: employeeId)),
      child: const _EmployeeView(),
    );
  }
}

class _EmployeeView extends StatelessWidget {
  const _EmployeeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee')),
      body: BlocBuilder<EmployeeBloc, EmployeeState>(
        buildWhen: (prev, curr) =>
            prev.employeeState != curr.employeeState,
        builder: (context, state) {
          final s = state.employeeState;
          if (s.isLoading || s.isInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (s.hasError) {
            return Center(child: Text(s.message ?? 'Error'));
          }
          if (s.data == null) {
            return const Center(child: Text('Not found'));
          }
          return EmployeeContent(employee: s.data!);
        },
      ),
    );
  }
}
```

---

## BlocListener (Side Effects) <!-- 34 -->

Use `BlocListener` for navigation, toasts, dialogs — one-time reactions not reflected in UI.

```dart
BlocListener<EmployeeBloc, EmployeeState>(
  listenWhen: (prev, curr) => prev.updateState != curr.updateState,
  listener: (context, state) {
    if (state.updateState.isLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updated successfully')),
      );
      Navigator.of(context).pop();
    }
    if (state.updateState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.updateState.message ?? 'Failed')),
      );
    }
  },
  child: ...,
)
```

**BlocBuilder vs BlocListener:**

| Use | When |
|-----|------|
| `BlocBuilder` | Rebuild widgets based on state |
| `BlocListener` | Side effects: navigate, show toast, analytics |
| `BlocConsumer` | Both in the same widget tree |

---

## MultiBlocProvider <!-- 22 -->

For screens needing multiple BLoCs:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (_) => getIt<EmployeeBloc>()
        ..add(EmployeeEvent.loadEmployee(employeeId: id)),
    ),
    BlocProvider(
      create: (_) => getIt<AttendanceBloc>()
        ..add(const AttendanceEvent.loadHistory()),
    ),
  ],
  child: const _DashboardView(),
)
```

---

## State Access from Child Widgets <!-- 18 -->

```dart
// In a child widget — read without listening
final bloc = context.read<EmployeeBloc>();
bloc.add(const EmployeeEvent.refreshEmployee());

// Watch — rebuilds on every state change
final state = context.watch<EmployeeBloc>().state;

// Select — rebuilds only when selected value changes
final isLoading = context.select<EmployeeBloc, bool>(
  (bloc) => bloc.state.employeeState.isLoading,
);
```

---

## Shared Component Paths <!-- 11 -->

When running a Component Reuse Check, search these locations for existing reusable widgets:

| Scope | Path | File pattern |
|---|---|---|
| Shared core widgets (cross-feature) | `talenta/lib/src/shared/core/` | `*.dart` |
| Feature screens | `talenta/lib/src/features/*/presentation/screens/` | `*_screen.dart` |
| Feature widgets | `talenta/lib/src/features/*/presentation/widgets/` | `*_widget.dart` |

**Search strategy:** Grep for the widget concept (e.g. `"Card"`, `"Avatar"`, `"EmptyState"`, `"ListItem"`) across `shared/core/` first — widgets there are safe to reuse cross-feature. Only look inside a feature's own `widgets/` folder for local reuse within the same feature. Prefer a `StatelessWidget` found in shared over creating a new one.
