---
name: domain-create-repository
description: |
  Create a Repository protocol in the Domain layer.
user-invocable: false
---

Create a Repository protocol following `.claude/reference/domain.md §3.2`.

## Steps

1. **Grep** `.claude/reference/domain.md` for `§3.2`; only **Read** the full file if the section cannot be located
2. **Locate** module path: `Talenta/Module/[Module]/Domain/Repository/`
3. **Create** `[Feature]RepositoryProtocol.swift`

## Repository Protocol Pattern

```swift
protocol [Feature]RepositoryProtocol {
    func methodName(params: [UseCase].Params,
                    completion: @escaping (Result<[Model], BaseErrorModel>) -> Void)
}
```

Rules:
- Protocol only — no implementation here (impl goes in Data layer as `[Feature]RepositoryImpl`)
- Method signatures mirror the UseCase's needs exactly
- Return type: `Result<Model, BaseErrorModel>`
- File contains only the protocol — no extensions, no helpers

## Output

Confirm file path and list all declared method signatures.
