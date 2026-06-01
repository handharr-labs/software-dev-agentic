---
name: developer-test-create-data
description: Create unit tests for Data layer artifacts — Mapper and Repository implementation.
user-invocable: false
---

Create data layer tests following `.claude/reference/code-architecture/testing-impl.md ## Repository Tests, ## Mapper Tests sections`.

## Steps

1. **Grep** `.claude/reference/code-architecture/testing-impl.md` for `## Repository Tests` and `## Mapper Tests`
2. **Read** the RepositoryImpl and/or Mapper file being tested
3. **Update** `features/<feature>/test/helpers/test_data.dart` with models and response fixtures
4. **Create** test files in `features/<feature>/test/src/data/repositories/remote/` and/or `data/mappers/`

## Repository Test Pattern

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:jurnal_<feature>/src/data/data.dart';
import 'package:jurnal_<feature>/src/domain/domains.dart';
import 'package:jurnal_core/jurnal_core.dart';

@GenerateMocks([<Feature>RemoteDatasource])
void main() {
  late Mock<Feature>RemoteDatasource mockDatasource;
  late <Feature>RemoteRepositoryImpl repository;

  setUp(() {
    mockDatasource = Mock<Feature>RemoteDatasource();
    repository = <Feature>RemoteRepositoryImpl(
      datasource: mockDatasource,
      mapper: const <Feature>Mapper(),
    );
  });

  group('get<Feature>', () {
    test('returns entity when datasource succeeds', () async {
      // Arrange
      when(mockDatasource.get<Feature>(any))
          .thenAnswer((_) async => t<Feature>Response);
      // Act
      final result = await repository.get<Feature>(1);
      // Assert
      result.when(
        success: (data) => expect(data, isA<<Entity>>()),
        failure: (_) => fail('Expected success'),
      );
    });

    test('returns failure when datasource throws', () async {
      // Arrange
      when(mockDatasource.get<Feature>(any)).thenThrow(Exception('Network error'));
      // Act
      final result = await repository.get<Feature>(1);
      // Assert
      result.when(
        success: (_) => fail('Expected failure'),
        failure: (f) => expect(f, isA<NetworkFailure>()),
      );
    });
  });
}
```

## Mapper Test Pattern (no mocks needed)

```dart
void main() {
  late <Feature>Mapper mapper;

  setUp(() => mapper = const <Feature>Mapper());

  group('<Feature>Mapper', () {
    test('maps all fields correctly', () {
      // Arrange & Act
      final entity = mapper.responseToEntity(t<Feature>Response);
      // Assert
      expect(entity.id, t<Feature>Response.id);
      expect(entity.name, t<Feature>Response.name);
    });

    test('handles null fields with domain defaults', () {
      final entity = mapper.responseToEntity(const <Feature>Response());
      expect(entity.id, 0);
      expect(entity.name, '');
    });

    test('fromJsonToResponse returns null for null input', () {
      expect(mapper.fromJsonToResponse(null), isNull);
    });
  });
}
```

**Rules:**
- Repository: success + exception paths for every method
- Mapper: all-fields-present case + all-null case
- Mapper tests instantiate directly — no mocks
- `catchError` ensures all exceptions become `NetworkFailure` — assert `isA<NetworkFailure>()`

## Output

Confirm test file paths and list all test group + test names.
