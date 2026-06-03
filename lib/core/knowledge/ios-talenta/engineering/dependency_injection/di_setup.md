---
platform: ios
project: ios-talenta
discipline: engineering
topic: dependency_injection
pattern: di_setup
---

## Theory

These rules apply regardless of framework (Next.js React Context, Swinject, get_it):

1. **Constructor injection** — dependencies are declared as constructor parameters, never fetched inside a class body
2. **Depend on interfaces, not implementations** — callers reference abstract types; the container resolves the concrete class
3. **No `new` inside business logic** — use cases, StateHolders, and repository implementations never instantiate their own dependencies
4. **Container owns lifecycle** — the DI container decides whether a dependency is a singleton, feature-scoped, or transient; callers never manage this
5. **One container per runtime boundary** — if your platform has multiple runtimes (e.g. server + client), each runtime gets its own container; never share a container across boundaries

---

## Architecture Overview

Talenta iOS uses **Constructor Injection with defaults** as the current pattern — dependencies are injected via `init` parameters that default to shared singletons. The **Manual DI Container** pattern described below is the target architecture and is not yet implemented in the codebase.

```
┌─────────────────────────────────────────────────┐
│  App Launch → DIContainer.shared.configure()   │
│  (Production, Dev, Mock environments)           │
└───────────────────┬─────────────────────────────┘
                    │
        ┌───────────┴──────────┐
        │                      │
┌───────▼─────────┐   ┌────────▼────────┐
│ Feature Module  │   │ Shared Module   │
│   DI Container  │   │   DI Container  │
│  (TalentaTM)    │   │   (Common)      │
└───────┬─────────┘   └────────┬────────┘
        │                      │
        └──────────┬───────────┘
                   │
        ┌──────────▼──────────┐
        │  Coordinator/       │
        │  ViewModel          │
        │  (Consumes deps)    │
        └─────────────────────┘
```

## Manual DI Container Pattern

**Recommendation:** Use a lightweight manual DI Container per module to centralize dependency creation.

### Shared DI Container

```swift
// Talenta/Shared/DI/SharedDIContainer.swift
final class SharedDIContainer {

    // MARK: - Singleton
    static let shared = SharedDIContainer()
    private init() {}

    // MARK: - Environment
    enum Environment {
        case production
        case development
        case testing
    }

    private(set) var environment: Environment = .production

    func configure(for environment: Environment) {
        self.environment = environment
    }

    // MARK: - Data Layer

    lazy var baseErrorMapper: BaseErrorModelMapper = {
        BaseErrorModelMapper()
    }()

    // MARK: - Core Services

    lazy var networkMonitor: NetworkMonitoring = {
        switch environment {
        case .production, .development:
            return NetworkMonitor.shared
        case .testing:
            return MockNetworkMonitor()
        }
    }()

    lazy var locationManager: TalentaLocationManager = {
        switch environment {
        case .production, .development:
            return LocationManager()
        case .testing:
            return MockLocationManager()
        }
    }()

    lazy var analyticsService: AnalyticsService = {
        switch environment {
        case .production:
            return FirebaseAnalyticsService.shared
        case .development:
            return DebugAnalyticsService()
        case .testing:
            return MockAnalyticsService()
        }
    }()

    // MARK: - Reset (for testing)

    func reset() {
        // Reset all lazy properties by recreating container
        // Used in unit tests between test cases
    }
}
```

### Feature Module DI Container

