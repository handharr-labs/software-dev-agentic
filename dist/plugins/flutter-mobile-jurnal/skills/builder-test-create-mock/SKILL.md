---
name: builder-test-create-mock
description: Generate or update mock classes for a feature using mockito @GenerateMocks / @GenerateNiceMocks.
user-invocable: false
---

Create or update mock specs for a feature.

## Steps

1. **Identify** which interfaces need mocking: Repository, DataSource, UseCase (as needed by tests)
2. **Locate** or create: `features/<feature>/test/helpers/test_data.dart`
3. **Add** `@GenerateMocks` annotation and run code generation

## Mock Spec Pattern

```dart
// features/<feature>/test/src/<layer>/<file>_test.dart
// (mocks are declared per-test-file in this codebase)

import 'package:mockito/annotations.dart';
import 'package:jurnal_<feature>/src/domain/domains.dart';
import 'package:jurnal_<feature>/src/data/data.dart';

@GenerateMocks([
  <Feature>RemoteRepository,    // for UseCase tests
  <Feature>RemoteDatasource,    // for RepositoryImpl tests
  Get<Feature>ListUseCase,      // for BLoC tests
])
void main() { ... }
```

## Code Generation

After adding `@GenerateMocks`, run:

```bash
cd features/<feature>
dart run build_runner build --delete-conflicting-outputs
```

This generates `<file>_test.mocks.dart` alongside the test file.

**Conventions:**
- `@GenerateMocks` in the same file that uses the mock (not a shared mocks file)
- `@GenerateNiceMocks` when strict verification is not needed (stubs return sensible defaults)
- Generated file: `<test_file>_test.mocks.dart` — committed to VCS
- Import: `import '<test_file>_test.mocks.dart';`

## Output

Confirm which mocks were added, and the build_runner command to run.
