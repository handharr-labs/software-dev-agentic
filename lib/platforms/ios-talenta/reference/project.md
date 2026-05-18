# iOS — Project Structure

## Modular Architecture (Feature-Based) <!-- 103 -->

### Current Module Structure

```
Talenta/Module/
├── TalentaTM/                          # Time Management
│   ├── DI/                             # Dependency Injection Container
│   │   └── TalentaTMDIContainer.swift  # Module DI Container
│   ├── Data/
│   │   ├── Models/                     # API response models
│   │   ├── Mapper/                     # Response → Domain Entity mappers
│   │   ├── DataSource/                 # Remote/Local data sources
│   │   │   ├── Remote/
│   │   │   └── Local/
│   │   └── RepositoriesImpl/           # Repository implementations
│   ├── Domain/
│   │   ├── Entities/                   # Business models
│   │   ├── Repository/                 # Repository protocols
│   │   ├── UseCase/                    # UseCases (with nested Params)
│   │   │   ├── CICO/
│   │   │   │   └── PostSubmitCICOUseCase.swift  # Contains nested Params + Payload
│   │   │   ├── Employee/
│   │   │   │   └── GetEmployeesUseCase.swift    # Contains nested Params
│   │   │   └── ...
│   │   ├── Services/                   # Business logic services (optional)
│   │   └── enum/                       # Domain enums
│   └── Presentation/
│       ├── Coordinator/                # Navigation coordinators
│       ├── ViewModel/                  # ViewModels (State/Event/Action)
│       ├── View/                       # ViewControllers
│       └── Views/                      # Custom UI components
├── TalentaPayslip/                     # Payroll
│   └── DI/                             # TalentaPayslipDIContainer.swift
├── feature_integration/                # Employee feedback
│   └── DI/                             # FeatureIntegrationDIContainer.swift
├── TalentaDashboard/                   # Dashboard
│   └── DI/                             # TalentaDashboardDIContainer.swift
└── TalentaECM/                         # Employee directory
    └── DI/                             # TalentaECMDIContainer.swift
```

**Key Change:** No more separate `Param/Query/` or `Param/Path/` directories! Params now live **inside** each UseCase as nested structs. ✅

### AppLayer

The app shell — OS entry points, composition root, and platform event routing. Not a Clean Architecture layer in the Data/Domain/Presentation sense; it's the outermost ring that wires everything together.

```
Talenta/AppLayer/
├── AppDelegate.swift                   # Process-level setup (Firebase, SDKs, push config)
├── SceneDelegate.swift                 # Scene lifecycle + window setup
└── Deeplink/
    └── DeeplinkManager.swift           # URL / universal link / shortcut → DeeplinkStream
```

**Rules:**
- ✅ Can depend on everything: `Module/`, `Shared/`, `DIComponents/`
- ❌ Nothing else depends on `AppLayer/` — it is the entry point, not a service
- ❌ No business logic — only OS event translation and wiring

---

### Shared Layer

```
Talenta/Shared/
├── DI/                                 # Dependency Injection
│   └── SharedDIContainer.swift         # Shared DI Container (environment config)
├── Data/
│   ├── Models/                         # Shared response models
│   ├── Mapper/                         # BaseErrorModelMapper, shared mappers
│   ├── DataSource/                     # Shared data sources
│   └── RepositoryImpl/                 # Shared repository implementations
├── Domain/
│   ├── Base/                           # BaseViewModelV2
│   ├── Entities/                       # PaginationBaseModel, BaseErrorModel
│   ├── Repository/                     # Shared repository protocols
│   ├── UseCase/                        # Shared use cases (with nested Params)
│   └── UseCaseType.swift               # UseCase protocol definitions
├── Presentation/
│   ├── Base/                           # TalentaBaseViewController
│   └── Components/                     # Shared UI components
├── Infrastructure/                     # ✅ NEW — platform/SDK adapters
│   ├── Notifications/                  # FCMManager.swift
│   ├── Analytics/                      # ClarityManager, MekariLogManager
│   ├── Location/                       # TalentaLocationManager, LocationManagerDelegate
│   └── FeatureFlag/                    # FeatureFlag, FeatureFlagManager
├── Extension/                          # orEmpty(), orFalse(), etc.
├── Utilities/                          # ❌ LEGACY - DO NOT ADD (use Infrastructure/)
└── Network/                            # Moya API definitions
```

**Infrastructure Rules:**
- Platform/SDK adapters — have side effects, wrap external frameworks
- ✅ Can depend on `Shared/Domain/`, `Shared/Data/`, external SDKs
- ❌ Cannot depend on `AppLayer/` or any `Module/`
- Distinguishes from `Domain/Services/` which must be pure (no I/O, no side effects)

**Key Change:** No more `Param/` directory in Shared layer either! All params are nested inside their respective UseCases.

---

## Project Structure <!-- 42 -->

```
talenta-ios/
├── Talenta/                            # Main app target
│   ├── AppLayer/                       # ✅ NEW CODE HERE — app shell
│   │   ├── AppDelegate.swift
│   │   ├── SceneDelegate.swift
│   │   └── Deeplink/
│   │       └── DeeplinkManager.swift
│   ├── Module/                         # ✅ NEW CODE HERE — feature modules
│   │   ├── TalentaTM/
│   │   ├── TalentaPayslip/
│   │   ├── feature_integration/
│   │   ├── TalentaDashboard/
│   │   └── TalentaECM/
│   ├── Shared/                         # ✅ NEW CODE HERE — cross-cutting
│   │   ├── Infrastructure/             # ✅ NEW — SDK/platform adapters
│   │   │   ├── Notifications/
│   │   │   ├── Analytics/
│   │   │   ├── Location/
│   │   │   └── FeatureFlag/
│   │   ├── Data/
│   │   ├── Domain/
│   │   ├── Presentation/
│   │   ├── Extension/
│   │   └── Network/
│   ├── DIComponents/                   # Needle DI bootstrap (RootComponent, streams)
│   ├── Models/                         # ❌ LEGACY - DO NOT ADD
│   ├── Controllers/                    # ❌ LEGACY - DO NOT ADD
│   ├── ViewModels/                     # ❌ LEGACY - DO NOT ADD
│   └── Resources/
├── TalentaTests/
│   ├── Module/
│   └── Mock/
├── Podfile
├── CLAUDE.md
└── temp-dir/                           # Temporary reports
```

