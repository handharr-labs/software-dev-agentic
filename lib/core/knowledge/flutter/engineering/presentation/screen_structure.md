---
platform: flutter
discipline: engineering
topic: presentation
pattern: screen_structure
---

## Theory

A **Screen** is a full-page view bound to a single StateHolder. It observes state and sends events — it contains no business logic.

**Invariants:**
- Bound to exactly one StateHolder — instantiated via DI, never with direct `new` / `init`
- Observes every State field declared in the StateHolder contract — no State field goes unhandled
- Sends events to the StateHolder for every user interaction — never mutates state directly
- Contains no business logic — conditionals exist only to decide what to render, not what to compute
- No use case calls — all data flows through the StateHolder

**When to create:** One screen per route/destination. Created after the StateHolder contract exists.

---

Screens split into two widgets: outer `Screen` (owns `BlocProvider` + initial event) and inner `_View` (stateless, reads BLoC). Keeps provider wiring separate from rendering.

**Rules:**
- `BlocProvider` in the outer screen widget only
- `getIt<XBloc>()` creates a fresh instance — never `getIt.get()` inside a `BlocBuilder`
- `buildWhen` to limit rebuilds to relevant state slices

## Code Pattern

```dart
// presentation/screens/employee_screen.dart
class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({super.key, required this.employeeId});
  final String employeeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
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
        buildWhen: (prev, curr) => prev.employeeState != curr.employeeState,
        builder: (context, state) {
          final s = state.employeeState;
          if (s.isLoading || s.isInitial) return const Center(child: CircularProgressIndicator());
          if (s.hasError) return Center(child: Text(s.message ?? 'Error'));
          if (s.data == null) return const Center(child: Text('Not found'));
          return EmployeeContent(employee: s.data!);
        },
      ),
    );
  }
}
```
