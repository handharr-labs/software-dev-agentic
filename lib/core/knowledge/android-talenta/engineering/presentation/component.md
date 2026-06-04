---
platform: android
project: android-talenta
discipline: engineering
topic: presentation
pattern: component
---

## Theory

A **Component** (also called Sub-view, Widget, or View) is a reusable UI element smaller than a full screen.

**Invariants:**
- Stateless by default — receives data via props/parameters and emits callbacks
- If stateful, bound to a scoped StateHolder — never manages business state inline
- No use case calls — all data passed in from the parent screen or a scoped StateHolder
- Reuse check required before creating — search shared component directories first

**When to create:** When a UI element appears in ≥2 screens, or when a screen section is complex enough to isolate for readability.

---

## Definition

Reusable item view for RecyclerView — ViewHolder pattern, no Presenter awareness. Receives a plain data class via `bind(model)`.

Path: `presentation/common/[Feature]ItemView.kt` or as a ViewHolder inside `[Feature]Adapter.kt`

Rules:
- `UIModel` is a plain data class — display values only, no business logic
- No Presenter or UseCase references inside ViewHolder
- Use ViewBinding — no `findViewById`

## Code Pattern

```kotlin
class [Feature]ViewHolder(
    private val binding: Item[Feature]Binding
) : RecyclerView.ViewHolder(binding.root) {

    data class UIModel(
        val title: String,
        val subtitle: String
    )

    fun bind(model: UIModel) {
        binding.titleText.text = model.title
        binding.subtitleText.text = model.subtitle
    }
}
```
