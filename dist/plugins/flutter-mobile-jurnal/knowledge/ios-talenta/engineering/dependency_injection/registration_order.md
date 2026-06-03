---
platform: ios
project: ios-talenta
discipline: engineering
topic: dependency_injection
pattern: registration_order
---

## Theory

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

## Registration Order

Dependencies must be declared before they are referenced. The correct order mirrors the dependency graph (leaf nodes first):

```swift
// SharedDIContainer.swift — infrastructure first
lazy var networkMonitor: NetworkMonitoring = NetworkMonitor.shared
lazy var locationManager: TalentaLocationManager = LocationManager()
lazy var baseErrorMapper: BaseErrorModelMapper = BaseErrorModelMapper()

// TalentaTMDIContainer.swift — data layer
lazy var liveAttendanceRemoteDataSource: LiveAttendanceRemoteDataSource = LiveAttendanceRemoteDataSourceImpl()
lazy var requestLiveAttendanceMapper: RequestLiveAttendanceModelMapperType = RequestLiveAttendanceModelMapper()
lazy var liveAttendanceRepository: LiveAttendanceRepository = LiveAttendanceRepositoryImpl(
    remoteDataSource: liveAttendanceRemoteDataSource,
    requestLiveAttendanceMapper: requestLiveAttendanceMapper
)

// Domain layer — use cases depend on repositories
lazy var postSubmitCICOUseCase: PostSubmitCICOUseCaseType = PostSubmitCICOUseCase(repository: liveAttendanceRepository)

// Presentation — ViewModels created via factory methods, never as singletons
func makeCICOLocationViewModel(navigator: CICOLocationNavigator) -> CICOLocationViewModel { ... }
```

## Scope Rules

| Scope | Swift pattern | Use for |
|---|---|---|
| Singleton (lazy) | `lazy var` on the container | Repositories, use cases, mappers, data sources — stateless, shared |
| Factory | `func make*()` on the container | ViewModels — stateful, must be fresh per screen |
| Per-coordinator | Stored on the `Coordinator` instance | Coordinators — owned by their parent coordinator |

**Never register a ViewModel as a `lazy var` singleton** — it holds mutable UI state that must reset when the screen is destroyed. Always use `make*()` factory methods.
