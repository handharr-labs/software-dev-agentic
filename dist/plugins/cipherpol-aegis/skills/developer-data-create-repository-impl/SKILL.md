---
name: developer-data-create-repository-impl
description: Create the repository implementation that bridges domain interfaces and data sources.
user-invocable: false
knowledge_scope: engineering
---

Create a Repository Implementation following the {platform} standard architecture, loaded from the KMS.

## Steps

1. **Load pattern** (fetch-by-topic — see `kms-conventions.md §Retrieval Protocol`):
   - `kms_list(discipline="engineering", artifact="standard-architecture", topic="data", platform={platform})` — scan the data TOC for the repository-implementation pattern slug (e.g. `repository_implementation`).
   - `kms_fetch(discipline="engineering", artifact="standard-architecture", topic="data", pattern="<repository-impl slug from list>", platform={platform})` — full content: naming, path convention, code pattern.
   - If the TOC has no repository-implementation pattern, STOP and report a KMS seed gap for `{platform}/engineering/standard-architecture/data` — do not guess.
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
