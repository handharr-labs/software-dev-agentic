# presentation — flutter

| Pattern | Description |
|---|---|
| `bloc_listener` | `BlocListener` handles one-time side effects — navigation, toasts, dialogs — outside the rebuild cycle. |
| `component` | Reusable presentational widget — BLoC-unaware, receives plain domain entities via constructor. |
| `screen_structure` | Screens split into outer `Screen` (owns `BlocProvider`) and inner `_View` (stateless renderer). |
