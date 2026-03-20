---
name: new-usecase
description: Create a use case (interface + implementation) for a domain operation. Use when adding a new business action.
allowed-tools: Read, Write, Glob
---

Create a new use case for this Next.js Clean Architecture project.

Ask me:
1. Operation verb + feature (e.g. `GetEmployee`, `SubmitLeaveRequest`, `DeleteEmployee`)
2. What repository method(s) does it call?
3. Input: what params does the caller provide?
4. Output: what entity does it return?
5. Does it need domain validation via a Service? If yes, what rule?

Then generate **`src/domain/use-cases/[feature]/[Verb][Feature]UseCase.ts`** containing:

**Params type**:
- GET single: `{ [entityId]: string }`
- GET list: `{ page: number; limit: number; [filters]?: type }`
- POST: `{ payload: { fields } }`
- PUT: `{ [entityId]: string; payload: { fields } }`
- DELETE: `{ [entityId]: string }`

**Interface**:
```typescript
export interface [Verb][Feature]UseCase {
  execute(params: [Verb][Feature]UseCaseParams): Promise<[Entity | void]>;
}
```

**Implementation**:
```typescript
export class [Verb][Feature]UseCaseImpl implements [Verb][Feature]UseCase {
  constructor(private readonly repository: [Feature]Repository) {}
  async execute(params: ...): Promise<...> { ... }
}
```

Rules:
- One `execute()` method, one responsibility
- If validation needed: inject a domain Service (not inline logic > 3 lines)
- Never import from `react`, `next`, `axios`, or Data/Presentation layers
- Constructor receives repository interface, not implementation

After creating, remind me to:
- Wire in `src/di/container.server.ts` and/or `container.client.ts`
- Create mock repository if not yet in `__tests__/mocks/`
- Add test: `__tests__/domain/use-cases/[Verb][Feature]UseCase.test.ts`
