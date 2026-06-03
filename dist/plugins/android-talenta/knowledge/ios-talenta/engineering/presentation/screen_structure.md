---
platform: ios
project: ios-talenta
discipline: engineering
topic: presentation
pattern: screen_structure
---

## Theory

A **Screen** is a full-page view bound to a single StateHolder. It observes state and sends events — it contains no business logic.

**Invariants:**
- Bound to exactly one StateHolder — instantiated via DI, never with direct `new` / `init`
- Observes every State field declared in the StateHolder contract — no State field goes unhandled
- Sends events to the StateHolder for every user interaction — never mutates state directly
- Contains no business logic — conditionals exist only to decide what to render, not what to compute
- No use case calls — all data flows through the StateHolder

**When to create:** One screen per route/destination. Created after the StateHolder contract exists.

---

## Screen Structure

```swift
// Presentation/View/CICOLocation/CICOLocationViewController.swift
class CICOLocationViewController: TalentaBaseViewController {

    // MARK: - UI
    private let mapView: GMSMapView = {
        let mapView = GMSMapView()
        return mapView
    }()

    private let submitButton: MPButton = {
        let button = MPButton()
        button.setTitle("Submit", for: .normal)
        return button
    }()

    // MARK: - ViewModel
    private let viewModel: CICOLocationViewModel

    // MARK: - Init
    init(viewModel: CICOLocationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.emitEvent(.viewDidLoad)
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(mapView)
        view.addSubview(submitButton)

        // Layout constraints...
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
    }

    private func bindViewModel() {
        // Bind state changes
        viewModel.stateDriver
            .drive(onNext: { [weak self] state in
                self?.render(state: state)
            })
            .disposed(by: disposeBag)

        // Bind actions
        viewModel.actionDriver
            .drive(onNext: { [weak self] action in
                self?.handle(action: action)
            })
            .disposed(by: disposeBag)

        // Bind common actions
        viewModel.commonActionDriver
            .drive(onNext: { [weak self] action in
                self?.handleCommonAction(action: action)
            })
            .disposed(by: disposeBag)
    }

    private func render(state: CICOLocationViewModelState) {
        title = state.appBarTitle
        submitButton.setTitle(state.submitButtonTitle, for: .normal)
        submitButton.isEnabled = state.nextButtonIsEnable

        if let cameraPosition = state.mapViewCameraPosition {
            let camera = GMSCameraPosition.camera(
                withLatitude: cameraPosition.coordinate.latitude,
                longitude: cameraPosition.coordinate.longitude,
                zoom: 15
            )
            mapView.camera = camera
        }
    }

    private func handle(action: CICOLocationViewModelAction) {
        switch action {
        case .showToast(let message):
            showToast(message: message)
        case .showLoading:
            showLoading()
        case .hideLoading:
            hideLoading()
        case .openCamera:
            openCamera()
        case .navigateToSuccess:
            break // Coordinator handles
        case .navigationItemRightBarButtonItemRemoveAnimation:
            break
        }
    }

    private func handleCommonAction(_ action: CommonViewModelAction) {
        switch action {
        case .showToast(let message):
            showToast(message: message)
        case .showLoading:
            showLoading()
        case .hideLoading:
            hideLoading()
        }
    }

    // MARK: - Actions
    @objc private func submitButtonTapped() {
        viewModel.emitEvent(.submitButtonTapped)
    }
}
```

**ViewController Pattern:**
- Inject ViewModel via constructor
- Call `viewModel.emitEvent(.viewDidLoad)` in `viewDidLoad()`
- Bind `stateDriver` → render UI
- Bind `actionDriver` → handle actions
- UI events call `viewModel.emitEvent(...)`
- Pure UI logic stays in ViewController
- Business logic stays in ViewModel
