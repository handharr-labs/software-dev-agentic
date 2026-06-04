---
platform: ios
project: ios-talenta
discipline: engineering
topic: presentation
pattern: view_model
---

## Theory

A **StateHolder** is the single source of truth for a screen's UI state. Platform names vary (ViewModel, BLoC, Presenter) but the contract is identical across platforms.

**Invariants:**
- Owns no view imports — no UI framework, no widget, no component type
- Depends on use case interfaces only — never calls repositories or data sources directly
- Use cases are injected via DI — never instantiated directly inside the StateHolder
- Exposes state as a read-only stream or observable — UI observes, never mutates
- One StateHolder per screen — never shared across screens unless explicitly scoped

**When to create:** One StateHolder per screen. Created before the screen that observes it.

---

## StateHolder

In iOS, the StateHolder is implemented as a **ViewModel** extending `BaseViewModelV2`.

Invariants:
- Receives use cases via constructor injection — default singleton parameters are acceptable for legacy code; prefer protocol types
- Exposes state via `stateDriver: Driver<State>` — ViewController observes, never mutates
- Emits navigation as an `Action` — never calls `navigator` directly from event handlers without routing through `emitAction`
- One ViewModel per screen — scoped to the screen's lifecycle

---

### State

In iOS, **State** is a `struct` conforming to `ViewModelState` — a plain value type with an `initial` factory.

Invariants:
- Immutable from the ViewController's perspective — updated only via `updateDataState` inside the ViewModel
- Covers all render cases: loading flag, data fields, error/toast messages
- No UIKit types — no `UIColor`, `UIImage`, `NSAttributedString`; use primitives or UIModel wrappers

---

### Events / Input

In iOS, Events are `enum` cases conforming to `ViewModelEvent`. ViewController calls `viewModel.emitEvent(.caseName)` for every user interaction.

Invariants:
- Named after user actions — `.submitButtonTapped`, `.viewDidLoad`, not `.buttonClicked`
- Carry only the data needed — no raw `UIEvent` or `UITouch` objects
- Processed inside `emitEvent(_ event:)` override — ViewController never acts on them directly

---

### Actions / Output

In iOS, Actions are `enum` cases conforming to `ViewModelAction`, emitted via `emitAction(_:)`. ViewController observes `actionDriver` and responds.

Invariants:
- One-shot — emitted through `PublishSubject`, not stored in state
- Named after the outcome — `.navigateToSuccess`, `.showToast(message:)`, `.openCamera`
- Navigation targets are abstract — the ViewModel emits `.navigateToSuccess`; the Coordinator/Navigator decides *how*

---

### State Protocol

```swift
// Shared/Domain/Base/ViewModelState.swift
protocol ViewModelState {
    static var initial: Self { get }
}
```

### State Implementation

```swift
// Presentation/ViewModel/CICOLocation/CICOLocationViewModelState.swift
struct CICOLocationViewModelState: ViewModelState {
    var nextButtonIsEnable: Bool
    var mapViewCameraPosition: CLLocation?
    var updateLocationInfo: CLLocation?
    var actionContainerIsHidden: Bool
    var submitButtonTitle: String
    var appBarTitle: String
    var isLoading: Bool

    static var initial: CICOLocationViewModelState {
        return CICOLocationViewModelState(
            nextButtonIsEnable: false,
            mapViewCameraPosition: nil,
            updateLocationInfo: nil,
            actionContainerIsHidden: false,
            submitButtonTitle: "",
            appBarTitle: "",
            isLoading: false
        )
    }
}
```

### Event Protocol

```swift
// Shared/Domain/Base/ViewModelEvent.swift
protocol ViewModelEvent {}
```

### Event Implementation

```swift
// Presentation/ViewModel/CICOLocation/CICOLocationViewModelEvent.swift
enum CICOLocationViewModelEvent: ViewModelEvent {
    case viewDidLoad
    case submitButtonTapped
    case reloadLocationTapped
    case backButtonTapped
    case openCameraForSelfie
}
```

