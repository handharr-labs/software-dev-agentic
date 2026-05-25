---
name: builder-pres-create-component
description: Create a reusable presentational Widget or ChangeNotifier-controlled component with no BLoC awareness.
user-invocable: false
---

Create a reusable widget following `.claude/reference/code-architecture/presentation-impl.md ## Shared Component Paths section`.

## Steps

1. **Identify** the entity or data type the component displays — read the entity file
2. **Decide** component type:
   - Simple display → plain `StatelessWidget`
   - Multi-widget coordination → `StatefulWidget` with `ChangeNotifier`-based controller (see `CustomFieldInputController` pattern)
3. **Locate** path: `features/<feature>/lib/src/presentation/widgets/` or `widgets/components/`
4. **Create** `<feature>_<component_name>.dart`
5. **Export** from `widgets.dart` barrel

## Simple Component Pattern

```dart
import 'package:flutter/material.dart';
import 'package:jurnal_<feature>/src/domain/domains.dart';

class <Feature><ComponentName> extends StatelessWidget {
  const <Feature><ComponentName>({
    super.key,
    required this.<entity>,
    this.onTap,
  });

  final <Entity> <entity>;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(<entity>.name),
        onTap: onTap,
      ),
    );
  }
}
```

## Controller-Based Component Pattern (for complex multi-widget components)

```dart
class <Feature>InputController extends ChangeNotifier {
  final List<<Schema>> _schemas;
  final Map<int, dynamic> _values = {};

  <Feature>InputController({required List<<Schema>> schemas}) : _schemas = schemas;

  void setValue(int fieldId, dynamic value) {
    _values[fieldId] = value;
    notifyListeners();
  }

  bool validate() => _schemas.every((s) => !s.isRequired || _values[s.id] != null);
  List<<Value>> getValues() => _values.entries.map((e) => <Value>(fieldId: e.key, value: e.value)).toList();
}

class <Feature>InputManager extends StatefulWidget {
  const <Feature>InputManager({super.key, required this.controller});
  final <Feature>InputController controller;
  @override
  State<<Feature>InputManager> createState() => _<Feature>InputManagerState();
}
```

**Rules:**
- No `BlocProvider`, no `context.read<Bloc>()` inside components
- Receives entities or primitives as constructor parameters only
- Controller pattern used only when multiple child widgets must share mutable input state

## Output

Confirm file path, list constructor parameters, and confirm barrel export updated.
