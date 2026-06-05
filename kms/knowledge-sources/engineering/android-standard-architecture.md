Consolidated Android Clean Architecture reference — covers all engineering layers, patterns, and cross-cutting concerns used across Android projects.

# Domain

## Creation Order

### Theory

When building a new feature's domain layer:

```
Entity → Repository Interface → Use Case(s) → Domain Service (only if needed)
```

Never create a use case before the repository interface it depends on.

---

### Definition

When building a new feature's domain layer, create files in this sequence.

### Code Pattern

```
1. domain/entity/[Feature].kt                          ← Entity (pure Kotlin data class)
2. domain/repository/[Feature]Repository.kt            ← Repository interface
3. domain/usecase/Get[Feature]UseCase.kt
   domain/usecase/Submit[Feature]UseCase.kt
   ...                                                 ← Use Case(s) (extend SingleUseCase)
4. domain/service/[Feature][Concept]Service.kt         ← Domain Service (only if needed)
```

Never create a use case before the repository interface it depends on.

## Dependency Rule

### Theory

Domain is the innermost layer. It imports nothing from outer layers.

```
UI  →  Presentation  →  Data  →  Domain
```

Allowed imports: language primitives and pure functional utilities only.
Forbidden: any framework, UI library, HTTP client, database driver, or data-layer type.

---

### Definition

Domain is the innermost layer — it imports nothing from outer layers.

**Allowed:** Kotlin standard library (`kotlin.*`), `java.io.Serializable`, `RxJava3` schedulers used only in the base `UseCase` infrastructure.

**Forbidden:**
- `import retrofit2.*` — networking belongs in data
- `import androidx.*` — any AndroidX import signals a framework dependency
- Room annotations (`@Entity`, `@ColumnInfo`) — database concerns belong in data
- OkHttp types — HTTP client belongs in data
- Any `*Response`, `*Api`, or `*RepositoryImpl` type from the data layer

### Code Pattern

```kotlin
// domain/entity/TimeOffRequest.kt
// ✅ Pure Kotlin — no framework imports
data class TimeOffRequest(
    val id: String,
    val employeeId: String,
    val startDate: String,
    val endDate: String,
    val reason: String,
    val status: String,
    val totalDays: Int
)

// ❌ Never inside domain:
// import retrofit2.*
// import androidx.room.*
// import okhttp3.*
```

## Domain Error

### Theory

A **Domain Error** is the unified error type returned from all repository and use case operations. It decouples the domain from transport-layer error types (HTTP status codes, network errors).

**Invariants:**
- Domain operations return a Result/Either typed with the domain error — they never propagate raw network errors upward
- Repositories map transport errors to domain errors before returning
- Error codes are business-meaningful (`notFound`, `validationFailed`, `unauthorized`) — not HTTP status codes

---

### Definition

Typed exceptions thrown from the domain boundary. Repository implementations map transport errors to these before returning.

Rules:
- Sealed class — exhaustive `when` in presenter error handling
- No transport types leak out — `ApiException`, `IOException` are mapped in `RepositoryImpl`
- Presenters catch `DomainException` subtypes via `ErrorHandler`

### Code Pattern

```kotlin
// domain/exception/DomainException.kt
sealed class DomainException(message: String) : Exception(message) {
    class Unauthorized(message: String = "Unauthorized") : DomainException(message)
    class NotFound(message: String = "Resource not found") : DomainException(message)
    class NetworkError(message: String = "Network unavailable") : DomainException(message)
    class Unknown(message: String = "Unknown error") : DomainException(message)
}
```

## Domain Service

### Theory

A **Domain Service** contains pure business logic that spans multiple entities or is reused across multiple use cases.

**Invariants:**
- No I/O — no async, no network, no database, no file system
- No side effects — pure functions; same input always produces the same output
- No framework imports
- Returns structured data — never formatted strings, CSS classes, or display labels (presentation formats output)

**When to extract to a service:**

| Scenario | Decision |
|----------|----------|
| 1–3 line condition | Keep inline in use case |
| Complex multi-step validation | Extract to service |
| Logic reused across ≥ 2 use cases | Extract to service |
| Needs independent unit testing | Extract to service |

**Naming:** `[Feature][Noun]` — e.g. `LeaveBalanceCalculator`, `AttendanceScheduleResolver`

---

### Definition

Domain services encapsulate business logic that spans multiple entities or does not naturally belong to a single use case. In Android MVP, these are plain Kotlin classes with no Android framework dependencies.

Rules:
- Pure Kotlin — no Android imports, no RxJava, no framework dependencies
- Injected into use cases via `@Inject constructor`, never into presenters directly
- Name: `[Domain][Concept]Service`

### Code Pattern

```kotlin
// domain/service/TimeOffEligibilityService.kt
class TimeOffEligibilityService @Inject constructor() {
    fun isEligible(employee: Employee, requestDays: Int): Boolean {
        return employee.remainingLeave >= requestDays && !employee.isProbation
    }
}
```

## Entity

### Theory

An **Entity** is a pure data structure representing a business concept.

**Invariants:**
- No framework imports — value types or pure classes only
- No business logic — entities hold data; use cases execute logic
- No serialization annotations — no `@JsonKey`, no `Codable`, no `fromJson`
- Immutable — all properties are read-only; mutation produces a new instance (`copyWith`)
- Represent domain concepts, not API shapes — field names match the business domain, not the JSON payload

**When to create:** When the domain needs a named, typed concept with identified fields (e.g. `Employee`, `LeaveRequest`, `AttendanceRecord`).

---

### Definition

Pure Kotlin data classes — no JSON annotations, no Android framework imports.

Rules:
- Pure Kotlin data class — no `@SerializedName`, no `@Json`, no Android imports
- All properties non-optional at the domain boundary (use sensible defaults in mapper)
- Field names use domain terminology, not API field names
- Immutable — use `val` for all properties

### Code Pattern

```kotlin
// domain/entity/TimeOffRequest.kt
data class TimeOffRequest(
    val id: String,
    val employeeId: String,
    val startDate: String,
    val endDate: String,
    val reason: String,
    val status: String,
    val totalDays: Int
)
```

## Repository Interface

### Theory

A **Repository** is a contract that defines data access operations — *what* is needed, not *how* it is done.

**Invariants:**
- Lives in Domain as an interface/protocol/abstract class only — implementation lives in Data
- Returns domain Entities — never raw DTOs, API response types, or database records
- Method names follow the operation's intent: `get*`, `create*`, `update*`, `delete*`, `submit*`
- Parameters are domain objects — not raw dictionaries, JSON maps, or HTTP types
- Error type is the domain error type — never a networking or transport error

**When to create:** One repository per aggregate root or feature domain. Created before use cases — use cases depend on the repository interface.

---

### Definition

Defined in `domain/repository/` — platform-agnostic contracts only.

Rules:
- Interface only — no implementation in domain layer
- Return `Single<T>` (RxJava 3) for all async operations
- Params are domain types — never response/DTO types
- Name: `[Module]Repository` (one interface per feature module)

### Code Pattern

```kotlin
// domain/repository/TimeOffRepository.kt
interface TimeOffRepository {
    fun getTimeOffRequests(page: Int, limit: Int): Single<List<TimeOffRequest>>
    fun submitTimeOffRequest(request: SubmitTimeOffRequest): Single<TimeOffRequest>
}
```

## Use Case

### Theory

A **UseCase** encapsulates a single business operation: one class, one public method, one responsibility.

**Invariants:**
- One business operation per class — never combine unrelated operations
- Depends only on repository interfaces — never on repository implementations or data-layer types
- No framework dependencies — no HTTP clients, no UI types
- Accepts typed input (Params/Request struct) — never raw dictionaries or loose primitives
- Returns domain entities or primitives — never DTOs or view models
- All I/O goes through the repository — use cases never call APIs or databases directly

**Mandatory call flow — no exceptions:**
```
Presentation → UseCase → Repository    ✅
Presentation → Repository              ❌  direct call is a CLEAN violation
```

**When to create:** One use case per business operation (e.g. `GetEmployeeUseCase`, `SubmitLeaveRequestUseCase`, `ApproveLeaveRequestUseCase`). Even thin pass-through use cases are mandatory — they preserve a stable indirection point for future validation, caching, or logging without touching the presentation layer.

**Naming:** `[Verb][Feature]UseCase` — verb names the business operation, not the HTTP method.

**Params pattern by operation:**

| Operation | Params structure |
|-----------|-----------------|
| GET (single) | `id` or typed identifier |
| GET (list) | `{ page, limit, filters... }` |
| POST | `{ payload: { fields... } }` |
| PUT | `{ id, payload: { fields... } }` |
| DELETE | `id` |
| No input | platform `NoParams` / `Void` equivalent |

---

### Definition

Extend `SingleUseCase<Result, Params>` from `domain/usecase/base/`.

Rules:
- Annotate with `@OpenForTesting` to allow mocking in tests
- Use `@Inject constructor` — never instantiate directly
- Inject `SchedulerTransformers` and `Logger` with nullable defaults (test-friendly)
- `Params` is a nested data class inside the use case
- Return type wraps the domain entity — never raw response types
- Name: `[Action][Entity]UseCase` (e.g. `GetTimeOffRequestsUseCase`, `SubmitTimeOffUseCase`)

### Code Pattern

```kotlin
// domain/usecase/GetTimeOffRequestsUseCase.kt
@OpenForTesting
class GetTimeOffRequestsUseCase @Inject constructor(
    private val timeOffRepository: TimeOffRepository,
    schedulerTransformer: SchedulerTransformers? = null,
    logger: Logger? = null
) : SingleUseCase<List<TimeOffRequest>, GetTimeOffRequestsUseCase.Params>(
    schedulerTransformer?.applySingleIoSchedulers(),
    logger
) {

    override fun build(params: Params?): Single<List<TimeOffRequest>> = params!!.run {
        timeOffRepository.getTimeOffRequests(page, limit)
    }

    data class Params(
        val page: Int,
        val limit: Int
    )
}
```

# Data

## Creation Order

### Theory

**Remote API feature:**

```
DTO → Mapper → DataSource interface → DataSource impl → Repository impl
```

**Local DB feature:**

```
DB Record → DB DataSource interface → DB DataSource impl → DB Mapper → Repository impl
```

Never create a repository implementation before the DataSource it depends on.

---

### Definition

When building a new feature's data layer, create files in this sequence.

### Code Pattern

```
1. data/response/[Feature]Response.kt               ← DTO (*Response suffix, all nullable, @SerializedName)
2. data/mapper/[Feature]Mapper.kt                   ← Mapper (extends BaseMapper<Response, Entity>)
3. service/[Feature]Api.kt                          ← DataSource (Retrofit interface, *Api suffix)
4. data/repoimpl/[Feature]RepositoryImpl.kt         ← Repository implementation
```

Never create a repository implementation before the Retrofit API interface it depends on.

## Data Source

### Theory

A **DataSource** is an abstract interface for raw data access — remote (HTTP) or local (DB, cache).

**Invariants:**
- Interface only in the data layer — implementation is injected, never instantiated directly
- Methods return raw data (DTOs or primitives) — never domain entities
- One DataSource per data origin (remote API, local DB, cache) — do not mix sources in one interface
- Throws or returns transport-layer errors — the repository implementation maps these to domain errors

**When to create:** One DataSource interface per data origin per feature. Created after the DTO and mapper, before the repository implementation.

---

### Definition

Android implements the DataSource contract as a **Retrofit interface** (`*Api` suffix, placed in `service/`). The interface is the abstraction; Retrofit generates the implementation at runtime via Dagger injection — no separate `*Impl` class needed.

Rules:
- Return `Single<Response>` for endpoints with response body; `Completable` for DELETE/void endpoints
- Use `@Query` for URL params, `@Path` for path segments, `@Body` for request body
- One interface per feature module

### Code Pattern

```kotlin
// service/TimeOffApi.kt
interface TimeOffApi {
    @GET("v1/time-off/requests")
    fun getTimeOffRequests(
        @Query("page") page: Int,
        @Query("limit") limit: Int
    ): Single<TimeOffRequestListResponse>

    @POST("v1/time-off/requests")
    fun submitTimeOffRequest(
        @Body request: SubmitTimeOffRequest
    ): Single<TimeOffRequestResponse>

    @DELETE("v1/time-off/requests/{id}")
    fun deleteTimeOffRequest(@Path("id") id: String): Completable
}
```

## Dependency Rule

### Theory

Data depends on Domain only. It never imports from Presentation or UI.

```
Domain  ←  Data
```

Allowed imports: domain entities, repository interfaces, language primitives.
Forbidden: any presentation type, UI framework, StateHolder, or view import.

---

### Definition

Data depends on Domain only. It never imports from Presentation or UI.

**Allowed:** Retrofit2, OkHttp, Room, `@SerializedName` (Gson), `@Inject` (Dagger/Hilt), RxJava3 operators, domain entities and repository interfaces.

