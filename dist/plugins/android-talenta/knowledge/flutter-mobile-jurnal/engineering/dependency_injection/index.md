# dependency_injection — flutter-mobile-jurnal

| Pattern | Description |
|---|---|
| `feature_injector` | Jurnal uses `get_it` directly without `injectable` annotations — each feature owns a static `Injector` class. |
