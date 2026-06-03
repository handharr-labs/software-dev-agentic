---
platform: android
project: android-talenta
discipline: engineering
topic: ui
pattern: dependency_rule
---

## Theory

UI depends on Presentation only. It never imports from Domain or Data directly.

```
Presentation  ←  UI
```

Allowed imports: StateHolder contract types, State/Event/Action types, platform UI framework primitives.
Forbidden: use case interfaces, repository interfaces, DTOs, mappers, datasources, or any domain/data type instantiated directly.

---

## Definition

UI depends on Presentation only — never imports Domain or Data directly.

Allowed imports: Presenter contract interfaces, View contract interfaces, Android framework primitives (`Activity`, `Fragment`, `View`).
Forbidden: use case interfaces, repository interfaces, DTOs, mappers, datasources, or Retrofit types.

## Code Pattern

```kotlin
// ✅ Allowed in UI layer
import presentation.contract.TimeOffRequestContract
import presentation.presenter.TimeOffRequestPresenter
import android.os.Bundle
import android.view.LayoutInflater

// ❌ Never in UI layer
// import domain.usecase.GetTimeOffRequestsUseCase
// import data.response.TimeOffRequestResponse
// import service.TimeOffApi
```
