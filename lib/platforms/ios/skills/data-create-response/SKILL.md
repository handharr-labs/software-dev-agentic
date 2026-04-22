---
name: data-create-response
description: |
  Create a Codable Response DTO from API JSON for a new feature.
user-invocable: false
---

Create a Response DTO following `.claude/reference/contract/builder/data.md ## Response Models (DTOs) section` and naming conventions in `.claude/reference/project.md ## Conventions & Naming section`.

## Steps

1. **Grep** `.claude/reference/contract/builder/data.md` for `## DTOs`; only **Read** the full file if the section cannot be located
2. **Locate** module path: `Talenta/Module/[Module]/Data/Models/`
3. **Create** `[Feature]Response.swift`

## Response Pattern

```swift
struct [Feature]Response: Codable {
    let id: Int?
    let name: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdAt = "created_at"
    }
}
```

Rules:
- All properties `optional` (API may omit any field)
- Include `CodingKeys` **only** for snake_case → camelCase mappings; omit if all names match
- Conform to `Codable` (not just `Decodable`) for test flexibility
- No business logic — pure data container
- Nested objects use nested Response structs (e.g., `[Feature]ItemResponse`)

## Output

Confirm file path and list all properties with their CodingKeys mappings.
