---
name: pres-update-screen
description: |
  Update an existing Screen *(iOS: ViewController)* — add bindings for new State fields, handle new Actions, or send new Events.
user-invocable: false
---

Update an existing ViewController following `.claude/reference/contract/builder/presentation.md ## ViewController section`.

## Steps

1. **Read** the existing ViewController file completely
2. **Read** the updated ViewModel to understand the new State/Event/Action changes
3. **Apply targeted changes** — do not restructure unrelated code

## Common Update Scenarios

**Bind a new State field:**
```swift
viewModel.stateDriver
    .compactMap({ $0.newField })
    .distinctUntilChanged()
    .drive(onNext: { [weak self] value in
        self?.newView.configure(value)
    })
    .disposed(by: disposeBag)
```

**Handle a new Action case:**
In the `actionDriver` switch, add:
```swift
case .newAction(let param):
    self.handleNewAction(param)
```

**Send a new Event:**
```swift
newButton.rx.tap
    .bind(onNext: { [weak self] in
        self?.viewModel.emitEvent(.newEvent)
    })
    .disposed(by: disposeBag)
```

## Rules

- `[weak self]` in all closures
- `distinctUntilChanged()` on all new state bindings
- `.disposed(by: disposeBag)` on all new subscriptions
- Never remove existing bindings unless explicitly asked
- New code → V2 patterns. Existing code → keep its pattern.

## Output

List all changes made with file paths and line numbers.
