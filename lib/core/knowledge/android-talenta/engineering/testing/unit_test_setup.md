---
platform: android
project: android-talenta
discipline: engineering
topic: testing
pattern: unit_test_setup
---

## Theory

Each test gets its own container instance — never share container state across tests. Test naming: `[unit under test]_[scenario]_[expected outcome]`.

---

## Definition

Test naming convention: `test_given[Condition]_when[Action]_then[ExpectedResult]`

## Code Pattern

```kotlin
@RunWith(MockitoJUnitRunner::class)
class GetTimeOffRequestsUseCaseTest {

    @get:Rule
    val fake = JUnitForger()

    private lateinit var useCase: GetTimeOffRequestsUseCase

    @Mock lateinit var mockRepository: TimeOffRepository
    @Mock lateinit var mockResult: Single<List<TimeOffRequest>>
    @Mock lateinit var mockSchedulerTransformers: SchedulerTransformers
    @Mock lateinit var mockLogger: Logger

    @Before
    fun setUp() {
        fake.reset(1)
    }

    @After
    fun tearDown() {
        reset(mockRepository, mockResult, mockSchedulerTransformers, mockLogger)
    }
}
```
