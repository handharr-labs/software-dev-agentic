# testing — android-talenta

| Pattern | Description |
|---|---|
| `mapper_tests` | Pure input/output assertions — never mock Mappers, instantiate directly, test valid and null-field cases. |
| `mock_vs_real` | Mock dependencies with I/O (API, DB); use real implementations for pure functions (Mappers). |
| `presenter_tests` | JUnit4 + Mockito — `attachView`/`detachView`, `inOrder(mockView)` for call order, test success/error/detached paths. |
| `repository_tests` | Mock Api and Mapper — test success path, ApiException→DomainException mapping, and empty list. |
| `test_naming_convention` | Pattern: `test_given[Condition]_when[Action]_then[ExpectedResult]`. |
| `test_pyramid` | Unit (JUnit4+Mockito) heavy; Instrumented (Espresso) light. Run with `./gradlew test` / `./gradlew connectedAndroidTest`. |
| `unit_test_setup` | `@RunWith(MockitoJUnitRunner::class)`, `JUnitForger`, `@Before` setUp, `@After` reset — test class is self-contained. |
| `use_case_tests` | Verify use case calls the correct repository method with correct params; test null-scheduler/logger variants. |
| `what_to_test` | Per-layer test targets and exclusions — domain: business rules; data: mapping; presentation: view call order. |
| `procedure` | Step-by-step test writing procedure for this platform |
