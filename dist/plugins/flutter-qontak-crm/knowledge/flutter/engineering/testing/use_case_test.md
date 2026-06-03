---
platform: flutter
discipline: engineering
topic: testing
pattern: use_case_test
---

## Theory

| Layer | Test targets | What to assert |
|---|---|---|
| Domain | Use cases, domain services | Business rules, edge cases, error conditions |
| Data | Mappers, repository implementations | DTO → entity mapping correctness; error mapping from transport to domain |
| Presentation | StateHolder (ViewModel/BLoC) | State transitions for each event; correct use case calls; action emissions |

---

Mock the repository, pass directly via constructor. Verify call count and both success/failure paths.

## Code Pattern

```dart
void main() {
  late MockEmployeeRepository mockRepository;
  late GetEmployeeUseCase useCase;

  setUp(() {
    mockRepository = MockEmployeeRepository();
    useCase = GetEmployeeUseCase(repository: mockRepository);
  });

  group('GetEmployeeUseCase', () {
    test('returns entity when repository succeeds', () async {
      when(mockRepository.getEmployee(any)).thenAnswer((_) async => Right(tEmployeeEntity));
      final result = await useCase('1');
      expect(result, Right(tEmployeeEntity));
      verify(mockRepository.getEmployee('1')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns failure when repository fails', () async {
      when(mockRepository.getEmployee(any)).thenAnswer((_) async => Left(tServerFailure));
      final result = await useCase('1');
      expect(result.isLeft(), isTrue);
    });
  });
}
```
