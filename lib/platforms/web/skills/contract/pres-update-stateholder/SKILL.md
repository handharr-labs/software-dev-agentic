---
name: pres-update-stateholder
description: Update an existing StateHolder — add/remove state fields, query keys, event handlers, or mutation actions. Called by presentation-worker.
user-invocable: false
tools: Read, Edit, Glob
---

Update an existing StateHolder (ViewModel hook or pure function) following `reference/contract/builder/presentation.md`.

## Steps

1. **Read** the existing StateHolder file completely
2. **Read** `reference/contract/builder/presentation.md` — `Grep` for the relevant pattern section
3. **Apply targeted changes** — do not restructure unrelated code

## Common Update Scenarios

**Add a state field (hook pattern):**
```ts
const [newField, setNewField] = useState<Type>(defaultValue)
// expose in returned object
return { ...existing, newField }
```

**Add a query (TanStack Query hook):**
```ts
const newQuery = useQuery({
  queryKey: ['feature', 'new-key', params],
  queryFn: () => useCases.getNewData.execute(params),
})
```

**Add a mutation:**
```ts
const newMutation = useMutation({
  mutationFn: (params: Params) => useCases.doNew.execute(params),
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['feature'] }),
})
```

**Add a derived field (pure function pattern):**
```ts
const newDerivedField = computeFromEntities(entities)
return { ...existing, newDerivedField }
```

## Rules

- No business logic — only state management or pure data transformation
- Never remove existing fields unless explicitly asked
- After adding state fields, flag that the View (`pres-update-screen`) needs updating

## Output

List all changes made with file path and line numbers. Flag any View updates needed.
