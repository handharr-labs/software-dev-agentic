---
name: developer-data-create-repository-impl
description: Create the repository implementation that bridges domain interfaces and data sources.
user-invocable: false
knowledge_scope: engineering/data
---

Create a Repository Implementation following `lib/core/knowledge/{platform}/engineering/data/repository_impl.md`.

## Steps

1. **Read** `lib/core/knowledge/{platform}/engineering/data/repository_impl.md` for the canonical pattern and path convention. Check `lib/core/knowledge/{project}/engineering/data/repository_impl.md` first (project-specific override), fall back to `lib/core/knowledge/{platform}/engineering/data/repository_impl.md` (platform-base).
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
