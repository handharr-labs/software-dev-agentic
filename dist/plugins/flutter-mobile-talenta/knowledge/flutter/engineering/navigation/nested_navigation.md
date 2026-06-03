---
platform: flutter
discipline: engineering
topic: navigation
pattern: nested_navigation
---

## Theory

**Nested Navigation** preserves a persistent shell (tab bar, side nav, bottom nav) while navigating between child destinations.

**Invariants:**
- Persistent shell defined at the router/coordinator level — not duplicated in each child screen
- Child screens within the shell navigate without destroying the shell (push within the shell, not replace the root)
- Tab selection state owned by the shell — child screens do not manage tab state
- Deep links into a nested route restore the shell correctly — not just the leaf screen

**When to create:** When the app has a persistent navigation structure (tabs, sidebar) with independent navigation stacks per tab.

---

Use `ShellRoute` for persistent navigation bars (bottom nav, tab bars). The shell widget persists across tab changes.

## Code Pattern

```dart
GoRouter(
  routes: [
    ShellRoute(
      builder: (_, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeTab()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileTab()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsTab()),
      ],
    ),
  ],
)
```
