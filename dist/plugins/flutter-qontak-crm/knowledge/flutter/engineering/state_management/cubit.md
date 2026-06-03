---
platform: flutter
discipline: engineering
topic: state_management
pattern: cubit
---

## Theory

A **StateHolder** is the single source of truth for a screen's UI state — in Flutter, a Cubit is a simplified StateHolder with no events, only direct method calls.

**Invariants:**
- Depends on use case interfaces only — never calls repositories or data sources directly
- Exposes state as a stream — UI observes, never mutates
- One StateHolder per screen — use `@lazySingleton` only for globally shared state (theme, locale)

---

Use Cubit when there are no events — only direct method calls. Simpler than BLoC for state toggles and shared global state.

Use `@lazySingleton` for shared state (theme, locale). Use `@injectable` for per-screen state.

## Code Pattern

```dart
// presentation/cubits/theme_cubit.dart
@lazySingleton
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  void setLight() => emit(ThemeMode.light);
  void setDark() => emit(ThemeMode.dark);
  void toggle() => emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
}
```