---

## Conventions & Naming <!-- 49 -->

### File Naming

| Component | Naming | Example |
|-----------|--------|---------|
| Entity | `[Feature]Model` | `RequestLiveAttendanceModel` |
| Response | `[Feature]Response` | `RequestLiveAttendanceResponse` |
| Mapper | `[Feature]ModelMapper` | `RequestLiveAttendanceModelMapper` |
| Mapper Protocol | `[Feature]ModelMapperType` | `RequestLiveAttendanceModelMapperType` |
| UseCase | `[HttpMethod][Feature]UseCase` | `PostSubmitCICOUseCase` |
| UseCase Protocol | `[UseCase]Type` | `PostSubmitCICOUseCaseType` |
| Repository Protocol | `[Feature]Repository` | `LiveAttendanceRepository` |
| Repository Impl | `[Feature]RepositoryImpl` | `LiveAttendanceRepositoryImpl` |
| DataSource Protocol | `[Feature]RemoteDataSource` | `LiveAttendanceRemoteDataSource` |
| DataSource Impl | `[Feature]RemoteDataSourceImpl` | `LiveAttendanceRemoteDataSourceImpl` |
| Query Param | `[HttpMethod][Feature]QueryParam` | `PostSubmitCICOQueryParam` |
| Path Param | `[Feature]PathParam` | `LiveAttendanceCICOPathParam` |
| ViewModel | `[Feature]ViewModel` | `CICOLocationViewModel` |
| ViewModel State | `[Feature]ViewModelState` | `CICOLocationViewModelState` |
| ViewModel Event | `[Feature]ViewModelEvent` | `CICOLocationViewModelEvent` |
| ViewModel Action | `[Feature]ViewModelAction` | `CICOLocationViewModelAction` |
| ViewController | `[Feature]ViewController` | `CICOLocationViewController` |
| Coordinator | `[Feature]Coordinator` | `CICOLocationCoordinator` |
| Navigator Protocol | `[Feature]Navigator` | `CICOLocationNavigator` |
| Service | `[Feature][Verb/Noun]` | `LeaveBalanceCalculator` |
| Mock | `[OriginalClassName]Mock` | `PostSubmitCICOUseCaseMock` |

### HTTP Method Prefix

| HTTP | UseCase Prefix | Example |
|------|---------------|---------|
| GET | `Get` | `GetAttendanceHistoryUseCase` |
| POST | `Post` | `PostSubmitCICOUseCase` |
| PUT | `Put` | `PutUpdateProfileUseCase` |
| PATCH | `Patch` | `PatchUpdateStatusUseCase` |
| DELETE | `Delete` | `DeleteTaskUseCase` |

### Code Style

- **Indentation**: 4 spaces
- **Line length**: No strict limit (readable)
- **Braces**: Opening on same line
- **Comments**: Only when logic is non-obvious
- **Access control**: Explicit (private, internal, public)
- **Optionals**: Use extensions (`.orEmpty()`, `.orFalse()`)

---

## Design Decisions & Rationale <!-- 52 -->

### Why UIKit?

- ✅ Maturity: Stable, battle-tested
- ✅ Team expertise: Existing knowledge base
- ✅ Third-party: Better library support
- ✅ Fine-grained control: Complex layouts

### Why RxSwift?

- ✅ iOS 13+ support (Combine requires iOS 13+)
- ✅ Existing codebase: Already uses RxSwift
- ✅ Mature ecosystem: More operators/extensions
- ✅ Community: Established resources

### Why Moya?

- ✅ Type safety: Enum-based API definitions
- ✅ Testability: Protocol-based, easy mocking
- ✅ Centralized: All endpoints in one place
- ✅ RxSwift support: Built-in extensions

### Why Singleton + Constructor Injection?

- ✅ Simplicity: No DI framework
- ✅ Flexibility: Tests inject mocks via constructor
- ✅ Performance: Singletons shared across app
- ✅ Testability: Default params allow overrides

### Why BaseViewModelV2?

- ✅ UIKit compatibility: Works with UIKit
- ✅ Reactive patterns: Full RxSwift power
- ✅ Standardization: Unified ViewModel interface
- ✅ Type safety: Generic State/Event/Action

### Why Mappers in Data Layer?

- ✅ **Dependency Rule**: Data depends on Domain, not vice versa. Mappers convert `Response` (Data) → `Entity` (Domain), so they live where both types are visible.
- ✅ **Implementation Detail**: How we parse/transform API responses is infrastructure concern, not business logic.
- ✅ **Framework Independence**: Mappers use `Codable`, JSON parsing, optional unwrapping — Domain must remain pure Swift.
- ✅ **Testability**: Repositories still mockable with mock mappers via protocol injection.
- ✅ **Flexibility**: Swap mappers for API versioning without touching Domain.
- ✅ **Clean Architecture Compliance**: Industry standard practice — mappers are adapter pattern in outer layer.

### Why UseCase Mandatory?

- ✅ Single Responsibility: Each UseCase does one thing
- ✅ Testability: ViewModels don't mock repositories
- ✅ Reusability: Same UseCase across ViewModels
- ✅ Business logic isolation: Validation/caching centralized
