---
name: developer-domain-create-repository
description: Create a Domain Repository abstract class for a feature.
user-invocable: false
---

Create a Repository interface following `.claude/reference/code-architecture/domain-impl.md ## Repository section`.

## Steps

1. **Grep** `.claude/reference/code-architecture/domain-impl.md` for `## Repository`; only **Read** the full file if the section cannot be located
2. **Locate** path: `features/<feature>/lib/src/domain/repositories/`
3. **Create** `<feature>_remote_repository.dart` (abstract interface)
4. **Export** from barrel `repositories.dart`

## Repository Pattern

```dart
import 'package:jurnal_core/jurnal_core.dart';
import '../entities/entities.dart';

abstract class <Feature>RemoteRepository {
  Future<Result<<Entity>?>> get<Entity>(int id);
  Future<Result<<Entity>List?>> get<Entity>List({
    int page,
    int pageSize,
    String? searchKey,
  });
  Future<Result<void>> create<Entity>(<Create><Entity>Request request);
  Future<Result<void>> delete<Entity>(int id);
}
```

**Rules:**
- Abstract class only — no implementation here
- Return type always `Future<Result<T?>>` — never throws, never `Either`
- Suffix: `RemoteRepository` (network) or `LocalRepository` (local storage)

## Output

Confirm file path and list all declared method signatures.
