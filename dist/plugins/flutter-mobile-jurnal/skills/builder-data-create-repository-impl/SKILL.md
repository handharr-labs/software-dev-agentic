---
name: builder-data-create-repository-impl
description: Create the Repository implementation class that bridges Datasource to the Domain Repository interface.
user-invocable: false
---

Create a Repository implementation following `.claude/reference/code-architecture/data-impl.md ## Repository Impl section`.

## Steps

1. **Grep** `.claude/reference/code-architecture/data-impl.md` for `## Repository Impl`; only **Read** the full file if the section cannot be located
2. **Read** the domain Repository interface to match all method signatures exactly
3. **Verify** Datasource and Mapper exist before creating this file
4. **Locate** path: `features/<feature>/lib/src/data/repositories/remote/`
5. **Create** `<feature>_remote_repository_impl.dart`
6. **Export** from `remotes.dart` → `repositories.dart` barrel
7. **Register** in `Jurnal<Feature>Injector.init()` under Repositories section

## Repository Impl Pattern

```dart
import 'package:jurnal_core/jurnal_core.dart';
import 'package:jurnal_<feature>/src/data/data.dart';
import 'package:jurnal_<feature>/src/domain/domains.dart';

class <Feature>RemoteRepositoryImpl extends <Feature>RemoteRepository {
  final <Feature>RemoteDatasource datasource;
  final <Feature>Mapper mapper;

  const <Feature>RemoteRepositoryImpl({
    required this.datasource,
    required this.mapper,
  });

  @override
  Future<Result<<Entity>?>> get<Entity>(int id) =>
      catchError(() async {
        final response = await datasource.get<Entity>(id);
        if (response == null) return Result.success(null);
        return Result.success(mapper.responseToEntity(response));
      });

  @override
  Future<Result<<Entity>List?>> get<Entity>List({
    int page = 1,
    int pageSize = 20,
    String? searchKey,
  }) =>
      catchError(() async {
        final response = await datasource.get<Entity>List(
          page: page,
          pageSize: pageSize,
          searchQuery: searchKey,
        );
        if (response == null) return Result.success(null);
        return Result.success(mapper.responseToEntityList(response));
      });

  @override
  Future<Result<void>> delete<Entity>(int id) =>
      catchError(() async {
        await datasource.delete<Entity>(id);
        return Result.success(null);
      });
}
```

**Rules:**
- Extends domain abstract class (`extends`, not `implements`)
- `catchError(() async { ... })` wraps every method — never manual try/catch
- `Result.success(null)` when the API returns null (not an error state)
- `const` constructor with named required parameters

## Output

Confirm file path, list all overridden methods, and injector registration line.
