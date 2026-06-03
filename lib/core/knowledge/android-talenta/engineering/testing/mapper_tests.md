---
platform: android
project: android-talenta
discipline: engineering
topic: testing
pattern: mapper_tests
---

## Theory

Mapper tests are pure input → output assertions — the simplest tests to write:

- Provide a fully-populated DTO → assert every field maps to the correct entity field
- Provide a DTO with missing/null optional fields → assert safe defaults or null handling
- No mocks needed — mappers have no dependencies

---

## Definition

**Never mock Mappers** — they are pure functions. Instantiate directly and test with real input/output.

## Code Pattern

```kotlin
@RunWith(MockitoJUnitRunner::class)
class TimeOffRequestMapperTest {

    private lateinit var mapper: TimeOffRequestMapper

    @Before
    fun setUp() { mapper = TimeOffRequestMapper() }

    @Test
    fun test_givenValidResponse_whenMap_thenEntityIsCorrect() {
        val response = TimeOffRequestResponse(
            id = "123", employeeId = "emp-1", startDate = "2024-01-01",
            endDate = "2024-01-05", reason = "Vacation", status = "pending", totalDays = 5
        )
        val result = mapper.map(response)
        assertEquals("123", result.id)
        assertEquals(5, result.totalDays)
    }

    @Test
    fun test_givenNullFields_whenMap_thenDefaultsApplied() {
        val result = mapper.map(TimeOffRequestResponse(null, null, null, null, null, null, null))
        assertEquals("", result.id)
        assertEquals(0, result.totalDays)
    }

    @Test
    fun test_givenListResponse_whenMapList_thenAllEntitiesMapped() {
        val responses = listOf(
            TimeOffRequestResponse("1", null, null, null, null, null, 3),
            TimeOffRequestResponse("2", null, null, null, null, null, 5)
        )
        val results = responses.map { mapper.map(it) }
        assertEquals(2, results.size)
        assertEquals("1", results[0].id)
    }
}
```
