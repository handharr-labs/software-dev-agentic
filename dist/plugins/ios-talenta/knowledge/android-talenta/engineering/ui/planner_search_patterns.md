---
platform: android
project: android-talenta
discipline: engineering
topic: ui
pattern: planner_search_patterns
---

## Theory

When exploring the UI layer, use these glob patterns to find relevant files.

---

## Definition

When exploring the UI layer, glob for:
- `**/presentation/**/*Activity.kt` — screen Activity files
- `**/presentation/**/*Fragment.kt` — screen Fragment files
- `**/presentation/common/views/**/*.kt` — shared component files
- `**/navigation/**/*NavigationImpl.kt` — navigator implementation files

## Code Pattern

```bash
# Find all screen Activities
find . -name "*Activity.kt" -path "*/presentation/*"

# Find all screen Fragments
find . -name "*Fragment.kt" -path "*/presentation/*"

# Find shared UI components
find . -path "*/presentation/common/views/*" -name "*.kt"

# Find navigation implementations
find . -name "*NavigationImpl.kt" -path "*/navigation/*"
```
