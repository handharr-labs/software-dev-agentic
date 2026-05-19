---
name: builder-domain-create-service
description: Create a Domain Service for cross-entity orchestration logic that does not belong to any single repository.
user-invocable: false
---

Create a Domain Service following `.claude/reference/code-architecture/domain-impl.md ## Services section`.

## Steps

1. **Grep** `.claude/reference/code-architecture/domain-impl.md` for `## Services`; only **Read** the full file if the section cannot be located
2. **Confirm** this logic genuinely spans multiple entities or repositories — if it fits a single UseCase, use a UseCase instead
3. **Locate** path: `features/<feature>/lib/src/domain/services/`
4. **Create** `<feature>_service.dart` (abstract interface) and `<feature>_service_impl.dart`
5. **Register** in `Jurnal<Feature>Injector.init()`

## Service Pattern

```dart
// Abstract
abstract class <Feature>Service {
  Future<Result<void>> <orchestrationMethod>(<Params> params);
}

// Implementation
class <Feature>ServiceImpl extends <Feature>Service {
  final <RepositoryA>RemoteRepository _repositoryA;
  final <RepositoryB>RemoteRepository _repositoryB;

  const <Feature>ServiceImpl({
    required <RepositoryA>RemoteRepository repositoryA,
    required <RepositoryB>RemoteRepository repositoryB,
  })  : _repositoryA = repositoryA,
        _repositoryB = repositoryB;

  @override
  Future<Result<void>> <orchestrationMethod>(<Params> params) =>
      catchError(() async {
        // cross-entity orchestration
      });
}
```

**Rules:**
- Only create when logic spans 2+ repositories/entities
- Service impl extends `BaseRemoteRepository` if using `catchError()`
- Abstract interface in domain layer; implementation registered in injector

## Output

Confirm file paths, injected repositories, and all method signatures.