**Forbidden:**
- `import androidx.activity.*` / `import androidx.fragment.*` — Activity and Fragment are presentation concerns
- Any ViewModel, LiveData, or StateFlow from presentation — data layer must not know about UI state holders
- Any Presenter or View type — data layer output goes to domain, not directly to UI

### Code Pattern

```kotlin
// ✅ Allowed data layer imports
import retrofit2.http.GET
import domain.entity.TimeOffRequest
import domain.repository.TimeOffRepository

// ❌ Never in data layer:
// import androidx.fragment.app.Fragment
// import presentation.presenter.TimeOffPresenter
```

## DTO

### Theory

A **DTO (Data Transfer Object)** mirrors the raw API or database shape exactly.

**Invariants:**
- No domain logic — plain data container only
- No computed fields — no derived values, no formatting
- No domain entity types — DTOs use primitive types and nested DTOs
- Serialization annotations live here, not on domain entities (`@JsonKey`, `Codable`, `fromJson`)
- Field names match the API/DB schema — not the business domain vocabulary

**When to create:** One DTO per API response type or DB table row. Created before the mapper that consumes it.

---

### Definition

Android calls these **Response Models** (`*Response` suffix, placed in `data/response/`). Same contract as core — raw API shape, all fields nullable, `@SerializedName` for every field, no business logic. Never returned from repository — always mapped to an entity first.

Rules:
- All fields `val` and nullable (`?`) — server may omit any field
- Use `@SerializedName` for every field
- No business logic in response models
- Class suffix is `*Response`; file lives in `data/response/`

### Code Pattern

```kotlin
// data/response/TimeOffRequestListResponse.kt
data class TimeOffRequestListResponse(
    @SerializedName("data") val data: List<TimeOffRequestResponse>?,
    @SerializedName("meta") val meta: MetaResponse?
)

data class TimeOffRequestResponse(
    @SerializedName("id") val id: String?,
    @SerializedName("employee_id") val employeeId: String?,
    @SerializedName("start_date") val startDate: String?,
    @SerializedName("end_date") val endDate: String?,
    @SerializedName("reason") val reason: String?,
    @SerializedName("status") val status: String?,
    @SerializedName("total_days") val totalDays: Int?
)

data class MetaResponse(
    @SerializedName("total") val total: Int?,
    @SerializedName("page") val page: Int?,
    @SerializedName("limit") val limit: Int?
)
```

## Layer Invariants

### Theory

- Imports from domain layer only — never from presentation or UI
- Raw transport errors never propagate upward — repository implementation maps them to domain errors
- DTOs and DB records never cross into the domain layer — mappers are the boundary

---

### Definition

Enforced constraints for all data layer artifacts.

### Code Pattern

- Import from domain layer only — never from Activity, Fragment, ViewModel, or Presenter files
- `ApiException` and `IOException` never propagate upward — `RepositoryImpl` maps them to `DomainException` subtypes via `onErrorResumeNext` before returning to the domain
- `*Response` classes never cross into the domain layer — `mapper.map()` or `mapper.mapList()` is the boundary
- Retrofit interfaces are registered in the Dagger module — the concrete Retrofit implementation is never referenced outside the data layer
- Room DAOs and OkHttp `Interceptor` live only in data layer infrastructure files — never in domain or presentation

## Mapper

### Theory

A **Mapper** converts between a DTO and a domain entity — always defined as an interface with a concrete implementation.

**Invariants:**
- Always interface + implementation — never a plain utility function or static helper
- One direction per method: `toDomain(dto)` converts inward; `toDTO(entity)` converts outward (if write operations exist)
- No I/O — pure transformation only; no network calls, no DB reads
- No business logic — field mapping only; validation belongs in domain use cases
- Null/missing fields handled defensively — never let a missing API field crash the mapper

**When to create:** One mapper per DTO ↔ entity pair. Created after the DTO, before the DataSource implementation.

---

### Definition

Extend `BaseMapper<Response, Entity>` — map every entity field, use null-safety extensions.

Rules:
- **Every entity field must appear in the mapper call** — no silent defaults
- Use `.orEmpty()` for String/List, `.orZero()` for Int/Long/Double, `.orFalse()` or `.orTrue()` for Boolean
- Never use `?: ""` or `?: 0` — always the extension function
- Add `mapList(responses: List<Response>?)` helper for list mappings
- For nested objects: create a nested mapper class

### Code Pattern

```kotlin
// data/mapper/TimeOffRequestMapper.kt
import com.mekari.commons.extension.orEmpty
import com.mekari.commons.extension.orZero

class TimeOffRequestMapper : BaseMapper<TimeOffRequestResponse, TimeOffRequest> {
    override fun map(input: TimeOffRequestResponse): TimeOffRequest {
        return TimeOffRequest(
            id = input.id.orEmpty(),
            employeeId = input.employeeId.orEmpty(),
            startDate = input.startDate.orEmpty(),
            endDate = input.endDate.orEmpty(),
            reason = input.reason.orEmpty(),
            status = input.status.orEmpty(),
            totalDays = input.totalDays.orZero()
        )
    }

    fun mapList(responses: List<TimeOffRequestResponse>?): List<TimeOffRequest> {
        return responses?.map { map(it) } ?: emptyList()
    }
}
```

## Repository Implementation

### Theory

A **Repository Implementation** implements the domain repository interface using a DataSource and Mapper.

**Invariants:**
- Implements a domain repository interface — it is the bridge between Data and Domain
- Calls the DataSource for raw data, calls the Mapper to convert to domain entities
- Wraps all DataSource calls with error handling — maps transport errors to domain errors before returning
- Never lets raw HTTP errors, DB exceptions, or transport-layer types propagate to the domain
- Never calls another repository implementation directly

**When to create:** Last in the creation order — after DataSource interface and implementation exist.

---

### Definition

Implement domain repository interface — inject API and mapper via Dagger.

Rules:
- `@Inject constructor` — Dagger provides all dependencies
- Use `mapper.mapList(response.data)` for list responses
- Map `ApiException` to domain exceptions via `onErrorResumeNext`
- Never expose response types outside the data layer

### Code Pattern

```kotlin
// data/repoimpl/TimeOffRepositoryImpl.kt
class TimeOffRepositoryImpl @Inject constructor(
    private val api: TimeOffApi,
    private val mapper: TimeOffRequestMapper
) : TimeOffRepository {

    override fun getTimeOffRequests(page: Int, limit: Int): Single<List<TimeOffRequest>> {
        return api.getTimeOffRequests(page, limit)
            .map { response -> mapper.mapList(response.data) }
            .onErrorResumeNext { throwable ->
                when (throwable) {
                    is ApiException -> when (throwable.code) {
                        401 -> Single.error(UnauthorizedException())
                        404 -> Single.error(NotFoundException())
                        else -> Single.error(throwable)
                    }
                    is IOException -> Single.error(NetworkException())
                    else -> Single.error(throwable)
                }
            }
    }

    override fun deleteTimeOffRequest(id: String): Completable {
        return api.deleteTimeOffRequest(id)
    }
}
```

# Presentation

## Component

### Theory

A **Component** (also called Sub-view, Widget, or View) is a reusable UI element smaller than a full screen.

**Invariants:**
- Stateless by default — receives data via props/parameters and emits callbacks
- If stateful, bound to a scoped StateHolder — never manages business state inline
- No use case calls — all data passed in from the parent screen or a scoped StateHolder
- Reuse check required before creating — search shared component directories first

**When to create:** When a UI element appears in ≥2 screens, or when a screen section is complex enough to isolate for readability.

---

### Definition

Reusable item view for RecyclerView — ViewHolder pattern, no Presenter awareness. Receives a plain data class via `bind(model)`.

Path: `presentation/common/[Feature]ItemView.kt` or as a ViewHolder inside `[Feature]Adapter.kt`

Rules:
- `UIModel` is a plain data class — display values only, no business logic
- No Presenter or UseCase references inside ViewHolder
- Use ViewBinding — no `findViewById`

### Code Pattern

```kotlin
class [Feature]ViewHolder(
    private val binding: Item[Feature]Binding
) : RecyclerView.ViewHolder(binding.root) {

    data class UIModel(
        val title: String,
        val subtitle: String
    )

    fun bind(model: UIModel) {
        binding.titleText.text = model.title
        binding.subtitleText.text = model.subtitle
    }
}
```

## Creation Order

### Theory

```
Use Cases → StateHolder → StateHolder contract → Screen
```

Never write the screen before the StateHolder contract exists.

---

### Definition

```
Use Cases → Presenter (StateHolder) → MVP Contract → StateHolder contract → Activity/Fragment
```

Never write the Activity/Fragment before the StateHolder contract exists.

### Code Pattern

Before the UI worker writes the Activity/Fragment, the feature worker produces a stateholder contract file containing:
- Presenter class name and file path
- Contract.View interface methods (name, parameter types)
- Contract.Presenter interface methods (name, parameter types)
- Navigation interface name and methods (if navigation is involved)
- Dagger injection keys or module bindings

## Dependency Rule

### Theory

Presentation depends on Domain only. It never imports from the Data layer.

```
Domain  ←  Presentation
```

Allowed imports: domain use case interfaces, domain entities, language primitives.
Forbidden: any DataSource, RepositoryImpl, DTO, mapper, HTTP client, or database type.

---

### Definition

Presentation depends on Domain only — no Data layer imports. Presenter and Activity/Fragment may only import domain use case interfaces, domain entities, and Android/Kotlin primitives.

Forbidden: any `RepositoryImpl`, `DataSource`, `DTO`, mapper, `Retrofit` interface, or Room type inside the Presentation layer.

### Code Pattern

```kotlin
// ✅ Allowed in presentation layer
import domain.usecase.GetTimeOffRequestsUseCase
import domain.entity.TimeOffRequest
import domain.exception.DomainException

// ❌ Never in presentation layer
// import data.repoimpl.TimeOffRepositoryImpl
// import data.response.TimeOffRequestResponse
// import service.TimeOffApi
```

## Logging

### Theory

**Logger** is the centralized logging abstraction with severity levels. All log output goes through this interface.

---

### Definition

Log format: `Log.d("DebugTest", "[MethodName] <event> — <value>")`.

Rules:
- Use `"DebugTest"` tag on every log — filter in Logcat with tag `DebugTest`
- Never log passwords or tokens — log `.length` instead
- Never commit `[DebugTest]` logs

### Code Pattern

```kotlin
Log.d("DebugTest", "[methodName] entry — param: $param")
Log.d("DebugTest", "[methodName] state — before: $before, after: $after")
Log.d("DebugTest", "[methodName] error — $error")
```

## MVP Contract

### Theory

**Events** (also called Input or Intent) represent user intentions flowing into the StateHolder.
**Actions** (also called Output or SideEffects) represent one-time side effects the StateHolder emits after processing an event.

---

### Definition

Interface defining the View and Presenter contracts for a feature screen.

Rules:
- One Contract interface per screen
- `View` extends `BaseMvpView`; `Presenter` extends `BaseMvpPresenter<View>`
- View methods are UI commands: show/hide/navigate — no business logic
- Presenter methods correspond to user interactions and lifecycle events
- Name: `[Feature]Contract`

### Code Pattern

```kotlin
// presentation/[feature]/TimeOffRequestContract.kt
interface TimeOffRequestContract {

    interface View : BaseMvpView {
        fun showTimeOffRequests(requests: List<TimeOffRequest>)
        fun showError(error: Throwable)
        fun showEmptyState()
    }

    interface Presenter : BaseMvpPresenter<View> {
        fun loadTimeOffRequests(id: String)
        fun refreshData()
    }
}
```

## Presenter

### Theory

A **StateHolder** is the single source of truth for a screen's UI state. Use cases are injected via DI — never instantiated directly inside the StateHolder.

---

### Definition

Extends `BasePresenter<View>` — injects use case and `ErrorHandler` via Dagger.
Uses `doOnSubscribe`/`doFinally` for loading state, `addToDisposables()` for cleanup.

Rules:
- `@Inject constructor` — Dagger provides use cases, SchedulerTransformers, ErrorHandler
- `doOnSubscribe { view?.showLoading() }` / `doFinally { view?.hideLoading() }` — loading state always managed this way
- `errorHandler.proceed(error)` — delegates error display to the ErrorHandler; never call `view?.showError(error.message.orEmpty())` directly
- `addToDisposables()` — disposes on `detachView()`; never call `dispose()` manually
- `view?.` guard on all view calls — view may be null after `detachView()`
- One presenter per screen

### Code Pattern

```kotlin
// presentation/[feature]/TimeOffRequestPresenter.kt
class TimeOffRequestPresenter @Inject constructor(
    private val getTimeOffRequestsUseCase: GetTimeOffRequestsUseCase,
    private val schedulerTransformers: SchedulerTransformers?,
    private val errorHandler: ErrorHandler
) : BasePresenter<TimeOffRequestContract.View>(), TimeOffRequestContract.Presenter {

    override fun loadTimeOffRequests(id: String) {
        val params = GetTimeOffRequestsUseCase.Params(id)
        getTimeOffRequestsUseCase.execute(params)
            .doOnSubscribe { view?.showLoading() }
            .doFinally { view?.hideLoading() }
            .subscribe(
                { requests -> view?.showTimeOffRequests(requests) },
                { error -> errorHandler.proceed(error) }
            )
            .addToDisposables()
    }

    override fun refreshData() {
        // re-invoke loadTimeOffRequests
    }
}
```