```swift
// Talenta/Module/TalentaTM/DI/TalentaTMDIContainer.swift
final class TalentaTMDIContainer {

    // MARK: - Singleton
    static let shared = TalentaTMDIContainer()
    private init() {}

    // MARK: - Shared Dependencies
    private let sharedContainer = SharedDIContainer.shared

    // MARK: - Data Layer - DataSources

    lazy var liveAttendanceRemoteDataSource: LiveAttendanceRemoteDataSource = {
        LiveAttendanceRemoteDataSourceImpl()
    }()

    // MARK: - Data Layer - Mappers

    lazy var requestLiveAttendanceMapper: RequestLiveAttendanceModelMapperType = {
        RequestLiveAttendanceModelMapper()
    }()

    lazy var cicoLocationValidationMapper: CICOLocationValidationModelMapperType = {
        CICOLocationValidationModelMapper()
    }()

    lazy var serverTimeMapper: LiveAttendanceServerTimeModelMapperType = {
        LiveAttendanceServerTimeModelMapper()
    }()

    // MARK: - Data Layer - Repositories

    lazy var liveAttendanceRepository: LiveAttendanceRepository = {
        LiveAttendanceRepositoryImpl(
            remoteDataSource: liveAttendanceRemoteDataSource,
            requestLiveAttendanceMapper: requestLiveAttendanceMapper,
            cicoLocationValidationMapper: cicoLocationValidationMapper,
            serverTimeMapper: serverTimeMapper,
            baseErrorModelMapper: sharedContainer.baseErrorMapper
        )
    }()

    // MARK: - Domain Layer - UseCases

    lazy var postSubmitCICOUseCase: PostSubmitCICOUseCaseType = {
        PostSubmitCICOUseCase(
            repository: liveAttendanceRepository
        )
    }()

    // MARK: - Domain Layer - Services

    lazy var cicoValidator: CICOValidationService = {
        CICOValidationService()
    }()

    // MARK: - Factory Methods (for ViewModels)

    func makeCICOLocationViewModel(
        navigator: CICOLocationNavigator
    ) -> CICOLocationViewModel {
        CICOLocationViewModel(
            navigator: navigator,
            postSubmitCICOUseCase: postSubmitCICOUseCase,
            getCICOLocationValidationUseCase: getCICOLocationValidationUseCase,
            locationManager: sharedContainer.locationManager,
            analyticsService: sharedContainer.analyticsService
        )
    }

    // MARK: - Reset (for testing)

    func reset() {
        // Force recreation of all lazy properties
        // Called in setUp() of unit tests
    }
}
```

### App Configuration

```swift
// AppDelegate.swift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        configureDependencies()

        return true
    }

    private func configureDependencies() {
        #if DEBUG
        // Use development environment for debug builds
        SharedDIContainer.shared.configure(for: .development)
        #else
        // Use production environment for release builds
        SharedDIContainer.shared.configure(for: .production)
        #endif
    }
}
```

### Usage in Coordinator

```swift
// Talenta/Module/TalentaTM/Presentation/Coordinator/CICOCoordinator.swift
class CICOCoordinator: Coordinator {

    private let container = TalentaTMDIContainer.shared

    func showCICOLocation() {
        // ViewModel created by DI Container factory
        let viewModel = container.makeCICOLocationViewModel(navigator: self)
        let viewController = CICOLocationViewController(viewModel: viewModel)

        navigationController.pushViewController(viewController, animated: true)
    }
}

extension CICOCoordinator: CICOLocationNavigator {
    func navigateToSuccess() {
        // Navigation logic
    }
}
```

## Constructor Injection (Current Pattern)

The actual pattern in use throughout the codebase — Coordinators instantiate ViewModels directly via `init`, and dependencies default to shared singletons:

```swift
class CICOLocationViewModel: BaseViewModelV2<...> {
    private let postSubmitCICOUseCase: any PostSubmitCICOUseCaseType
    private let locationManager: TalentaLocationManager

    init(
        navigator: any CICOLocationNavigator,
        postSubmitCICOUseCase: any PostSubmitCICOUseCaseType = TalentaTMDIContainer.shared.postSubmitCICOUseCase,
        locationManager: TalentaLocationManager = SharedDIContainer.shared.locationManager
    ) {
        self.postSubmitCICOUseCase = postSubmitCICOUseCase
        self.locationManager = locationManager
        super.init()
    }
}
```

**When to use:**
- ✅ **Constructor Injection with Defaults:** Current codebase pattern — use this for all new code until DIContainer is introduced
- ✅ **DI Container Factory:** Target pattern for new modules once DIContainer is established

## DI Principles

| Component | Lifecycle | Managed By |
|-----------|-----------|------------|
| **Repositories** | Singleton (lazy) | DI Container |
| **Mappers** | Singleton (lazy) | DI Container |
| **UseCases** | Singleton (lazy) | DI Container |
| **Services** | Singleton (lazy) | DI Container |
| **ViewModels** | Factory (new instance) | DI Container `make*()` methods |
| **Coordinators** | Factory (new instance) | Parent coordinator |
| **ViewControllers** | Factory (new instance) | Coordinator |

## When to Use What?

```swift
// ✅ RECOMMENDED: DI Container factory for ViewModels
let viewModel = TalentaTMDIContainer.shared.makeCICOLocationViewModel(navigator: self)

// ✅ OK: Direct access for UseCases/Repositories (if needed outside container)
let useCase = TalentaTMDIContainer.shared.postSubmitCICOUseCase

// ✅ OK: Constructor injection with container defaults (legacy compatibility)
init(useCase: PostSubmitCICOUseCaseType = TalentaTMDIContainer.shared.postSubmitCICOUseCase)

// ❌ AVOID: Hardcoded singleton instances (not testable)
let useCase = PostSubmitCICOUseCase.sharedInstance

// ❌ AVOID: Creating instances directly in ViewModel
let repository = LiveAttendanceRepositoryImpl()
```
