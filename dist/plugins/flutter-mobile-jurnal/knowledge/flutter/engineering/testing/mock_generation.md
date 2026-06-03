---
platform: flutter
discipline: engineering
topic: testing
pattern: mock_generation
---

## Theory

Mapper tests are pure input → output assertions — the simplest tests to write:

- Provide a fully-populated DTO → assert every field maps to the correct entity field
- Provide a DTO with missing/null optional fields → assert safe defaults or null handling
- No mocks needed — mappers have no dependencies

---

Declare all mocks for a feature in one file using `@GenerateNiceMocks`. Never mock Mappers — they are pure functions, instantiate directly.

Use `@GenerateNiceMocks` for interfaces. Pass mocks directly via constructor injection — avoid `getIt` in tests.

## Code Pattern

```dart
// test/helpers/mocks/employee_mocks.dart
@GenerateNiceMocks([
  MockSpec<EmployeeRepository>(),
  MockSpec<GetEmployeeUseCase>(),
  MockSpec<UpdateEmployeeUseCase>(),
  MockSpec<EmployeeRemoteDataSource>(),
])
void main() {}
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

```dart
// test/helpers/fixtures/employee_fixtures.dart
const tEmployeeModel = EmployeeModel(id: '1', name: 'Alice', email: 'alice@example.com');
final tEmployeeEntity = EmployeeEntity(id: '1', name: 'Alice', email: 'alice@example.com');
final tServerFailure = Failure.serverFailure(message: 'Server error', developerMessage: 'HTTP 500');
```
