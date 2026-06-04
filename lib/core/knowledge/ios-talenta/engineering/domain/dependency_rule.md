---
platform: ios
project: ios-talenta
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

**Allowed:** Swift standard library, `Foundation` primitives (`Date`, `UUID`, `Decimal`, `String`, `Int`, `Bool`).

**Forbidden:**
- `import UIKit` — any UIKit type signals a presentation leak into domain
- `import RxSwift` / `import Combine` — reactive frameworks belong in data or presentation
- `import Alamofire` / `import Moya` — networking belongs in data
- Any type defined in a `*RepositoryImpl`, `*DataSource`, or `*Response` file