## Screen Structure

### Theory

A **Screen** is a full-page view bound to a single StateHolder. It observes state and sends events — it contains no business logic.

**Invariants:**
- Bound to exactly one StateHolder — instantiated via DI, never with direct `new` / `init`
- Observes every State field declared in the StateHolder contract — no State field goes unhandled
- Sends events to the StateHolder for every user interaction — never mutates state directly
- Contains no business logic — conditionals exist only to decide what to render, not what to compute
- No use case calls — all data flows through the StateHolder

---

### Definition

Extends `BaseMvpVbActivity<Presenter, View, Binding>` — three type params in order: Presenter contract, View contract, ViewBinding. ViewBinding via `bindingInflater`, presenter injected via `@Inject`.

Rules:
- Extends `BaseMvpVbActivity<Presenter, View, Binding>` — type param order is `<Presenter, View, Binding>`; handles `attachView`/`detachView` lifecycle automatically
- `@Inject override lateinit var presenter` — Dagger field injection for presenter
- `bindingInflater` property provides the ViewBinding — no `setContentView` needed
- Override `onViewCreated` (not `onCreate`) for setup logic
- Use `companion object { fun newIntent(...) }` for activity launch — not direct `startActivity`
- `BaseMvpVbFragment` for Fragment-based screens — same pattern

### Code Pattern

```kotlin
// presentation/[feature]/TimeOffRequestActivity.kt
class TimeOffRequestActivity :
    BaseMvpVbActivity<TimeOffRequestPresenter, TimeOffRequestContract.View, ActivityTimeOffRequestBinding>(),
    TimeOffRequestContract.View {

    @Inject
    override lateinit var presenter: TimeOffRequestPresenter

    override val bindingInflater: (LayoutInflater) -> ActivityTimeOffRequestBinding
        get() = ActivityTimeOffRequestBinding::inflate

    override fun onViewCreated(savedInstanceState: Bundle?) {
        val featureId = intent.getStringExtra(EXTRA_FEATURE_ID)
        presenter.loadTimeOffRequests(featureId.orEmpty())

        binding.swipeRefresh.setOnRefreshListener {
            presenter.refreshData()
        }
    }

    override fun showTimeOffRequests(requests: List<TimeOffRequest>) {
        adapter.submitList(requests)
    }

    override fun showError(error: Throwable) {
        showToast(error.message.orEmpty())
    }

    override fun showEmptyState() {
        binding.emptyStateView.isVisible = true
    }

    companion object {
        private const val EXTRA_FEATURE_ID = "extra_feature_id"

        fun newIntent(context: Context, featureId: String) =
            Intent(context, TimeOffRequestActivity::class.java).apply {
                putExtra(EXTRA_FEATURE_ID, featureId)
            }
    }
}
```

## State Holder

### Theory

A **StateHolder** is the single source of truth for a screen's UI state. Platform names vary (ViewModel, BLoC, Presenter) but the contract is identical across platforms.

**Invariants:**
- Owns no view imports — no UI framework, no widget, no component type
- Depends on use case interfaces only — never calls repositories or data sources directly
- Use cases are injected via DI — never instantiated directly inside the StateHolder
- Exposes state as a read-only stream or observable — UI observes, never mutates
- One StateHolder per screen — never shared across screens unless explicitly scoped

**When to create:** One StateHolder per screen. Created before the screen that observes it.

---

### Definition

In Android (MVP), the StateHolder is the **Presenter** extending `BasePresenter<View>`.

Invariants:
- Receives use cases via `@Inject constructor` — Dagger provides all dependencies; never instantiate use cases directly
- Drives the View interface imperatively via `view?.show*` / `view?.hide*` calls — Activity/Fragment never mutates presenter state
- Calls navigation via an injected `Navigation` interface — never starts Activities directly from the Presenter
- One Presenter per screen — scoped to the Activity/Fragment lifecycle via `attachView`/`detachView`

### Code Pattern

```kotlin
// presentation/[feature]/TimeOffRequestPresenter.kt
class TimeOffRequestPresenter @Inject constructor(
    private val getTimeOffRequestsUseCase: GetTimeOffRequestsUseCase,
    private val schedulerTransformers: SchedulerTransformers?,
    private val errorHandler: ErrorHandler
) : BasePresenter<TimeOffRequestContract.View>(), TimeOffRequestContract.Presenter {

    override fun loadTimeOffRequests(id: String) {
        val params = GetTimeOffRequestsUseCase.Params(id)
        getTimeOffRequestsUseCase.execute(params)
            .doOnSubscribe { view?.showLoading() }
            .doFinally { view?.hideLoading() }
            .subscribe(
                { requests -> view?.showTimeOffRequests(requests) },
                { error -> errorHandler.proceed(error) }
            )
            .addToDisposables()
    }

    override fun refreshData() {
        // re-invoke loadTimeOffRequests
    }
}
```

## State Management

### Theory

**State** is an immutable snapshot of what the UI should render at a given moment.

**Invariants:**
- Immutable — produced by the StateHolder, never mutated by the UI
- Covers all render cases: loading, data (success), error
- No view logic — no CSS classes, no display strings, no format calls; formatting happens in the UI layer
- Typed — each field has a declared type; avoid untyped `any` or `Object`

**Common shape:**

```
loading  →  no data yet; UI shows a spinner or skeleton
data     →  domain entities or view-ready primitives ready to render
error    →  domain error type; UI decides how to display it
```

---

### Definition

Android MVP has no explicit state container. The **View interface** is the state surface — the Presenter drives it imperatively via `view?.show*` / `view?.hide*` calls. Loading, success, and error states are expressed as discrete View methods rather than a sealed state class.

For screens that need richer state (e.g. multi-section loading), define a `ViewState` data class and expose it via a single `renderState(state: ViewState)` method on the View interface.

### Code Pattern

```kotlin
interface TimeOffRequestContract {
    interface View : BaseMvpView {
        fun showLoading()        // loading state
        fun hideLoading()        // loading cleared
        fun showTimeOffRequests(requests: List<TimeOffRequest>)  // success state
        fun showError(error: Throwable)   // error state
        fun showEmptyState()              // empty state
    }
}
```

# Dependency Injection

## Activity Binding

### Theory

`@ContributesAndroidInjector` scopes injection to the Activity/Fragment lifetime.

---

### Definition

Activity binding module wires Dagger injection for an Activity and its associated feature module.

Rules:
- Register the activity module in the app-level `ActivityModule` or equivalent binding module
- Presenter is injected by Dagger via `@Inject` — declare it as `@Inject lateinit var presenter` in the activity
- Do not instantiate any injectable class with `MyClass()`; always let Dagger provide it

### Code Pattern

```kotlin
// di/TimeOffActivityModule.kt
@Module
abstract class TimeOffActivityModule {

    @ContributesAndroidInjector(modules = [TimeOffModule::class])
    abstract fun contributeTimeOffRequestActivity(): TimeOffRequestActivity
}
```

## DI Module

### Theory

Each feature owns its own registration unit (component, module, or file) — one file per feature.

---

### Definition

Feature DI module containing all `@Provides` bindings for a feature.

### Code Pattern

```kotlin
// di/TimeOffModule.kt
@Module
class TimeOffModule {

    @Provides
    fun provideTimeOffApi(retrofit: Retrofit): TimeOffApi {
        return retrofit.create(TimeOffApi::class.java)
    }

    @Provides
    fun provideTimeOffRequestMapper(): TimeOffRequestMapper {
        return TimeOffRequestMapper()
    }

    @Provides
    fun provideTimeOffRepository(
        api: TimeOffApi,
        mapper: TimeOffRequestMapper
    ): TimeOffRepository {
        return TimeOffRepositoryImpl(api, mapper)
    }
}
```

## DI Principles

### Theory

These rules apply regardless of framework:

1. **Constructor injection** — dependencies are declared as constructor parameters, never fetched inside a class body
2. **Depend on interfaces, not implementations** — callers reference abstract types; the container resolves the concrete class
3. **No `new` inside business logic** — use cases, StateHolders, and repository implementations never instantiate their own dependencies
4. **Container owns lifecycle** — the DI container decides whether a dependency is a singleton, feature-scoped, or transient; callers never manage this
5. **One container per runtime boundary** — if your platform has multiple runtimes, each runtime gets its own container; never share a container across boundaries

---

### Definition

- Prefer constructor injection (`@Inject constructor`) — avoid field injection except in Activities/Fragments
- Dagger modules live in each feature's `di/` package
- `app/` composes the top-level component graph
- Use `@ContributesAndroidInjector` for activities and fragments

### Code Pattern

```kotlin
// ✅ Constructor injection (use cases, presenters, repositories)
class TimeOffRequestPresenter @Inject constructor(
    private val useCase: GetTimeOffRequestsUseCase,
    private val errorHandler: ErrorHandler
) : BasePresenter<TimeOffRequestContract.View>()

// ✅ Field injection (Activities/Fragments only)
class TimeOffRequestActivity : BaseMvpVbActivity<...>() {
    @Inject
    override lateinit var presenter: TimeOffRequestPresenter
}

// ❌ Never instantiate directly
// val presenter = TimeOffRequestPresenter(useCase, errorHandler)
```

## Registration Order

### Theory

Dependencies must be registered before they are resolved. The correct registration order mirrors the dependency graph:

```
Infrastructure (HTTP client, DB driver)
  → DataSources
  → Mappers
  → Repository Implementations
  → Use Cases
  → StateHolders
```

Register leaf nodes (no dependencies) first. Register consumers after their dependencies.

---

### Definition

Dagger resolves the dependency graph at compile time, but module declarations must follow leaf-first order to keep the graph readable.

### Code Pattern

```kotlin
// TimeOffModule.kt — leaf-first registration
@Module
class TimeOffModule {
    // 1. Infrastructure — no app dependencies
    @Provides fun provideTimeOffApi(retrofit: Retrofit): TimeOffApi = retrofit.create(TimeOffApi::class.java)

    // 2. Mappers — no dependencies
    @Provides fun provideTimeOffRequestMapper(): TimeOffRequestMapper = TimeOffRequestMapper()

    // 3. Repository — depends on Api + Mapper
    @Provides fun provideTimeOffRepository(api: TimeOffApi, mapper: TimeOffRequestMapper): TimeOffRepository =
        TimeOffRepositoryImpl(api, mapper)

    // 4. Use Case — depends on Repository (provided via @Inject constructor in UseCase class)
}
```

## Scope Rules

### Theory

| Scope | Use for | Lifetime |
|---|---|---|
| Singleton | Shared infrastructure — HTTP client, token store, logger | App lifetime |
| Feature-scoped | StateHolders and use cases for a single feature | Screen/route lifetime |
| Transient | Stateless helpers, mappers, pure services | Per-resolution |

**Never register a StateHolder as a singleton** — it holds mutable UI state that must be reset when the screen is destroyed.

---

### Definition

| Dagger scope | Use for | Lifetime |
|---|---|---|
| `@Singleton` | HTTP client (`Retrofit`), database, shared utilities | App lifetime |
| `@ActivityScoped` / feature scope | Presenters — one per Activity/Fragment | Screen lifetime |
| Unscoped (default) | Mappers, pure helpers — stateless, cheap | Per-resolution |

**Never scope a Presenter as `@Singleton`** — it holds a View reference that must be released when the Activity is destroyed. Use `@ActivityScoped` or inject via `@ContributesAndroidInjector`.

### Code Pattern

```kotlin
// ✅ Singleton — shared infrastructure
@Singleton
@Provides fun provideRetrofit(okHttpClient: OkHttpClient): Retrofit = Retrofit.Builder()
    .client(okHttpClient)
    .build()

// ✅ ActivityScoped — presenter
@ActivityScoped
@Provides fun provideTimeOffPresenter(
    useCase: GetTimeOffRequestsUseCase,
    errorHandler: ErrorHandler
): TimeOffRequestPresenter = TimeOffRequestPresenter(useCase, errorHandler)

// ✅ Unscoped (default) — mappers
@Provides fun provideTimeOffRequestMapper(): TimeOffRequestMapper = TimeOffRequestMapper()
```

## Testing with DI

### Theory

- Swap real implementations for test doubles at registration time — the caller never changes
- Each test gets its own container instance — never share container state across tests
- Verify that the container resolves the full dependency graph in an integration test — catches missing registrations before runtime

---

### Definition

In unit tests, bypass Dagger entirely — instantiate the class under test directly with `@Mock` dependencies.

Each test class is self-contained. Never share a Dagger component or module instance across test classes — recreate in `@Before`.

### Code Pattern

