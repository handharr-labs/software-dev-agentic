---
platform: ios
project: ios-talenta
discipline: engineering
topic: app
pattern: deeplink_registration
---

## Theory

**Deeplink Registration** is the act of mapping incoming URLs and notification taps to screens or flows within the app.

**Invariants:**
- Mappings live at the app shell — never inside individual feature modules
- Deeplink route identifiers are the same identifiers used for in-app navigation — no parallel routing system
- URL parsing is separated from routing — the parser produces a route identifier, the router acts on it
- Each feature declares its own deeplink paths; the app shell assembles the complete registry
- Deeplinks arriving while the app is backgrounded or unauthenticated must be queued and replayed after auth completes

**When to add:** Any feature reachable from a push notification tap, an external URL, or a cross-app link.

---

## Deeplink Registration

All deeplink sources — push notification taps, URL schemes, universal links, and home screen quick actions — converge on a single `DeeplinkStreamImpl.shared` (`Talenta/DIComponents/DataStream/DeeplinkStream.swift`). Coordinators subscribe to the stream; they never parse URLs or payloads directly.

**Entry points:**

| Source | Handler | Writes to stream via |
|---|---|---|
| Push notification tap | `FCMManager.handlePushNotification(userInfo:)` | `DeeplinkStreamImpl.shared.set(deeplink:)` |
| URL scheme (`talenta://`) | `DeeplinkManager.handle(url:)` | `dispatch(url:)` → stream |
| Universal link (`https://`) | `DeeplinkManager.handle(userActivity:)` | `dispatch(url:)` → stream |
| Home screen quick action | `DeeplinkManager.handle(shortcutItem:)` | `stream.set(deeplink:)` directly |

All entry points are wired in `AppDelegate` — no coordinator touches them directly.

**Step 1 — Register the path in `DeeplinkPath`:**

```swift
// Talenta/DIComponents/DataStream/DeeplinkStream.swift
enum DeeplinkPath: String {
    // ... existing cases
    case {feature} = "{feature-url-path}"  // ← raw value = URL path, confirm with backend
}
```

**Step 2 — Add a routing method to `DeeplinkComponent`:**

```swift
// Talenta/DIComponents/Deeplink/DeeplinkComponent.swift
extension DeeplinkComponent {
    func coordinate{Feature}() -> Observable<Void> {
        let component = {Feature}Component(parent: self)
        let coordinator = {Feature}Coordinator(
            navigationController: rootNavigationController,
            component: component
        )
        return coordinate(to: coordinator).map { _ in }
    }
}
```

**Step 3 — Subscribe in the consuming coordinator or ViewController:**

```swift
deeplinkStream?.deeplinkData
    .subscribe(onNext: { [weak self] data in
        guard let data = data else { return }
        switch data.link {
        case .{feature}:
            self?.coordinate{Feature}()
        default: break
        }
    })
    .disposed(by: disposeBag)
```

**Rules:**
- ✅ `DeeplinkPath` raw value is the URL path string — confirm with backend/web team
- ✅ After handling, call `deeplinkStream?.set(deeplink: nil)` to clear the stream
- ❌ Never parse URLs or push payloads directly in coordinators or ViewModels — `DeeplinkData` handles all parsing
- ❌ Never add a second deeplink dispatch path — all sources must write to `DeeplinkStreamImpl.shared`

**When to add:** Any feature reachable from a push notification tap, universal link, URL scheme, or home screen quick action.

## Hybrid Embedding

> iOS-specific patterns using BrickWrap + FlutterModuleManager.

### Key Files

| File | Role |
|------|------|
| `Talenta/BrickWrap/Bricks.swift` | Singleton entry point — engine init, module factory |
| `Talenta/BrickWrap/System/Utils/BricksEngineManager.swift` | FlutterEngineGroup lifecycle, channel creation, engine cache |
| `Talenta/BrickWrap/System/Navigator/BricksNavigator.swift` | Launches guest as full-screen `BricksViewController` |
| `Talenta/BrickWrap/System/Executor/BricksExecutor.swift` | Headless execution — invokes guest and awaits typed callback |
| `Talenta/BrickWrap/System/ViewController/BricksViewController.swift` | `FlutterViewController` subclass — hosts the guest UI, wires `BricksChannelDelegate` |
| `Talenta/BrickWrap/System/Navigator/BricksChannelDelegate.swift` | Handles inbound MethodChannel calls from guest (`sendResponse`, `sendActionRequest`, `is24HourFormat`) |
| `Talenta/BrickWrap/System/Configs/BrickChannelConfig.swift` | Channel name and method name constants |
| `Talenta/Utils/FlutterModuleManager/Factory/ModuleFactory.swift` | HostParams Assembler — builds the `HostParams` JSON blob per module type |
| `Talenta/Utils/FlutterModuleManager/<Name>/<Name>Manager.swift` | Feature-scoped entry point — builds `LaunchParams` and calls `openModule()` |

### Host → Guest: Navigation Launch

```swift
// 1. Obtain the module
let module = Bricks.shared.getModule(module: PayslipModule.self)!

// 2. Assemble HostParams via ModuleFactory (HostParams Assembler)
let factory = ModuleFactory<PayslipParams>(moduleParams: PayslipParams(...))
let hostParamsString = factory.generateStringHostParams()

// 3. Build LaunchParams with a brick:// URI
let launchParam = LaunchParams(
    brickAddress: BricksAddress(
        host: PayslipConfig.host,
        path: PayslipConfig.route,
        param: hostParamsString,   // becomes ?hostParam=<json> in the URI
        engine: PayslipConfig.engineId
    ),
    presentingViewController: self
)

// 4. Launch — engine is created/reused; URI sent to guest via MethodChannel "open"
module.openModule(launchParam: launchParam, completion: { result in ... })
```

### MethodChannel Constants

```swift
// BrickChannelConfig.swift
static let methodChannel          = "com.mekari.module"     // channel name
static let sendMethodOpen         = "open"                  // host → guest: navigate
static let sendMethodExecute      = "execute"               // host → guest: headless
static let receiveResponseMethod  = "sendResponse"          // guest → host: result
static let receiveActionMethod    = "sendActionRequest"     // guest → host: native action
static let is24HourFormat         = "is24HourFormat"        // guest → host: query (sync)
```