### Action Protocol

```swift
// Shared/Domain/Base/ViewModelAction.swift
protocol ViewModelAction {}
```

### Action Implementation

```swift
// Presentation/ViewModel/CICOLocation/CICOLocationViewModelAction.swift
enum CICOLocationViewModelAction: ViewModelAction {
    case showToast(message: String)
    case showLoading
    case hideLoading
    case openCamera
    case navigateToSuccess
    case navigationItemRightBarButtonItemRemoveAnimation
}
```

### BaseViewModelV2

Generic base class for all ViewModels with reactive state management.

```swift
// Shared/Domain/Base/BaseViewModelV2.swift
class BaseViewModelV2<State: ViewModelState, Event: ViewModelEvent, Action: ViewModelAction> {

    // MARK: - State Management
    let stateRelay = BehaviorRelay<State>(value: State.initial)

    // MARK: - Lifecycle
    let disposeBag = DisposeBag()

    // MARK: - Action Management
    let actionSubject = PublishSubject<Action>()
    let commonActionSubject = PublishSubject<CommonViewModelAction>()

    // MARK: - Public Reactive Interfaces
    lazy var stateDriver: Driver<State> = {
        return stateRelay.asDriver()
    }()

    lazy var actionDriver: Driver<Action> = {
        return actionSubject.asDriverOnErrorJustComplete()
    }()

    lazy var commonActionDriver: Driver<CommonViewModelAction> = {
        return commonActionSubject.asDriverOnErrorJustComplete()
    }()

    // MARK: - Init
    init() {
        setBinders()
    }

    // MARK: - Overridable

    /// Override to handle events from View
    func emitEvent(_ event: Event) {
        // Subclasses override
    }

    /// Override to setup reactive bindings
    func setBinders() {
        // Subclasses override
    }

    // MARK: - State Updates

    /// Update state with builder closure
    func updateDataState(builder: (inout State) -> Void) {
        var state = stateRelay.value
        builder(&state)
        stateRelay.accept(state)
    }

    /// Update state with builder closure (alternative)
    func updateDataStateWith(builder: (inout State?) -> Void) {
        var state: State? = stateRelay.value
        builder(&state)
        if let updatedState = state {
            stateRelay.accept(updatedState)
        }
    }

    // MARK: - Action Emission

    /// Emit custom action
    func emitAction(_ action: Action) {
        actionSubject.onNext(action)
    }

    /// Emit common action
    func emitCommonAction(_ action: CommonViewModelAction) {
        commonActionSubject.onNext(action)
    }
}
```

**BaseViewModelV2 Pattern:**
- Generic over `State`, `Event`, `Action`
- State in `BehaviorRelay<State>` for reactive updates
- `stateDriver` exposes state as Driver (main thread, no errors)
- `actionDriver` exposes custom actions
- `commonActionDriver` exposes standard actions (toast, loading)
- Subclasses override `emitEvent(_ event:)` for user interactions
- Subclasses override `setBinders()` for RxSwift bindings

### Concrete ViewModel

