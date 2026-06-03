---
platform: android
project: android-talenta
discipline: engineering
topic: app
pattern: route_registration
---

## Theory

**Route Registration** is the act of declaring how the app navigates to a feature's screen — mapping a route identifier (string key, enum case, or coordinator type) to a screen factory.

**Invariants:**
- Routes live at the app shell or navigation coordinator — never inside a CLEAN layer
- Each feature owns one route declaration unit (route file, coordinator class, or destination enum)
- Route identifiers are stable string keys or typed values — not view instances
- Deep link destinations must be registered in the same place as regular routes

**When to add:** Any time a new screen is introduced. An unregistered route is a silent navigation failure.

---

## Definition

Android uses **interface-based navigation** — the navigation interface lives in `base/`, the implementation lives in `app/navigator/`, and it is bound in a `NavigationModule`.

Rules:
- ✅ Navigation interface in `base/` — never import Activity classes into feature modules
- ✅ One interface per feature, injected into ViewModels that need to navigate
- ❌ No `startActivity` calls inside feature module ViewModels — delegate to the navigator

## Code Pattern

```kotlin
// base/navigation/{Feature}Navigation.kt

interface {Feature}Navigation {
    fun navigateTo{Feature}(context: Context)
    fun navigateTo{Feature}Detail(context: Context, id: String)
}

// app/navigator/{Feature}NavigationImpl.kt

class {Feature}NavigationImpl @Inject constructor() : {Feature}Navigation {

    override fun navigateTo{Feature}(context: Context) {
        context.startActivity(Intent(context, {Feature}Activity::class.java))
    }

    override fun navigateTo{Feature}Detail(context: Context, id: String) {
        context.startActivity(
            Intent(context, {Feature}DetailActivity::class.java).apply {
                putExtra({Feature}DetailActivity.EXTRA_ID, id)
            }
        )
    }
}

// app/di/NavigationModule.kt
@Module
abstract class NavigationModule {
    // ... existing bindings
    @Binds abstract fun bind{Feature}Navigation(impl: {Feature}NavigationImpl): {Feature}Navigation  // ← add here
}
```
