# dependency_injection — web

| Pattern | Description |
|---|---|
| `di_setup` | Next.js App Router splits Server and Client Components — DI strategy differs per component type. |
| `registration_order` | Instantiate in leaf-first order — infrastructure before consumers; Node.js module caching enforces this on the server. |
