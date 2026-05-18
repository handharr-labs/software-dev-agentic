# iOS — Migration Guide

## Migration Guide <!-- 353 -->

### Legacy → Modern Code

**Legacy** (root-level folders):
```
Models/
Controllers/
ViewModels/
```

**Modern** (module-based):
```
Talenta/Module/[Feature]/Data|Domain|Presentation/
Talenta/Shared/Data|Domain|Presentation/
```

### Modern UseCase Migration

**Migrating from old Param pattern to nested Params:**

#### Before (Old Pattern)

```swift
// Separate Param files
// Domain/Param/Query/PostSubmitCICOQueryParam.swift
struct PostSubmitCICOQueryParam {
    let employeeId: Int
    let scheduleId: Int
    // ...
}

// Domain/Param/Path/LiveAttendanceCICOPathParam.swift
struct LiveAttendanceCICOPathParam {
    let companyId: Int
}

// UseCase with old protocol
typealias PostSubmitCICOUseCaseType = UseCase<PostSubmitCICOQueryParam, LiveAttendanceCICOPathParam, RequestLiveAttendanceModel>

class PostSubmitCICOUseCase: UseCase {
    func call(
        queryParams: PostSubmitCICOQueryParam?,
        pathParams: LiveAttendanceCICOPathParam?,
        expected: @escaping (Result<RequestLiveAttendanceModel, BaseErrorModel>) -> Void
    ) { ... }
}
```

#### After (Modern Pattern)

```swift
// Single file - all params nested inside UseCase
// Domain/UseCase/CICO/PostSubmitCICOUseCase.swift

final class PostSubmitCICOUseCase: UseCaseProtocol {
    // MARK: - Params (nested)
    struct Params {
        let companyId: Int          // Path parameter
        let payload: Payload        // Request body

        struct Payload {
            let employeeId: Int
            let scheduleId: Int
            // ...
        }
    }

    func execute(
        params: Params,
        completion: @escaping (Result<RequestLiveAttendanceModel, BaseErrorModel>) -> Void
    ) { ... }
}
```

#### Migration Steps

1. **Update protocol definitions** in `Shared/Domain/UseCaseType.swift`
2. **Create new UseCases** with nested Params pattern
3. **Migrate existing UseCases** one module at a time
4. **Update ViewModels** to use new Params structure
5. **Delete old Param files** from `Domain/Param/Query/` and `Domain/Param/Path/`
6. **Run tests** to ensure everything works

### Moving Mappers from Domain to Data Layer

**Important:** The current codebase has Mappers in `Domain/Mapper/`, but following Clean Architecture principles, they should be in `Data/Mapper/`.

#### Why This Change?

| Principle | Explanation |
|-----------|-------------|
| **Dependency Rule** | Data layer depends on Domain, not vice versa. Mappers need to see both Response (Data) and Entity (Domain). |
| **Framework Independence** | Domain must be pure Swift. Mappers use `Codable`, JSON parsing, and optional extensions. |
| **Implementation Detail** | How we convert API responses is infrastructure, not business logic. |

#### Migration Steps

**Phase 1: Create New Structure**
```bash
# For each feature module
mkdir -p Talenta/Module/TalentaTM/Data/Mapper
mkdir -p Talenta/Module/TalentaPayslip/Data/Mapper
mkdir -p Talenta/Module/feature_integration/Data/Mapper
# etc...

# For shared mappers
mkdir -p Talenta/Shared/Data/Mapper
```

**Phase 2: Move Mapper Files**
```bash
# Example for TalentaTM
mv Talenta/Module/TalentaTM/Domain/Mapper/*.swift \
   Talenta/Module/TalentaTM/Data/Mapper/

# Update imports in Repository files if needed (usually no change needed)
```

**Phase 3: Update File Paths in Comments**
```swift
// Before
// Domain/Mapper/RequestLiveAttendanceModelMapper.swift

// After
// Data/Mapper/RequestLiveAttendanceModelMapper.swift
```

