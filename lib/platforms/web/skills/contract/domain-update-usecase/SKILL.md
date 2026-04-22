---
name: domain-update-usecase
description: Update an existing UseCase — add/remove Params fields, change return type, or adjust repository call. Called by domain-worker.
user-invocable: false
tools: Read, Edit, Glob
---

Update an existing UseCase following `reference/contract/builder/domain.md` — Grep `## Use Cases`.

## Steps

1. **Read** the existing UseCase file completely
2. **Apply targeted changes only** — do not restructure unrelated code
3. **Check** if `[Feature]Repository` interface signature needs updating
4. **Check** if DI registration needs updating

## Common Update Scenarios

**Add a Params field:**
```ts
// In the Params type
export type GetFeatureParams = {
  existingField: string
  newField: NewType  // ← add here
}
```

**Change return type:** Update both interface and `Impl` signature.

**Add a new method:** Add to both interface and `Impl` class.

## Rules

- Zero framework imports in domain layer
- `Impl` calls only the repository — no direct data source access
- Never remove existing methods unless explicitly asked
- After updating Params, check all call sites in the codebase and update them

## Output

List all changes made with file paths and line numbers.
