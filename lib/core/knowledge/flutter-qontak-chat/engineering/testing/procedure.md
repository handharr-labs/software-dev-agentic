---
platform: flutter
project: flutter-qontak-chat
discipline: engineering
topic: testing
pattern: procedure
---

# Flutter Qontak Chat — Unit Test Procedure Implementation

Platform: `flutter-qontak-chat` · Language: Dart · Test framework: `flutter_test` + `mockito` · Architecture: Clean Architecture + BLoC · Project: Multi-package monorepo under `features/`

---

## Test File Naming <!-- 12 -->

Pattern: `<source_file_name>_test.dart`

Examples:
- `call_repository_impl.dart` → `call_repository_impl_test.dart`
- `get_call_permission_use_case.dart` → `get_call_permission_use_case_test.dart`
- `call_bloc.dart` → `call_bloc_test.dart`
- `call_mapper.dart` → `call_mapper_test.dart`

---

## Test File Location <!-- 19 -->

Each feature is a separate Dart package under `features/`. Mirror the source path under each feature package's `test/` directory:

```
Source:  features/<feature_pkg>/lib/src/<layer>/<path>/<file>.dart
Test:    features/<feature_pkg>/test/<layer>/<path>/<file>_test.dart
```

Examples:
- `features/chat_call/lib/src/data/repositories/call_repository_impl.dart`
  → `features/chat_call/test/data/repositories/call_repository_impl_test.dart`
- `features/chat_call/lib/src/domain/usecases/get_call_permission_use_case.dart`
  → `features/chat_call/test/domain/usecases/get_call_permission_use_case_test.dart`
- `features/chat_call/lib/src/presentation/blocs/call_bloc.dart`
  → `features/chat_call/test/presentation/blocs/call_bloc_test.dart`

---

## Test File Scaffold <!-- 36 -->

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
// import source under test and domain entities

import '../../mock/mock_helper.mocks.dart';

void main() {
  late <ClassUnderTest> sut;
  late Mock<DependencyInterface> mockDependency;

  setUp(() {
    mockDependency = Mock<DependencyInterface>();
    sut = <ClassUnderTest>(dependency: mockDependency);
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

---

## Mock Strategy <!-- 28 -->

Uses **mockito** (`package:mockito`) with `@GenerateNiceMocks` annotation. All mocks for a feature package are declared centrally in a `mock_helper.dart` file:

```
features/<feature_pkg>/test/mock/mock_helper.dart
```

Example from `chat_call`:
```dart
@GenerateNiceMocks([
  MockSpec<CallRepository>(),
  MockSpec<GetCallPermissionUseCase>(),
  MockSpec<CallRemoteDataSource>(),
  // ... all mocks for this package
])
void main() {}
```

The generated file is:
```
features/<feature_pkg>/test/mock/mock_helper.mocks.dart
```

`@GenerateNiceMocks` is preferred over `@GenerateMocks` — it returns sensible null-safe defaults without requiring every method to be stubbed.

---

## Mock Location <!-- 10 -->

All mock declarations are in `features/<feature_pkg>/test/mock/mock_helper.dart`.

Generated mock classes live in `features/<feature_pkg>/test/mock/mock_helper.mocks.dart`.

Individual test files import from `mock_helper.mocks.dart` — they do not declare mock annotations themselves.

---

## Mock Generation <!-- 18 -->

After adding a new `MockSpec<T>()` to `@GenerateNiceMocks([...])` in `mock_helper.dart`:

```bash
cd features/<feature_pkg>
flutter pub run build_runner build --delete-conflicting-outputs
```

**Steps to add a new mock:**
1. Open `features/<feature_pkg>/test/mock/mock_helper.dart`.
2. Add `MockSpec<ClassName>()` inside the `@GenerateNiceMocks([...])` annotation.
3. Add the required import at the top if the class is from another package.
4. Run `flutter pub run build_runner build --delete-conflicting-outputs` from the feature package directory.
5. The generated `Mock<ClassName>` class will be available in `mock_helper.mocks.dart`.

---

## Test Naming Convention <!-- 14 -->

Use plain English descriptions inside `test()` and `group()`:

```dart
group('GetCallPermissionUseCase', () {
  test('returns CallPermission on success', () async { ... });
  test('returns Failure on network error', () async { ... });
  test('calls repository with correct params', () async { ... });
});
```

---

## Test Structure (Arrange-Act-Assert) <!-- 33 -->

```dart
test('returns CallPermission on success', () async {
  // Arrange
  when(mockRepository.getCallPermission())
      .thenAnswer((_) async => Right(callPermissionEntity));

  // Act
  final result = await sut.call(NoParams());

  // Assert
  expect(result.isRight(), true);
  expect(result.getRight().toNullable(), callPermissionEntity);
  verify(mockRepository.getCallPermission()).called(1);
});
```

For BLoC tests, use `bloc_test`:
```dart
blocTest<CallBloc, CallState>(
  'emits [loading, success] when permission fetch succeeds',
  build: () => CallBloc(useCase: mockUseCase),
  act: (bloc) => bloc.add(const FetchCallPermission()),
  expect: () => [
    const CallState.loading(),
    CallState.success(callPermissionEntity),
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

Run with verbose output:
```bash
cd features/<feature_pkg>
flutter test --reporter expanded
```

---

## Failure Patterns <!-- 9 -->

| Symptom | Diagnosis | Fix |
|---|---|---|
| `Null check operator used on a null value` | `@GenerateNiceMocks` returned null for non-nullable return | Stub the method explicitly with `when(...).thenAnswer(...)` |
| `Mock class not found` | Class not added to `@GenerateNiceMocks` | Add `MockSpec<T>()` to `mock_helper.dart` and re-run `build_runner` |
| `type mismatch` in assertion | Entity equality not implemented via `==` | Compare field-by-field or use `isA<Type>()` |
| BLoC test emits unexpected states | Side-effect triggering additional events | Inspect `act:` — ensure only one event is triggered, or add all states to `expect:` |
| `build_runner` conflict | Generated file out of sync | Always use `--delete-conflicting-outputs` flag |
