---
platform: android
project: android-talenta
discipline: engineering
topic: app
pattern: hybrid_embedding
---

## Theory

**Hybrid Embedding** is the architecture where a native host app (iOS or Android) embeds a Flutter module as a full-screen view or headless executor, communicating over MethodChannel via the Bridge library (`BrickWrap` / `brick_way`).

**When it applies:** iOS and Android hosts only. Not applicable to web or to Flutter apps that are the host.

**Invariants:**
- Module launch always goes through the Bridge (`BrickWrap` / `brick_way`) — never via raw `FlutterEngine` or `MethodChannel` directly
- Module registration, engine slot config, and HostParams assembly live in the host app shell — not inside individual feature screens
- Each module has exactly one engine slot ID — reusing an existing slot causes lifecycle conflicts
- The `brick://` URI scheme and engine slot ID must be agreed between host and guest teams before implementation begins

---

## Definition

Android-specific patterns using bricks-talenta + BrickHelper.

### Key Files

| File | Role |
|------|------|
| `bricks-talenta/.../Bricks.kt` | Singleton entry point — engine init (`FlutterEngineGroup`), module factory, `preWarmEngine()` |
| `bricks-talenta/.../system/utils/BricksEngineManager.kt` | Engine lifecycle, MethodChannel wiring, `buildEngine()`, `listen()`, `invokeMethod()` |
| `bricks-talenta/.../system/models/BrickModule.kt` | Abstract base — declares `engine`, `host`, `open()`, `execute()`, `createExecutorEngineId()` |
| `bricks-talenta/.../system/activity/BrickActivity.kt` | `FlutterActivity` subclass — hosts the guest UI, wires `BrickChannelDelegate` in `configureFlutterEngine()` |
| `bricks-talenta/.../system/navigator/BrickChannelDelegate.kt` | Handles inbound MethodChannel calls from guest (`sendResponse`, `sendActionRequest`, `is24HourFormat`) |
| `bricks-talenta/.../system/navigator/BrickNavigator.kt` | Builds the `Intent` for `BrickActivity` and starts it |
| `bricks-talenta/.../system/executor/BrickExecutor.kt` | Headless execution — invokes guest and awaits typed `ExecutorCallback<T>` |
| `bricks-talenta/.../system/configs/BrickChannelConfig.kt` | Channel name and all method name / key constants |
| `app/.../helper/brickhelper/BrickHelper.kt` | HostParams Assembler — builds `hostParam` JSON, handles standard action callbacks |
| `bricks-talenta/.../module/talenta/TalentaModule.kt` | Concrete module — wraps all feature routes as typed `openXxx()` / `executeXxx()` methods |

## Code Pattern

```kotlin
// Host → Guest: Navigation Launch
val module = Bricks.getModule<TalentaModule>(context)

val hostParamJson = BrickHelper.getDefaultJsonObject(
    sessionPreference, remoteConfigFlagProvider
).apply {
    put("moduleJson", JSONObject().apply { /* module-specific params */ }.toString())
}.toString()

val params = MainParams(hostParam = hostParamJson)

module.openPayslipIndex(
    context = context,
    params = params,
    launcher = activityResultLauncher,
    actionListener = brickActionListener
)

// Host → Guest: Headless Execution
module.executeTmClearDatabase(
    context = context,
    params = params,
    callBack = object : ExecutorCallback<TmClearDatabaseResponse> {
        override fun onLoading() { ... }
        override fun onSuccess(response: TmClearDatabaseResponse?) { ... }
        override fun onError(code: Int, message: String) { ... }
    }
)

// MethodChannel Constants (BrickChannelConfig.kt)
const val METHOD_CHANNEL           = "com.mekari.module"
const val SEND_METHOD_OPEN         = "open"
const val SEND_METHOD_EXECUTE      = "execute"
const val RECEIVE_RESPONSE_METHOD  = "sendResponse"
const val RECEIVE_ACTION_METHOD    = "sendActionRequest"
const val IS_24_HOUR_FORMAT_METHOD = "is24HourFormat"
```
