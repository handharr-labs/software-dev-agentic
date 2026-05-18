# UI Layer — Flutter Qontak

Platform-specific UI layer patterns. Canonical definitions: `reference/code-architecture/ui-theory.md`.

---

## Dependency Rule <!-- 9 -->

UI depends on Presentation only — never imports Domain or Data directly.

Allowed imports: `Bloc`/`Cubit` types, `State`/`Event` types, `[prefix]_core` shared primitives, `flutter/material.dart`.
Forbidden: use case interfaces, repository interfaces, DTOs, mappers, datasources, or direct imports from another feature module.

---

## Screen <!-- 15 -->

A **Screen** is a `StatelessWidget` or `StatefulWidget` that observes state via `BlocBuilder`/`BlocListener` and dispatches events — it contains no business logic.

**Invariants:**
- `BlocProvider` placed at the app-level route manager (`route_manager.dart`) — not inside the Screen widget itself and not per-module
- Bound to exactly one `Bloc`/`Cubit` — resolved from GetIt, never `MyBloc()` inline
- Observes every `State` variant via `BlocBuilder` — no state variant goes unhandled
- Sends events via `context.read<MyBloc>().add(...)` — never mutates state directly
- Contains no business logic — `if`/`switch` only decides what to render

**When to create:** One Screen widget per route. Created after the Bloc/Cubit contract exists. `BlocProvider` wiring added in `route_manager.dart`.

---

## Component / Sub-view <!-- 14 -->

A **Component** is a reusable `StatelessWidget` smaller than a full screen, living in `[prefix]_core` if shared across modules.

**Invariants:**
- Stateless by default — receives data via constructor parameters and emits callbacks via typed callbacks
- If stateful, wrapped with a scoped `BlocProvider` — never manages business state inline
- No use case calls — all data passed in from the parent Screen or a scoped Bloc
- Reuse check required before creating — search `[prefix]_core/lib/src/widgets/` and `[prefix]_core/lib/src/components/` first

**When to create:** When a UI element appears in ≥2 modules, or when a Screen section is complex enough to isolate. Cross-module components live in `[prefix]_core`.

---

## Navigator / Coordinator <!-- 14 -->

A **Navigator** is modular: each feature declares routes in `BaseModule.routes()`, and cross-module navigation uses the Module API pattern defined in `[prefix]_core`.

**Invariants:**
- The Screen delegates navigation intent via `BlocListener` — never hard-codes a destination inline
- The Bloc emits a `NavAction` field in `State` — the Screen's `BlocListener` calls `context.go/goNamed`
- Route constants defined per-module in `[ModulePrefix]Routes` class — exported from the module barrel
- Cross-module navigation uses `[Feature]NavigationApi` abstract class in `[prefix]_core` — never a direct import of another module

**When to create:** When a Screen navigates to another screen. Route entry added to `BaseModule.routes()`. See `navigation-impl.md` for the full modular GoRouter pattern.

---

## DI Wiring <!-- 14 -->

**DI wiring** registers the `Bloc`/`Cubit` in the module's injectable setup via `injectable`.

**Invariants:**
- Bloc annotated `@injectable` within the feature module — scope matches module lifetime
- Use cases injected into the Bloc constructor — never instantiated inside the Bloc
- Module DI setup called from `ModuleRegistrar` — each module self-registers its dependencies
- Cross-module APIs (`[Feature]NavigationApi` implementations) registered as `@LazySingleton(as: ...)` in the owning module

**When to create:** After the Screen and Bloc exist. Required before the module route is registered.

---

## Creation Order <!-- 10 -->

```
Screen widget → BaseModule.routes() entry + [ModulePrefix]Routes constant (if navigation needed) → module DI registration
```

The `Bloc`/`Cubit` and its contract must exist before any UI layer file is written.

---

## Layer Invariants <!-- 10 -->

- Screen never mutates state directly — observes via `BlocBuilder`/`BlocConsumer` only
- Screen never calls use cases directly — all interactions dispatched as Bloc events
- Bloc instantiated via GetIt — never `MyBloc()` inline in a widget tree
- Navigation delegated via `BlocListener` + Module API — no direct imports between feature modules
- No data layer knowledge — no DTOs, no datasources, no HTTP types visible in widget files

---

## Planner Search Patterns <!-- 8 -->

When exploring the UI layer, glob for:
- `**/lib/src/presentation/screens/**/*_screen.dart` — screen files within a module
- `**/[prefix]_core/lib/src/widgets/**/*.dart` — shared component files
- `**/[prefix]_core/lib/src/components/**/*.dart` — shared component files (alternate path)
- `**/lib/src/configs/*_module.dart` — module route registration files
- `**/lib/src/configs/*_routes.dart` — per-module route constants
