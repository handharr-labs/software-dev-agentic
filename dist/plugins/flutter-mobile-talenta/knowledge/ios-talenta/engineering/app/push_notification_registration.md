---
platform: ios
project: ios-talenta
discipline: engineering
topic: app
pattern: push_notification_registration
---

## Theory

**Push Notification Registration** is the act of wiring the app to receive push notifications — fetching the device token, delivering it to the server, and removing it on logout.

**Invariants:**
- Registration is owned by the infrastructure layer — never by an individual feature
- The notification manager is wired once at the app shell, not inside feature modules
- Payload routing (which screen or flow a notification opens) is declared separately from payload receipt (receiving and decoding the notification)
- Notification display concerns — channels, builders, and visual configuration — are isolated from the message handler
- Silent push notifications must route through domain use cases — they must not trigger UI state directly

**When to add:** Once per app. The token lifecycle is tied to the auth flow — token registration occurs on login and token deletion occurs on logout.

---

## Push Notification Registration

Push notifications and deeplinks share the same delivery path — both ultimately write to `DeeplinkStreamImpl.shared` (`Talenta/DIComponents/DataStream/DeeplinkStream.swift`). No per-feature notification registration is needed; the infrastructure is wired once in `AppDelegate`.

**Token lifecycle:**
- `AppDelegate.messaging(_:didReceiveRegistrationToken:)` receives new FCM tokens → calls `FCMManager.setToken(value:)` (stores locally) and `FCMManager.postToken()` (posts to server via `PostSendFCMTokenUseCase`)
- On logout: call `FCMManager.deletePostToken()` — deletes from server (`DeleteFCMTokenUseCase`), clears local storage, and removes from the Messaging SDK
- Token lifecycle is **not** automatic on login/logout — the auth flow must explicitly call `postToken()` on login and `deletePostToken()` on logout

**Notification tap → deeplink routing:**

`AppDelegate.userNotificationCenter(_:didReceive:withCompletionHandler:)` receives the tap → delegates to `FCMManager.handlePushNotification(userInfo:)` which parses the payload by `navigation_type`:

| `navigation_type` | Payload field | Action |
|---|---|---|
| `deeplinking` | `deeplink_ios` (URL string) | `DeeplinkData(url:)` → `DeeplinkStreamImpl.shared.set(deeplink:)` |
| `screenName` | `screen_name_ios` (path string) | `DeeplinkData(url:nil, payload:)` → `DeeplinkStreamImpl.shared.set(deeplink:)` |
| `uri` | `uri` | `UIApplication.openScreenBasedOnURL()` — bypasses DeeplinkStream |
| *(legacy)* | `type` (DeeplinkPath rawValue) | `DeeplinkStreamImpl.shared.set(deeplink:)` |

**When a new notification type must route to a new screen:** add a `DeeplinkPath` case and ensure the push payload includes `screen_name_ios` with that case's rawValue. `DeeplinkData` parses it automatically. No new files needed.