```kotlin
@RunWith(MockitoJUnitRunner::class)
class TimeOffRepositoryImplTest {
    @Mock lateinit var mockApi: TimeOffApi
    @Mock lateinit var mockMapper: TimeOffRequestMapper

    private lateinit var repository: TimeOffRepositoryImpl

    @Before
    fun setUp() {
        // No Dagger — construct directly with mocks
        repository = TimeOffRepositoryImpl(mockApi, mockMapper)
    }
}
```

# Navigation

## Navigator

### Theory

A **Navigator** (web/Flutter/Android) or **Coordinator** (iOS) is the single owner of navigation logic for a feature or flow.

**Invariants:**
- Defined as an interface/protocol — the Screen or Presenter holds only the interface, never the concrete type
- Implemented in a separate class that knows how to resolve the destination (push a controller, call `context.go`, start an Activity)
- The StateHolder (ViewModel/Bloc/Presenter) emits a navigation intent — the Navigator/Coordinator decides the implementation
- Knows route constants or destination types — the Screen does not
- One Navigator/Coordinator per feature flow — not per screen
- Injected into the StateHolder — never instantiated by the Screen or StateHolder directly

**When to create:** When a screen navigates to another screen. Created after the Screen that triggers navigation.

---

### Definition

Each feature defines a navigation interface and implementation. The presenter holds the interface; the Activity/Fragment provides the `Context`.

Android does not use the Navigation Component. Navigation is handled via custom `NavigationImpl` classes injected into presenters.

Rules:
- Navigation interfaces live in `base/common` module — not in feature modules
- Inject `Navigation` interface into Presenter, not Activity
- Activity provides `Context` via `view?.getContext()` — never store Activity reference in Presenter
- Each Activity exposes a `companion object { fun newIntent(...) }` factory

### Code Pattern

```kotlin
// navigation/TimeOffNavigation.kt (base/common module)
interface TimeOffNavigation {
    fun navigateToTimeOffDetail(context: Context, requestId: String)
    fun navigateToSubmitTimeOff(context: Context)
}

// navigation/TimeOffNavigationImpl.kt
class TimeOffNavigationImpl @Inject constructor() : TimeOffNavigation {
    override fun navigateToTimeOffDetail(context: Context, requestId: String) {
        context.startActivity(TimeOffDetailActivity.newIntent(context, requestId))
    }

    override fun navigateToSubmitTimeOff(context: Context) {
        context.startActivity(SubmitTimeOffActivity.newIntent(context))
    }
}

// Inject navigation into presenter when cross-screen navigation is needed:
class TimeOffPresenter @Inject constructor(
    private val useCase: GetTimeOffRequestsUseCase,
    private val navigation: TimeOffNavigation,
    private val errorHandler: ErrorHandler
) : BasePresenter<TimeOffContract.View>(), TimeOffContract.Presenter {

    override fun onRequestSelected(requestId: String) {
        view?.let { navigation.navigateToTimeOffDetail(it.getContext(), requestId) }
    }
}
```

## Route Constants

### Theory

**Route Constants** are named, centralized identifiers for every navigation destination in the app.

**Invariants:**
- All destination identifiers defined in a single constants file per feature or app — never hard-coded at the call site
- String paths (web/Flutter) or typed class references (Android/iOS) — platform dictates the form, the principle is the same
- Parameterised routes expose a typed helper function/method — callers never construct path strings inline
- Route constants exported from the feature or navigation module — consumers import the constant, not a string literal

**When to create:** Before any screen that navigates to a destination. Constants file created once per feature; entries added as destinations are added.

---

### Definition

Android does not use string route constants. Activity class references serve as the routing mechanism. If deep links are added, register URI patterns here.

### Code Pattern

```kotlin
// Android routing via Activity companion object factory — no string route constants needed
companion object {
    private const val EXTRA_FEATURE_ID = "extra_feature_id"

    fun newIntent(context: Context, featureId: String) =
        Intent(context, TimeOffRequestActivity::class.java).apply {
            putExtra(EXTRA_FEATURE_ID, featureId)
        }
}
```

# Error Handling

## Error Flow

### Theory

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

### Definition

```
DataSource (ApiException / IOException)
      ↓
RepositoryImpl  →  maps to DomainException
      ↓
UseCase         →  propagates via RxJava onError
      ↓
Presenter       →  ErrorHandler.handle() → view?.showError()
      ↓
View (Activity/Fragment)  →  shows Toast / inline error UI
```

### Code Pattern

```kotlin
// Full error flow:

// 1. DataSource throws ApiException
interface TimeOffApi {
    @GET("v1/time-off/requests")
    fun getTimeOffRequests(...): Single<TimeOffRequestListResponse>
    // ApiException thrown by ErrorInterceptor on non-2xx response
}

// 2. RepositoryImpl maps to DomainException
.onErrorResumeNext { throwable ->
    when (throwable) {
        is ApiException -> when (throwable.code) {
            401 -> Single.error(DomainException.Unauthorized())
            404 -> Single.error(DomainException.NotFound())
            else -> Single.error(throwable)
        }
        is IOException -> Single.error(DomainException.NetworkError())
        else -> Single.error(throwable)
    }
}

// 3. Presenter delegates to ErrorHandler
{ error -> errorHandler.handle(error) { view?.showError(it) } }

// 4. View renders error
override fun showError(error: Throwable) {
    showToast(error.message.orEmpty())
}
```

## Error Handler

### Theory

The StateHolder maps `DomainError` to an error State that the screen renders. Never show raw error messages or stack traces to users.

---

### Definition

Central error handler injected into presenters. Never call `view?.showError(error.message)` directly.

### Code Pattern

```kotlin
class FeaturePresenter @Inject constructor(
    private val useCase: GetFeatureUseCase,
    private val errorHandler: ErrorHandler
) : BasePresenter<FeatureContract.View>(), FeatureContract.Presenter {

    override fun loadData(id: String) {
        useCase.execute(GetFeatureUseCase.Params(id))
            .doOnSubscribe { view?.showLoading() }
            .doFinally { view?.hideLoading() }
            .subscribe(
                { view?.showData(it) },
                { error -> errorHandler.handle(error) { view?.showError(it) } }
            )
            .addToDisposables()
    }
}
```

## Error Interceptor

### Theory

The DataSource layer throws transport errors — it never returns null to signal failure. The repository implementation maps these to domain errors.

---

### Definition

OkHttp interceptor that converts non-2xx HTTP responses into `ApiException` before they reach the Retrofit interface.

### Code Pattern

```kotlin
class ErrorInterceptor @Inject constructor(private val gson: Gson) : Interceptor {

    override fun intercept(chain: Interceptor.Chain): Response {
        val response = chain.proceed(chain.request())
        if (!response.isSuccessful) {
            val errorBody = response.body?.string()
            val errorResponse = try { gson.fromJson(errorBody, ErrorResponse::class.java) } catch (e: Exception) { null }
            throw ApiException(
                code = response.code,
                errorResponse = errorResponse,
                message = errorResponse?.error?.message ?: "Unknown error"
            )
        }
        return response
    }
}
```

## Error Mapping

### Theory

Repository implementations own the mapping from transport errors to domain errors:

- HTTP 404 → `DomainError.notFound`
- HTTP 401/403 → `DomainError.unauthorized`
- HTTP 422 / validation response → `DomainError.validationFailed`
- Network timeout / no connection → `DomainError.networkUnavailable`
- HTTP 5xx / unexpected → `DomainError.serverError`
- Parse failure → `DomainError.serverError` (malformed response is a server problem)

---

### Definition

`RepositoryImpl` maps transport errors to `DomainException` via `onErrorResumeNext`. Presenter delegates to `ErrorHandler` — never inspect the error directly in the Presenter.

### Code Pattern

```kotlin
// RepositoryImpl error mapping
.onErrorResumeNext { throwable ->
    when (throwable) {
        is ApiException -> when (throwable.code) {
            401 -> Single.error(DomainException.Unauthorized())
            404 -> Single.error(DomainException.NotFound())
            else -> Single.error(throwable)
        }
        is IOException -> Single.error(DomainException.NetworkError())
        else -> Single.error(throwable)
    }
}

// Presenter delegates to ErrorHandler
errorHandler.handle(error) { message -> view?.showError(message) }
```

## Error Response Models

### Theory

DTOs mirror the raw API error shape exactly. All fields are nullable — server may omit any field.

---

### Definition

Error response data classes used to deserialize API error bodies from Retrofit.

### Code Pattern

```kotlin
data class ErrorResponse(
    @SerializedName("error") val error: ErrorDetail?
)

data class ErrorDetail(
    @SerializedName("code") val code: String?,
    @SerializedName("message") val message: String?,
    @SerializedName("errors") val errors: List<FieldError>?
)

data class FieldError(
    @SerializedName("field") val field: String?,
    @SerializedName("message") val message: String?
)

class ApiException(
    val code: Int,
    val errorResponse: ErrorResponse?,
    override val message: String
) : Exception(message)
```

## Error Types

### Theory

| Layer | Error type owned | Purpose |
|---|---|---|
| Data (transport) | Platform HTTP/network error | Represents wire failures — HTTP status, timeout, parse failure |
| Domain | `DomainError` | Business-meaningful error codes (`notFound`, `validationFailed`, `unauthorized`) |
| Presentation | UI error State | What the screen renders — message, retry action, recovery path |

**Domain error codes are business vocabulary** — `notFound`, `validationFailed`, `unauthorized`, `networkUnavailable`, `serverError`. Never use HTTP status codes as domain error codes.

---

### Definition

| Type | Layer | Description |
|---|---|---|
| `ApiException` | Data | HTTP error from Retrofit; carries status code |
| `IOException` | Data | Network failure (no connectivity, timeout) |
| `DomainException` | Domain | Sealed class; subtypes: `Unauthorized`, `NotFound`, `NetworkError`, `Unknown` |
| `BaseErrorModel` | Presentation | UI-facing error with user-readable message |

### Code Pattern

```kotlin
// Data layer error types
class ApiException(
    val code: Int,
    val errorResponse: ErrorResponse?,
    override val message: String
) : Exception(message)

// Domain layer error type
sealed class DomainException(message: String) : Exception(message) {
    class Unauthorized(message: String = "Unauthorized") : DomainException(message)
    class NotFound(message: String = "Resource not found") : DomainException(message)
    class NetworkError(message: String = "Network unavailable") : DomainException(message)
    class Unknown(message: String = "Unknown error") : DomainException(message)
}
```

## Layer Invariants

### Theory

- DataSources throw — they never return null to signal failure
- Repository implementations always catch and map — never let transport errors propagate to use cases
- Use cases propagate `DomainError` unchanged — they do not re-map errors
- StateHolders catch all errors from use cases — no unhandled promise rejections or uncaught exceptions reach the UI
- Screens never inspect error codes directly — they render the error State the StateHolder produces

---

### Definition

Enforced constraints for error handling across all layers.

### Code Pattern

- DataSources throw `ApiException` or `IOException` — they never return `null` or a partial model to signal failure
- Repository implementations always catch and map to `DomainException` via `onErrorResumeNext` — no transport error propagates to use cases
- Use cases propagate `DomainException` via RxJava `onError` unchanged — they do not re-map errors
- Presenters delegate all error handling to `ErrorHandler` — never call `view?.showError(error.message)` directly
- Views never inspect `DomainException` subtypes — they render the error message `ErrorHandler` produces

# Testing

## Mapper Tests

### Theory

Mapper tests are pure input → output assertions — the simplest tests to write:

- Provide a fully-populated DTO → assert every field maps to the correct entity field
- Provide a DTO with missing/null optional fields → assert safe defaults or null handling
- No mocks needed — mappers have no dependencies

---

### Definition

**Never mock Mappers** — they are pure functions. Instantiate directly and test with real input/output.

### Code Pattern

```kotlin
@RunWith(MockitoJUnitRunner::class)
class TimeOffRequestMapperTest {

    private lateinit var mapper: TimeOffRequestMapper

    @Before
    fun setUp() { mapper = TimeOffRequestMapper() }

    @Test
    fun test_givenValidResponse_whenMap_thenEntityIsCorrect() {
        val response = TimeOffRequestResponse(
            id = "123", employeeId = "emp-1", startDate = "2024-01-01",
            endDate = "2024-01-05", reason = "Vacation", status = "pending", totalDays = 5
        )
        val result = mapper.map(response)
        assertEquals("123", result.id)
        assertEquals(5, result.totalDays)
    }

    @Test
    fun test_givenNullFields_whenMap_thenDefaultsApplied() {
        val result = mapper.map(TimeOffRequestResponse(null, null, null, null, null, null, null))
        assertEquals("", result.id)
        assertEquals(0, result.totalDays)
    }

    @Test
    fun test_givenListResponse_whenMapList_thenAllEntitiesMapped() {
        val responses = listOf(
            TimeOffRequestResponse("1", null, null, null, null, null, 3),
            TimeOffRequestResponse("2", null, null, null, null, null, 5)
        )
        val results = responses.map { mapper.map(it) }
        assertEquals(2, results.size)
        assertEquals("1", results[0].id)
    }
}
```

## Mock vs Real

### Theory

