---
platform: flutter
discipline: engineering
topic: domain
pattern: dependency_rule
---

## Theory

Domain is the innermost layer. It imports nothing from outer layers.

```
UI  →  Presentation  →  Data  →  Domain
```

Allowed imports: language primitives and pure functional utilities only.
Forbidden: any framework, UI library, HTTP client, database driver, or data-layer type.

---

Domain is the innermost layer — it imports nothing from outer layers.

**Allowed:** `dart:core`, `package:freezed_annotation`, `package:equatable`, `package:fpdart` (for `Either`/`Option`).

**Forbidden:**
- `package:dio` / `package:http` — HTTP clients belong in data
- `package:flutter/material.dart` or any Flutter UI package — domain must be pure Dart
- Any BLoC, Cubit, or state-management import (`package:flutter_bloc`, `package:bloc`)
- Any data-layer import — no `*Model`, `*Dto`, or `*DataSource` types from `data/`
