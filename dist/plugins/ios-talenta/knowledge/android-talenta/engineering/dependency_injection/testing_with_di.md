---
platform: android
project: android-talenta
discipline: engineering
topic: dependency_injection
pattern: testing_with_di
---

## Theory

- Swap real implementations for test doubles at registration time — the caller never changes
- Each test gets its own container instance — never share container state across tests
- Verify that the container resolves the full dependency graph in an integration test — catches missing registrations before runtime

---

## Definition

In unit tests, bypass Dagger entirely — instantiate the class under test directly with `@Mock` dependencies.

Each test class is self-contained. Never share a Dagger component or module instance across test classes — recreate in `@Before`.

## Code Pattern

```kotlin
@RunWith(MockitoJUnitRunner::class)
class TimeOffRepositoryImplTest {
    @Mock lateinit var mockApi: TimeOffApi
    @Mock lateinit var mockMapper: TimeOffRequestMapper

    private lateinit var repository: TimeOffRepositoryImpl

    @Before
    fun setUp() {
        // No Dagger — construct directly with mocks
        repository = TimeOffRepositoryImpl(mockApi, mockMapper)
    }
}
```
