# Flutter Platform

Flutter · Clean Architecture + BLoC · get_it/injectable

## Structure

```
lib/platforms/flutter-mobile-talenta/
  skills/
    developer-domain-create-entity/       # @freezed entity, no fromJson
    developer-domain-create-repository/   # abstract class, Either returns
    developer-domain-create-usecase/      # UseCase<T, P>, Params class
    developer-domain-create-service/      # pure sync business logic
    developer-data-create-mapper/         # Model (freezed+json) + BaseMapper impl
    developer-data-create-datasource/     # abstract + Dio impl, throws AppException
    developer-data-create-repository-impl/# catches AppException → Left(failure)
    developer-pres-create-stateholder/    # BLoC: Event + State + BLoC class
    developer-pres-create-screen/         # Screen (BlocProvider) + View (BlocBuilder)
    developer-pres-create-component/      # reusable presentational Widget
    developer-test-create-domain/         # UseCase + Service tests
    developer-test-create-data/           # Mapper + RepositoryImpl tests
    developer-test-create-presentation/   # BLoC tests with bloc_test
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

The core workers (`lib/core/agents/developer/`) are platform-agnostic. When invoked on a Flutter project, they call the skills in this platform folder:

```
developer-feature-strategist
  └─ domain-worker           →  skills/developer-domain-create-entity
                             →  skills/developer-domain-create-repository
                             →  skills/developer-domain-create-usecase
  └─ data-worker             →  skills/developer-data-create-mapper
                             →  skills/developer-data-create-datasource
                             →  skills/developer-data-create-repository-impl
  └─ presentation-worker     →  skills/developer-pres-create-stateholder
  └─ developer-ui-worker       →  skills/developer-pres-create-screen
  └─ developer-test-worker     →  skills/developer-test-create-domain
                             →  skills/developer-test-create-data
                             →  skills/developer-test-create-presentation
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
