---
name: builder-pres-create-component
description: Create a reusable RecyclerView Adapter + ViewHolder for Android Talenta, using ViewBinding and DiffUtil.
user-invocable: false
---

Create a RecyclerView Adapter following `.claude/reference/code-architecture/presentation-impl.md ## Adapter section`.

## Steps

1. **Identify** the entity type the adapter displays
2. **Locate** path: `feature_[module]/src/main/java/co/talenta/feature_[module]/presentation/[feature]/adapter/`
3. **Create** `[Feature]Adapter.kt`
4. **Create** the corresponding item layout `res/layout/item_[feature].xml` if it does not exist

## Adapter Pattern

```kotlin
class [Feature]Adapter(
    private val onItemClick: ([Feature]Entity) -> Unit
) : ListAdapter<[Feature]Entity, [Feature]Adapter.[Feature]ViewHolder>(DiffCallback()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): [Feature]ViewHolder {
        val binding = Item[Feature]Binding.inflate(
            LayoutInflater.from(parent.context), parent, false
        )
        return [Feature]ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: [Feature]ViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class [Feature]ViewHolder(
        private val binding: Item[Feature]Binding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(item: [Feature]Entity) {
            binding.tvName.text = item.name
            binding.root.setOnClickListener { onItemClick(item) }
        }
    }

    private class DiffCallback : DiffUtil.ItemCallback<[Feature]Entity>() {
        override fun areItemsTheSame(old: [Feature]Entity, new: [Feature]Entity) = old.id == new.id
        override fun areContentsTheSame(old: [Feature]Entity, new: [Feature]Entity) = old == new
    }
}
```

## Rules

- Extend `ListAdapter` with `DiffUtil.ItemCallback` — never `RecyclerView.Adapter` directly
- Use ViewBinding — never `findViewById`
- Click callbacks injected via constructor — Adapter never accesses Presenter directly
- Entity is a plain domain entity — no UI model conversion inside Adapter

## Output

Confirm file path and list all bound fields and click callbacks.
