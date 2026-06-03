# dependency_injection — flutter-qontak-crm

| Pattern | Description |
|---|---|
| `crm_di` | Qontak CRM uses `get_it` manually — `@injectable` annotations are forbidden; `CrmDi.initDependency()` calls feature `register*()` methods in order. |
