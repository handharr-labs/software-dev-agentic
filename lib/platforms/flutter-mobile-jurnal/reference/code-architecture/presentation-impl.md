## State

BLoC state uses `freezed` with a `ViewDataState<T>` wrapper from `jurnal_core` for each distinct async operation. State class is annotated `@freezed` and holds one `ViewDataState<T>` per async operation plus pagination helpers.

```dart
// <feature>_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jurnal_core/jurnal_core.dart';
import '../../../domain/entities/entities.dart';

part '<feature>_state.freezed.dart';

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

**ViewDataState variants:**
- `ViewDataInitial()` — not yet loaded
- `ViewDataLoading()` — in-flight
- `ViewDataSuccess<T>(T data, {bool? loadMore, Failure? failure})` — data available; `loadMore: true` for pagination spinner
- `ViewDataEmpty()` — success but empty list
- `ViewDataFailure(Failure failure)` — error terminal state

**Events** use `@freezed` union with verb-noun naming:

```dart
// <feature>_event.dart
@freezed
class <Feature>Event with _$<Feature>Event {
  const factory <Feature>Event.get<Feature>s({
    String? searchKey,
    @Default(false) bool fullRefresh,
  }) = Get<Feature>s;
  const factory <Feature>Event.getMore<Feature>s() = GetMore<Feature>s;
}
```

**BLoC class:**

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

  Future<void> _onLoadMore(GetMore<Feature>s event, Emitter<<Feature>State> emit) async {
    if (!state.hasMore) return;
    if (state.state is! ViewDataSuccess<<EntityList>>) return;
    // ... pagination merge pattern
  }
}
```

---

## Screen Structure

Screens are `StatelessWidget` classes that own `BlocProvider` setup. The screen file also contains the argument class (via `part 'argument.dart'`). Content/view is split into a separate `content.dart` file.

```
features/<feature>/lib/src/presentation/screens/<screen_name>/
  screen.dart      — BlocProvider + argument
  argument.dart    — screen argument data class (part of screen.dart)
  content.dart     — StatefulWidget or StatelessWidget with BlocConsumer/Builder
```

```dart
// screen.dart
part 'argument.dart';

class <Feature>Screen extends StatelessWidget {
  const <Feature>Screen({super.key, required this.argument});
  final <Feature>Argument argument;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => <Feature>Injector.find<<Feature>Bloc>(),
        ),
      ],
      child: <Feature>Content(argument: argument),
    );
  }
}
```

BLoCs are instantiated via the feature's static `Injector.find<T>()` method — never `context.read`.

---

## Shared Component Paths

Reusable widgets live at:
- `features/<feature>/lib/src/presentation/widgets/` — feature-scoped widgets
- `features/<feature>/lib/src/presentation/widgets/components/` — sub-components (e.g. `selection_field.dart`, `bundle_info.dart`)
- `features/<feature>/lib/src/presentation/widgets/bottom_sheet/` — bottom sheets
- `features/jurnal_core/lib/` — cross-feature shared widgets and utilities

Reusable widgets are plain `StatelessWidget` (or `StatefulWidget`) with no BLoC awareness. They receive entities or primitive values as constructor parameters. `ChangeNotifier`-based controllers (e.g. `CustomFieldInputController`) are used for complex multi-widget coordination without BLoC.

```dart
class <Feature><ComponentName> extends StatelessWidget {
  const <Feature><ComponentName>({
    super.key,
    required this.<entity>,
  });

  final <Entity> <entity>;

  @override
  Widget build(BuildContext context) { ... }
}
```
