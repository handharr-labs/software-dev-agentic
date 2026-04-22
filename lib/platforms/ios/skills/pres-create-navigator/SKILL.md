---
name: pres-create-navigator
description: |
  Create a Navigator protocol and its implementation *(iOS: Coordinator)* for a feature screen.
user-invocable: false
---

Create Navigator + Coordinator following `.claude/reference/contract/builder/navigation.md ## Navigator Protocol section` and DI rules in `.claude/reference/contract/builder/di.md ## DI Principles section`.

## Steps

1. **Grep** `.claude/reference/contract/builder/navigation.md` for `## Navigator Protocol` and `.claude/reference/contract/builder/di.md` for `## DI Principles`; only **Read** a file in full if the section cannot be located
2. **Locate** module path: `Talenta/Module/[Module]/Presentation/Coordinator/`
3. **Create** `[Feature]Coordinator.swift` (contains both protocol and impl)
4. **Wire** into the module's `DIContainer`

## Navigator + Coordinator Pattern

```swift
// Navigator Protocol (used by ViewModel)
protocol [Feature]NavigatorProtocol: AnyObject {
    func showDetail(_ model: [Feature]Model)
    func showErrorAlert(message: String)
    func dismiss()
}

// Coordinator (implements Navigator, owned by parent coordinator)
final class [Feature]Coordinator: [Feature]NavigatorProtocol {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    func showDetail(_ model: [Feature]Model) {
        let vc = [Feature]DetailViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func showErrorAlert(message: String) {
        // show alert
    }

    func dismiss() {
        navigationController?.popViewController(animated: true)
    }
}
```

Rules:
- ViewModel holds `weak var navigator: [Feature]NavigatorProtocol?` — never the Coordinator directly
- Coordinator conforms to the Navigator protocol
- All navigation methods are concrete — no abstract base
- Mark coordinator class `final`

## DI Wire-up

```swift
lazy var [feature]Navigator: [Feature]NavigatorProtocol = {
    [Feature]Coordinator(navigationController: self.navigationController)
}()
```

## Output

Confirm file path, list all Navigator protocol methods, and DI property name.
