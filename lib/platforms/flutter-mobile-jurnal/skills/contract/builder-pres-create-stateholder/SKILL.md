---
name: builder-pres-create-stateholder
description: Create a BLoC with its Event and State types for a feature. Flutter mapping — StateHolder = BLoC.
user-invocable: false
---

> **Flutter mapping**: StateHolder = BLoC (or Cubit for 1-3 simple mutations with no payload)

Create a BLoC following `.claude/reference/code-architecture/presentation-impl.md ## State section`.

## Steps

1. **Grep** `.claude/reference/code-architecture/presentation-impl.md` for `## State`; only **Read** the full file if the section cannot be located
2. **Read** the UseCase signatures that this BLoC will call — never guess method names
3. **Decide**: BLoC (events with payload, pagination, complex flows) or Cubit (simple toggle/flag mutations)
4. **Locate** path: `features/<feature>/lib/src/presentation/blocs/<feature_name>/`
5. **Create** `<feature>_event.dart` → `<feature>_state.dart` → `<feature>_bloc.dart`

## BLoC Pattern

```dart
// <feature>_bloc.dart
import 'package:jurnal_core/jurnal_core.dart';

part '<feature>_bloc.freezed.dart';
part '<feature>_event.dart';
part '<feature>_state.dart';

class <Feature>Bloc extends Bloc<<Feature>Event, <Feature>State> {
  <Feature>Bloc(this.useCase)
      : super(const <Feature>State(state: ViewDataInitial())) {
    on<Get<Feature>s>(_onLoad);
    on<GetMore<Feature>s>(_onLoadMore);
  }

  final Get<Feature>ListUseCase useCase;
  static const int _pageSize = 20;

  Future<void> _onLoad(Get<Feature>s event, Emitter<<Feature>State> emit) async {
    if (state.state is ViewDataLoading) return;
    emit(state.copyWith(state: const ViewDataLoading(), page: 1));

    final result = await useCase.call(Get<Feature>ListParams(
      page: 1,
      pageSize: _pageSize,
      searchKey: event.searchKey,
    ));

    result.when(
      success: (data) {
        if (data == null || data.items.isEmpty) {
          emit(state.copyWith(state: const ViewDataEmpty()));
        } else {
          emit(state.copyWith(
            state: ViewDataState.success(data),
            hasMore: data.items.length >= _pageSize,
          ));
        }
      },
      failure: (f) => emit(state.copyWith(state: ViewDataFailure(f.toFailure()))),
    );
  }
}

// <feature>_event.dart
@freezed
class <Feature>Event with _$<Feature>Event {
  const factory <Feature>Event.get<Feature>s({
    String? searchKey,
    @Default(false) bool fullRefresh,
  }) = Get<Feature>s;
  const factory <Feature>Event.getMore<Feature>s() = GetMore<Feature>s;
}

// <feature>_state.dart
@freezed
class <Feature>State with _$<Feature>State {
  const factory <Feature>State({
    required ViewDataState<<Entity>> state,
    @Default(1) int page,
    @Default(false) bool hasMore,
    String? searchKey,
  }) = _<Feature>State;
}
```

## Output

Confirm all file paths, State fields, Event cases, and use cases injected into the BLoC constructor.
