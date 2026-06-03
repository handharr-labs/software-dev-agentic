---
platform: android
project: android-talenta
discipline: engineering
topic: data
pattern: dependency_rule
---

## Theory

Data depends on Domain only. It never imports from Presentation or UI.

```
Domain  ←  Data
```

Allowed imports: domain entities, repository interfaces, language primitives.
Forbidden: any presentation type, UI framework, StateHolder, or view import.

---

## Definition

Data depends on Domain only. It never imports from Presentation or UI.

**Allowed:** Retrofit2, OkHttp, Room, `@SerializedName` (Gson), `@Inject` (Dagger/Hilt), RxJava3 operators, domain entities and repository interfaces.

**Forbidden:**
- `import androidx.activity.*` / `import androidx.fragment.*` — Activity and Fragment are presentation concerns
- Any ViewModel, LiveData, or StateFlow from presentation — data layer must not know about UI state holders
- Any Presenter or View type — data layer output goes to domain, not directly to UI

## Code Pattern

```kotlin
// ✅ Allowed data layer imports
import retrofit2.http.GET
import com.mekari.commons.extension.orEmpty
import domain.entity.TimeOffRequest
import domain.repository.TimeOffRepository

// ❌ Never in data layer:
// import androidx.fragment.app.Fragment
// import presentation.presenter.TimeOffPresenter
```
