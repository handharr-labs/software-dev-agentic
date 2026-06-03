---
platform: flutter
discipline: engineering
topic: navigation
pattern: navigate_from_bloc
---

## Theory

A **Navigation Action** is the signal emitted by a StateHolder to request navigation without the StateHolder knowing the destination implementation.

**Invariants:**
- Expressed as a typed value in the StateHolder's output (state field, Observable result, or action callback)
- Consumed by the UI layer (BlocListener, Coordinator subscribe, ViewModel hook) — never handled inside the StateHolder
- Cleared after consumption — the UI layer resets the navigation action field so it is not re-triggered on recomposition/re-render
- Carries only the data needed to resolve the destination (IDs, flags) — not the destination itself

**When to create:** Whenever a StateHolder needs to trigger navigation as a result of business logic (e.g., after a successful form submission or a delete confirmation).

---

BLoC never calls `Navigator` directly. It emits a typed `navAction` in state. `BlocListener` in the widget reads it and calls `context.go/push`. Clear the action after handling.

## Code Pattern

```dart
// In BLoC state — add a navigation action field
@freezed
class EmployeeState with _$EmployeeState {
  const factory EmployeeState({
    required ViewDataState<EmployeeEntity> employeeState,
    @Default(null) EmployeeNavAction? navAction,
  }) = _EmployeeState;
}

sealed class EmployeeNavAction {
  const factory EmployeeNavAction.goToEdit(String employeeId) = GoToEditAction;
  const factory EmployeeNavAction.popAfterDelete() = PopAfterDeleteAction;
}
```

```dart
// In Screen
BlocListener<EmployeeBloc, EmployeeState>(
  listenWhen: (prev, curr) => prev.navAction != curr.navAction,
  listener: (context, state) {
    final action = state.navAction;
    if (action == null) return;
    switch (action) {
      case GoToEditAction(:final employeeId):
        context.push(Routes.employeeEditPath(employeeId));
      case PopAfterDeleteAction():
        context.pop();
    }
    context.read<EmployeeBloc>().add(const EmployeeEvent.clearNavAction());
  },
  child: ...,
)
```
