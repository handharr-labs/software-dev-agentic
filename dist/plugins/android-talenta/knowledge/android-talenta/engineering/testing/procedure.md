---
platform: android
project: android-talenta
discipline: engineering
topic: testing
pattern: procedure
---

# Android Talenta — Unit Test Procedure Implementation

Platform: `android-talenta` · Language: Kotlin · Test framework: JUnit4 + Mockito-Kotlin · Architecture: MVP (Presenter/View Contract)

---

## Test File Naming <!-- 11 -->

Pattern: `<SourceClassName>Test.kt`

Examples:
- `ReimbursementEssMenuPresenter.kt` → `ReimbursementEssMenuPresenterTest.kt`
- `AnnouncementCreatorParcelMapper.kt` → `AnnouncementCreatorParcelMapperTest.kt`
- `LoginMapper.kt` → `LoginMapperTest.kt`

---

## Test File Location <!-- 17 -->

Source files live in multi-module Gradle modules. Mirror the source path under the module's `test` source set:

```
Source:  <module>/src/main/java/<package>/<ClassName>.kt
Test:    <module>/src/test/java/<package>/<ClassName>Test.kt
```

Examples:
- `app/src/main/java/co/talenta/modul/home/essmenu/reimbursementessmenu/ReimbursementEssMenuPresenter.kt`
  → `app/src/test/java/co/talenta/modul/home/essmenu/reimbursementessmenu/ReimbursementEssMenuPresenterTest.kt`
- `data/src/main/java/co/talenta/data/mapper/LoginMapper.kt`
  → `data/src/test/java/co/talenta/data/mapper/LoginMapperTest.kt`

---

## Test File Scaffold <!-- 58 -->

```kotlin
package <package>

import co.talenta.commontest.RxTestRule
import org.mockito.kotlin.mock
import org.mockito.kotlin.reset
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mock
import org.mockito.junit.MockitoJUnitRunner

@RunWith(MockitoJUnitRunner::class)
class <ClassName>Test {

    @get:Rule
    val rxTestRule = RxTestRule()

    private lateinit var sut: <ClassName>

    @Mock
    lateinit var mock<Dependency>: <DependencyInterface>

    @Before
    fun setUp() {
        sut = <ClassName>(mock<Dependency>)
    }

    @After
    fun tearDown() {
        reset(mock<Dependency>)
    }
}
```

For Presenter tests, attach and detach the view:
```kotlin
@Before
fun setUp() {
    sut = <Presenter>(<useCaseMock>).apply {
        errorHandler = mockErrorHandler
        attach(mockView)
    }
}

@After
fun tearDown() {
    sut.detach()
    reset(mock<Dependency>, mockView, mockErrorHandler)
}
```

---

## Mock Strategy <!-- 32 -->

Uses **Mockito-Kotlin** (`org.mockito.kotlin`). Mocks are declared inline in the test class using `@Mock` annotation or `mock<T>()` function — no separate mock files.

Dependencies in `app/build.gradle`:
```groovy
testImplementation testDependencies.mockitoInline
testImplementation testDependencies.mockitoKotlin
```

**Key Mockito-Kotlin patterns:**
```kotlin
// Stub a method
whenever(mockUseCase.execute(param)).thenReturn(Flowable.just(result))

// Verify call
verify(mockView).showLoading()
verify(mockView, times(2)).hideLoading()
verify(mockView, never()).showError(any())

// Verify no more interactions
verifyNoMoreInteractions(mockView)
```

For RxJava3 flows, trigger the scheduler after the call:
```kotlin
presenter.doSomething(param)
rxTestRule.testScheduler.triggerActions()
```

---

## Mock Location <!-- 8 -->

Mocks are declared directly inside test files using `@Mock` annotations. There are no separate mock files for Android Talenta.

For test helpers shared across modules, see `commontest/` module.

---

## Mock Generation <!-- 11 -->

No code generation required. Mockito creates mocks at runtime via `@RunWith(MockitoJUnitRunner::class)` and `@Mock` annotations.

Steps:
1. Declare `@Mock lateinit var mock<Name>: <Interface>` in the test class.
2. Ensure the interface is not `final` — Mockito-Inline handles final classes, but interfaces are preferred.
3. Add `reset(mock<Name>)` in `@After` to clear state between tests.

---

## Test Naming Convention <!-- 17 -->

```
test_given<Condition>_when<Action>_then<Expectation>
```

Shorthand used in practice:
```
test_given<Param>_when<MethodName>_then<Result>
```

Examples:
- `test_givenParam_whenRepoGetEncryptedTokenMekariExpense_thenViewShouldOnSuccessGetEncryptedTokenMekariExpense`
- `test_givenErrorBundle_whenRepoGetEncryptedTokenMekariExpenseAndViewIsNull_thenViewShouldShowError`

---

## Test Structure (Given-When-Then) <!-- 32 -->

```kotlin
@Test
fun test_given<Condition>_when<Action>_then<Expectation>() {
    // given
    val givenParam = fake.aString()
    val mockResult = fake.aString()

    // when
    whenever(mockUseCase.execute(givenParam)).thenReturn(Flowable.just(mockResult))
    sut.doSomething(givenParam)
    rxTestRule.testScheduler.triggerActions()

    // then
    verify(mockView).showLoading()
    verify(mockView).onSuccess(mockResult)
    verifyNoMoreInteractions(mockView)
}
```

Optional: use `fr.xgouchet.elmyr.junit.JUnitForger` for random-but-deterministic test data:
```kotlin
@get:Rule
val fake = JUnitForger()

val randomString = fake.aString()
val randomBool = fake.aBool()
```

---

## Test Runner <!-- 25 -->

Run unit tests for a specific module:
```bash
./gradlew :<module>:test
```

Run a specific test class:
```bash
./gradlew :<module>:test --tests "<fully.qualified.ClassName>"
```

Run a specific test method:
```bash
./gradlew :<module>:test --tests "<fully.qualified.ClassName>.testMethodName"
```

Examples:
```bash
./gradlew :app:test --tests "co.talenta.modul.home.essmenu.reimbursementessmenu.ReimbursementEssMenuPresenterTest"
./gradlew :data:test --tests "co.talenta.data.mapper.LoginMapperTest.test_map_success"
```

---

## Failure Patterns <!-- 8 -->

| Symptom | Diagnosis | Fix |
|---|---|---|
| `Wanted but not invoked` | Method never called — missing `triggerActions()` or wrong stub | Add `rxTestRule.testScheduler.triggerActions()` after the call under test |
| `Argument mismatch` | Stub param doesn't match actual call | Use `any()` matcher or align param value |
| `NullPointerException` on mock | View detached before assertion | Assert before `detach()` or use `verify(mockView, never())` pattern |
| `WantedButNotInvoked` on `verifyNoMoreInteractions` | Extra unexpected call | Check if another view method is being called not included in `verify` |
