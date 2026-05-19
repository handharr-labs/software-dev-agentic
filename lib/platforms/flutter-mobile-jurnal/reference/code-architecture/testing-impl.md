## Test Pyramid

Tests are co-located within each feature package under `features/<feature>/test/`. Test structure mirrors source:

```
features/<feature>/test/
  src/
    domain/
      entities/         — entity unit tests (equality, default values)
      usecases/         — use case tests
    data/
      datasources/
        remote/         — datasource tests
        locals/         — local datasource tests
      mappers/          — mapper tests
      models/           — response model serialisation tests
    presentation/
      blocs/            — bloc tests
  helpers/
    test_data.dart      — shared test data/fixtures
```

Test framework: `flutter_test`. Mocking: `mockito` with `@GenerateMocks` or `@GenerateNiceMocks` code generation.

---

## Repository Tests

Repository implementations are tested by mocking the datasource and mapper. The `catchError` wrapper on the repo is exercised via thrown exceptions.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '<feature>_remote_repository_test.mocks.dart';

@GenerateMocks([<Feature>RemoteDatasource, <Feature>Mapper])
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
    test('returns entity on success', () async {
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

**Rules:**
- Mock at the datasource boundary — never below
- `Result.when(success:, failure:)` for assertions
- Both success and failure paths for every method
- Use `verify(mock.method(any)).called(1)` to assert call count
- Use `verifyNever(mock.method(any))` to assert not called

---

## Mapper Tests

Mappers are instantiated directly — no mocks needed.

```dart
void main() {
  late <Feature>Mapper mapper;

  setUp(() => mapper = const <Feature>Mapper());

  group('<Feature>Mapper', () {
    test('maps all fields correctly', () {
      // Arrange
      final response = <Feature>Response(id: 1, name: 'Test');
      // Act
      final entity = mapper.responseToEntity(response);
      // Assert
      expect(entity.id, 1);
      expect(entity.name, 'Test');
    });

    test('handles null fields with domain defaults', () {
      final response = const <Feature>Response();
      final entity = mapper.responseToEntity(response);
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
- Two cases minimum: all fields present, all nullable fields null
- Assert every mapped field individually
- Test `fromJsonToResponse(null)` explicitly

---

## Use Case Tests

Use cases are tested by mocking the repository. Params classes are constructed directly.

```dart
@GenerateMocks([<Feature>RemoteRepository])
void main() {
  late Mock<Feature>RemoteRepository mockRepository;
  late Get<Feature>ListUseCase useCase;

  setUp(() {
    mockRepository = Mock<Feature>RemoteRepository();
    useCase = Get<Feature>ListUseCase(mockRepository);
  });

  group('Get<Feature>ListUseCase', () {
    test('returns list when repository succeeds', () async {
      // Arrange
      when(mockRepository.get<Feature>List(page: anyNamed('page'), pageSize: anyNamed('pageSize')))
          .thenAnswer((_) async => Result.success(t<Feature>List));
      // Act
      final result = await useCase.call(const Get<Feature>ListParams());
      // Assert
      result.when(
        success: (data) => expect(data, t<Feature>List),
        failure: (_) => fail('Expected success'),
      );
      verify(mockRepository.get<Feature>List(page: 1, pageSize: 20)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
```

---

## BLoC Tests

BLoC tests use `bloc_test` package with `blocTest<Bloc, State>`.

```dart
blocTest<<Feature>Bloc, <Feature>State>(
  'emits [loading, success] when Get<Feature>s added',
  build: () => <Feature>Bloc(mockUseCase),
  act: (bloc) => bloc.add(const <Feature>Event.get<Feature>s()),
  expect: () => [
    const <Feature>State(state: ViewDataLoading()),
    <Feature>State(state: ViewDataState.success(t<Feature>List)),
  ],
);
```
