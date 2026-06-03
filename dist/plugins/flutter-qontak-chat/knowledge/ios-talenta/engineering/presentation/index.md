# presentation — ios-talenta

| Pattern | Description |
|---|---|
| `component` | Reusable cell or view using the UIModel pattern — receives a plain `UIModel` struct via `configure(with:)`. |
| `logging` | Log format: `print("[DebugTest][ClassName.methodName] <event> — <value>")`. |
| `screen_structure` | ViewController + ViewModel split — ViewController owns UI layout, ViewModel owns state and business calls. |
| `shared_component_paths` | Reference paths to search when running a Component Reuse Check for existing reusable views. |
| `view_model` | StateHolder implemented as a ViewModel extending `BaseViewModelV2`. |
