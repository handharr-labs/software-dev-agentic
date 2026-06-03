---
platform: android
project: android-talenta
discipline: engineering
topic: testing
pattern: test_naming_convention
---

## Theory

`[unit under test]_[scenario]_[expected outcome]`

Examples:
- `getEmployeeUseCase_whenRepositoryReturnsEmployee_emitsEmployee`
- `employeeMapper_whenDtoHasNullDepartment_mapsToDefaultDepartment`
- `employeeViewModel_whenFetchFails_emitsErrorState`

---

## Definition

Pattern: `test_given[Condition]_when[Action]_then[ExpectedResult]`

## Code Pattern

Examples:

- `test_givenApiSuccess_whenGetRequests_thenMapperIsCalledAndEntityReturned`
- `test_givenApiError_whenGetRequests_thenDomainExceptionPropagated`
- `test_givenValidResponse_whenMap_thenEntityIsCorrect`
- `test_givenNullFields_whenMap_thenDefaultsApplied`
- `test_givenViewAttached_whenLoadData_thenShowLoadingThenData`
- `test_givenViewDetached_whenLoadData_thenNoViewInteraction`
