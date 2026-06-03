---
platform: flutter
discipline: engineering
topic: testing
pattern: presenter_test
---

## Theory

| Use a mock/stub when… | Use a real implementation when… |
|---|---|
| The dependency has I/O (network, DB, file) | The dependency is pure (mappers, domain services) |
| The test must control exact return values | The test verifies the full integration path |
| Speed matters — unit test suite | Correctness of wiring matters — integration test |

**Never mock domain services or mappers in unit tests** — they are pure functions; test them with real inputs and outputs.

---

Use `bloc_test` — never test BLoC state by calling `act` and inspecting `.state` manually. Always `setUp` mock return values, assert state sequence, verify use case call count.

## Code Pattern

```dart
// test/features/employee/presentation/blocs/employee_bloc_test.dart
void main() {
  late MockGetEmployeeUseCase mockGetUseCase;
  late MockUpdateEmployeeUseCase mockUpdateUseCase;
  late EmployeeBloc bloc;

  setUp(() {
    mockGetUseCase = MockGetEmployeeUseCase();
    mockUpdateUseCase = MockUpdateEmployeeUseCase();
    bloc = EmployeeBloc(
      getEmployeeUseCase: mockGetUseCase,
      updateEmployeeUseCase: mockUpdateUseCase,
    );
  });

  tearDown(() => bloc.close());

  group('LoadEmployee', () {
    blocTest<EmployeeBloc, EmployeeState>(
      'emits [loading, loaded] when use case succeeds',
      setUp: () {
        when(mockGetUseCase.call(any)).thenAnswer((_) async => Right(tEmployeeEntity));
      },
      build: () => bloc,
      act: (b) => b.add(const EmployeeEvent.loadEmployee(employeeId: '1')),
      expect: () => [
        isA<EmployeeState>().having((s) => s.employeeState.isLoading, 'isLoading', isTrue),
        isA<EmployeeState>().having((s) => s.employeeState.isLoaded, 'isLoaded', isTrue),
      ],
      verify: (_) => verify(mockGetUseCase.call('1')).called(1),
    );

    blocTest<EmployeeBloc, EmployeeState>(
      'emits [loading, error] when use case fails',
      setUp: () {
        when(mockGetUseCase.call(any)).thenAnswer((_) async => Left(tServerFailure));
      },
      build: () => bloc,
      act: (b) => b.add(const EmployeeEvent.loadEmployee(employeeId: '1')),
      expect: () => [
        predicate<EmployeeState>((s) => s.employeeState.isLoading),
        predicate<EmployeeState>((s) => s.employeeState.hasError),
      ],
    );
  });
}
```