```swift
// Presentation/ViewModel/CICOLocation/CICOLocationViewModel.swift
class CICOLocationViewModel: BaseViewModelV2<
    CICOLocationViewModelState,
    CICOLocationViewModelEvent,
    CICOLocationViewModelAction
> {
    // MARK: - DEPENDENCIES
    private weak var navigator: (any CICOLocationNavigator)?
    private let locationManager: TalentaLocationManager
    private let postSubmitCICOUseCase: PostSubmitCICOUseCase
    private let postCICOValidateLocationUseCase: PostCICOValidateLocationUseCase
    private let userViewModel: UserModel

    // MARK: - DATA
    private let currentLocationRelay = BehaviorRelay<CLLocation?>(value: nil)
    private var selfieImage: Data?
    private var notes = ""

    // MARK: - INIT
    init(
        navigator: any CICOLocationNavigator,
        displayMode: CICOLocationDisplayMode,
        type: CICOType,
        scheduleData: AttendanceScheduleModel?,
        currentLocation: CLLocation?,
        mainScheduler: SchedulerType = MainScheduler.instance,
        locationManager: TalentaLocationManager = LocationManager(),
        postSubmitCICOUseCase: PostSubmitCICOUseCase = PostSubmitCICOUseCase.sharedInstance,
        postCICOValidateLocationUseCase: PostCICOValidateLocationUseCase = PostCICOValidateLocationUseCase.sharedInstance,
        userViewModel: UserModel = UserViewModel()
    ) {
        self.navigator = navigator
        self.locationManager = locationManager
        self.postSubmitCICOUseCase = postSubmitCICOUseCase
        self.postCICOValidateLocationUseCase = postCICOValidateLocationUseCase
        self.userViewModel = userViewModel
        self.currentLocationRelay.accept(currentLocation)

        super.init()
    }

    override func setBinders() {
        // Setup reactive bindings
        currentLocationRelay.asObservable()
            .subscribe(onNext: { [weak self] location in
                self?.updateDataStateWith { state in
                    state?.nextButtonIsEnable = location != nil
                    guard let location = location else { return }
                    state?.mapViewCameraPosition = location
                    state?.updateLocationInfo = location
                }
            })
            .disposed(by: disposeBag)
    }

    override func emitEvent(_ event: CICOLocationViewModelEvent) {
        switch event {
        case .viewDidLoad:
            handleViewDidLoad()
        case .submitButtonTapped:
            handleSubmit()
        case .reloadLocationTapped:
            handleReloadLocation()
        case .backButtonTapped:
            navigator?.back()
        case .openCameraForSelfie:
            emitAction(.openCamera)
        }
    }

    // MARK: - Private

    private func handleViewDidLoad() {
        updateDataState { state in
            state.appBarTitle = "Check In"
            state.submitButtonTitle = "Submit Attendance"
        }

        locationManager.startUpdatingLocation()
    }

    private func handleSubmit() {
        guard let location = currentLocationRelay.value else { return }

        emitAction(.showLoading)

        let payload = PostSubmitCICOUseCase.Params.Payload(
            employeeId: userViewModel.employeeId,
            scheduleId: scheduleData?.id.orZero(),
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            media: selfieImage,
            notes: notes
        )

        let params = PostSubmitCICOUseCase.Params(
            companyId: userViewModel.companyId,
            payload: payload
        )

        postSubmitCICOUseCase.execute(params: params) { [weak self] result in
            self?.emitAction(.hideLoading)

            switch result {
            case .success(let model):
                self?.emitAction(.navigateToSuccess)
            case .failure(let error):
                self?.emitAction(.showToast(message: error.message.orEmpty()))
            }
        }
    }

    private func handleReloadLocation() {
        locationManager.requestLocation()
    }
}
```

**ViewModel Pattern Summary:**
- Inject dependencies via constructor with defaults
- Use UseCases for all data operations
- State updates via `updateDataState` or `updateDataStateWith`
- Emit actions to communicate with ViewController
- Use `weak self` in closures
- Dispose subscriptions via `disposeBag`

---

### Complex Dependency Management

When ViewModels have 20+ dependencies, organize them systematically using MARK comments:

