# testing — web

| Pattern | Description |
|---|---|
| `mapper_test` | Pure input/output tests for mappers — no mocks needed. |
| `presenter_test` | Decide when to mock vs use real implementations based on isolation strategy. |
| `repository_test` | With injectable mappers, isolate repository logic from mapping logic in separate test cases. |
| `test_pyramid` | Layer-based mocking strategy — unit at the base, integration above, minimal E2E at the top. |
