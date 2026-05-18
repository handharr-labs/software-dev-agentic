# Flutter Platform

Flutter · Clean Architecture + BLoC · get_it/injectable

## Structure

```
lib/platforms/flutter-mobile-talenta/
  skills/
    builder-domain-create-entity/       # @freezed entity, no fromJson
    builder-domain-create-repository/   # abstract class, Either returns
    builder-domain-create-usecase/      # UseCase<T, P>, Params class
    builder-domain-create-service/      # pure sync business logic
    builder-data-create-mapper/         # Model (freezed+json) + BaseMapper impl
    builder-data-create-datasource/     # abstract + Dio impl, throws AppException
    builder-data-create-repository-impl/# catches AppException → Left(failure)
    builder-pres-create-stateholder/    # BLoC: Event + State + BLoC class
    builder-pres-create-screen/         # Screen (BlocProvider) + View (BlocBuilder)
    builder-pres-create-component/      # reusable presentational Widget
    builder-test-create-domain/         # UseCase + Service tests
    builder-test-create-data/           # Mapper + RepositoryImpl tests
    builder-test-create-presentation/   # BLoC tests with bloc_test
  reference/
    domain.md              # Entities, repository interfaces, use cases, services, Failure
    data.md                # Models, payloads, mappers, datasources, repository impls
    presentation.md        # BLoC pattern, ViewDataState, Events, States, widget bindings
    di.md                  # get_it + injectable setup and patterns
    testing.md             # bloc_test, mockito, test structure
    navigation.md          # go_router setup and patterns
    project.md             # Folder structure, naming conventions, code style
    error-handling.md      # Failure, AppException, error flow
  CLAUDE-template.md       # Drop into downstream project as CLAUDE.md content
```

## How It Fits Into the Core Orchestrator

The core workers (`lib/core/agents/builder/`) are platform-agnostic. When invoked on a Flutter project, they call the skills in this platform folder:

```
builder-feature-orchestrator
  └─ domain-worker           →  skills/builder-domain-create-entity
                             →  skills/builder-domain-create-repository
                             →  skills/builder-domain-create-usecase
  └─ data-worker             →  skills/builder-data-create-mapper
                             →  skills/builder-data-create-datasource
                             →  skills/builder-data-create-repository-impl
  └─ presentation-worker     →  skills/builder-pres-create-stateholder
  └─ builder-ui-worker       →  skills/builder-pres-create-screen
  └─ builder-test-worker     →  skills/builder-test-create-domain
                             →  skills/builder-test-create-data
                             →  skills/builder-test-create-presentation
```

## Key Patterns

- **Entity** — `@freezed`, no `fromJson`, `.freezed.dart` only
- **Model** — `@freezed` + `@JsonKey`, has `fromJson`, both `.freezed.dart` + `.g.dart`
- **Payload** — separate write class, same parts as Model
- **UseCase** — `implements UseCase<T, Params>`, `@lazySingleton`, returns `Either<Failure, T>`
- **BLoC** — `@injectable`, `ViewDataState<T>` in state, always `result.fold()`
- **RepositoryImpl** — `on AppException catch → Left(failure)`, generic `catch → unknownFailure`

## Reference Philosophy

References are **project-agnostic**. They document patterns, not project-specific utilities.
Downstream projects extend via `.claude/agents.local/extensions/<worker>.md`.
