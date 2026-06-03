---
platform: web
project: web
discipline: engineering
topic: data
pattern: dto
---

## Theory

A **DTO (Data Transfer Object)** mirrors the raw API or database shape exactly.

**Invariants:**
- No domain logic — plain data container only
- No computed fields — no derived values, no formatting
- No domain entity types — DTOs use primitive types and nested DTOs
- Serialization annotations live here, not on domain entities (`@JsonKey`, `Codable`, `fromJson`)
- Field names match the API/DB schema — not the business domain vocabulary

**When to create:** One DTO per API response type or DB table row. Created before the mapper that consumes it.

---

## DTOs

Network response models. Separate from domain entities.

```typescript
// data/dtos/DepartmentDTO.ts
export interface DepartmentDTO {
  id: string;
  name: string;
  head_count?: number;
}

// data/dtos/EmployeeDTO.ts
export interface EmployeeDTO {
  id: string;
  full_name: string;
  email_address: string;
  department: DepartmentDTO;  // nested DTO — mapped by DepartmentMapper
  joined_at: string;          // ISO 8601 string
}

// data/dtos/PaginatedDTO.ts
export interface PaginatedDTO<T> {
  items: T[];
  total_count: number;
  current_page: number;
  total_pages: number;
}

// data/dtos/APIResponse.ts
export interface APIResponse<T> {
  data: T;
  message?: string;
  success: boolean;
}
```

**Rules:**
- DTOs use snake_case to match API JSON keys (convert to camelCase in mappers)
- DTOs are plain interfaces — no methods, no classes
- DTOs never escape the Data layer
- Nested API objects get their own DTO + Mapper pair
