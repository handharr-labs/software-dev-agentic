---
name: developer-test-create-presentation
description: Create unit tests for Presentation layer BLoC — event handling and state transitions.
user-invocable: false
---

Create BLoC tests following `.claude/reference/code-architecture/testing-impl.md ## BLoC Tests section`.

## Steps

1. **Grep** `.claude/reference/code-architecture/testing-impl.md` for `## BLoC Tests`; only **Read** the full file if the section cannot be located
2. **Read** the BLoC's Event and State files completely — must match types exactly
3. **Read** the UseCase being called — mock at this boundary
4. **Locate** test path: `features/<feature>/test/src/presentation/blocs/<feature_name>/`
5. **Create** `<feature>_bloc_test.dart`

## BLoC Test Pattern

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:jurnal_<feature>/src/domain/domains.dart';
import 'package:jurnal_<feature>/src/presentation/presentations.dart';
import 'package:jurnal_core/jurnal_core.dart';

@GenerateMocks([Get<Feature>ListUseCase])
void main() {
  late MockGet<Feature>ListUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGet<Feature>ListUseCase();
  });

  group('<Feature>Bloc', () {
    blocTest<<Feature>Bloc, <Feature>State>(
      'emits [loading, success] when Get<Feature>s added and data returned',
      build: () => <Feature>Bloc(mockUseCase),
      setUp: () {
        when(mockUseCase.call(any)).thenAnswer(
          (_) async => Result.success(t<Feature>List),
        );
      },
      act: (bloc) => bloc.add(const <Feature>Event.get<Feature>s()),
      expect: () => [
        const <Feature>State(state: ViewDataLoading()),
        <Feature>State(
          state: ViewDataState.success(t<Feature>List),
          hasMore: false,
        ),
      ],
    );

    blocTest<<Feature>Bloc, <Feature>State>(
      'emits [loading, empty] when Get<Feature>s added and empty list returned',
      build: () => <Feature>Bloc(mockUseCase),
      setUp: () {
        when(mockUseCase.call(any)).thenAnswer(
          (_) async => Result.success(<Feature>List(items: [])),
        );
      },
      act: (bloc) => bloc.add(const <Feature>Event.get<Feature>s()),
      expect: () => [
        const <Feature>State(state: ViewDataLoading()),
        const <Feature>State(state: ViewDataEmpty()),
      ],
    );

    blocTest<<Feature>Bloc, <Feature>State>(
      'emits [loading, failure] when Get<Feature>s added and use case fails',
      build: () => <Feature>Bloc(mockUseCase),
      setUp: () {
        when(mockUseCase.call(any)).thenAnswer(
          (_) async => Result.failure(
            NetworkFailure(message: 'Error', type: NetworkFailureType.others),
          ),
        );
      },
      act: (bloc) => bloc.add(const <Feature>Event.get<Feature>s()),
      expect: () => [
        const <Feature>State(state: ViewDataLoading()),
        isA<<Feature>State>()
            .having((s) => s.state, 'state', isA<ViewDataFailure>()),
      ],
    );

    blocTest<<Feature>Bloc, <Feature>State>(
      'does not emit when Get<Feature>s added while loading',
      build: () => <Feature>Bloc(mockUseCase),
      seed: () => const <Feature>State(state: ViewDataLoading()),
      act: (bloc) => bloc.add(const <Feature>Event.get<Feature>s()),
      expect: () => [],
    );
  });
}
```

**Rules:**
- `blocTest` for all state transition tests
- Mock at UseCase boundary — never mock repository in BLoC tests
- Test: success with data, success with empty, failure, guard conditions (already loading)
- Use `seed:` to set initial state for guard condition tests

## Output

Confirm test file path, mock class generated, and list all test names.
