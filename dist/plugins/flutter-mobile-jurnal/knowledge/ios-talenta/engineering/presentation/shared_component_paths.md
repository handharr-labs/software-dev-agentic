---
platform: ios
project: ios-talenta
discipline: engineering
topic: presentation
pattern: shared_component_paths
---

## Shared Component Paths

When running a Component Reuse Check, search these locations for existing reusable views:

| Scope | Path | File pattern |
|---|---|---|
| Shared across all modules | `Talenta/Shared/Presentation/View/` | `*View.swift` |
| Shared shimmer/loading views | `Talenta/Shared/Presentation/ShimmerView/` | `*View.swift` |
| Shared table view components | `Talenta/Shared/Presentation/CustomTableView/` | `*View.swift` |
| Module-local views (cross-feature reuse candidate) | `Talenta/Module/*/Presentation/View/` | `*View.swift` |

**Search strategy:** Grep for the component concept (e.g. `"Card"`, `"Avatar"`, `"EmptyState"`, `"ListItem"`) across these paths before creating a new view. A `UIView` or `UIViewController` subclass found here is a reuse candidate.
