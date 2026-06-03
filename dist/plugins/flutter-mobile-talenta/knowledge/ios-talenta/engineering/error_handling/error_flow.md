---
platform: ios
project: ios-talenta
discipline: engineering
topic: error_handling
pattern: error_flow
---

## Theory

Errors travel inward-to-outward, mapped at each layer boundary:

```
DataSource throws transport error (NetworkError, HTTP 4xx/5xx, DB exception)
    ↓ caught and mapped by
Repository Implementation → DomainError
    ↓ returned to
Use Case → propagates DomainError unchanged
    ↓ received by
StateHolder → maps to UI error State
    ↓ observed by
Screen → renders error UI
```

**Rule:** Each layer catches the error type from the layer below it and converts it to the type its consumers expect. No raw transport errors escape the Data layer. No domain errors escape the Presentation layer uncaught.

---

## Error Flow

```
DataSource throws NetworkError
    ↓ caught by
Repository transforms to BaseErrorModel
    ↓ propagated via
UseCase (passes through or enriches)
    ↓ caught by
ViewModel maps to user message → Action
    ↓ rendered by
ViewController shows error UI
```

## Error Types

```swift
// Shared/Domain/Entities/BaseErrorModel.swift
struct BaseErrorModel: Error {
    let status: Int?
    let message: String
    let errors: [String: [String]]?

    init(
        status: Int? = nil,
        message: String = "An error occurred",
        errors: [String: [String]]? = nil
    ) {
        self.status = status
        self.message = message
        self.errors = errors
    }
}
```

## Result Type

```swift
Result<Model, BaseErrorModel>

// Success
expected(.success(model))

// Failure
expected(.failure(BaseErrorModel(message: "Network error")))
```

All UseCase/Repository completions use `Result<Model, BaseErrorModel>`.

## Error Mapping

```swift
// Shared/Data/Mapper/BaseErrorModelMapper.swift
class BaseErrorModelMapper {
    func fromResponseToModel(from error: TalentaBaseError) -> BaseErrorModel {
        return BaseErrorModel(
            status: error.status,
            message: error.message.orEmpty(),
            errors: error.errors
        )
    }
}
```

**Pattern:**
- Map API errors to `BaseErrorModel` in repositories
- ViewModel handles result, emits actions (toast, alert)
- ViewController displays errors via actions

## Error UI

ViewController observes ViewModel actions to surface errors. Platform patterns are in `UIViewController+Extensions.swift`.

```swift
// In ViewController — drive error actions from ViewModel
viewModel.actionDriver
    .drive(onNext: { [weak self] action in
        switch action {
        case .showError(let message):
            self?.showErrorAlert(message: message)
        case .showToast(let message):
            self?.showToast(message)
        case .showFieldErrors(let errors):
            self?.showValidationErrors(errors)
        default:
            break
        }
    })
    .disposed(by: disposeBag)
```

**Rules:**
- ViewModel never references UIKit — it emits typed `Action` values
- ViewController maps actions to UI calls; no business logic here
- `showErrorAlert(message:)` for blocking errors; `showToast` for non-blocking

## Layer Invariants

- DataSources throw `NetworkError` — they never return `nil` or a partial `Result` to signal failure
- Repository implementations always catch and map to `BaseErrorModel` — no `NetworkError` propagates to use cases
- Use cases propagate `Result<Model, BaseErrorModel>` unchanged — they do not re-map errors
- ViewModels catch all results from use cases — no unhandled `Result.failure` reaches the ViewController
- ViewControllers never inspect `BaseErrorModel` codes directly — they render the `Action` the ViewModel emits
