---
platform: ios
project: ios-talenta
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

## Feature Flag Registration

iOS uses **MekariFlagCustomProvider** (`Utils/MekariFlag/MekariFlagCustomProvider.swift`) backed by the MekariFlag SDK (Flagsmith). Add a new case to `FeatureIdentity` — the case name is the flag key.

> ⚠️ `FeatureFlagKey` / `FeatureFlagCollection` in `Shared/Infrastructure/FeatureFlag/FeatureFlag.swift` is the V2 system — **not in use yet**. Do not add to it.

**Add to `FeatureIdentity` enum:**

```swift
// Utils/MekariFlag/MekariFlagCustomProvider.swift
enum FeatureIdentity: String {
    // ... existing cases
    case isEnable{Feature}  // ← add here — case name = Flagsmith flag key
}
```

**Read the flag value:**

```swift
// In ViewModel or DataSource — inject MekariFlagCustomProtocol
let isEnabled = flagProvider.getBoolValue(forFeature: FeatureIdentity.isEnable{Feature}.rawValue)
```

**Rules:**
- ✅ Case name must exactly match the flag key string configured in Flagsmith — confirm with backend
- ✅ Inject `MekariFlagCustomProtocol` — never access `MekariFlagCustomProvider` directly in business logic
- ❌ Never use raw string literals for flag keys — always reference `FeatureIdentity`

**When to add:** Any feature that requires remote gating or gradual rollout. Optional — skip for features that launch immediately to 100% of users.
