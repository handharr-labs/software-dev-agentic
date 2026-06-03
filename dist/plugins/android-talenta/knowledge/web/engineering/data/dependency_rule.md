---
platform: web
project: web
discipline: engineering
topic: data
pattern: dependency_rule
---

## Theory

Data depends on Domain only. It never imports from Presentation or UI.

```
Domain  ←  Data
```

Allowed imports: domain entities, repository interfaces, language primitives.
Forbidden: any presentation type, UI framework, StateHolder, or view import.

---

## Dependency Rule

Data depends on Domain only. It never imports from Presentation or UI.

**Allowed:** `axios`, `axios-retry`, domain entities and repository interfaces, `localStorage`/`sessionStorage` utilities, any data-layer utility.

**Forbidden:**
- `import React` / `import { useXxx } from 'react'` — React hooks and components must not appear in data files
- Next.js server/client imports (`next/navigation`, `next/headers`) — data layer must be framework-agnostic
- Any presentation-layer type — `Page`, `Component`, `Hook`, or `Store` types must not be referenced here

## Layer Invariants

- Import from domain layer only — never from React components, Next.js pages, hooks, or store files
- `NetworkError` thrown by the HTTP client is caught in the repository `try/catch` and re-thrown as a `DomainError` — raw Axios errors never reach domain or presentation
- DTO interfaces never cross into the domain layer — `mapper.toDomain(dto)` is the boundary
- Repository implementations reference the domain repository interface as their class type — the concrete class is never imported outside the data layer
- `axios` and `localStorage` live only in DataSource implementations and HTTP client utilities — never in repository or domain files
