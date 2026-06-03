---
platform: web
project: web
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

## Dependency Rule

Domain is the innermost layer — it imports nothing from outer layers.

**Allowed:** TypeScript built-in types (`string`, `number`, `boolean`, `Date`, `Record`, `Promise`), pure utility types defined within the domain layer itself.

**Forbidden:**
- `import axios` / `import fetch` — HTTP clients belong in data
- `import React` / `import { useXxx } from 'react'` or any Next.js import — UI belongs in presentation
- Any data-layer type — no DTO, DataSource, or repository implementation import
- `import { useState } from 'react'` or any hook — domain must be framework-free TypeScript
