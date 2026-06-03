# utilities — flutter

| Pattern | Description |
|---|---|
| `date_service` | Centralized date handling with timezone and formatting, registered via `@LazySingleton(as: DateService)`. |
| `logger` | Structured logging using the `logger` package — interface-based, swappable per environment. |
| `storage_service` | Abstracts key-value storage — `SharedPreferences` for preferences, `FlutterSecureStorage` for tokens. |
