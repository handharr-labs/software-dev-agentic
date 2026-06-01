---
name: developer-pres-create-screen
description: Create a Screen widget (BlocProvider + Argument) and a Content widget (BlocConsumer/Builder) for a feature.
user-invocable: false
---

Create a Screen following `.claude/reference/code-architecture/presentation-impl.md ## Screen Structure section`.

## Steps

1. **Read** the BLoC's Event and State files completely — must match types exactly
2. **Grep** `.claude/reference/code-architecture/presentation-impl.md` for `## Screen Structure`
3. **Locate** path: `features/<feature>/lib/src/presentation/screens/<screen_name>/`
4. **Create** `screen.dart` and `content.dart` (and `argument.dart` as `part` of `screen.dart` if arguments required)

## Screen Pattern

```dart
// screen.dart
import 'package:flutter/material.dart';
import 'package:jurnal_core/jurnal_core.dart';
import 'package:jurnal_<feature>/src/domain/domains.dart';
import 'package:jurnal_<feature>/src/presentation/presentations.dart';

part 'argument.dart';

class <Feature>Screen extends StatelessWidget {
  const <Feature>Screen({super.key, required this.argument});
  final <Feature>Argument argument;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => Jurnal<Feature>Injector.find<<Feature>Bloc>(),
        ),
      ],
      child: <Feature>Content(argument: argument),
    );
  }
}

// argument.dart (part of screen.dart)
part of '<feature>_screen.dart';

class <Feature>Argument {
  const <Feature>Argument({required this.id});
  final int id;
}
```

## Content Pattern

```dart
// content.dart
class <Feature>Content extends StatelessWidget {
  const <Feature>Content({super.key, required this.argument});
  final <Feature>Argument argument;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('<Feature>')),
      body: BlocConsumer<<Feature>Bloc, <Feature>State>(
        listener: (context, state) {
          // side effects: snackbars, navigation
          if (state.state is ViewDataFailure) {
            final failure = (state.state as ViewDataFailure).failure;
            if (failure.hasNoAccess) { /* handle 403 */ }
          }
        },
        builder: (context, state) {
          final s = state.state;
          if (s is ViewDataLoading || s is ViewDataInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (s is ViewDataFailure) {
            return Center(child: Text((s).failure.message));
          }
          if (s is ViewDataEmpty) {
            return const Center(child: Text('No data'));
          }
          if (s is ViewDataSuccess) {
            return <Feature>ContentBody(data: (s).data);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

**Rules:**
- BLoCs resolved via `Jurnal<Feature>Injector.find<T>()` — never `getIt<T>()` directly in screens
- `MultiBlocProvider` even for a single BLoC — consistent across codebase
- Argument class lives in `argument.dart` as a `part` of `screen.dart`
- Content split into `content.dart` to keep screen.dart slim

## Output

Confirm all file paths, argument fields, state cases handled, and events dispatched.
