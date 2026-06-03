---
platform: flutter
discipline: engineering
topic: data
pattern: local_data_source
---

## Theory

Cache-first pattern: try local cache first, fall back to remote, then cache the result.

## Code Pattern

```dart
// data/datasources/employee_local_data_source.dart
abstract class EmployeeLocalDataSource {
  Future<EmployeeModel?> getCachedEmployee(String id);
  Future<void> cacheEmployee(String id, EmployeeModel model);
  Future<void> clearCache();
}
```

```dart
// Repository cache-first variant
@override
Future<Either<Failure, EmployeeEntity>> getEmployee(String id) async {
  final cached = await localDataSource.getCachedEmployee(id);
  if (cached != null) return Right(mapper.toEntity(cached));

  try {
    final model = await remoteDataSource.getEmployee(id);
    await localDataSource.cacheEmployee(id, model);
    return Right(mapper.toEntity(model));
  } on AppException catch (e) {
    return Left(e.toFailure());
  } catch (e) {
    return Left(Failure.unknownFailure(message: e.toString()));
  }
}
```
