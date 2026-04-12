---
name: domain-create-usecase
description: |
  Create a UseCase with UseCaseProtocol conformance, nested Params struct, and DI wire-up.
user-invocable: false
---

Create a UseCase following `.claude/reference/domain.md §3.3` and DI rules in `.claude/reference/di.md §7.2`.

## Steps

1. **Grep** `.claude/reference/domain.md` for `§3.3` and `.claude/reference/di.md` for `§7.2`; only **Read** a file in full if the section cannot be located
2. **Locate** module path: `Talenta/Module/[Module]/Domain/UseCase/`
3. **Create** `[HttpMethod][Feature]UseCase.swift`
4. **Wire** into the module's `DIContainer`

## UseCase Pattern

```swift
protocol [HttpMethod][Feature]UseCaseProtocol {
    func call(params: [HttpMethod][Feature]UseCase.Params,
              completion: @escaping (Result<[ReturnModel], BaseErrorModel>) -> Void)
}

final class [HttpMethod][Feature]UseCase: [HttpMethod][Feature]UseCaseProtocol {
    struct Params {
        let paramName: ParamType
    }

    private let repository: [Feature]RepositoryProtocol

    init(repository: [Feature]RepositoryProtocol) {
        self.repository = repository
    }

    func call(params: Params,
              completion: @escaping (Result<[ReturnModel], BaseErrorModel>) -> Void) {
        repository.methodName(params: params, completion: completion)
    }
}
```

Rules:
- Protocol name = `[ClassName]Protocol`
- `Params` is a nested struct inside the UseCase class
- Return type: `Result<Model, BaseErrorModel>` — never raw types or throwing
- Inject repository via initializer — never instantiate directly
- Mark class `final`

## DI Wire-up

Add lazy property to `[Module]DIContainer`:
```swift
lazy var [feature]UseCase: [HttpMethod][Feature]UseCaseProtocol = {
    [HttpMethod][Feature]UseCase(repository: self.[feature]Repository)
}()
```

## Output

Confirm file path, protocol name, Params fields, and DI property name.
