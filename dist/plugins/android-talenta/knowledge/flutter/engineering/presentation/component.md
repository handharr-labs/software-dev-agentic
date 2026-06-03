---
platform: flutter
discipline: engineering
topic: presentation
pattern: component
---

## Theory

A **Component** (also called Sub-view, Widget, or View) is a reusable UI element smaller than a full screen.

**Invariants:**
- Stateless by default — receives data via props/parameters and emits callbacks
- If stateful, bound to a scoped StateHolder — never manages business state inline
- No use case calls — all data passed in from the parent screen or a scoped StateHolder
- Reuse check required before creating — search shared component directories first

**When to create:** When a UI element appears in ≥2 screens, or when a screen section is complex enough to isolate for readability.

---

Reusable presentational widget — BLoC-unaware. Receives plain domain entities via constructor. Shared cross-feature widgets go in `lib/src/shared/core/`.

**Rules:**
- No `BlocProvider`, `BlocBuilder`, or `context.read` inside a component
- `const` constructor — all fields `final`

**Component reuse search paths:**

| Scope | Path |
|---|---|
| Shared core (cross-feature) | `talenta/lib/src/shared/core/` |
| Feature screens | `talenta/lib/src/features/*/presentation/screens/` |
| Feature widgets | `talenta/lib/src/features/*/presentation/widgets/` |

## Code Pattern

```dart
// presentation/widgets/employee_card.dart
class EmployeeCard extends StatelessWidget {
  const EmployeeCard({super.key, required this.employee});
  final EmployeeEntity employee;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(employee.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(employee.email),
          ],
        ),
      ),
    );
  }
}
```
