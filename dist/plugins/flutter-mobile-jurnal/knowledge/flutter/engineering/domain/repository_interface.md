---
platform: flutter
discipline: engineering
topic: domain
pattern: repository_interface
---

## Theory

A **Repository** is a contract that defines data access operations — *what* is needed, not *how* it is done.

**Invariants:**
- Lives in Domain as an interface/protocol/abstract class only — implementation lives in Data
- Returns domain Entities — never raw DTOs, API response types, or database records
- Method names follow the operation's intent: `get*`, `create*`, `update*`, `delete*`, `submit*`
- Parameters are domain objects — not raw dictionaries, JSON maps, or HTTP types
- Error type is the domain error type — never a networking or transport error

**When to create:** One repository per aggregate root or feature domain. Created before use cases — use cases depend on the repository interface.

---

Abstract contract that the data layer must implement. Domain defines the interface — it never knows how data is fetched.

**Rules:**
- `abstract class` (not `interface` or `mixin`)
- Return `Either<Failure, T>` — never throw from a repository
- Return domain entities, never DTOs
- Method names follow REST: `get*`, `create*`, `update*`, `delete*`
- Params are domain objects, not raw `Map<String, dynamic>`

## Code Pattern

```dart
// domain/repositories/employee_repository.dart
import 'package:fpdart/fpdart.dart';
import '../entities/employee_entity.dart';
import '../errors/failure.dart';

abstract class EmployeeRepository {
  Future<Either<Failure, EmployeeEntity>> getEmployee(String id);
  Future<Either<Failure, List<EmployeeEntity>>> getEmployees({
    int page = 1,
    int limit = 20,
    String? departmentId,
  });
  Future<Either<Failure, EmployeeEntity>> updateEmployee(
    String id,
    UpdateEmployeeParams params,
  );
  Future<Either<Failure, void>> deleteEmployee(String id);
}
```
