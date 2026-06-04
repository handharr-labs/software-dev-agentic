---
platform: flutter
discipline: engineering
topic: data
pattern: repository_impl
---

## Theory

A **Repository Implementation** implements the domain repository interface using a DataSource and Mapper.

**Invariants:**
- Implements a domain repository interface — it is the bridge between Data and Domain
- Calls the DataSource for raw data, calls the Mapper to convert to domain entities
- Wraps all DataSource calls with error handling — maps transport errors to domain errors before returning
- Never lets raw HTTP errors, DB exceptions, or transport-layer types propagate to the domain
- Never calls another repository implementation directly

**When to create:** Last in the creation order — after DataSource interface and implementation exist.

---

Implements domain repository interface. Orchestrates datasource → mapper → Either. The `try/catch` boundary lives here — never in datasources.

**Rules:**
- Catch `AppException` first, then `catch (e)` for unexpected errors
- Never let exceptions escape into domain or presentation layers
- `*Model` instances never cross into domain — `mapper.toEntity()` is the boundary
- Registered with `@LazySingleton(as: RepositoryInterface)`

## Code Pattern

```dart
// data/repositories/employee_repository_impl.dart
@LazySingleton(as: EmployeeRepository)
class EmployeeRepositoryImpl implements EmployeeRepository {
  EmployeeRepositoryImpl({required this.remoteDataSource, required this.mapper});

  final EmployeeRemoteDataSource remoteDataSource;
  final EmployeeMapper mapper;

  @override
  Future<Either<Failure, EmployeeEntity>> getEmployee(String id) async {
    try {
      final model = await remoteDataSource.getEmployee(id);
      return Right(mapper.toEntity(model));
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EmployeeEntity>> updateEmployee(
    String id,
    UpdateEmployeeParams params,
  ) async {
    try {
      final payload = UpdateEmployeePayload(
        name: params.name,
        email: params.email,
        departmentId: params.departmentId,
      );
      final model = await remoteDataSource.updateEmployee(id, payload);
      return Right(mapper.toEntity(model));
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
}
```
