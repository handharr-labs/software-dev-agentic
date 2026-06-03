---
platform: ios
project: ios-talenta
discipline: engineering
topic: data
pattern: dependency_rule
---

## Theory

Data depends on Domain only. It never imports from Presentation or UI.

```
Domain  ←  Data
```

Allowed imports: domain entities, repository interfaces, language primitives.
Forbidden: any presentation type, UI framework, StateHolder, or view import.

---

## Dependency Rule

Data depends on Domain only. It never imports from Presentation or UI.

**Allowed:** `Foundation`, Moya, `MoyaProvider`, `JSONDecoder`, `UserDefaults`, `CoreData`, `NWPathMonitor`, any persistence or networking library.

**Forbidden:**
- `import UIKit` — UI types must not appear in data layer files
- Any `ViewModel`, `ViewController`, `Coordinator`, or `Navigator` type
- Any presentation-layer import — data layer must not know how results are displayed
