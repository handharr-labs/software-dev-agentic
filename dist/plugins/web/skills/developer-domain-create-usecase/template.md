# UseCase Template

```typescript
// src/domain/use-cases/[feature]/[Verb][Feature]UseCase.ts
export interface [Verb][Feature]UseCaseParams {
  // params here
}

export interface [Verb][Feature]UseCase {
  execute(params: [Verb][Feature]UseCaseParams): Promise<[ReturnType]>;
}

export class [Verb][Feature]UseCaseImpl implements [Verb][Feature]UseCase {
  constructor(private readonly repository: [Feature]Repository) {}

  async execute(params: [Verb][Feature]UseCaseParams): Promise<[ReturnType]> {
    return this.repository.[method](params);
  }
}
```
