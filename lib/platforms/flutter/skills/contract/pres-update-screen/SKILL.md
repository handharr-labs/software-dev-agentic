---
name: pres-update-screen
description: Update an existing Screen or View widget — add new state bindings, handle new events, add new widgets.
user-invocable: false
---

Update an existing Screen following `.claude/reference/contract/builder/presentation.md ## Screen Structure section`.

## Steps

1. **Read** the target Screen file completely
2. **Read** the updated State and Event files — identify what's new
3. **Edit** the Screen: add `BlocBuilder`/`BlocListener` bindings for new state fields; dispatch new events

Rules:
- New `ViewDataState<T>` fields need corresponding `buildWhen`/`listenWhen` predicates
- Each new side effect (navigation, toast) goes in `BlocListener`, not `BlocBuilder`
- New sub-widgets take entities as parameters — no BLoC passed down
- Keep `_[Feature]View` private — never promote to public widget
- `const` all constructors that can be const

## Output

Confirm file path and list bindings added/removed and events wired.
