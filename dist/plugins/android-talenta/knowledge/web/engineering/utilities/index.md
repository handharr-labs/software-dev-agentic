# utilities — web

| Pattern | Description |
|---|---|
| `date_service` | Centralized date handling with timezone and formatting — wraps `date-fns` or the native `Intl` API. |
| `helper_extensions` | Utility functions in `presentation/common/utils/` or `core/utils/`, grouped by the type they transform. |
| `image_cache` | Asynchronous image loading leveraging Next.js `<Image>` component and browser cache. |
| `logger` | Structured logging abstraction — swap implementation per environment. |
| `network_monitor` | Connectivity state observation using the browser's `navigator.onLine` and `online`/`offline` events. |
| `storage_service` | Abstracts key-value storage for auth tokens, user preferences, and cached data. |
| `validator` | Input validation for common form fields. |
