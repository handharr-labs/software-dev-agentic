---
name: detective-debug-add-logs
description: Add strategic debug logs to a Next.js Clean Architecture codebase to trace execution flow at runtime.
user-invocable: false
tools: Read, Edit, Glob, Grep
---

# Debug: Add Strategic Logs (Web / Next.js)

Add `console.log` statements with a `[DebugTest]` prefix for easy filtering in browser devtools or server terminal.

## Log Format

```ts
// Method entry
console.log('[DebugTest][ClassName.methodName] entry —', { param1, param2 })

// State change
console.log('[DebugTest][ClassName.methodName] state —', { before, after })

// Result / exit
console.log('[DebugTest][ClassName.methodName] result —', result)

// Error
console.error('[DebugTest][ClassName.methodName] error —', error)
```

## Filtering

- **Browser devtools Console tab**: filter by `[DebugTest]`
- **Server terminal**: `| grep '\[DebugTest\]'`

## Placement by Layer

### StateHolder (ViewModel hook)
```ts
// Log event received and state change
const handleSubmit = useCallback((data: FormData) => {
  console.log('[DebugTest][useLeaveViewModel.handleSubmit] entry —', data)
  submitUseCase.execute(data).then(result => {
    console.log('[DebugTest][useLeaveViewModel.handleSubmit] result —', result)
    setState(result)
  }).catch(err => {
    console.error('[DebugTest][useLeaveViewModel.handleSubmit] error —', err)
  })
}, [])
```

### Use Case
```ts
async execute(params: Params): Promise<Result> {
  console.log('[DebugTest][SubmitLeaveUseCase.execute] entry —', params)
  const result = await this.repository.submit(params)
  console.log('[DebugTest][SubmitLeaveUseCase.execute] result —', result)
  return result
}
```

### Repository Impl
```ts
async submit(params: Params): Promise<Entity> {
  console.log('[DebugTest][LeaveRepositoryImpl.submit] entry —', params)
  try {
    const dto = await this.dataSource.submit(params)
    console.log('[DebugTest][LeaveRepositoryImpl.submit] raw dto —', dto)
    return this.mapper.toDomain(dto)
  } catch (error) {
    console.error('[DebugTest][LeaveRepositoryImpl.submit] error —', error)
    throw this.errorMapper.map(error)
  }
}
```

### Server Action
```ts
export const submitLeaveAction = createSafeAction(schema, async (data) => {
  console.log('[DebugTest][submitLeaveAction] entry —', data)
  const result = await container.submitLeaveUseCase.execute(data)
  console.log('[DebugTest][submitLeaveAction] result —', result)
  return result
})
```

## Key Principles

- Log entry params and exit results at every layer boundary
- Log before/after every conditional branch
- Log before/after every async boundary
- Never log passwords, tokens, or PII — use `[REDACTED]` or log `.length` only
- Never commit `[DebugTest]` logs — use `debug-remove-logs` to clean up

## Extension Point

Check for `.claude/skills.local/extensions/debug-add-logs.md` — if it exists, follow its additional instructions.
