---
name: developer-data-create-datasource
description: Create a data source (remote or local) in the data layer.
user-invocable: false
knowledge_scope: engineering
---

Create a DataSource following the {platform} standard architecture, loaded from the KMS.

## Steps

1. **Load pattern** (fetch-by-topic — see `kms-conventions.md §Retrieval Protocol`):
   - `kms_list(discipline="engineering", artifact="standard-architecture", topic="data", platform={platform})` — scan the data TOC for the data-source pattern slug(s) (e.g. `data_source`, `local_data_source`).
   - `kms_fetch(discipline="engineering", artifact="standard-architecture", topic="data", pattern="<data-source slug from list>", platform={platform})` — full content: naming, path convention, code pattern. Fetch both remote and local slugs if present.
   - If the TOC has no data-source pattern, STOP and report a KMS seed gap for `{platform}/engineering/standard-architecture/data` — do not guess.
2. **Identify** whether this is a remote (API) or local (cache/DB) data source
3. **Locate** path per the impl doc's data source directory convention
4. **Create** the data source interface and implementation files following the impl doc pattern

## Rules

- DataSource depends on the platform's HTTP client or local storage — never on domain types directly
- Returns DTOs — never domain entities
- Error handling maps HTTP/storage errors to domain errors via the platform's error pattern

## Output

Confirm file path(s), list all methods with DTO return types, and confirm error mapping approach.
