---
platform: android
project: android-talenta
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

## Definition

Android deeplinks enter through `RedirectionActivity` (`app/src/main/java/co/talenta/modul/redirection/RedirectionActivity.kt`) — a `singleTask` exported activity declared in `AndroidManifest.xml`.

Rules:
- ✅ All deeplink entry points flow through `RedirectionActivity` — never add `VIEW` intent filters to feature Activities
- ✅ URL patterns live in `UrlHelper` — never hardcode URL strings inside `RedirectionActivity`
- ✅ Routing delegates to the feature's Navigation interface — `RedirectionActivity` never starts Activities directly
- ❌ Never parse deeplink URLs in ViewModels or Fragments

## Code Pattern

```kotlin
// Step 1 — Add URL pattern to UrlHelper
fun Uri.is{Feature}(): Boolean = toString().contains("{feature-url-segment}")

// Step 2 — Add routing in RedirectionActivity.checkTalentaDeepLink()
uri.is{Feature}() -> redirect{Feature}(uri)

// Step 3 — Implement redirect method
private fun redirect{Feature}(uri: Uri) {
    val id = uri.getQueryParameter("id").orEmpty()
    {feature}Navigation.navigateTo{Feature}(this, id)
}

// Step 4 — Register Intent filter for App Links (if universally linked)
// app/src/main/AndroidManifest.xml — inside RedirectionActivity intent-filter
// <data android:pathPrefix="@string/universal_link_{feature}_index" />
```
