---
name: domain-update-usecase
description: |
  Update an existing UseCase — add/remove Params fields, change return type, or adjust repository call.
user-invocable: false
---

Update an existing UseCase following `.claude/reference/domain.md §3.3`.

## Steps

1. **Read** the existing UseCase file completely
2. **Grep** `.claude/reference/domain.md` for `§3.3`; only **Read** the full file if the section cannot be located
3. **Apply targeted changes only** — do not restructure unrelated code
4. **Check** if `[Feature]RepositoryProtocol` signature needs updating
5. **Check** if DI container usage needs updating

## Common Update Scenarios

**Add a Params field:**
```swift
struct Params {
    let existingField: Type
    let newField: NewType  // ← add here
}
```

**Change return type:** Update both protocol and implementation signature.

**Add a new method:** Add to both protocol and class.

## Rules

- New code → V2 patterns (nested Params, Result type). Existing code → keep its pattern.
- Never remove existing methods unless explicitly asked
- After updating Params, check all call sites in the codebase and update them

## Output

List all changes made with file paths and line numbers.
