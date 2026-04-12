---
name: data-create-repository-impl
description: |
  Create a RepositoryImpl in the Data layer that bridges DataSource → Mapper → Domain.
user-invocable: false
---

Create a RepositoryImpl following `.claude/reference/data.md §4.4`, DI rules in `.claude/reference/di.md §7.2`, and error utilities in `.claude/reference/error-utilities.md §8`.

## Steps

1. **Grep** `.claude/reference/data.md` for `§4.4`, `.claude/reference/di.md` for `§7.2`, and `.claude/reference/error-utilities.md` for `§8`; only **Read** a file in full if the section cannot be located
2. **Read** the Repository protocol, DataSource protocol, and Mapper protocol to understand signatures
3. **Locate** module path: `Talenta/Module/[Module]/Data/Repository/`
4. **Create** `[Feature]RepositoryImpl.swift`
5. **Wire** into the module's `DIContainer`

## RepositoryImpl Pattern

```swift
final class [Feature]RepositoryImpl: [Feature]RepositoryProtocol {
    private let dataSource: [Feature]DataSourceProtocol
    private let mapper: [Feature]ModelMapperProtocol

    init(dataSource: [Feature]DataSourceProtocol,
         mapper: [Feature]ModelMapperProtocol) {
        self.dataSource = dataSource
        self.mapper = mapper
    }

    func methodName(params: [UseCase].Params,
                    completion: @escaping (Result<[Model], BaseErrorModel>) -> Void) {
        dataSource.methodName(params: params) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let model = self.mapper.fromResponseToModel(from: response)
                completion(.success(model))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
```

Rules:
- Bridge DataSource (Response) → Mapper → Domain (Model)
- Use `[weak self]` in all closures
- Pass errors through unchanged — never swallow
- Mark class `final`
- Note: some RepositoryImpl files exist in the Domain layer — follow existing placement for the module

## DI Wire-up

```swift
lazy var [feature]Repository: [Feature]RepositoryProtocol = {
    [Feature]RepositoryImpl(
        dataSource: self.[feature]DataSource,
        mapper: self.[feature]Mapper
    )
}()
```

## Output

Confirm file path and DI property name.
