---
name: developer-data-create-repository-impl
description: Create the repository implementation that bridges domain interfaces and data sources.
user-invocable: false
---

Create a Repository Implementation following `.claude/reference/code-architecture/data-impl.md ## Repository Implementation`.

## Steps

1. **Read** `.claude/reference/code-architecture/data-impl.md` — locate `## Repository Implementation` for the canonical pattern and path convention
2. **Confirm** the domain repository interface, data source, and mapper all exist
3. **Locate** path per the impl doc's repository impl directory convention
4. **Create** the repository implementation file following the impl doc pattern
5. **Register** in DI if required by the platform

## Rules

- Implements the domain repository interface — every method must match exactly
- Calls data source, then maps DTO → entity via mapper — never maps inline
- Error handling converts data layer exceptions to domain errors

## Output

Confirm file path, confirm all interface methods are implemented, and confirm DI registration if applicable.
