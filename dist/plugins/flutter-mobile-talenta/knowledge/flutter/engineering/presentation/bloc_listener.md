---
platform: flutter
discipline: engineering
topic: presentation
pattern: bloc_listener
---

## Theory

**Actions** (also called Output or SideEffects) represent one-time side effects the StateHolder emits after processing an event.

**Invariants:**
- One-shot — consumed once; not part of persistent state
- Named after the outcome — `NavigateToDetail`, `ShowErrorToast`, `CloseScreen`
- Navigation targets are abstract — the StateHolder says *what*, the UI/navigator decides *how*

In Flutter, `BlocListener` is the mechanism for consuming Actions from a BLoC.

---

`BlocListener` handles one-time side effects — navigation, toasts, dialogs — that are not reflected in the UI rebuild cycle.

| Use | When |
|---|---|
| `BlocBuilder` | Rebuild widgets based on state |
| `BlocListener` | Side effects: navigate, show toast, analytics |
| `BlocConsumer` | Both in the same widget tree |

## Code Pattern

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
