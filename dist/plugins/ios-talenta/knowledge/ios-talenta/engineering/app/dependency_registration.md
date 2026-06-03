---
platform: ios
project: ios-talenta
discipline: engineering
topic: app
pattern: dependency_registration
---

## Theory

**Dependency Registration** is the act of binding concrete implementations to their interfaces in the app's DI container so that the runtime can inject them into use cases, repositories, and state holders.

**Invariants:**
- Bindings live at the app shell — never inside a CLEAN layer
- Each feature owns its own registration unit (component, module, or file) — one file per feature
- Use cases and repositories are registered, not constructed inline at call sites
- Registration order follows the dependency graph: data sources → repositories → use cases

**When to add:** Any time a new use case, repository implementation, or data source is introduced. Skipping registration causes runtime crashes — this step is mandatory, not optional.

---

## Dependency Registration

iOS uses **Needle** — a compile-time, hierarchical component tree. Each feature has its own `Component<DependencyType>`.

**Component hierarchy:**
```
RootComponent
  └── MainTabComponent
        └── {Feature}Component (child component per feature)
```

**Step 1 — Define the Dependency protocol:**

```swift
// Talenta/DIComponents/{Feature}/{Feature}Dependency.swift
protocol {Feature}Dependency: Dependency {
    var get{Feature}UseCase: Get{Feature}UseCase { get }
    var {feature}Repository: {Feature}Repository { get }
}
```

**Step 2 — Implement the Component:**

```swift
// Talenta/DIComponents/{Feature}/{Feature}Component.swift
final class {Feature}Component: Component<{Feature}Dependency> {
    var get{Feature}UseCase: Get{Feature}UseCase {
        Get{Feature}UseCase(repository: dependency.{feature}Repository)
    }

    var {feature}Repository: {Feature}Repository {
        {Feature}RepositoryImpl.sharedInstance
    }
}
```

**Step 3 — Wire into MainTabComponent:**

```swift
// Talenta/DIComponents/MainTab/MainTabComponent.swift
extension MainTabComponent: {Feature}Dependency {
    var {feature}Repository: {Feature}Repository {
        {Feature}RepositoryImpl.sharedInstance
    }
}
```

**Step 4 — Needle code generation:**

After adding a new component, run Needle's code generator:
```bash
needle generate Talenta/DIComponents/NeedleGenerated.swift Talenta/
```

**Rules:**
- ✅ One `Component` per feature
- ✅ Declare dependencies in the `Dependency` protocol — never access sibling components directly
- ✅ `NeedleGenerated.swift` is always auto-generated — never edit by hand
- ❌ No service locators or singletons outside Needle except `sharedInstance` on `*Impl` types
