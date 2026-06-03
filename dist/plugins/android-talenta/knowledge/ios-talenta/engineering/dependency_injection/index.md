# dependency_injection — ios-talenta

| Pattern | Description |
|---|---|
| `di_setup` | Constructor injection with defaults as the current pattern — target architecture is a Manual DI Container. |
| `registration_order` | Dependencies must be declared before they are referenced — leaf nodes registered first. |
| `testing_with_di` | Configure the container for `.testing` environment and inject mocks via constructor parameters. |
