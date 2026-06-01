---
name: developer-pres-create-component
description: Create a reusable presentational Widget for Qontak Chat that takes plain entities as parameters with no BLoC awareness.
user-invocable: false
---

Create a presentational Widget following `.claude/reference/code-architecture/presentation-impl.md ## Screen Structure section`.

## Steps

1. **Identify** the entity or data type the component displays
2. **Locate** path: `lib/presentation/widgets/[feature]/` (app-level) or `features/[prefix]_[feature]/lib/src/presentation/widgets/`
3. **Create** `[feature]_[component].dart` (e.g. `conversation_card.dart`)

## Component Pattern

```dart
import 'package:flutter/material.dart';
import '../../domain/entities/[feature]_entity.dart';

class [Feature][Component] extends StatelessWidget {
  const [Feature][Component]({
    super.key,
    required this.[feature],
  });

  final [Feature]Entity [feature];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              [feature].name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text([feature].subtitle),
          ],
        ),
      ),
    );
  }
}
```

## Rules

- Components are BLoC-unaware — receive only plain entity data via constructor
- No `BlocProvider`, `BlocBuilder`, or `context.read` inside a component
- Use `const` constructor — all fields `final`

## Output

Confirm file path and list all constructor parameters.