| Use a mock/stub when… | Use a real implementation when… |
|---|---|
| The dependency has I/O (network, DB, file) | The dependency is pure (mappers, domain services) |
| The test must control exact return values | The test verifies the full integration path |
| Speed matters — unit test suite | Correctness of wiring matters — integration test |

**Never mock domain services or mappers in unit tests** — they are pure functions; test them with real inputs and outputs.

---

### Definition

| Use a mock/stub when… | Use a real implementation when… |
|---|---|
| The dependency has I/O (Retrofit API, DB) | The dependency is pure (Mapper, domain service) |
| The test must control exact return values | The test verifies full integration wiring |
| Unit test speed matters | Correctness of data transformation matters |

Use `@Mock` with `MockitoJUnitRunner` for all collaborators (Api, Mapper, Repository, SchedulerTransformers). Use `.blockingGet()` for synchronous assertion on RxJava Singles.

### Code Pattern

```kotlin
// ✅ Mock the API (has I/O)
@Mock lateinit var mockApi: TimeOffApi

// ✅ Use real mapper (pure function)
private val mapper = TimeOffRequestMapper()

// ❌ Never mock a Mapper
@Mock lateinit var mockMapper: TimeOffRequestMapper  // wrong — use real instance
```

## Presenter Tests

### Theory

Presentation tests verify State transitions for each event; correct use case calls; action emissions.

---

### Definition

Rules:
- Test naming: `test_given[Condition]_when[Action]_then[ExpectedResult]`
- Use `inOrder(mockView)` to verify call order (showLoading → hideLoading → showData)
- `presenter.attachView(mockView)` in `@Before`, `reset(...)` all mocks in `@After`
- `presenter.detachView()` (not `detach()`) — test that detached presenter ignores use case results
- Always test: success path, error path, detached-view path

### Code Pattern

```kotlin
@RunWith(MockitoJUnitRunner::class)
class TimeOffRequestPresenterTest {

    @get:Rule
    val fake = JUnitForger()

    @Mock lateinit var mockView: TimeOffRequestContract.View
    @Mock lateinit var mockUseCase: GetTimeOffRequestsUseCase
    @Mock lateinit var mockSchedulerTransformers: SchedulerTransformers
    @Mock lateinit var mockErrorHandler: ErrorHandler

    private lateinit var presenter: TimeOffRequestPresenter

    @Before
    fun setUp() {
        fake.reset(1)
        presenter = TimeOffRequestPresenter(mockUseCase, mockSchedulerTransformers, mockErrorHandler)
        presenter.attachView(mockView)
    }

    @After
    fun tearDown() {
        reset(mockView, mockUseCase, mockSchedulerTransformers, mockErrorHandler)
    }

    @Test
    fun test_givenViewAttached_whenLoadData_thenShowLoadingThenData() {
        val featureId = fake.aString()
        val mockData = with(fake) { TimeOffRequest(aString(), aString(), aString(), aString(), aString(), aString(), aPositiveInt()) }
        given(mockUseCase.execute(any())).willReturn(Single.just(listOf(mockData)))

        presenter.loadTimeOffRequests(featureId)

        val inOrder = inOrder(mockView)
        inOrder.verify(mockView).showLoading()
        inOrder.verify(mockView).hideLoading()
        inOrder.verify(mockView).showTimeOffRequests(listOf(mockData))
        inOrder.verifyNoMoreInteractions()
    }

    @Test
    fun test_givenError_whenLoadData_thenShowError() {
        val error = RuntimeException("Network error")
        given(mockUseCase.execute(any())).willReturn(Single.error(error))

        presenter.loadTimeOffRequests(fake.aString())

        val inOrder = inOrder(mockView)
        inOrder.verify(mockView).showLoading()
        inOrder.verify(mockView).hideLoading()
        verify(mockErrorHandler).handle(eq(error), any())
    }

    @Test
    fun test_givenViewDetached_whenLoadData_thenNoViewInteraction() {
        presenter.detachView()

        presenter.loadTimeOffRequests(fake.aString())

        verifyNoMoreInteractions(mockView)
    }
}
```

## Procedure

Platform: Android · Language: Kotlin · Test framework: JUnit4 + Mockito-Kotlin · Architecture: MVP (Presenter/View Contract)

---

### Test File Naming

Pattern: `<SourceClassName>Test.kt`

Examples:
- `ReimbursementEssMenuPresenter.kt` → `ReimbursementEssMenuPresenterTest.kt`
- `AnnouncementCreatorParcelMapper.kt` → `AnnouncementCreatorParcelMapperTest.kt`
- `LoginMapper.kt` → `LoginMapperTest.kt`

---

### Test File Location

Source files live in multi-module Gradle modules. Mirror the source path under the module's `test` source set:

```
Source:  <module>/src/main/java/<package>/<ClassName>.kt
Test:    <module>/src/test/java/<package>/<ClassName>Test.kt
```

---

### Test File Scaffold

```kotlin
package <package>

import org.mockito.kotlin.mock
import org.mockito.kotlin.reset
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mock
import org.mockito.junit.MockitoJUnitRunner

@RunWith(MockitoJUnitRunner::class)
class <ClassName>Test {

    @get:Rule
    val rxTestRule = RxTestRule()

    private lateinit var sut: <ClassName>

    @Mock
    lateinit var mock<Dependency>: <DependencyInterface>

    @Before
    fun setUp() {
        sut = <ClassName>(mock<Dependency>)
    }

    @After
    fun tearDown() {
        reset(mock<Dependency>)
    }
}
```

For Presenter tests, attach and detach the view:
```kotlin
@Before
fun setUp() {
    sut = <Presenter>(<useCaseMock>).apply {
        errorHandler = mockErrorHandler
        attach(mockView)
    }
}

@After
fun tearDown() {
    sut.detach()
    reset(mock<Dependency>, mockView, mockErrorHandler)
}
```

---

### Mock Strategy

Uses **Mockito-Kotlin** (`org.mockito.kotlin`). Mocks are declared inline in the test class using `@Mock` annotation or `mock<T>()` function — no separate mock files.

**Key Mockito-Kotlin patterns:**
```kotlin
// Stub a method
whenever(mockUseCase.execute(param)).thenReturn(Flowable.just(result))

// Verify call
verify(mockView).showLoading()
verify(mockView, times(2)).hideLoading()
verify(mockView, never()).showError(any())

// Verify no more interactions
verifyNoMoreInteractions(mockView)
```

For RxJava3 flows, trigger the scheduler after the call:
```kotlin
presenter.doSomething(param)
rxTestRule.testScheduler.triggerActions()
```

---

### Mock Generation

No code generation required. Mockito creates mocks at runtime via `@RunWith(MockitoJUnitRunner::class)` and `@Mock` annotations.

Steps:
1. Declare `@Mock lateinit var mock<Name>: <Interface>` in the test class.
2. Ensure the interface is not `final` — Mockito-Inline handles final classes, but interfaces are preferred.
3. Add `reset(mock<Name>)` in `@After` to clear state between tests.

---

### Test Structure (Given-When-Then)

```kotlin
@Test
fun test_given<Condition>_when<Action>_then<Expectation>() {
    // given
    val givenParam = fake.aString()
    val mockResult = fake.aString()

    // when
    whenever(mockUseCase.execute(givenParam)).thenReturn(Flowable.just(mockResult))
    sut.doSomething(givenParam)
    rxTestRule.testScheduler.triggerActions()

    // then
    verify(mockView).showLoading()
    verify(mockView).onSuccess(mockResult)
    verifyNoMoreInteractions(mockView)
}
```

Optional: use `fr.xgouchet.elmyr.junit.JUnitForger` for random-but-deterministic test data:
```kotlin
@get:Rule
val fake = JUnitForger()

val randomString = fake.aString()
val randomBool = fake.aBool()
```

---

### Test Runner

Run unit tests for a specific module:
```bash
./gradlew :<module>:test
```

Run a specific test class:
```bash
./gradlew :<module>:test --tests "<fully.qualified.ClassName>"
```

Run a specific test method:
```bash
./gradlew :<module>:test --tests "<fully.qualified.ClassName>.testMethodName"
```

---

### Failure Patterns

| Symptom | Diagnosis | Fix |
|---|---|---|
| `Wanted but not invoked` | Method never called — missing `triggerActions()` or wrong stub | Add `rxTestRule.testScheduler.triggerActions()` after the call under test |
| `Argument mismatch` | Stub param doesn't match actual call | Use `any()` matcher or align param value |
| `NullPointerException` on mock | View detached before assertion | Assert before `detach()` or use `verify(mockView, never())` pattern |
| `WantedButNotInvoked` on `verifyNoMoreInteractions` | Extra unexpected call | Check if another view method is being called not included in `verify` |

## Repository Tests

### Theory

Repository implementation tests verify the bridge between DataSource and Domain:

- Use a test double (mock/stub) for the DataSource — not a real network or DB
- Assert that the repository maps DataSource output to the correct domain entity
- Assert that DataSource errors are caught and mapped to the correct domain error type
- One test per operation (get, create, update, delete)

---

### Definition

Test that the repository implementation calls the API and maps the response correctly. Mock the API and mapper.

Rules:
- Mock `Api` and `Mapper` — never the repository itself
- Test success path, error path (ApiException → DomainException), and empty list
- Use `.blockingGet()` for synchronous assertion in unit tests

### Code Pattern

```kotlin
@RunWith(MockitoJUnitRunner::class)
class TimeOffRepositoryImplTest {

    @Mock lateinit var mockApi: TimeOffApi
    @Mock lateinit var mockMapper: TimeOffRequestMapper

    private lateinit var repository: TimeOffRepositoryImpl

    @Before
    fun setUp() {
        repository = TimeOffRepositoryImpl(mockApi, mockMapper)
    }

    @Test
    fun test_givenApiSuccess_whenGetRequests_thenMapperIsCalledAndEntityReturned() {
        val response = TimeOffRequestListResponse(data = listOf(TimeOffRequestResponse("1", null, null, null, null, null, 3)), meta = null)
        val entity = TimeOffRequest("1", "", "", "", "", "", 3)
        given(mockApi.getTimeOffRequests(1, 20)).willReturn(Single.just(response))
        given(mockMapper.map(response.data!!.first())).willReturn(entity)

        val result = repository.getTimeOffRequests(1, 20).blockingGet()

        assertEquals(listOf(entity), result)
        then(mockMapper).should().map(response.data!!.first())
    }

    @Test
    fun test_givenApiError_whenGetRequests_thenDomainExceptionPropagated() {
        given(mockApi.getTimeOffRequests(1, 20)).willReturn(Single.error(ApiException(401, "Unauthorized")))

        val error = assertThrows(DomainException.Unauthorized::class.java) {
            repository.getTimeOffRequests(1, 20).blockingGet()
        }
        assertNotNull(error)
    }
}
```

## Test Naming Convention

### Theory

`[unit under test]_[scenario]_[expected outcome]`

Examples:
- `getEmployeeUseCase_whenRepositoryReturnsEmployee_emitsEmployee`
- `employeeMapper_whenDtoHasNullDepartment_mapsToDefaultDepartment`
- `employeeViewModel_whenFetchFails_emitsErrorState`

---

### Definition

Pattern: `test_given[Condition]_when[Action]_then[ExpectedResult]`

### Code Pattern

Examples:

- `test_givenApiSuccess_whenGetRequests_thenMapperIsCalledAndEntityReturned`
- `test_givenApiError_whenGetRequests_thenDomainExceptionPropagated`
- `test_givenValidResponse_whenMap_thenEntityIsCorrect`
- `test_givenNullFields_whenMap_thenDefaultsApplied`
- `test_givenViewAttached_whenLoadData_thenShowLoadingThenData`
- `test_givenViewDetached_whenLoadData_thenNoViewInteraction`

## Test Pyramid

### Theory

```
         ┌──────────────────┐
         │   E2E Tests      │  few — critical user journeys only
         └────────┬─────────┘
         ┌────────┴─────────┐
         │ Integration Tests│  moderate — repository + datasource wiring
         └────────┬─────────┘
         ┌────────┴─────────┐
         │   Unit Tests     │  many — use cases, mappers, domain services
         └──────────────────┘
```

**Distribution target:** unit-heavy, integration-light, e2e-minimal. A test suite with more e2e than unit tests is inverted — slow, brittle, and expensive to maintain.

---

### Definition

| Layer | Type | Tool | Target ratio |
|---|---|---|---|
| Domain (use cases, services) | Unit | JUnit4 + Mockito | Heavy — fast, isolated |
| Data (mappers, repository impl) | Unit | JUnit4 + Mockito | Heavy |
| Presentation (presenters) | Unit | JUnit4 + Mockito + RxJava test schedulers | Medium |
| UI (activity/fragment) | Instrumented | Espresso | Light — slow, avoid |

### Code Pattern

```bash
# Unit tests
./gradlew test

# Instrumented tests
./gradlew connectedAndroidTest
```

## Unit Test Setup

### Theory

Each test gets its own container instance — never share container state across tests. Test naming: `[unit under test]_[scenario]_[expected outcome]`.

---

