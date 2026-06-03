---
platform: android
project: android-talenta
discipline: engineering
topic: navigation
pattern: route_constants
---

## Theory

**Route Constants** are named, centralized identifiers for every navigation destination in the app.

**Invariants:**
- All destination identifiers defined in a single constants file per feature or app — never hard-coded at the call site
- String paths (web/Flutter) or typed class references (Android/iOS) — platform dictates the form, the principle is the same
- Parameterised routes expose a typed helper function/method — callers never construct path strings inline
- Route constants exported from the feature or navigation module — consumers import the constant, not a string literal

**When to create:** Before any screen that navigates to a destination. Constants file created once per feature; entries added as destinations are added.

---

## Definition

Android does not use string route constants. Activity class references serve as the routing mechanism. If deep links are added, register URI patterns here.

## Code Pattern

```kotlin
// Android routing via Activity companion object factory — no string route constants needed
companion object {
    private const val EXTRA_FEATURE_ID = "extra_feature_id"

    fun newIntent(context: Context, featureId: String) =
        Intent(context, TimeOffRequestActivity::class.java).apply {
            putExtra(EXTRA_FEATURE_ID, featureId)
        }
}
```
