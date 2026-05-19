---
name: builder-test-create-domain
description: Create unit tests for Domain layer artifacts — UseCase and Entity.
user-invocable: false
---

Create domain tests following `.claude/reference/code-architecture/testing-impl.md ## Use Case Tests section`.

## Steps

1. **Grep** `.claude/reference/code-architecture/testing-impl.md` for `## Use Case Tests`; only **Read** the full file if the section cannot be located
2. **Read** the UseCase file being tested — map all inputs and return types
3. **Read** the Repository interface to generate the mock
4. **Locate** test path: `features/<feature>/test/src/domain/usecases/`
5. **Create** `<verb>_<feature>_usecase_test.dart`
6. **Update** `features/<feature>/test/helpers/test_data.dart` with any missing fixtures

## UseCase Test Pattern

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:jurnal_<feature>/src/domain/domains.dart';
import 'package:jurnal_core/jurnal_core.dart';

import '<verb>_<feature>_usecase_test.mocks.dart';

@GenerateMocks([<Feature>RemoteRepository])
void main() {
  late Mock<Feature>RemoteRepository mockRepository;
  late <Verb><Feature>UseCase useCase;

  setUp(() {
    mockRepository = Mock<Feature>RemoteRepository();
    useCase = <Verb><Feature>UseCase(mockRepository);
  });

  group('<Verb><Feature>UseCase', () {
    test('returns entity when repository succeeds', () async {
      // Arrange
      when(mockRepository.<method>(page: anyNamed('page'), pageSize: anyNamed('pageSize')))
          .thenAnswer((_) async => Result.success(t<Feature>Entity));
      // Act
      final result = await useCase.call(const <Verb><Feature>Params());
      // Assert
      result.when(
        success: (data) => expect(data, t<Feature>Entity),
        failure: (_) => fail('Should not be a failure'),
      );
      verify(mockRepository.<method>(page: 1, pageSize: 20)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns failure when repository fails', () async {
      // Arrange
      when(mockRepository.<method>(page: anyNamed('page'), pageSize: anyNamed('pageSize')))
          .thenAnswer((_) async => Result.failure(
                NetworkFailure(message: 'error', type: NetworkFailureType.others),
              ));
      // Act
      final result = await useCase.call(const <Verb><Feature>Params());
      // Assert
      result.when(
        success: (_) => fail('Should not be a success'),
        failure: (f) => expect(f, isA<NetworkFailure>()),
      );
    });
  });
}
```

**Rules:**
- AAA: Arrange / Act / Assert — in that order, labelled with comments
- One concept per test
- Both success and failure paths for every method
- Mock at repository boundary only
- `verifyNoMoreInteractions` after last expected call

## Output

Confirm test file path, mock class generated, and list all test names.
