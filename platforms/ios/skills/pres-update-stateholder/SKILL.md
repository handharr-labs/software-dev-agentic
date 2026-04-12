---
name: pres-update-stateholder
description: |
  Update an existing StateHolder *(iOS: ViewModel)* — add/remove State fields, Event cases, Action cases, or modify event handling logic.
user-invocable: false
---

Update an existing ViewModel following `.claude/reference/presentation.md`.

## Steps

1. **Read** the existing ViewModel file completely
2. **Grep** `.claude/reference/presentation.md` for the relevant pattern keyword; only **Read** the full file if the section cannot be located
3. **Apply targeted changes** — do not restructure unrelated code
4. **Check** if ViewController needs corresponding updates (binding new State fields, sending new Events)

## Common Update Scenarios

**Add a State field:**
```swift
struct State {
    var existingField: Type
    var newField: NewType = defaultValue  // ← add
}
```

**Add an Event + handler:**
```swift
enum Event {
    case existingEvent
    case newEvent(param: Type)  // ← add
}

// In emitEvent:
case .newEvent(let param):
    handleNewEvent(param)  // ← add case
```

**Add an Action:**
```swift
enum Action {
    case existingAction
    case newAction  // ← add
}
```

## Rules

- New code → V2 patterns. Existing code → keep its pattern (never force migration).
- `[weak self]` in all new closures
- After adding State fields, remind caller to update ViewController bindings
- After adding Events, remind caller to wire ViewController to send the new event

## Output

List all changes made with file paths and line numbers. Flag any ViewController updates needed.
