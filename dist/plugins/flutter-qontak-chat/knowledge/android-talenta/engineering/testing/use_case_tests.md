---
platform: android
project: android-talenta
discipline: engineering
topic: testing
pattern: use_case_tests
---

## Theory

Use case tests verify business rules, edge cases, and error conditions. Use cases depend only on repository interfaces.

---

## Definition

Test that the use case calls the correct repository method with the correct params.

## Code Pattern

```kotlin
@Test
fun test_givenValidParams_whenExecute_thenRepositoryShouldGetRequests() {
    // given
    useCase = GetTimeOffRequestsUseCase(mockRepository, mockSchedulerTransformers, mockLogger)
    val params = with(fake) {
        GetTimeOffRequestsUseCase.Params(id = aString())
    }
    given(mockRepository.getTimeOffRequests(params.id)).willReturn(mockResult)

    // when
    useCase.execute(params)

    // then
    then(mockRepository).should().getTimeOffRequests(params.id)
    then(mockRepository).shouldHaveNoMoreInteractions()
}

@Test
fun test_givenNullSchedulerAndLogger_whenExecute_thenWorksWithoutThem() {
    // given
    useCase = GetTimeOffRequestsUseCase(mockRepository)
    val params = with(fake) { GetTimeOffRequestsUseCase.Params(id = aString()) }
    given(mockRepository.getTimeOffRequests(params.id)).willReturn(mockResult)

    // when
    useCase.execute(params)

    // then
    then(mockRepository).should().getTimeOffRequests(params.id)
}
```
