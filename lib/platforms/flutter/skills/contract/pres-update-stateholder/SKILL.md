---
name: pres-update-stateholder
description: Update an existing BLoC — add/remove events, update state fields, wire new use cases.
user-invocable: false
---

Update an existing BLoC following `.claude/reference/contract/builder/presentation.md ## Events, ## States, ## BLoC sections`.

## Steps

1. **Read** the Event, State, and BLoC files completely
2. **Identify** what changes: new event, new state field, new use case dependency
3. **Update Event** — add new frozen factory constructors if needed
4. **Update State** — add new `ViewDataState<T>` fields; update `initial()` factory
5. **Update BLoC** — register new `on<Event>` handler; inject new use case in constructor

Rules:
- Never remove events that may have call sites — search first: `Grep` for event name
- New state fields always get a `ViewDataState.initial()` default in `initial()`
- New constructor dependencies must be added to the `@injectable` constructor
- After editing, regenerate with `dart run build_runner build --delete-conflicting-outputs`
- Run `flutter analyze` to surface call sites that need updating

## Output

Confirm all changed file paths and list what was added/removed/changed.
