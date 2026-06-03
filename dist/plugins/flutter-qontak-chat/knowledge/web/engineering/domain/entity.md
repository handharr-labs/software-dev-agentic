---
platform: web
project: web
discipline: engineering
topic: domain
pattern: entity
---

## Theory

An **Entity** is a pure data structure representing a business concept.

**Invariants:**
- No framework imports — value types or pure classes only
- No business logic — entities hold data; use cases execute logic
- No serialization annotations — no `@JsonKey`, no `Codable`, no `fromJson`
- Immutable — all properties are read-only; mutation produces a new instance (`copyWith`)
- Represent domain concepts, not API shapes — field names match the business domain, not the JSON payload

**When to create:** When the domain needs a named, typed concept with identified fields (e.g. `Employee`, `LeaveRequest`, `AttendanceRecord`).

---

## Entities

```typescript
// domain/entities/Employee.ts
export interface Employee {
  readonly id: string;
  readonly name: string;
  readonly email: string;
  readonly department: Department;
  readonly joinDate: Date;
}

// domain/entities/Department.ts
export interface Department {
  readonly id: string;
  readonly name: string;
  readonly headCount: number;
}

// domain/entities/PaginatedResult.ts
export interface PaginatedResult<T> {
  readonly items: T[];
  readonly totalCount: number;
  readonly currentPage: number;
  readonly totalPages: number;
}
```

**Rules:**
- No framework imports (`react`, `next`, etc.)
- Readonly properties — entities are immutable value objects
- Plain TypeScript interfaces — no class inheritance, no decorators
- Represent business concepts, not API shapes