```swift
final class CICOLocationViewModel: BaseViewModelV2<CICOLocationViewModelState, CICOLocationViewModelEvent, CICOLocationViewModelAction> {

    // MARK: INJECTED
    private weak var navigator: (any CICOLocationNavigator)?

    // MARK: DEPENDENCIES
    private let getAttendanceLocationUseCase: any GetAttendanceLocationUseCaseProtocol
    private let getAttendancePolicyUseCase: any GetAttendancePolicyUseCaseProtocol
    // ... 15+ more use cases

    // MARK: UTILS
    private let mekariFlagCustomRepository: any MekariFlagCustomProtocol
    private let analytics: any TalentaAnalyticsProtocol

    // MARK: DATA
    private var activeSchedule: ScheduleModel?

    // MARK: STATE
    private let backEventSubject = PublishSubject<CICOLocationResult>()

    init(
        navigator: (any CICOLocationNavigator)? = nil,
        getAttendanceLocationUseCase: any GetAttendanceLocationUseCaseProtocol = GetAttendanceLocationUseCase.sharedInstance,
        // ... all other dependencies with defaults
        mekariFlagCustomRepository: any MekariFlagCustomProtocol = MekariFlagCustomRepository.shared,
        analytics: any TalentaAnalyticsProtocol = TalentaAnalytics.shared,
        mainScheduler: SchedulerType = MainScheduler.instance
    ) {
        // ... assign all dependencies
        super.init(mainScheduler: mainScheduler)
    }
}
```

**Key Principles:**
- **Group by category**: INJECTED (navigation), DEPENDENCIES (use cases), UTILS (shared tools), DATA (cached data), STATE (reactive streams)
- **Weak navigator**: Always use `weak` for navigator/coordinator references
- **Default singletons**: Every dependency has default parameter for testability
- **Protocol types**: Use `any ProtocolName` for all dependencies to enable mocking

### Navigator Protocol Pattern

ViewModels never perform navigation directly. Use Navigator protocol with weak reference:

```swift
// Define Navigator protocol
protocol CICOLocationNavigator: AnyObject {
    func back(result: CICOLocationResult)
    func showLocationFraudSheet() -> Observable<Void>
    func showPolicySheet() -> Observable<Void>
}

// In ViewModel
final class CICOLocationViewModel {
    private weak var navigator: (any CICOLocationNavigator)?

    init(navigator: (any CICOLocationNavigator)? = nil) {
        self.navigator = navigator
        super.init()
    }

    private func handleBackButton() {
        let result = CICOLocationResult(location: selectedLocation)
        navigator?.back(result: result)
    }

    private func handleShowPolicyTapped() -> Observable<Action> {
        return (navigator?.showPolicySheet()).orEmpty()
            .map { _ in Action.policySheetClosed }
    }
}
```

**Key Points:**
- Navigator is a protocol, not a concrete class
- Always use `weak var` to prevent retain cycles
- Navigation methods can return `Observable<T>` for bidirectional data flow
- Use `.orEmpty()` when calling optional navigator methods that return Observable

### Advanced RxSwift Patterns

#### Observable.zip for Parallel Requests

```swift
private func loadInitialData() -> Observable<Action> {
    return Observable.zip(
        getActiveScheduleUseCase.execute(param: nil),
        getLiveAttendanceSettingUseCase.execute(param: nil),
        getAttendancePolicyUseCase.execute(param: nil)
    )
    .map { [weak self] (schedules, liveSetting, policy) -> Action in
        guard let self = self else { return .empty }
        self.activeSchedule = schedules.first
        self.liveAttendanceSetting = liveSetting
        return .dataLoaded(schedule: schedules.first, policy: policy)
    }
    .catch { error in
        .just(.showError(error.toBaseError()))
    }
}
```

#### Background Processing with Scheduler

```swift
final class AttendanceScheduleViewModel {
    private let backgroundScheduler: SchedulerType = ConcurrentDispatchQueueScheduler(
        queue: DispatchQueue(label: "schedulescomponent.data.process", qos: .userInitiated)
    )
    private let mainScheduler: SchedulerType

    private func processSchedules(_ schedules: [ScheduleModel]) -> Observable<Action> {
        return Observable.just(schedules)
            .observe(on: backgroundScheduler)
            .compactMap { [weak self] schedules in
                guard let self = self else { return nil }
                return self.findDefaultShift(schedules: schedules)
            }
            .flatMap { $0 }
            .observe(on: mainScheduler)
            .map { index in Action.defaultShiftFound(index: index) }
    }
}
```

