---
platform: android
project: android-talenta
discipline: engineering
topic: app
pattern: feature_flag_registration
---

## Theory

**Feature Flag Registration** is the act of declaring a new feature-gating key in the app's centralized flag registry, enabling remote enable/disable without a new app release.

**Invariants:**
- Flag keys live in a centralized registry (enum, struct, or constants file) — never as inline string literals at call sites
- One key per feature toggle — never reuse an existing flag for a different purpose
- Default values are explicit — the flag's behavior when unset must be defined in the registry

**When to add:** Any feature that requires remote gating, gradual rollout, or a kill switch. Optional — skip for features that launch immediately to 100% of users.

---

## Definition

Android has three flag types — pick the right enum based on the flag's backend:

| Type | Enum | Backend |
|---|---|---|
| Local only | `LocalFeatureFlag` | No backend — compile-time default |
| Firebase Remote Config | `RemoteConfigFeatureFlag` | `firebaseRemoteConfigKey` string |
| MekariFlag (Flagsmith) | `FlagsmithFeatureFlag` | `featureId` string |

All three implement the `Feature` interface (`domain/featureflag/Feature.kt`). Checked via `FeatureFlagManager.isFeatureEnabled(featureFlag)`.

Rules:
- ✅ Always provide `description` and `link` — required for traceability
- ✅ `firebaseRemoteConfigKey` must match a constant in `RemoteConfigKey` — confirm with backend
- ✅ `featureId` must exactly match the Flagsmith feature key — confirm with backend
- ✅ `defaultFlag = false` unless the feature should be on by default when the flag is unreachable
- ❌ Never use raw string literals for flag keys at call sites — always reference the enum

## Code Pattern

```kotlin
// RemoteConfigFeatureFlag example
ENABLE_{FEATURE}(
    description = "Short description of what this gates",
    deprecated = arrayOf(),
    link = arrayOf("https://jurnal.atlassian.net/browse/{TICKET}"),
    defaultFlag = false,
    firebaseRemoteConfigKey = RemoteConfigKey.ENABLE_{FEATURE},
),

// FlagsmithFeatureFlag example
ENABLE_{FEATURE}(
    description = "Short description of what this gates",
    deprecated = arrayOf(),
    link = arrayOf("https://jurnal.atlassian.net/browse/{TICKET}"),
    defaultFlag = false,
    featureId = "enable_{feature}",
),
```