### Definition

Test naming convention: `test_given[Condition]_when[Action]_then[ExpectedResult]`

### Code Pattern

```kotlin
@RunWith(MockitoJUnitRunner::class)
class GetTimeOffRequestsUseCaseTest {

    @get:Rule
    val fake = JUnitForger()

    private lateinit var useCase: GetTimeOffRequestsUseCase

    @Mock lateinit var mockRepository: TimeOffRepository
    @Mock lateinit var mockResult: Single<List<TimeOffRequest>>
    @Mock lateinit var mockSchedulerTransformers: SchedulerTransformers
    @Mock lateinit var mockLogger: Logger

    @Before
    fun setUp() {
        fake.reset(1)
    }

    @After
    fun tearDown() {
        reset(mockRepository, mockResult, mockSchedulerTransformers, mockLogger)
    }
}
```

## Use Case Tests

### Theory

Use case tests verify business rules, edge cases, and error conditions. Use cases depend only on repository interfaces.

---

### Definition

Test that the use case calls the correct repository method with the correct params.

### Code Pattern

```kotlin
@Test
fun test_givenValidParams_whenExecute_thenRepositoryShouldGetRequests() {
    // given
    useCase = GetTimeOffRequestsUseCase(mockRepository, mockSchedulerTransformers, mockLogger)
    val params = with(fake) {
        GetTimeOffRequestsUseCase.Params(id = aString())
    }
    given(mockRepository.getTimeOffRequests(params.id)).willReturn(mockResult)

    // when
    useCase.execute(params)

    // then
    then(mockRepository).should().getTimeOffRequests(params.id)
    then(mockRepository).shouldHaveNoMoreInteractions()
}

@Test
fun test_givenNullSchedulerAndLogger_whenExecute_thenWorksWithoutThem() {
    // given
    useCase = GetTimeOffRequestsUseCase(mockRepository)
    val params = with(fake) { GetTimeOffRequestsUseCase.Params(id = aString()) }
    given(mockRepository.getTimeOffRequests(params.id)).willReturn(mockResult)

    // when
    useCase.execute(params)

    // then
    then(mockRepository).should().getTimeOffRequests(params.id)
}
```

## What to Test

### Theory

| Layer | Test targets | What to assert |
|---|---|---|
| Domain | Use cases, domain services | Business rules, edge cases, error conditions |
| Data | Mappers, repository implementations | DTO → entity mapping correctness; error mapping from transport to domain |
| Presentation | StateHolder (ViewModel/BLoC) | State transitions for each event; correct use case calls; action emissions |
| UI | Screen rendering | Correct state → UI binding; event dispatch on user interaction |

---

### Definition

| Layer | What to test | What NOT to test |
|---|---|---|
| Domain (UseCases, Services) | Business rules, edge cases, error conditions | Implementation details of other layers |
| Data (Mappers, RepositoryImpl) | Response → entity field mapping; ApiException → DomainException propagation | Real HTTP responses, network stack |
| Presentation (Presenter) | View method call order; use case invocations; detached-view safety | Activity/Fragment lifecycle internals |
| UI (Espresso) | Critical happy-path journeys only | Business logic, mapping logic |

### Code Pattern

```kotlin
// ✅ Test what matters per layer:

// Domain: business rule
@Test
fun test_givenValidParams_whenExecute_thenRepositoryShouldGetRequests() { ... }

// Data: mapping correctness
@Test
fun test_givenValidResponse_whenMap_thenEntityIsCorrect() { ... }

// Presentation: view method call order
@Test
fun test_givenViewAttached_whenLoadData_thenShowLoadingThenData() { ... }
```

# App

## Analytics Constants

### Theory

**Analytics Constants** are feature-scoped files that declare the event names, screen names, or tracking identifiers reported to the analytics service.

**Invariants:**
- One constants file per feature — never share event names across features in a single file
- Constants are plain string literals — no logic, no SDK imports
- Analytics SDK calls are made in the Presentation layer — these files only declare the identifiers they reference

**When to create:** Any feature that instruments user interactions or screen views. Optional — skip if the feature has no analytics events.

---

### Definition

Analytics event names and screen identifiers are declared as constants in the feature module — never as inline strings in ViewModel or Fragment code.

Rules:
- `object` with `const val String` constants — no logic, no analytics SDK import
- snake_case string values matching the analytics platform convention
- Never inline event name strings in ViewModel or Fragment

### Code Pattern

```kotlin
// feature_{feature}/src/main/java/{package}/{feature}/analytics/{Feature}AnalyticsConstants.kt

object {Feature}AnalyticsConstants {
    const val SCREEN_NAME = "{feature}_screen"
    const val EVENT_LOAD_DATA = "{feature}_load_data"
    const val EVENT_SUBMIT = "{feature}_submit"
    const val EVENT_ERROR = "{feature}_error"
}
```

## Deeplink Registration

### Theory

**Deeplink Registration** is the act of mapping incoming URLs and notification taps to screens or flows within the app.

**Invariants:**
- Mappings live at the app shell — never inside individual feature modules
- Deeplink route identifiers are the same identifiers used for in-app navigation — no parallel routing system
- URL parsing is separated from routing — the parser produces a route identifier, the router acts on it
- Each feature declares its own deeplink paths; the app shell assembles the complete registry
- Deeplinks arriving while the app is backgrounded or unauthenticated must be queued and replayed after auth completes

**When to add:** Any feature reachable from a push notification tap, an external URL, or a cross-app link.

---

### Definition

Android deeplinks enter through a `RedirectionActivity` — a `singleTask` exported activity declared in `AndroidManifest.xml`.

Rules:
- All deeplink entry points flow through `RedirectionActivity` — never add `VIEW` intent filters to feature Activities
- URL patterns live in a `UrlHelper` utility — never hardcode URL strings inside `RedirectionActivity`
- Routing delegates to the feature's Navigation interface — `RedirectionActivity` never starts Activities directly
- Never parse deeplink URLs in ViewModels or Fragments

### Code Pattern

```kotlin
// Step 1 — Add URL pattern to UrlHelper
fun Uri.is{Feature}(): Boolean = toString().contains("{feature-url-segment}")

// Step 2 — Add routing in RedirectionActivity.checkDeepLink()
uri.is{Feature}() -> redirect{Feature}(uri)

// Step 3 — Implement redirect method
private fun redirect{Feature}(uri: Uri) {
    val id = uri.getQueryParameter("id").orEmpty()
    {feature}Navigation.navigateTo{Feature}(this, id)
}

// Step 4 — Register Intent filter for App Links (if universally linked)
// app/src/main/AndroidManifest.xml — inside RedirectionActivity intent-filter
// <data android:pathPrefix="@string/universal_link_{feature}_index" />
```

## Dependency Registration

### Theory

**Dependency Registration** is the act of binding concrete implementations to their interfaces in the app's DI container so that the runtime can inject them into use cases, repositories, and state holders.

**Invariants:**
- Bindings live at the app shell — never inside a CLEAN layer
- Each feature owns its own registration unit (component, module, or file) — one file per feature
- Use cases and repositories are registered, not constructed inline at call sites
- Registration order follows the dependency graph: data sources → repositories → use cases

**When to add:** Any time a new use case, repository implementation, or data source is introduced. Skipping registration causes runtime crashes — this step is mandatory, not optional.

---

### Definition

Android uses **Dagger 2** with `@Module` + `@Binds` + `@ContributesAndroidInjector` per feature.

Rules:
- One `@Module` per feature under `feature_{feature}/di/`
- `@Binds` for interface-to-implementation binding — never `@Provides` for simple bindings
- `@ContributesAndroidInjector` scopes injection to the Activity/Fragment
- Never inject `Context` directly — use `@ApplicationContext` or `@ActivityContext`

### Code Pattern

```kotlin
// feature_{feature}/di/Feature{Feature}Module.kt

@Module
abstract class Feature{Feature}Module {

    @Binds
    abstract fun bind{Feature}Repository(
        impl: {Feature}RepositoryImpl
    ): {Feature}Repository

    @Binds
    abstract fun bind{Feature}RemoteDataSource(
        impl: {Feature}RemoteDataSourceImpl
    ): {Feature}RemoteDataSource
}

// app/di/{Feature}ActivityBindingModule.kt

@Module
abstract class {Feature}ActivityBindingModule {

    @ContributesAndroidInjector(modules = [Feature{Feature}Module::class])
    abstract fun contribute{Feature}Activity(): {Feature}Activity
}

// app/di/MainComponent.kt
@Singleton
@Component(
    modules = [
        // ... existing modules
        {Feature}ActivityBindingModule::class,  // ← add here
    ]
)
interface MainComponent : AndroidInjector<App>
```

## Feature Flag Registration

### Theory

**Feature Flag Registration** is the act of declaring a new feature-gating key in the app's centralized flag registry, enabling remote enable/disable without a new app release.

**Invariants:**
- Flag keys live in a centralized registry (enum, struct, or constants file) — never as inline string literals at call sites
- One key per feature toggle — never reuse an existing flag for a different purpose
- Default values are explicit — the flag's behavior when unset must be defined in the registry

**When to add:** Any feature that requires remote gating, gradual rollout, or a kill switch. Optional — skip for features that launch immediately to 100% of users.

---

### Definition

Android has three flag types — pick the right enum based on the flag's backend:

| Type | Enum | Backend |
|---|---|---|
| Local only | `LocalFeatureFlag` | No backend — compile-time default |
| Firebase Remote Config | `RemoteConfigFeatureFlag` | `firebaseRemoteConfigKey` string |
| Remote Flag Service | `FlagsmithFeatureFlag` | `featureId` string |

All three implement the `Feature` interface (`domain/featureflag/Feature.kt`). Checked via `FeatureFlagManager.isFeatureEnabled(featureFlag)`.

Rules:
- Always provide `description` and `link` — required for traceability
- `firebaseRemoteConfigKey` must match a constant in `RemoteConfigKey` — confirm with backend
- `featureId` must exactly match the remote flag service key — confirm with backend
- `defaultFlag = false` unless the feature should be on by default when the flag is unreachable
- Never use raw string literals for flag keys at call sites — always reference the enum

### Code Pattern

```kotlin
// RemoteConfigFeatureFlag example
ENABLE_{FEATURE}(
    description = "Short description of what this gates",
    deprecated = arrayOf(),
    link = arrayOf("https://issue-tracker/browse/{TICKET}"),
    defaultFlag = false,
    firebaseRemoteConfigKey = RemoteConfigKey.ENABLE_{FEATURE},
),

// Remote flag service example
ENABLE_{FEATURE}(
    description = "Short description of what this gates",
    deprecated = arrayOf(),
    link = arrayOf("https://issue-tracker/browse/{TICKET}"),
    defaultFlag = false,
    featureId = "enable_{feature}",
),
```

## Hybrid Embedding

### Theory

**Hybrid Embedding** is the architecture where a native host app (Android) embeds a Flutter module as a full-screen view or headless executor, communicating over MethodChannel via a Bridge library.

**When it applies:** iOS and Android hosts only. Not applicable to web or to Flutter apps that are the host.

**Invariants:**
- Module launch always goes through the Bridge — never via raw `FlutterEngine` or `MethodChannel` directly
- Module registration, engine slot config, and HostParams assembly live in the host app shell — not inside individual feature screens
- Each module has exactly one engine slot ID — reusing an existing slot causes lifecycle conflicts
- The URI scheme and engine slot ID must be agreed between host and guest teams before implementation begins

---

### Definition

Android-specific patterns for embedding Flutter modules via a bridge library.

### Key Files

| File | Role |
|------|------|
| Bridge singleton | Engine init (`FlutterEngineGroup`), module factory, `preWarmEngine()` |
| Engine manager | Engine lifecycle, MethodChannel wiring, `buildEngine()`, `listen()`, `invokeMethod()` |
| Module base | Abstract base — declares `engine`, `host`, `open()`, `execute()`, `createExecutorEngineId()` |
| Bridge activity | `FlutterActivity` subclass — hosts the guest UI, wires channel delegate in `configureFlutterEngine()` |
| Channel delegate | Handles inbound MethodChannel calls from guest |
| Navigator | Builds the `Intent` for the bridge activity and starts it |
| Executor | Headless execution — invokes guest and awaits typed callback |
| Channel config | Channel name and all method name / key constants |
| Host params assembler | Builds `hostParam` JSON, handles standard action callbacks |
| Concrete module | Wraps all feature routes as typed `openXxx()` / `executeXxx()` methods |

### Code Pattern

