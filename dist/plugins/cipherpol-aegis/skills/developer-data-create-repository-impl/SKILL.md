---
name: developer-data-create-repository-impl
description: Create the repository implementation that bridges domain interfaces and data sources.
user-invocable: false
knowledge_scope: engineering
---

Create a Repository Implementation following the {platform} standard architecture in `kms/knowledge-sources/engineering/{platform}-standard-architecture.md`.

## Steps

1. **Fetch pattern** — `kms_query(text="data repository implementation naming convention code pattern", platform={platform}, discipline="engineering", n_results=3)` for the canonical pattern and path convention. **Fallback** if no results: Read `kms/knowledge-sources/engineering/{platform}-standard-architecture.md` and locate the relevant section.
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
