---
name: domain-create-entity
description: |
  Create a Domain Entity struct for a new feature.
user-invocable: false
---

Create a Domain Entity struct following `.claude/reference/domain.md §3.1` and project conventions in `.claude/reference/project.md §13`.

## Steps

1. **Grep** `.claude/reference/domain.md` for `§3.1`; only **Read** the full file if the section cannot be located
2. **Locate** the correct module path: `Talenta/Module/[Module]/Domain/Entities/`
3. **Create** the entity file named `[Feature]Model.swift`

## Entity Pattern

```swift
struct FeatureModel {
    let id: Int
    let name: String
    // all properties non-optional unless truly optional in domain
}
```

Rules:
- Use `let` for all properties (immutable domain objects)
- No `import Foundation` unless date types required
- No `Codable` — entities are not serialized (responses are)
- Match field names to domain terminology, not API field names
- Add `= defaultValue` only when the domain genuinely has a default

## Output

Confirm the file path created and list all properties.
