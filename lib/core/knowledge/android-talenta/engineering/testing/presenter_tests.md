---
platform: android
project: android-talenta
discipline: engineering
topic: testing
pattern: presenter_tests
---

## Theory

Presentation tests verify State transitions for each event; correct use case calls; action emissions.

---

## Definition

Rules:
- Test naming: `test_given[Condition]_when[Action]_then[ExpectedResult]`
- Use `inOrder(mockView)` to verify call order (showLoading → hideLoading → showData)
- `presenter.attachView(mockView)` in `@Before`, `reset(...)` all mocks in `@After`
- `presenter.detachView()` (not `detach()`) — test that detached presenter ignores use case results
- Always test: success path, error path, detached-view path

## Code Pattern

```kotlin
@RunWith(MockitoJUnitRunner::class)
class TimeOffRequestPresenterTest {

    @get:Rule
    val fake = JUnitForger()

    @Mock lateinit var mockView: TimeOffRequestContract.View
    @Mock lateinit var mockUseCase: GetTimeOffRequestsUseCase
    @Mock lateinit var mockSchedulerTransformers: SchedulerTransformers
    @Mock lateinit var mockErrorHandler: ErrorHandler

    private lateinit var presenter: TimeOffRequestPresenter

    @Before
    fun setUp() {
        fake.reset(1)
        presenter = TimeOffRequestPresenter(mockUseCase, mockSchedulerTransformers, mockErrorHandler)
        presenter.attachView(mockView)
    }

    @After
    fun tearDown() {
        reset(mockView, mockUseCase, mockSchedulerTransformers, mockErrorHandler)
    }

    @Test
    fun test_givenViewAttached_whenLoadData_thenShowLoadingThenData() {
        val featureId = fake.aString()
        val mockData = with(fake) { TimeOffRequest(aString(), aString(), aString(), aString(), aString(), aString(), aPositiveInt()) }
        given(mockUseCase.execute(any())).willReturn(Single.just(listOf(mockData)))

        presenter.loadTimeOffRequests(featureId)

        val inOrder = inOrder(mockView)
        inOrder.verify(mockView).showLoading()
        inOrder.verify(mockView).hideLoading()
        inOrder.verify(mockView).showTimeOffRequests(listOf(mockData))
        inOrder.verifyNoMoreInteractions()
    }

    @Test
    fun test_givenError_whenLoadData_thenShowError() {
        val error = RuntimeException("Network error")
        given(mockUseCase.execute(any())).willReturn(Single.error(error))

        presenter.loadTimeOffRequests(fake.aString())

        val inOrder = inOrder(mockView)
        inOrder.verify(mockView).showLoading()
        inOrder.verify(mockView).hideLoading()
        verify(mockErrorHandler).handle(eq(error), any())
    }

    @Test
    fun test_givenViewDetached_whenLoadData_thenNoViewInteraction() {
        presenter.detachView()

        presenter.loadTimeOffRequests(fake.aString())

        verifyNoMoreInteractions(mockView)
    }
}
```
