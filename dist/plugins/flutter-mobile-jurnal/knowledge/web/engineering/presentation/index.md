# presentation — web

| Pattern | Description |
|---|---|
| `atomic_design` | Clean Architecture owns the vertical slice; Atomic Design owns the horizontal component hierarchy. |
| `logging` | Log format: `console.log('[DebugTest][ClassName.methodName] <event> —', value)`. |
| `screen_structure` | Components are dumb renderers — receive state and callbacks from the ViewModel hook. |
| `view_model` | StateHolder implemented as a ViewModel Hook (`use*ViewModel`) for client components or a pure `build*ViewModel` function for Server Components. |
