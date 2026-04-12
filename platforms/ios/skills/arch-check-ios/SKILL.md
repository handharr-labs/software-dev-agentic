---
name: arch-check-ios
description: Check iOS-specific Clean Architecture rules for a Swift/UIKit project — layer import direction, module structure, legacy folder usage, and naming conventions. Called by arch-review-worker.
user-invocable: false
tools: Read, Glob, Grep
---

Check the provided files against iOS-specific architecture rules. Report violations with file path, line number, and fix.

## iOS-Specific Rules

**I1. Dependency Rule — Import Direction (Critical)**
- `Talenta/Module/[Module]/Domain/`: no imports from Data or Presentation layers
- `Talenta/Module/[Module]/Data/`: imports from Domain only — never from Presentation
- `Talenta/Module/[Module]/Presentation/`: imports from Domain (UseCases, protocols) — never from Data impls directly

How to check: **Grep** `Talenta/Module/*/Domain/**/*.swift` for imports referencing `Data/` or `Presentation/`; **Grep** `Talenta/Module/*/Data/**/*.swift` for imports referencing `Presentation/`.

**I2. Legacy Folder Violation (Critical)**
- New files must never be placed in legacy root-level folders: `Models/`, `Controllers/`, `ViewModels/`
- All new code must live in `Talenta/Module/` or `Talenta/Shared/`

How to check: **Glob** `Talenta/Models/**/*.swift`, `Talenta/Controllers/**/*.swift`, `Talenta/ViewModels/**/*.swift` — any recently modified file here is a violation.

**I3. UseCase Bypass (Critical)**
- ViewModels must never import `*RepositoryImpl` directly — only protocols

How to check: **Grep** `Talenta/Module/*/Presentation/**/*.swift` for `RepositoryImpl`.

**I4. RepositoryImpl Placement (Warning)**
- `*RepositoryImpl` files belong in `Data/Repository/` — check for misplaced impls in Domain layer

How to check: **Glob** `Talenta/Module/*/Domain/**/*RepositoryImpl.swift`.

## Naming Conventions

**Grep** `.claude/reference/project.md` for the naming convention table. Check:
- UseCase: `[HttpMethod][Feature]UseCase`
- Repository protocol: `[Feature]RepositoryProtocol`
- Repository impl: `[Feature]RepositoryImpl`
- Entity: `[Feature]Model`
- Response: `[Feature]Response`
- Mapper: `[Feature]ModelMapper`
- ViewModel: `[Feature]ViewModel`

Report deviations as Warning.

For the full iOS convention and review checklist, **Grep** `.claude/reference/review-rules.md` for the relevant section.

## Output

Return raw findings in the format expected by `arch-generate-report`:

```
FILE: <path>
  [CRITICAL] <rule id> — <specific violation with line reference>
  [WARNING]  <rule id> — <specific violation>
PASS: <path>
```
