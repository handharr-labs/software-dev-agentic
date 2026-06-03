---
platform: ios
project: ios-talenta
discipline: engineering
topic: app
pattern: route_registration
---

## Theory

**Route Registration** is the act of declaring how the app navigates to a feature's screen — mapping a route identifier (string key, enum case, or coordinator type) to a screen factory.

**Invariants:**
- Routes live at the app shell or navigation coordinator — never inside a CLEAN layer
- Each feature owns one route declaration unit (route file, coordinator class, or destination enum)
- Route identifiers are stable string keys or typed values — not view instances
- Deep link destinations must be registered in the same place as regular routes

**When to add:** Any time a new screen is introduced. An unregistered route is a silent navigation failure.

---

## Route Registration

iOS uses the **Coordinator pattern** with `BaseCoordinator<ResultType>`.

**Step 1 — Create the Feature Coordinator:**

```swift
// Talenta/Controllers/{Feature}/{Feature}Coordinator.swift
final class {Feature}Coordinator: BaseCoordinator<{Feature}Result> {

    private let navigationController: UINavigationController
    private let component: {Feature}Component

    init(
        navigationController: UINavigationController,
        component: {Feature}Component
    ) {
        self.navigationController = navigationController
        self.component = component
    }

    override func start() -> Observable<{Feature}Result> {
        let viewModel = {Feature}ViewModel(
            navigator: self,
            get{Feature}UseCase: component.get{Feature}UseCase
        )
        let viewController = {Feature}ViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)

        return viewModel.result
            .take(1)
            .do(onNext: { [weak self] _ in
                self?.navigationController.popViewController(animated: true)
            })
    }
}
```

**Step 2 — Register deep link (if applicable):**

```swift
// Talenta/DIComponents/Deeplink/DeeplinkComponent.swift
extension DeeplinkComponent {
    func coordinate{Feature}(path: String) -> Observable<Void> {
        let component = {Feature}Component(parent: self)
        let coordinator = {Feature}Coordinator(
            navigationController: rootNavigationController,
            component: component
        )
        return coordinate(to: coordinator).map { _ in }
    }
}
```

**Rules:**
- ✅ One coordinator per feature flow
- ✅ `BaseCoordinator<ResultType>` — result type models what the coordinator returns to its parent
- ✅ Rx lifecycle: `start()` returns `Observable<ResultType>` — parent subscribes
- ❌ No `UIViewController` subclasses performing navigation directly