```kotlin
// Host → Guest: Navigation Launch
val module = Bridge.getModule<FeatureModule>(context)

val hostParamJson = BridgeHelper.getDefaultJsonObject(
    sessionPreference, remoteConfigFlagProvider
).apply {
    put("moduleJson", JSONObject().apply { /* module-specific params */ }.toString())
}.toString()

val params = MainParams(hostParam = hostParamJson)

module.openFeatureIndex(
    context = context,
    params = params,
    launcher = activityResultLauncher,
    actionListener = bridgeActionListener
)

// Host → Guest: Headless Execution
module.executeFeatureAction(
    context = context,
    params = params,
    callBack = object : ExecutorCallback<FeatureResponse> {
        override fun onLoading() { ... }
        override fun onSuccess(response: FeatureResponse?) { ... }
        override fun onError(code: Int, message: String) { ... }
    }
)

// MethodChannel Constants
const val METHOD_CHANNEL           = "com.example.module"
const val SEND_METHOD_OPEN         = "open"
const val SEND_METHOD_EXECUTE      = "execute"
const val RECEIVE_RESPONSE_METHOD  = "sendResponse"
const val RECEIVE_ACTION_METHOD    = "sendActionRequest"
const val IS_24_HOUR_FORMAT_METHOD = "is24HourFormat"
```

## Module Registration

### Theory

**Module Registration** is the act of plugging a feature module into the app's module manager so it participates in the app lifecycle (startup, teardown, deep link handling).

**Invariants:**
- Module registration happens in one place — the app's module manager or root coordinator
- Each feature module is registered once — duplicates cause double initialization
- Module lifecycle hooks (`onStart`, `onStop`) must not duplicate logic already in use cases

**When to add:** Any time a new feature module is introduced.

---

### Definition

Android module registration has two parts: wiring Dagger (via the main component) and wiring Gradle (via `settings.gradle`).

Rules:
- Module name in `settings.gradle` must match the directory name exactly
- Both Gradle wiring and Dagger wiring are required — neither alone is sufficient
- Never add feature module code directly to the `app/` module — keep feature code in `feature_{feature}/`

### Code Pattern

```groovy
// settings.gradle
include ':feature_{feature}'   // ← add here

// app/build.gradle
dependencies {
    // ... existing
    implementation project(':feature_{feature}')   // ← add here
}
```

Dagger wiring is handled in Dependency Registration — the feature's `ActivityBindingModule` is added to `MainComponent`.

## Planner Search Patterns

### Theory

When exploring the app layer, use these glob patterns to find relevant files.

---

### Definition

`{Feature}` = PascalCase, `{feature}` = snake_case per Android convention.

### Code Pattern

| Scope key | Glob / Path | Grep hint |
|---|---|---|
| `di` | `*Feature{Feature}Module.kt`, `*{Feature}ActivityBindingModule.kt`, `*MainComponent.kt` under `app/di/` | `{Feature}ActivityBindingModule` in `app/di/MainComponent.kt` |
| `route` | `*{Feature}Navigation.kt` under `base/navigation/`, `*{Feature}NavigationImpl.kt` under `app/navigator/`, `*NavigationModule.kt` under `app/di/` | `{Feature}Navigation` in `app/di/NavigationModule.kt` |
| `module` | `settings.gradle`, `app/build.gradle`, `*MainComponent.kt` under `app/di/` | `feature_{feature}` in `settings.gradle` |
| `analytics` | `*{Feature}AnalyticsConstants.kt` under `feature_{feature}/src/main/java/` | — |
| `feature_flag` | `domain/featureflag/Feature.kt`, `*FlagsmithFeatureFlag.kt` | `ENABLE_{FEATURE}` enum entry |
| `hybrid_embedding` | bridge module files, app helper files | `## Hybrid Embedding` section |

## Push Notification Registration

### Theory

**Push Notification Registration** is the act of wiring the app to receive push notifications — fetching the device token, delivering it to the server, and removing it on logout.

**Invariants:**
- Registration is owned by the infrastructure layer — never by an individual feature
- The notification manager is wired once at the app shell, not inside feature modules
- Payload routing (which screen or flow a notification opens) is declared separately from payload receipt
- Notification display concerns — channels, builders, and visual configuration — are isolated from the message handler
- Silent push notifications must route through domain use cases — they must not trigger UI state directly

**When to add:** Once per app. The token lifecycle is tied to the auth flow — token registration occurs on login and token deletion occurs on logout.

---

### Definition

Android centralizes FCM handling in a `NotificationManagerImpl` class. The FCM service in `AndroidManifest.xml` delegates to this class — no per-feature setup is needed.

**Token lifecycle:**
- `PostFcmTokenUseCase` — sends token to server (called after login)
- `DeleteFcmTokenUseCase` — deletes token from server on logout
- Last pushed token is stored in session preferences

Rules:
- Per-feature notification types add a `NotificationNavigationType` variant and a handler in the notification manager
- New notification screen destinations register a deeplink path and rely on the redirection activity for routing
- Never handle FCM messages or display notifications inside feature modules

### Code Pattern

```kotlin
// NotificationManagerImpl.onMessageReceived() — centralised handler
// remoteMessage.data["notification_key"] → JSON → NotificationPayload
// NotificationNavigationType enum: DEEPLINK, SCREEN_NAME, SILENT_PUSH_NOTIFICATION, URI
// Display: NotificationBuilderImpl (separate from message handler)
```

## Route Registration

### Theory

**Route Registration** is the act of declaring how the app navigates to a feature's screen — mapping a route identifier (string key, enum case, or coordinator type) to a screen factory.

**Invariants:**
- Routes live at the app shell or navigation coordinator — never inside a CLEAN layer
- Each feature owns one route declaration unit (route file, coordinator class, or destination enum)
- Route identifiers are stable string keys or typed values — not view instances
- Deep link destinations must be registered in the same place as regular routes

**When to add:** Any time a new screen is introduced. An unregistered route is a silent navigation failure.

---

### Definition

Android uses **interface-based navigation** — the navigation interface lives in `base/`, the implementation lives in `app/navigator/`, and it is bound in a `NavigationModule`.

Rules:
- Navigation interface in `base/` — never import Activity classes into feature modules
- One interface per feature, injected into Presenters that need to navigate
- No `startActivity` calls inside feature module Presenters — delegate to the navigator

### Code Pattern

```kotlin
// base/navigation/{Feature}Navigation.kt

interface {Feature}Navigation {
    fun navigateTo{Feature}(context: Context)
    fun navigateTo{Feature}Detail(context: Context, id: String)
}

// app/navigator/{Feature}NavigationImpl.kt

class {Feature}NavigationImpl @Inject constructor() : {Feature}Navigation {

    override fun navigateTo{Feature}(context: Context) {
        context.startActivity(Intent(context, {Feature}Activity::class.java))
    }

    override fun navigateTo{Feature}Detail(context: Context, id: String) {
        context.startActivity(
            Intent(context, {Feature}DetailActivity::class.java).apply {
                putExtra({Feature}DetailActivity.EXTRA_ID, id)
            }
        )
    }
}

// app/di/NavigationModule.kt
@Module
abstract class NavigationModule {
    // ... existing bindings
    @Binds abstract fun bind{Feature}Navigation(impl: {Feature}NavigationImpl): {Feature}Navigation  // ← add here
}
```

# UI

## Component

### Theory

A **Component** (also called Sub-view, Widget, or View) is a reusable UI element smaller than a full screen.

**Invariants:**
- Stateless by default — receives data via props/parameters and emits callbacks
- If stateful, bound to a scoped StateHolder — never manages business state inline
- No use case calls — all data passed in from the parent screen or a scoped StateHolder
- Reuse check required before creating — search shared component directories first

**When to create:** When a UI element appears in ≥2 screens, or when a screen section is complex enough to isolate for readability.

---

### Definition

A **Component** is a custom `View` subclass or self-contained `Fragment` smaller than a full screen.

**Invariants:**
- Stateless by default — configured via a setter or data binding; emits events via listener interfaces or callbacks
- If stateful, driven by a scoped Presenter — never manages business state inline
- No use case calls — all data passed in from the parent Activity/Fragment or a scoped Presenter
- Reuse check required before creating — search `presentation/common/views/` and shared modules first

**When to create:** When a UI element appears in ≥2 screens, or when an Activity/Fragment section is complex enough to isolate for readability.

### Code Pattern

```kotlin
// Shared component search paths:
// **/presentation/common/views/**/*.kt
// **/presentation/common/**/*View.kt
```

## Creation Order

### Theory

```
Screen → Navigator/Coordinator (if navigation needed) → DI wiring
```

The StateHolder and its contract must exist before any UI layer file is written.

---

### Definition

```
Activity/Fragment (View contract) → NavigationImpl (if navigation needed) → module binding
```

The Presenter contract and View contract must exist before any UI layer file is written.

### Code Pattern

```
1. Define MVP Contract (View + Presenter interfaces)
2. Implement Presenter (StateHolder)
3. Write Activity/Fragment implementing View contract
4. Create NavigationImpl if cross-screen navigation needed
5. Wire DI module + ActivityBindingModule
```

## Dependency Rule

### Theory

UI depends on Presentation only. It never imports from Domain or Data directly.

```
Presentation  ←  UI
```

Allowed imports: StateHolder contract types, State/Event/Action types, platform UI framework primitives.
Forbidden: use case interfaces, repository interfaces, DTOs, mappers, datasources, or any domain/data type instantiated directly.

---

### Definition

UI depends on Presentation only — never imports Domain or Data directly.

Allowed imports: Presenter contract interfaces, View contract interfaces, Android framework primitives (`Activity`, `Fragment`, `View`).
Forbidden: use case interfaces, repository interfaces, DTOs, mappers, datasources, or Retrofit types.

### Code Pattern

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

## DI Wiring

### Theory

**DI wiring** registers the StateHolder and its dependencies in the project's DI container for a given screen.

**Invariants:**
- StateHolder registered with the correct scope (feature-scoped, not singleton unless explicitly shared)
- Use cases injected into the StateHolder — never instantiated inside the StateHolder
- DI factory or binding key matches the StateHolder contract exactly

**When to create:** After the Screen and StateHolder exist. Required before the feature is navigable.

---

### Definition

**DI wiring** registers the Presenter and its dependencies in a module.

**Invariants:**
- Presenter provided via `@Provides` or `@Binds` in a `@Module` — scope matches Activity/Fragment lifetime
- Use cases injected into the Presenter constructor — never instantiated inside the Presenter
- Navigation implementation bound to its interface in the module

**When to create:** After the Screen and Presenter exist. Required before the feature is navigable.

### Code Pattern

See `dependency_injection/di_module` and `dependency_injection/activity_binding` for full wiring patterns.

## Layer Invariants

### Theory

- UI never mutates state directly — observes only
- UI never calls use cases directly — all interactions go through the StateHolder
- StateHolder instantiated via DI — never `new ViewModel()` / `MyViewModel()` inline
- Navigation delegated to navigator/coordinator — UI emits intent, not destination
- No data layer knowledge — no DTOs, no datasources, no HTTP types visible in UI files

---

### Definition

Enforced constraints for all UI layer artifacts.

### Code Pattern

- Activity/Fragment never holds business logic — delegates everything to Presenter
- Activity/Fragment never calls use cases directly — all interactions go through the Presenter
- Presenter instantiated via Hilt/Dagger — never `MyPresenter()` inline in Activity
- Navigation delegated to `NavigationImpl` via interface — Presenter calls interface, not `startActivity` directly
- No data layer knowledge — no DTOs, no Retrofit types, no datasource references visible in UI files

## Navigator

### Theory

A **Navigator** owns all navigation logic for a feature or flow.

**Invariants:**
- The Screen delegates navigation intent to the Navigator — it never hard-codes a destination
- The StateHolder emits a navigation Action — the Navigator decides the implementation
- Knows route constants or destination types — the Screen does not
- One navigator per feature flow — not per screen

**When to create:** When a screen navigates to another screen. Created after the screen that triggers navigation.

---

### Definition

A **Navigator** is a `NavigationImpl` class implementing a navigation interface, injected into the Presenter.

**Invariants:**
- The Presenter holds the navigation interface — it never references `Activity` or `Intent` directly
- The Activity provides `Context` at navigation call time via `view?.getContext()` — never stored in Presenter
- Navigation interfaces live in `base/common` module — not in feature modules
- Each Activity exposes a `companion object { fun newIntent(...) }` factory for typed navigation

**When to create:** When a Presenter navigates to another screen. Navigation interface defined in `base/common` before the Presenter that uses it.

### Code Pattern

See `navigation/navigator` for the full `NavigationImpl` pattern.

## Planner Search Patterns

### Theory

When exploring the UI layer, use these glob patterns to find relevant files.

---

### Definition

When exploring the UI layer, glob for:
- `**/presentation/**/*Activity.kt` — screen Activity files
- `**/presentation/**/*Fragment.kt` — screen Fragment files
- `**/presentation/common/views/**/*.kt` — shared component files
- `**/navigation/**/*NavigationImpl.kt` — navigator implementation files

### Code Pattern

```bash
# Find all screen Activities
find . -name "*Activity.kt" -path "*/presentation/*"

# Find all screen Fragments
find . -name "*Fragment.kt" -path "*/presentation/*"

# Find shared UI components
find . -path "*/presentation/common/views/*" -name "*.kt"

# Find navigation implementations
find . -name "*NavigationImpl.kt" -path "*/navigation/*"
```

## Screen

### Theory

A **Screen** is a full-page view bound to a single StateHolder. It observes state and sends events — it contains no business logic.

