## Entities

Entities are defined in `features/<feature>/lib/src/domain/entities/` and use `freezed` for immutability. Each entity is annotated with `@freezed` and uses `const factory` constructors. The generated part file is `.freezed.dart` only — never `.g.dart`, as entities are not serialised from JSON.

Multiple related entities may live in a single directory and are exported via a barrel file (`entities.dart`).

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jurnal_<feature>/<feature>.dart';

part '<entity_name>.freezed.dart';

@freezed
class <EntityName> with _$<EntityName> {
  const factory <EntityName>({
    required int id,
    required String name,
    // required fields first; T? only when domain genuinely allows null
    @Default(false) bool isActive,
    String? optionalField,
  }) = _<EntityName>;
}
```

**Conventions:**
- Class name: `PascalCase` matching entity concept (e.g. `CustomFieldSchema`, `ProductStock`)
- File name: `snake_case` matching class (e.g. `custom_field_schema.dart`)
- Nested value types within the same entity file are allowed (`CustomFieldOption` alongside `CustomFieldSchema`)
- `@Default(value)` for fields with a domain-meaningful default

---

## Repository

Repository interfaces are defined in `features/<feature>/lib/src/domain/repositories/` and exported from `repositories.dart`. Implementations live in `features/<feature>/lib/src/data/repositories/`.

Repository interfaces are abstract classes. Methods return `Future<Result<T?>>` using the `Result` type from `jurnal_core`.

```dart
import 'package:jurnal_core/jurnal_core.dart';
import '../entities/entities.dart';

abstract class <Feature>RemoteRepository {
  Future<Result<<Entity>?>> get<Entity>(int id);
  Future<Result<<Entity>List?>> get<Entity>List({int page, int pageSize});
  Future<Result<void>> create<Entity>(<CreateParams> params);
  Future<Result<void>> delete<Entity>(int id);
}
```

**Conventions:**
- Abstract class, no annotations on the interface
- `Remote` vs `Local` suffix distinguishes network from local storage repositories
- Return type is always `Future<Result<T?>>` — never `Either`, never throws

---

## Use Cases

Use cases extend `UseCase<ReturnType, ParamsType>` from `jurnal_core` and live in `features/<feature>/lib/src/domain/usecases/`.

```dart
import 'package:jurnal_core/jurnal_core.dart';
import '../domains.dart';

class Get<Feature>ListUseCase extends UseCase<<Entity>List?, Get<Feature>ListParams> {
  const Get<Feature>ListUseCase(this._repository);
  final <Feature>RemoteRepository _repository;

  @override
  Future<Result<<Entity>List?>> call(Get<Feature>ListParams params) =>
      _repository.get<Feature>List(
        page: params.page,
        pageSize: params.pageSize,
        searchKey: params.searchKey,
      );
}

class Get<Feature>ListParams {
  const Get<Feature>ListParams({
    this.page = 1,
    this.pageSize = 20,
    this.searchKey,
  });

  final int page;
  final int pageSize;
  final String? searchKey;
}
```

**Conventions:**
- `<Verb><Feature>UseCase` naming (e.g. `GetProductListUseCase`, `ArchiveProductUseCase`)
- Params class defined in the same file as its use case
- `const` constructor on the use case class
- `call` delegates to repository — no business logic in `call` itself
- One use case = one operation

---

## Services

<!-- MISSING_PATTERN: no explicit domain service layer found in repo_path — domain logic is distributed via UseCases; no multi-entity orchestration service class was observed -->

If a domain service is needed (cross-entity orchestration not belonging to any single repository):

```dart
// features/<feature>/lib/src/domain/services/<feature>_service.dart
abstract class <Feature>Service {
  Future<Result<void>> orchestrate(Params params);
}
```

---

## Domain Errors

Domain errors are defined in `features/jurnal_core/lib/entities/failure/failure.dart` using `freezed` union types. The `Failure` sealed type has two variants: `ServerFailure` (network/API) and `LocalFailure` (local storage).

```dart
@freezed
abstract class Failure with _$Failure {
  factory Failure.serverFailure(
    String message, {
    StackTrace? stackTrace,
    int? statusCode,
    String? debugMessage,
  }) = ServerFailure;

  factory Failure.localFailure(
    String message, {
    StackTrace? stackTrace,
    String? debugMessage,
  }) = LocalFailure;
}
```

`NetworkFailure` (from `jurnal_core`) is the transport-level error. `Failure` is the domain-level error propagated through `Result<T>`. The extension `FailureExtension.toNetworkFailure()` bridges between them. The `hasNoAccess` extension checks for 403 / forbidden scenarios.