### UIModel Pattern with copyWith

ViewModels expose UIModels for the presentation layer, not domain entities:

```swift
struct ClockInConfirmationUIModel {
    let shiftName: String
    let shiftTime: String
    let isLiveTrackingEnabled: Bool
    let isLiveTrackingChecked: Bool
    let locationName: String

    func copyWith(
        shiftName: String? = nil,
        shiftTime: String? = nil,
        isLiveTrackingEnabled: Bool? = nil,
        isLiveTrackingChecked: Bool? = nil,
        locationName: String? = nil
    ) -> ClockInConfirmationUIModel {
        return ClockInConfirmationUIModel(
            shiftName: shiftName ?? self.shiftName,
            shiftTime: shiftTime ?? self.shiftTime,
            isLiveTrackingEnabled: isLiveTrackingEnabled ?? self.isLiveTrackingEnabled,
            isLiveTrackingChecked: isLiveTrackingChecked ?? self.isLiveTrackingChecked,
            locationName: locationName ?? self.locationName
        )
    }
}
```

### Advanced State Management

```swift
final class CICOBottomSheetViewModel {
    // Main State (BaseViewModelV2 pattern)
    struct State {
        var dataState: DataState<ClockInConfirmationUIModel> = .initial
    }

    // Specialized Relays
    private let locationFraudEvent = BehaviorRelay<Bool>(value: true)
    private let backEventSubject = PublishSubject<CICOLocationResult>()
    private let liveTrackingToggleRelay = BehaviorRelay<Bool>(value: false)

    var locationFraudDriver: Driver<Bool> {
        return locationFraudEvent.asDriver()
    }

    var backEventObservable: Observable<CICOLocationResult> {
        return backEventSubject.asObservable()
    }
}
```

**When to use what:**
- **State (DataState)**: Main UI state (loading, success, error)
- **BehaviorRelay**: Values that change over time, need current value
- **PublishSubject**: One-time events or commands (navigation, user actions)
- **Driver**: Safe UI binding (never errors, on main thread)

### Memory Management & deinit

Always implement `deinit` to clean up resources:

```swift
deinit {
    print("deinit:: \(String(describing: Self.self))")
    locationManager.stopUpdatingLocation()
    locationManager.delegate = nil
    backEventSubject.onCompleted()
    timerDisposable?.dispose()
}
```

**What to clean up:** location managers, publish/behavior subjects (`.onCompleted()`), timers, file handles.
Always log `deinit` to catch retain cycles.

### Feature Flags Integration

```swift
final class CICOLocationViewModel {
    private let mekariFlagCustomRepository: any MekariFlagCustomProtocol

    init(
        mekariFlagCustomRepository: any MekariFlagCustomProtocol = MekariFlagCustomRepository.shared
    ) {
        self.mekariFlagCustomRepository = mekariFlagCustomRepository
        super.init()
    }

    private func checkFeatureAvailability() -> Bool {
        return mekariFlagCustomRepository.getBoolValue(
            featureKey: "enable_live_tracking",
            defaultValue: false
        )
    }
}
```

**Best Practices:** Inject as protocol for testability. Always provide `defaultValue`. Check flags before expensive operations.

### Layer Invariants

- ViewModel never imports from the data layer — no DTOs, no `RepositoryImpl`, no `DataSource`
- Use cases injected via constructor — never `UseCase()` inside a ViewModel body
- State is read-only from ViewController's perspective — only `updateDataState` mutates it
- Actions are one-shot — emitted through `PublishSubject`, never stored in `stateRelay`
- Navigation belongs to a Navigator/Coordinator — ViewModel emits the intent, never pushes a ViewController itself

### Creation Order

```
Use Cases → ViewModel (StateHolder) → StateHolder contract → ViewController (developer-ui-worker)
```

Never write the ViewController before the StateHolder contract exists.
