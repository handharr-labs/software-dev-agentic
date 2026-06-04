---
platform: android
project: android-talenta
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

## Definition

Android centralizes FCM handling in `TalentaNotificationManagerImpl` (`app/src/main/java/co/talenta/service/fcm/TalentaNotificationManagerImpl.kt`). The FCM service in `AndroidManifest.xml` delegates to this class — no per-feature setup is needed.

**Token lifecycle:**
- `PostFcmTokenUseCase` — sends token to server (called in `HomeFragment.sendFcmTokenToServerIfNeeded()` after login)
- `DeleteFcmTokenUseCase` — deletes token from server on logout (called in `LogoutPresenter`, `ForgotPinLogoutPresenter`, `SessionExpiredActivity`)
- Last pushed token is stored in `SessionPreference.setLastPushedFcmToken(token)`

Rules:
- ✅ Per-feature notification types add a `NotificationNavigationType` variant and a handler in `TalentaNotificationManagerImpl`
- ✅ New notification screen destinations register a deeplink path and rely on `RedirectionActivity` for routing
- ❌ Never handle FCM messages or display notifications inside feature modules

## Code Pattern

```kotlin
// TalentaNotificationManagerImpl.onMessageReceived() — centralised handler
// remoteMessage.data["talenta_android_notification"] → JSON → TalentaNotificationPayload
// NotificationNavigationType enum: DEEPLINK, SCREEN_NAME, SILENT_PUSH_NOTIFICATION, URI
// Display: TalentaNotificationBuilderImpl (separate from message handler)
```
