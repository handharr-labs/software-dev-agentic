---
name: pres-update-screen
description: Update an existing View component — add bindings for new state fields, new event handlers, or new sub-components. Called by ui-worker.
user-invocable: false
tools: Read, Edit, Glob
---

Update an existing View component following `reference/contract/builder/presentation.md`.

## Steps

1. **Read** the existing View file completely
2. **Read** the updated StateHolder to understand new state fields or mutations added
3. **Apply targeted changes** — do not restructure unrelated code

## Common Update Scenarios

**Bind a new state field:**
```tsx
// Destructure new field from StateHolder
const { existingField, newField } = useLeaveViewModel(deps)

// Render it
<NewComponent value={newField} />
```

**Add a new event handler (mutation):**
```tsx
<Button onClick={() => viewModel.newMutation.mutate(params)}>
  New Action
</Button>
```

**Add a new sub-component:**
```tsx
import { NewComponent } from './components/NewComponent'

// Inside render
<NewComponent item={newField} onAction={handleAction} />
```

**Add loading/error state for new query:**
```tsx
if (viewModel.newQuery.isLoading) return <Skeleton />
if (viewModel.newQuery.isError) return <ErrorState />
```

## Rules

- Views render — no business logic added here
- Never remove existing bindings unless explicitly asked
- `'use client'` must already be present if adding event handlers
- After adding event handlers, verify the StateHolder exposes the mutation/action

**Pattern:** `reference/contract/builder/presentation.md` — `Grep` for view/binding section.

## Output

List all changes made with file path and line numbers.
