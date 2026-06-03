---
platform: flutter
discipline: engineering
topic: dependency_injection
pattern: registration_order
---

## Theory

Dependencies must be registered before they are resolved. The correct registration order mirrors the dependency graph:

```
Infrastructure (HTTP client, DB driver)
  → DataSources
  → Mappers
  → Repository Implementations
  → Use Cases
  → StateHolders
```

Register leaf nodes (no dependencies) first. Register consumers after their dependencies.

---

`injectable` resolves registration order automatically via the dependency graph. Declare annotations in leaf-first order so the generated `injection.config.dart` registers correctly.

| Layer | Lifecycle | Why |
|---|---|---|
| External deps (`@module`) | Before anything | No app dependencies |
| DataSources | `@lazySingleton` | Depend on Dio/storage |
| Mappers | `@lazySingleton` | Stateless, no dependencies |
| Repositories | `@LazySingleton(as:)` | Depend on DataSource + Mapper |
| Use Cases | `@lazySingleton` | Depend on Repository |
| BLoCs | `@injectable` | Stateful — fresh instance per screen |

**Never register a BLoC as `@lazySingleton`** — BLoC holds mutable state; every screen must get a fresh instance via `BlocProvider`.

## Code Pattern

```dart
// 1. External dependencies (no app dependencies)
@module abstract class AppModule {
  @lazySingleton Dio get dio => ...;
  @preResolve Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}

// 2. DataSources (depend on Dio)
@LazySingleton(as: EmployeeRemoteDataSource)
class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource { ... }

// 3. Mappers (no dependencies)
@lazySingleton class EmployeeMapper { ... }

// 4. Repositories (depend on DataSource + Mapper)
@LazySingleton(as: EmployeeRepository)
class EmployeeRepositoryImpl implements EmployeeRepository { ... }

// 5. Use Cases (depend on Repository)
@lazySingleton class GetEmployeeUseCase { ... }

// 6. BLoCs (depend on Use Cases) — @injectable, not singleton
@injectable class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> { ... }
```
