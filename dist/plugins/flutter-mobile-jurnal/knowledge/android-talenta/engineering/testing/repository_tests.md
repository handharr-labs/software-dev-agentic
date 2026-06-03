---
platform: android
project: android-talenta
discipline: engineering
topic: testing
pattern: repository_tests
---

## Theory

Repository implementation tests verify the bridge between DataSource and Domain:

- Use a test double (mock/stub) for the DataSource — not a real network or DB
- Assert that the repository maps DataSource output to the correct domain entity
- Assert that DataSource errors are caught and mapped to the correct domain error type
- One test per operation (get, create, update, delete)

---

## Definition

Test that the repository implementation calls the API and maps the response correctly. Mock the API (`TimeOffApi`) and mapper (`TimeOffRequestMapper`).

Rules:
- Mock `Api` and `Mapper` — never the repository itself
- Test success path, error path (ApiException → DomainException), and empty list
- Use `.blockingGet()` for synchronous assertion in unit tests

## Code Pattern

```kotlin
@RunWith(MockitoJUnitRunner::class)
class TimeOffRepositoryImplTest {

    @Mock lateinit var mockApi: TimeOffApi
    @Mock lateinit var mockMapper: TimeOffRequestMapper

    private lateinit var repository: TimeOffRepositoryImpl

    @Before
    fun setUp() {
        repository = TimeOffRepositoryImpl(mockApi, mockMapper)
    }

    @Test
    fun test_givenApiSuccess_whenGetRequests_thenMapperIsCalledAndEntityReturned() {
        val response = TimeOffRequestListResponse(data = listOf(TimeOffRequestResponse("1", null, null, null, null, null, 3)), meta = null)
        val entity = TimeOffRequest("1", "", "", "", "", "", 3)
        given(mockApi.getTimeOffRequests(1, 20)).willReturn(Single.just(response))
        given(mockMapper.map(response.data!!.first())).willReturn(entity)

        val result = repository.getTimeOffRequests(1, 20).blockingGet()

        assertEquals(listOf(entity), result)
        then(mockMapper).should().map(response.data!!.first())
    }

    @Test
    fun test_givenApiError_whenGetRequests_thenDomainExceptionPropagated() {
        given(mockApi.getTimeOffRequests(1, 20)).willReturn(Single.error(ApiException(401, "Unauthorized")))

        val error = assertThrows(DomainException.Unauthorized::class.java) {
            repository.getTimeOffRequests(1, 20).blockingGet()
        }
        assertNotNull(error)
    }
}
```
