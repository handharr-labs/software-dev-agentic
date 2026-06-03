# app — flutter-qontak-chat

| Pattern | Description |
|---|---|
| `module_communication` | Feature packages must not directly depend on each other — two patterns for cross-feature sharing. |
| `module_registrar` | Feature modules expose a `BaseModule` implementation; `ModuleRegistrar` aggregates them for a single registration call. |
