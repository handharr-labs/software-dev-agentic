---
platform: flutter
discipline: engineering
topic: testing
pattern: repository_test
---

## Theory

Repository implementation tests verify the bridge between DataSource and Domain:

- Use a test double (mock/stub) for the DataSource — not a real network or DB
- Assert that the repository maps DataSource output to the correct domain entity
- Assert that DataSource errors are caught and mapped to the correct domain error type
- One test per operation (get, create, update, delete)

---

Mock datasource and mapper. Test three paths: datasource succeeds, datasource throws `AppException`, datasource throws unexpected exception.

## Code Pattern

```dart
void main() {
  late MockEmployeeRemoteDataSource mockDataSource;
  late MockEmployeeMapper mockMapper;
  late EmployeeRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockEmployeeRemoteDataSource();
    mockMapper = MockEmployeeMapper();
    repository = EmployeeRepositoryImpl(remoteDataSource: mockDataSource, mapper: mockMapper);
  });

  group('getEmployee', () {
    test('returns entity when datasource succeeds', () async {
      when(mockDataSource.getEmployee(any)).thenAnswer((_) async => tEmployeeModel);
      when(mockMapper.toEntity(any)).thenReturn(tEmployeeEntity);
      final result = await repository.getEmployee('1');
      expect(result, Right(tEmployeeEntity));
    });

    test('returns failure when datasource throws AppException', () async {
      when(mockDataSource.getEmployee(any))
          .thenThrow(AppException.server(message: 'Not found', statusCode: 404));
      final result = await repository.getEmployee('1');
      expect(result.isLeft(), isTrue);
      result.fold((failure) => expect(failure, isA<ServerFailure>()), (_) => fail('Expected Left'));
    });

    test('returns unknownFailure for unexpected exceptions', () async {
      when(mockDataSource.getEmployee(any)).thenThrow(Exception('Crash'));
      final result = await repository.getEmployee('1');
      expect(result.isLeft(), isTrue);
    });
  });
}
```
