---
name: builder-domain-create-usecase
description: Create a UseCase class and its Params class for a feature operation.
user-invocable: false
---

Create a UseCase following `.claude/reference/code-architecture/domain-impl.md ## Use Cases section`.

## Steps

1. **Grep** `.claude/reference/code-architecture/domain-impl.md` for `## Use Cases`; only **Read** the full file if the section cannot be located
2. **Read** the Repository interface to confirm the method signature being delegated to
3. **Locate** path: `features/<feature>/lib/src/domain/usecases/`
4. **Create** `<verb>_<feature>_usecase.dart`
5. **Export** from barrel `usecases.dart`
6. **Register** in `Jurnal<Feature>Injector.init()` under the Use Cases section

## UseCase Pattern

```dart
import 'package:jurnal_core/jurnal_core.dart';
import '../domains.dart';

class <Verb><Feature>UseCase extends UseCase<<ReturnType>?, <Verb><Feature>Params> {
  const <Verb><Feature>UseCase(this._repository);
  final <Feature>RemoteRepository _repository;

  @override
  Future<Result<<ReturnType>?>> call(<Verb><Feature>Params params) =>
      _repository.<repositoryMethod>(
        page: params.page,
        pageSize: params.pageSize,
        // map all params fields to repository named params
      );
}

class <Verb><Feature>Params {
  const <Verb><Feature>Params({
    this.page = 1,
    this.pageSize = 20,
    this.searchKey,
  });

  final int page;
  final int pageSize;
  final String? searchKey;
}
```

**Rules:**
- Verb naming: Get, Create, Edit, Delete, Archive, Unarchive, Upload — match repository method verb
- Params class in same file as UseCase
- `const` constructor on UseCase
- `call` delegates to repository only — no business logic

## Output

Confirm file path, UseCase class name, Params fields, and injector registration line.
