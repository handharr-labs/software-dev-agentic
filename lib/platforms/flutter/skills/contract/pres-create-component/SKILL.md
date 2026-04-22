---
name: pres-create-component
description: Create a reusable presentational Widget that takes plain entities as parameters with no BLoC awareness.
user-invocable: false
---

Create a presentational Widget following `.claude/reference/contract/builder/presentation.md ## Screen Structure section`.

## Steps

1. **Identify** the entity or data type the component displays
2. **Locate** path: `lib/src/features/[feature]/presentation/widgets/`
3. **Create** `[feature]_[component].dart` (e.g. `employee_card.dart`)

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
            Text([feature].email),
          ],
        ),
      ),
    );
  }
}
```

Rules:
- `const` constructor — always
- Accept domain entities as parameters — never BLoC or use case references
- No `context.read<XxxBloc>()` — no BLoC access whatsoever
- No business logic in `build` — only layout and display decisions
- Prefer `StatelessWidget` — use `StatefulWidget` only for purely local UI state (animations, form fields)

## Output

Confirm file path and list all constructor parameters.
