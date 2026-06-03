---
platform: flutter
discipline: engineering
topic: error_handling
pattern: error_ui
---

## Theory

The StateHolder maps `DomainError` to an error State that the screen renders:

- **`notFound`** — show empty state with a descriptive message; offer navigation back
- **`validationFailed`** — show inline field errors; keep the form open for correction
- **`unauthorized`** — redirect to login or show a permission denied screen
- **`networkUnavailable`** — show offline banner with retry action
- **`serverError`** — show generic error with retry; log for observability

**Never show raw error messages or stack traces to users.** The StateHolder decides the user-facing copy; the Screen renders it.

---

Two patterns: inline error in `BlocBuilder` for blocking errors (full-screen), `BlocListener` toast/snackbar for non-blocking errors.

## Code Pattern

```dart
// Inline error in BlocBuilder
builder: (context, state) {
  if (state.dataState.hasError) {
    return ErrorView(
      message: state.dataState.message ?? 'Something went wrong',
      onRetry: () => context.read<EmployeeBloc>().add(const EmployeeEvent.refreshEmployee()),
    );
  }
  // ...
}
```

```dart
// Non-blocking toast via BlocListener
BlocListener<EmployeeBloc, EmployeeState>(
  listenWhen: (prev, curr) =>
      prev.submitState != curr.submitState && curr.submitState.hasError,
  listener: (context, state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.submitState.message ?? 'Failed'),
        backgroundColor: Colors.red,
      ),
    );
  },
  child: ...,
)
```
