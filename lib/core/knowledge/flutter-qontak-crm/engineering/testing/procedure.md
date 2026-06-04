---
platform: flutter
project: flutter-qontak-crm
discipline: engineering
topic: testing
pattern: procedure
---

# Flutter Qontak CRM — Unit Test Procedure Implementation

Platform: `flutter-qontak-crm` · Language: Dart · Test framework: `flutter_test` + `mockito` · Architecture: Clean Architecture + BLoC · Project: Multi-package monorepo under `features/`

---

## Test File Naming <!-- 12 -->

Pattern: `<source_file_name>_test.dart`

Examples:
- `company_repository_impl.dart` → `company_repository_impl_test.dart`
- `get_company_by_id_use_case.dart` → `get_company_by_id_test.dart`
- `company_bloc.dart` → `company_bloc_test.dart`
- `company_mapper.dart` → `company_mapper_test.dart`

---

## Test File Location <!-- 19 -->

Each feature is a separate Dart package under `features/`. Mirror the source path under each feature package's `test/` directory:

```
Source:  features/<feature_pkg>/lib/src/<layer>/<path>/<file>.dart
Test:    features/<feature_pkg>/test/<layer>/<path>/<file>_test.dart
```

Examples:
- `features/crm_company/lib/src/data/repository/company_repository_impl.dart`
  → `features/crm_company/test/data/repository/company_repository_impl_test.dart`
- `features/crm_company/lib/src/domain/usecases/get_company_by_id_use_case.dart`
  → `features/crm_company/test/domain/usecases/get_company_by_id_test.dart`
- `features/crm_company/lib/src/presentation/bloc/company_bloc.dart`
  → `features/crm_company/test/presentation/bloc/company_bloc_test.dart`

---

## Test File Scaffold <!-- 42 -->

For a use-case or repository test — use the centralized test helper:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
// import source under test and domain entities

import '../../helper/test_helper.dart';
import '../../helper/test_helper.mocks.dart';

void main() {
  late <ClassUnderTest> sut;
  late Mock<DependencyInterface> mockDependency;

  setUp(() {
    mockDependency = Mock<DependencyInterface>();
    sut = <ClassUnderTest>(dependency: mockDependency);
    setupTestDependencyInjection(); // only if DI is needed
  });

  group('<ClassName>', () {
    test('returns result on success', () async {
      // Arrange
      when(mockDependency.method(any)).thenAnswer((_) async => Right(expected));

      // Act
      final result = await sut.call(params);

      // Assert
      expect(result.isRight(), true);
      verify(mockDependency.method(params)).called(1);
    });
  });
}
```

If the mock for the dependency does not exist in `test_helper.dart` yet, add it there (see `## Mock Generation`).

---

## Mock Strategy <!-- 26 -->

Uses **mockito** (`package:mockito`) with `@GenerateMocks` annotation. All mocks for a feature package are declared centrally in:

```
features/<feature_pkg>/test/helper/test_helper.dart
```

Example pattern from `crm_company`:
```dart
@GenerateMocks([
  CompanyRemoteDataSource,
  CompanyRepository,
  GetCompanyByIdUseCase,
  // ... all mocks for this package
])
void main() {}
```

The generated file is:
```
features/<feature_pkg>/test/helper/test_helper.mocks.dart
```

---

## Mock Location <!-- 10 -->

All mock declarations are in `features/<feature_pkg>/test/helper/test_helper.dart`.

Generated mock classes live in `features/<feature_pkg>/test/helper/test_helper.mocks.dart`.

Individual test files import from `test_helper.mocks.dart` — they do not declare `@GenerateMocks` themselves.

---

## Mock Generation <!-- 22 -->

After adding a new class to `@GenerateMocks([...])` in `test_helper.dart`:

```bash
cd features/<feature_pkg>
flutter pub run build_runner build --delete-conflicting-outputs
```

Or from the monorepo root if a workspace-level runner is available:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Steps to add a new mock:**
1. Open `features/<feature_pkg>/test/helper/test_helper.dart`.
2. Add the class to the `@GenerateMocks([...])` list.
3. Run `flutter pub run build_runner build --delete-conflicting-outputs` from the feature package directory.
4. The generated `Mock<ClassName>` class will be available in `test_helper.mocks.dart`.

---

## Test Naming Convention <!-- 14 -->

Use plain English descriptions inside `test()` and `group()`:

```dart
group('GetCompanyByIdUseCase', () {
  test('returns Company on success', () async { ... });
  test('returns Failure on network error', () async { ... });
  test('calls repository with correct id', () async { ... });
});
```

---

## Test Structure (Arrange-Act-Assert) <!-- 33 -->

```dart
test('returns Company on success', () async {
  // Arrange
  when(mockRepository.getCompanyById(any))
      .thenAnswer((_) async => Right(companyEntity));

  // Act
  final result = await sut.call(GetCompanyByIdParams(id: '123'));

  // Assert
  expect(result.isRight(), true);
  expect(result.getRight().toNullable(), companyEntity);
  verify(mockRepository.getCompanyById(GetCompanyByIdParams(id: '123'))).called(1);
});
```

For BLoC tests, use `bloc_test`:
```dart
blocTest<CompanyBloc, CompanyState>(
  'emits [Loading, Loaded] on success',
  build: () => CompanyBloc(getCompanyByIdUseCase: mockUseCase),
  act: (bloc) => bloc.add(GetCompanyEvent(id: '123')),
  expect: () => [
    const CompanyState.loading(),
    CompanyState.loaded(companyEntity),
  ],
);
```

---

## Test Runner <!-- 22 -->

Run tests for a specific feature package:
```bash
cd features/<feature_pkg>
flutter test
```

Run a specific file:
```bash
cd features/<feature_pkg>
flutter test test/<layer>/<path>/<file>_test.dart
```

Run with coverage:
```bash
cd features/<feature_pkg>
flutter test --coverage
```

---

## Failure Patterns <!-- 9 -->

| Symptom | Diagnosis | Fix |
|---|---|---|
| `MissingStubError` | Method called but not stubbed | Add `when(mock.method(...)).thenAnswer(...)` before the call |
| `Mock class not found` | Class not added to `@GenerateMocks` | Add to `test_helper.dart` and re-run `build_runner` |
| `type mismatch` in assertion | Entity equality not implemented | Use `isA<Type>()` or verify field-by-field |
| DI not resolved | `GetIt` not set up in test | Call `setupTestDependencyInjection()` in `setUp()` |
| BLoC emits extra states | Intermediate states not listed | Add all emitted states to `expect:` list in `blocTest` |
