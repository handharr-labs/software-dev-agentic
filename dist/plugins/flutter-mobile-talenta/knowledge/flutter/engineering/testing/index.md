# testing — flutter

| Pattern | Description |
|---|---|
| `mock_generation` | Declare all mocks for a feature in one file using `@GenerateNiceMocks` — never mock Mappers. |
| `naming_convention` | Test names describe intent in plain English using `given/when/then` or `returns X when Y` style. |
| `presenter_test` | Use `bloc_test` — never test BLoC state by calling `act` and inspecting `.state` manually. |
| `repository_test` | Mock datasource and mapper — test success, `AppException` throw, and unexpected exception paths. |
| `test_pyramid` | Tests mirror the feature's layer structure with dedicated subdirectories per layer. |
| `use_case_test` | Mock the repository, pass directly via constructor — verify call count and success/failure paths. |
