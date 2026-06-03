---
platform: flutter
discipline: engineering
topic: domain
pattern: use_case
---

## Theory

A **UseCase** encapsulates a single business operation: one class, one public method, one responsibility.

**Invariants:**
- One business operation per class — never combine unrelated operations
- Depends only on repository interfaces — never on repository implementations or data-layer types
- No framework dependencies — no HTTP clients, no UI types
- Accepts typed input (Params/Request struct) — never raw dictionaries or loose primitives
- Returns domain entities or primitives — never DTOs or view models
- All I/O goes through the repository — use cases never call APIs or databases directly

**Mandatory call flow — no exceptions:**
```
Presentation → UseCase → Repository    ✅
Presentation → Repository              ❌  direct call is a CLEAN violation
```

**When to create:** One use case per business operation (e.g. `GetEmployeeUseCase`, `SubmitLeaveRequestUseCase`, `ApproveLeaveRequestUseCase`). Even thin pass-through use cases are mandatory — they preserve a stable indirection point for future validation, caching, or logging without touching the presentation layer.

---

Single-responsibility units of business logic. Each use case calls exactly one repository method. Registered with `@lazySingleton` via injectable.

**Naming:** `[Verb][Feature]UseCase` — `GetEmployeeUseCase`, `UpdateAttendanceUseCase`, `SubmitLeaveRequestUseCase`

**Params naming:**

| HTTP | Params structure |
|---|---|
| GET (single) | Plain `String` or typed ID |
| GET (list) | `XxxParams { page, limit, filters... }` |
| POST | `XxxParams { field1, field2... }` (pure Dart) |
| PUT | `XxxParams { id, field1... }` (pure Dart) |
| DELETE | Plain `String` ID |
| No input | `NoParams` |

## Code Pattern

```dart
// domain/usecases/use_case.dart
import 'package:fpdart/fpdart.dart';
import '../errors/failure.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
```

```dart
// GET — single item
// domain/usecases/employee/get_employee_usecase.dart
@lazySingleton
class GetEmployeeUseCase implements UseCase<EmployeeEntity, String> {
  GetEmployeeUseCase({required this.repository});
  final EmployeeRepository repository;

  @override
  Future<Either<Failure, EmployeeEntity>> call(String id) =>
      repository.getEmployee(id);
}
```

```dart
// GET — list with params
@lazySingleton
class GetEmployeesUseCase
    implements UseCase<List<EmployeeEntity>, GetEmployeesParams> {
  GetEmployeesUseCase({required this.repository});
  final EmployeeRepository repository;

  @override
  Future<Either<Failure, List<EmployeeEntity>>> call(
    GetEmployeesParams params,
  ) =>
      repository.getEmployees(
        page: params.page,
        limit: params.limit,
        departmentId: params.departmentId,
      );
}

class GetEmployeesParams {
  const GetEmployeesParams({this.page = 1, this.limit = 20, this.departmentId});
  final int page;
  final int limit;
  final String? departmentId;
}
```

```dart
// POST/PUT — write with params
@lazySingleton
class UpdateEmployeeUseCase
    implements UseCase<EmployeeEntity, UpdateEmployeeParams> {
  UpdateEmployeeUseCase({required this.repository});
  final EmployeeRepository repository;

  @override
  Future<Either<Failure, EmployeeEntity>> call(UpdateEmployeeParams params) =>
      repository.updateEmployee(params.id, params);
}

class UpdateEmployeeParams {
  const UpdateEmployeeParams({
    required this.id,
    required this.name,
    required this.email,
    this.departmentId,
  });
  final String id;
  final String name;
  final String email;
  final String? departmentId;
}
```

```dart
// No-params use case
@lazySingleton
class GetCurrentUserUseCase implements UseCase<EmployeeEntity, NoParams> {
  GetCurrentUserUseCase({required this.repository});
  final AuthRepository repository;

  @override
  Future<Either<Failure, EmployeeEntity>> call(NoParams _) =>
      repository.getCurrentUser();
}
```