**Phase 4: Update Xcode Project**
- Remove old Mapper folder references from Domain
- Add new Mapper folder references under Data
- Ensure all files are in correct target membership

**Phase 5: Verify No Import Changes Needed**
```swift
// Repository implementations already import Domain entities
// Mappers already convert Response → Entity
// No code changes needed, just file relocation!
```

**Phase 6: Clean Up**
```bash
# Delete empty Domain/Mapper directories
rmdir Talenta/Module/*/Domain/Mapper
rmdir Talenta/Shared/Domain/Mapper
```

#### Migration Priority

1. **Shared/Data/Mapper/** (affects all modules)
   - `BaseErrorModelMapper`
   - Common utility mappers

2. **TalentaTM/Data/Mapper/** (most active module)
   - Live attendance mappers
   - Time off mappers
   - Task management mappers

3. **Other modules** (as needed)
   - TalentaPayslip
   - feature_integration
   - TalentaDashboard
   - TalentaECM

**Testing After Migration:**
```bash
# Run all unit tests
xcodebuild test -scheme Talenta -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Verify repository tests still pass (they mock mappers)
# Verify mapper tests still pass
# Build and run app to ensure no runtime issues
```

### Legacy Code Migration Checklist

When migrating legacy code to modern architecture:

- [ ] Identify feature domain (TalentaTM, TalentaPayslip, etc.)
- [ ] Extract entities to `Domain/Entities/`
- [ ] Create repository protocol in `Domain/Repository/`
- [ ] Create repository impl in `Data/RepositoriesImpl/`
- [ ] Create UseCases with **nested Params** in `Domain/UseCase/`
- [ ] Convert ViewModels to BaseViewModelV2 pattern
- [ ] Create Coordinator for navigation
- [ ] Write unit tests for all layers
- [ ] Delete legacy code only after tests pass

### Adopting Manual DI Container

**Goal:** Replace scattered singleton instances with centralized DI Container per module.

#### Step 1: Create Shared DI Container

```swift
// Talenta/Shared/DI/SharedDIContainer.swift
final class SharedDIContainer {
    static let shared = SharedDIContainer()
    private init() {}

    enum Environment {
        case production
        case development
        case testing
    }

    private(set) var environment: Environment = .production

    func configure(for environment: Environment) {
        self.environment = environment
    }

    // Add shared dependencies (locationManager, analyticsService, etc.)
    lazy var baseErrorMapper: BaseErrorModelMapper = {
        BaseErrorModelMapper()
    }()

    lazy var networkMonitor: NetworkMonitoring = {
        switch environment {
        case .production, .development:
            return NetworkMonitor.shared
        case .testing:
            return MockNetworkMonitor()
        }
    }()
}
```

#### Step 2: Create Feature Module DI Container

```swift
// Talenta/Module/TalentaTM/DI/TalentaTMDIContainer.swift
final class TalentaTMDIContainer {
    static let shared = TalentaTMDIContainer()
    private init() {}

    private let sharedContainer = SharedDIContainer.shared

    // Data Layer
    lazy var liveAttendanceRemoteDataSource: LiveAttendanceRemoteDataSource = {
        LiveAttendanceRemoteDataSourceImpl()
    }()

    lazy var requestLiveAttendanceMapper: RequestLiveAttendanceModelMapperType = {
        RequestLiveAttendanceModelMapper()
    }()

    lazy var liveAttendanceRepository: LiveAttendanceRepository = {
        LiveAttendanceRepositoryImpl(
            remoteDataSource: liveAttendanceRemoteDataSource,
            requestLiveAttendanceMapper: requestLiveAttendanceMapper,
            baseErrorModelMapper: sharedContainer.baseErrorMapper
        )
    }()

    // Domain Layer
    lazy var postSubmitCICOUseCase: PostSubmitCICOUseCaseType = {
        PostSubmitCICOUseCase(repository: liveAttendanceRepository)
    }()

    // Factory Methods
    func makeCICOLocationViewModel(navigator: CICOLocationNavigator) -> CICOLocationViewModel {
        CICOLocationViewModel(
            navigator: navigator,
            postSubmitCICOUseCase: postSubmitCICOUseCase,
            locationManager: sharedContainer.locationManager
        )
    }
}
```

#### Step 3: Configure in AppDelegate

```swift
// AppDelegate.swift
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    #if DEBUG
    SharedDIContainer.shared.configure(for: .development)
    #else
    SharedDIContainer.shared.configure(for: .production)
    #endif

    return true
}
```

#### Step 4: Update Coordinators to Use Container

**Before:**
```swift
func showCICOLocation() {
    let viewModel = CICOLocationViewModel(navigator: self) // Uses default params
    let viewController = CICOLocationViewController(viewModel: viewModel)
    navigationController.pushViewController(viewController, animated: true)
}
```

**After:**
```swift
func showCICOLocation() {
    let viewModel = TalentaTMDIContainer.shared.makeCICOLocationViewModel(navigator: self)
    let viewController = CICOLocationViewController(viewModel: viewModel)
    navigationController.pushViewController(viewController, animated: true)
}
```

#### Step 5: Migrate Module by Module

1. **Start with Shared** — create SharedDIContainer for common dependencies
2. **TalentaTM** — highest activity, most dependencies
3. **TalentaPayslip** — second priority
4. **feature_integration** — custom forms, feedback
5. **TalentaDashboard** — dashboard, home
6. **TalentaECM** — employee directory, profiles

#### Benefits

| Before (Scattered Singletons) | After (DI Container) |
|-------------------------------|----------------------|
| `PostSubmitCICOUseCase.sharedInstance` | `TalentaTMDIContainer.shared.postSubmitCICOUseCase` |
| Hardcoded in default params | Centralized in container |
| Hard to swap prod/dev/test | Environment-based switching |
| No visibility of dependency graph | All dependencies in one file |
| Tests must override all defaults | Tests inject mocks via constructor |

#### Pro Tip: Use Lazy Properties for Minimal Setup

Instead of verbose lazy property closures, use **one-line lazy declarations** (see Section 7.8.5):

```swift
// ✅ Streamlined (one-line)
lazy var postSubmitCICOUseCase: PostSubmitCICOUseCaseType =
    PostSubmitCICOUseCase(repository: liveAttendanceRepository)

lazy var liveAttendanceRepository: LiveAttendanceRepository =
    LiveAttendanceRepositoryImpl(
        remoteDataSource: liveAttendanceDataSource,
        requestLiveAttendanceMapper: attendanceMapper
    )

// ❌ Verbose (old pattern - unnecessary braces)
lazy var postSubmitCICOUseCase: PostSubmitCICOUseCaseType = {
    PostSubmitCICOUseCase(repository: liveAttendanceRepository)
}()
```

**Result:** ~70% less boilerplate, same functionality!

---

## Appendix: Quick Reference <!-- 134 -->

### A. Layer Checklist (Modern Pattern)

When adding new feature:

- [ ] **Domain Layer**
  - [ ] Entity (Model) — `[Feature]Model.swift`
  - [ ] Repository protocol — `[Feature]Repository.swift`
  - [ ] UseCase with **nested Params** — `[Verb][Feature]UseCase.swift`
    - [ ] Define `Params` struct inside UseCase
    - [ ] Define `Payload` struct if needed (for POST/PUT)
  - [ ] Services if needed — `[Feature]Validator.swift`, `[Feature]Calculator.swift`
- [ ] **Data Layer**
  - [ ] Response model with CodingKeys — `[Feature]Response.swift`
  - [ ] Mapper protocol + implementation — `[Feature]ModelMapper.swift` (Data/Mapper/)
  - [ ] DataSource protocol — `[Feature]RemoteDataSource.swift`
  - [ ] DataSource implementation — `[Feature]RemoteDataSourceImpl.swift`
  - [ ] Repository implementation — `[Feature]RepositoryImpl.swift`
  - [ ] Inject mappers into repository
- [ ] **Presentation Layer**
  - [ ] ViewModel State struct — `[Feature]ViewModelState.swift`
  - [ ] ViewModel Event enum — `[Feature]ViewModelEvent.swift`
  - [ ] ViewModel Action enum — `[Feature]ViewModelAction.swift`
  - [ ] ViewModel extending BaseViewModelV2 — `[Feature]ViewModel.swift`
  - [ ] ViewController — `[Feature]ViewController.swift`
  - [ ] Coordinator + Navigator protocol — `[Feature]Coordinator.swift`
- [ ] **Testing**
  - [ ] UseCase mock
  - [ ] Repository mock
  - [ ] DataSource mock
  - [ ] ViewModel test
  - [ ] Repository test
  - [ ] Mapper test
  - [ ] Service test (if applicable)

### B. Common Patterns

| Pattern | Usage |
|---------|-------|
| Singleton | UseCases, Repositories |
| Constructor Injection | All dependencies with defaults |
| Protocol-based | Repositories, DataSources, Mappers |
| Result<Model, BaseErrorModel> | All async operations |
| BaseViewModelV2 | All ViewModels |
| BehaviorRelay<State> | ViewModel state |
| RxSwift Driver | ViewController bindings |
| Coordinator | Navigation flow |
| Moya TargetType | API definitions |

### C. File Templates

Reference these for AI-assisted development:

#### Modern UseCase Template (Recommended)

```swift
final class [Verb][Feature]UseCase: UseCaseProtocol {
    // MARK: - Params
    struct Params {
        // For GET with ID
        let [resource]Id: String

        // OR for GET with filters
        let page: Int
        let limit: Int
        let filter1: String?

        // OR for POST/PUT with path + body
        let [path]Id: String
        let payload: Payload

        struct Payload {
            let field1: String
            let field2: Int
            // ...

            init(...) { ... }
        }

        init(...) { ... }
    }

    // MARK: - Singleton
    private static var _sharedInstance: [Verb][Feature]UseCase?
    static var sharedInstance: [Verb][Feature]UseCase {
        if _sharedInstance == nil {
            _sharedInstance = [Verb][Feature]UseCase()
        }
        return _sharedInstance!
    }

    // MARK: - Dependencies
    private let repository: [Feature]Repository

    // MARK: - Init
    init(repository: [Feature]Repository = [Feature]RepositoryImpl.sharedInstance) {
        self.repository = repository
    }

    // MARK: - Execute
    func execute(
        params: Params,
        completion: @escaping (Result<[Model], BaseErrorModel>) -> Void
    ) {
        // Delegate to repository
        repository.[method](/* extract params */, completion: completion)
    }
}
```

#### Other Templates

- **Repository**: `LiveAttendanceRepositoryImpl.swift`
- **ViewModel**: `CICOLocationViewModel.swift`
- **State/Event/Action**: `CICOLocationViewModelState.swift`
- **Mapper**: `RequestLiveAttendanceModelMapper.swift`
- **Response**: `RequestLiveAttendanceResponse.swift`
- **Entity**: `RequestLiveAttendanceModel.swift`

#### Detailed Examples

See [.claude/usecase-best-practices-v2.md](.claude/usecase-best-practices-v2.md) for:
- Complete UseCase patterns (GET, POST, PUT, DELETE)
- Nested Params with Payload examples
- Service integration patterns
- Migration guide from old to new pattern

---

**Document Version**: 2.0
**Last Updated**: 2026-02-15
**Maintainer**: Talenta iOS Team
**Based On**: SwiftUI StarterKit Architecture + Talenta iOS V1
