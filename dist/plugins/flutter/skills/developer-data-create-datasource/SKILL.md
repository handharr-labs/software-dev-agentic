---
name: developer-data-create-datasource
description: Create a data source (remote or local) in the data layer.
user-invocable: false
knowledge_scope: engineering
---

Create a DataSource following the {platform} standard architecture in `kms/knowledge-sources/engineering/{platform}-standard-architecture.md`.

## Steps

1. **Fetch pattern** — `kms_query(text="data source naming convention code pattern", platform={platform}, discipline="engineering", n_results=3)` for the canonical pattern and path convention. **Fallback** if no results: Read `kms/knowledge-sources/engineering/{platform}-standard-architecture.md` and locate the relevant section.
2. **Identify** whether this is a remote (API) or local (cache/DB) data source
3. **Locate** path per the impl doc's data source directory convention
4. **Create** the data source interface and implementation files following the impl doc pattern

## Rules

- DataSource depends on the platform's HTTP client or local storage — never on domain types directly
- Returns DTOs — never domain entities
- Error handling maps HTTP/storage errors to domain errors via the platform's error pattern

## Output

Confirm file path(s), list all methods with DTO return types, and confirm error mapping approach.
