---
platform: flutter
discipline: engineering
topic: testing
pattern: naming_convention
---

## Theory

`[unit under test]_[scenario]_[expected outcome]`

Examples:
- `getEmployeeUseCase_whenRepositoryReturnsEmployee_emitsEmployee`
- `employeeMapper_whenDtoHasNullDepartment_mapsToDefaultDepartment`
- `employeeViewModel_whenFetchFails_emitsErrorState`

---

Test names describe intent in plain English. Use `given/when/then` or `returns X when Y` style for plain `test()`. Use full sentence for `blocTest`.

**Best practices:**
1. AAA — Arrange, Act, Assert — one concept per test
2. Use `blocTest` — never test BLoC by reading `.state` after `act`
3. Use `predicate<T>` when you care about shape, not exact value
4. Mock at the boundary — datasource for repository tests, repository for use case tests
5. Test both paths — success and failure for every method

## Code Pattern

```
// Plain test naming (returns X when Y)
'returns entity when repository succeeds'
'returns failure when repository fails'
'maps all fields correctly'
'handles null fields with defaults'

// blocTest naming (emits [...] when ...)
'emits [loading, loaded] when use case succeeds'
'emits [loading, error] when use case fails'
```

```
test/
  features/
    employee/
      data/
        mappers/employee_mapper_test.dart
        repositories/employee_repository_impl_test.dart
      domain/
        usecases/get_employee_usecase_test.dart
      presentation/
        blocs/employee_bloc_test.dart
  helpers/
    mocks/employee_mocks.dart
    fixtures/employee_fixtures.dart
```
