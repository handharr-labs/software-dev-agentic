# navigation — android-talenta

| Pattern | Description |
|---|---|
| `navigator` | Custom `NavigationImpl` interface+class injected into Presenter — interfaces in `base/common`, implementations in feature/app module. |
| `route_constants` | Android uses Activity class references as the routing mechanism — no string route constants; `companion object { fun newIntent(...) }` factory per Activity. |