**Invariants:**
- Bound to exactly one StateHolder — instantiated via DI, never with direct `new` / `init`
- Observes every State field declared in the StateHolder contract — no State field goes unhandled
- Sends events to the StateHolder for every user interaction — never mutates state directly
- Contains no business logic — conditionals exist only to decide what to render, not what to compute
- No use case calls — all data flows through the StateHolder

**When to create:** One screen per route/destination. Created after the StateHolder contract exists.

---

### Definition

A **Screen** is an `Activity` or `Fragment` that implements a View contract interface and delegates all logic to its `Presenter`. It renders UI from Presenter calls and forwards user events — it contains no business logic.

**Invariants:**
- Implements a `View` contract interface — Presenter calls methods on the interface, never on the concrete class
- Holds a Presenter reference injected by Hilt/Dagger — never `MyPresenter()` inline
- Forwards every user interaction to the Presenter — never computes results inline
- Renders all UI states declared in the View contract — no state method goes unimplemented
- Contains no business logic — all conditionals decide what to render, not what to compute

**When to create:** One Activity/Fragment per route destination. Created after the Presenter and View contract exist.

### Code Pattern

See `presentation/screen_structure` for the full Activity pattern.

# Project Structure

## Project Structure

### Project Layout

Feature modules follow this layout:

```
feature_[module]/src/main/java/{package}/feature_[module]/
├── data/
│   ├── mapper/       [Entity]Mapper.kt          extends BaseMapper<Response, Entity>
│   ├── request/      [Action]Request.kt
│   └── response/     [Entity]Response.kt         all fields @SerializedName + nullable
├── di/
│   ├── [Module]Module.kt                          @Provides factory methods
│   └── [Module]ActivityModule.kt                  @ContributesAndroidInjector bindings
├── domain/
│   ├── entity/       [Entity].kt                  pure Kotlin data class
│   ├── repository/   [Module]Repository.kt        interface only
│   └── usecase/      [Action][Entity]UseCase.kt   extends SingleUseCase<T, Params>
├── presentation/
│   └── [feature]/
│       ├── [Feature]Contract.kt                   View : BaseMvpView + Presenter : BaseMvpPresenter<View>
│       ├── [Feature]Presenter.kt                  extends BasePresenter<View>
│       └── [Feature]Activity.kt                   extends BaseMvpVbActivity<Binding, Presenter>
└── service/
    └── [Module]Api.kt                             Retrofit interface
```

Shared modules: `domain/` and `data/` at project root for cross-feature entities/repositories.
Core libraries: `lib_core_[name]` (e.g. `lib_core_network`, `lib_core_helper`).
Base classes: `base/` module — `BaseMvpVbActivity`, `BaseMvpVbFragment`, `BasePresenter`.

### Conventions and Naming

See `## Naming Convention` for the full naming rules.

### Build Commands

```bash
./gradlew assembleDevelopDebug    # dev debug build
./gradlew assembleProdRelease     # production release
./gradlew test                    # all unit tests
./gradlew :<module>:test          # per-module unit tests
./gradlew ktlint                  # check code style
./gradlew ktlintFormat            # auto-fix style
./gradlew detekt                  # static analysis
./gradlew lint                    # Android lint
./gradlew createDebugCoverageReport  # Jacoco coverage
```

### Key Dependencies

- Kotlin 1.9.x, AGP 8.x, min SDK 23, target SDK 35
- DI: Dagger 2 (`@Module`, `@Provides`, `@ContributesAndroidInjector`)
- Async: RxJava 3 + RxAndroid
- Network: Retrofit 2, OkHttp, Gson, `RxJava3CallAdapterFactory`
- UI: ViewBinding (no `findViewById`)
- Testing: JUnit4, Mockito + mockito-kotlin, JUnitForger (Elmyr), BDDMockito

## Naming Convention

### Theory

All identifiers follow Kotlin/Android conventions. Consistency matters most at module, file, and test method boundaries.

- Classes/interfaces/enums — PascalCase (`AttendancePresenter`, `EmployeeRepository`)
- Methods/properties/variables — camelCase (`onCheckInClicked`, `employeeList`)
- Constants — `UPPER_SNAKE_CASE`
- Resources — `snake_case` with component prefix (e.g. `ic_`, `bg_`, `layout_`, `item_`)
- Feature module directories — `snake_case` (e.g. `feature_attendance`)
- `{Feature}` placeholder in file names = PascalCase; `{feature}` placeholder = snake_case
- Analytics event and property string values — `snake_case` matching the analytics platform convention

### Definition

File-level naming patterns:

| Artifact | Pattern | Example |
|---|---|---|
| Entity | `[Entity].kt` | `Employee.kt` |
| DTO | `[Entity]Response.kt` | `EmployeeResponse.kt` |
| Mapper | `[Entity]Mapper.kt` | `EmployeeMapper.kt` |
| Repository interface | `[Module]Repository.kt` | `AttendanceRepository.kt` |
| Repository impl | `[Module]RepositoryImpl.kt` | `AttendanceRepositoryImpl.kt` |
| Use case | `[Action][Entity]UseCase.kt` | `GetTimeOffRequestsUseCase.kt` |
| MVP contract | `[Feature]Contract.kt` | `AttendanceContract.kt` |
| Presenter | `[Feature]Presenter.kt` | `AttendancePresenter.kt` |
| Activity/Fragment | `[Feature]Activity.kt` | `AttendanceActivity.kt` |
| Test file | `[Subject]Test.kt` | `AttendancePresenterTest.kt` |
| Test method | `test_given[Condition]_when[Action]_then[ExpectedResult]` | See `## Test Naming Convention` |

### Code Pattern

```kotlin
// Classes — PascalCase
class AttendancePresenter : BasePresenter<AttendanceContract.View>()

// Constants — UPPER_SNAKE_CASE
companion object {
    const val MAX_RETRY_COUNT = 3
}

// Resources — snake_case with prefix
R.layout.fragment_attendance
R.drawable.ic_check_in
R.id.tv_employee_name

// Analytics values — snake_case
const val EVENT_CHECK_IN_SUCCESS = "check_in_success"
const val PARAM_EMPLOYEE_ID = "employee_id"
```

# Syntax Conventions

## Null Safety Extensions

### Theory

**Rule:** Never use raw null-fallback operators (e.g. `?:`, `!!`) directly in domain, data, or presentation code. Always delegate to a named extension method or utility function.

**Why:** Raw operators scatter fallback semantics across the codebase — the intent (`orEmpty`, `orZero`) disappears into punctuation. Named methods make the fallback explicit, searchable, and consistently applied.

**Categories — every platform must implement all of these:**

| Category | Method name | Fallback |
|---|---|---|
| Nullable numeric | `orZero()` | `0` |
| Nullable string | `orEmpty()` | `""` |
| Nullable collection | `orEmpty()` | `[]` |
| Nullable bool (false) | `orFalse()` | `false` |
| Nullable bool (true) | `orTrue()` | `true` |
| Nullable with custom default | `orDefault(x)` | `x` |

**Invariant:** Raw null operators are allowed only inside the extension/utility implementations themselves — never in domain, data, or presentation artifacts.

---

### Definition

Extension functions for null safety. Import only what you use.

Rules:
- Never use `?: ""`, `?: 0`, `?: false` inline in mappers — always use the extension function
- For nested optional chains: `response.nested?.field.orEmpty()`
- For list mapping: `response.items?.map { mapper.map(it) }.orEmpty()`

### Code Pattern

```kotlin
import extensions.orEmpty   // String?, List<T>?
import extensions.orZero    // Int?, Long?, Double?, Float?
import extensions.orFalse   // Boolean?
import extensions.orTrue    // Boolean?

// Usage:
val name: String  = response.name.orEmpty()          // null → ""
val items: List<T> = response.items.orEmpty()        // null → emptyList()
val count: Int    = response.count.orZero()          // null → 0
val isActive: Boolean = response.isActive.orFalse()  // null → false
val isEnabled: Boolean = response.isEnabled.orTrue() // null → true

// ❌ Never:
val name = response.name ?: ""    // use .orEmpty()
val count = response.count ?: 0   // use .orZero()
```

# Utilities

## Date Service

### Theory

**DateService** is a centralized abstraction for all date and time operations — formatting, parsing, comparison, and timezone handling.

**Invariants:**
- All date formatting and parsing goes through `DateService` — never via inline format strings or `SimpleDateFormat`/`DateFormatter` at call sites
- Timezone handling is explicit — never assume device timezone in business logic
- The interface is injectable for testing — implementations can return fixed dates in tests

**When to use:** Any layer that formats, parses, or compares dates. Domain layer may define date-related value objects; `DateService` handles the conversion to/from display and wire formats.

---

### Definition

Android date formatting and parsing utilities — centralized to avoid scattered `SimpleDateFormat`/`DateTimeFormatter` usage.

### Code Pattern

```kotlin
// Extension functions in DateExtensions.kt: .toDisplayDate(), .toApiDate(), .isToday(), .isPast()
```

## Helper Extensions

### Theory

**Helper Extensions** are stateless utility functions scoped to a specific type — they extend built-in types with domain-safe convenience without introducing service dependencies.

**Invariants:**
- Extensions contain no business logic and no side effects — pure transformations only
- No analytics SDK, storage, or network imports inside extension files
- Grouped by the type they extend (e.g. `String+Formatting`, `Date+Helpers`) — never a catch-all utilities file

**When to use:** Repetitive type-level transformations that would otherwise be inlined everywhere. If the transformation requires injected state, it belongs in a use case or service, not an extension.

---

### Definition

Extension functions live in `core/extensions/`.

### Code Pattern

```kotlin
// core/extensions/StringExtensions.kt
// .orEmpty(), .orDash(), .removeWhitespace(), .capitalizeFirst(), .isNumeric()

// core/extensions/NumberExtensions.kt
// .orZero(), .toCurrencyString(), .toFormattedString()

// core/extensions/DateExtensions.kt
// .toDisplayDate(), .toApiDate(), .isToday(), .isPast()

// core/extensions/ViewExtensions.kt
// .show(), .hide(), .gone(), .addRipple()

// core/extensions/ContextExtensions.kt
// .showToast(msg), .showSnackbar(msg), .hideKeyboard()

// core/extensions/RxExtensions.kt
// .applySchedulers(), .mapToVoid(), .retryWithDelay(n)
```

| Helper | File | Key Functions |
|--------|------|---------------|
| `String?` | `StringExtensions.kt` | `.orEmpty()`, `.orDash()`, `.removeWhitespace()`, `.capitalizeFirst()`, `.isNumeric()` |
| `Int?` / `Double?` | `NumberExtensions.kt` | `.orZero()`, `.toCurrencyString()`, `.toFormattedString()` |
| `Date` / `Calendar` | `DateExtensions.kt` | `.toDisplayDate()`, `.toApiDate()`, `.isToday()`, `.isPast()` |
| `View` | `ViewExtensions.kt` | `.show()`, `.hide()`, `.gone()`, `.addRipple()` |
| `Activity` / `Fragment` | `ContextExtensions.kt` | `.showToast(msg)`, `.showSnackbar(msg)`, `.hideKeyboard()` |
| `Observable<T>` | `RxExtensions.kt` | `.applySchedulers()`, `.mapToVoid()`, `.retryWithDelay(n)` |

## Logger

### Theory

**Logger** is the centralized logging abstraction with severity levels. All log output goes through this interface.

**Invariants:**
- Severity levels: `debug`, `info`, `warning`, `error` — each with distinct routing (debug stripped in production)
- No `print` / `console.log` / `Log.d` calls at call sites — always use the Logger interface
- Sensitive data (tokens, PII) must never appear in log output
- The implementation routes to Crashlytics or the platform crash reporter for `error`-level events

**When to use:** Any layer that needs diagnostic output. Inject `Logger` — never call the platform logging API directly.

---

### Definition

Structured logging utility — Timber-based wrapper injected as a `Logger` interface.

### Code Pattern

```kotlin
// Placeholder — add Timber-based structured logger here
// Injected as Logger interface; implementation uses Timber.d/e/w
// Never use Log.d directly at call sites — use the injected Logger
```

## Storage Service

### Theory

**StorageService** is an interface-based key-value store for persisting tokens, user preferences, and cached data across app sessions.

**Invariants:**
- The interface lives in the infrastructure layer — never in domain or data
- All keys are typed constants (enum or sealed class) — never raw strings at call sites
- Implementations are swappable per environment (e.g. in-memory for tests, secure storage for production)
- `clearAll()` is only called on logout — never on individual feature teardown

**When to use:** Any layer that needs to read or write persistent state. Inject the interface — never access the concrete implementation directly.

---

### Definition

`SharedPreferences`/`EncryptedSharedPreferences` abstraction with typed keys, injected via Dagger.

### Code Pattern

```kotlin
// Pattern: interface SessionPreference with typed keys, injected via Dagger
// Implementation: SharedPreferences or EncryptedSharedPreferences
// Keys: typed constants in a sealed class or enum — never raw strings at call sites
```
