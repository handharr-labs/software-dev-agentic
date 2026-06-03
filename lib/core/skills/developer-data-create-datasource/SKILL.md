---
name: developer-data-create-datasource
description: Create a data source (remote or local) in the data layer.
user-invocable: false
knowledge_scope: engineering
---

Create a DataSource following `lib/core/knowledge/{platform}/engineering/data/data_source.md`.

## Steps

1. **Fetch pattern** — `kms_fetch(discipline="engineering", topic="data", pattern="data_source", platform={platform}, project={project})` for the canonical pattern and path convention. **Fallback** if KMS unavailable: `Read lib/core/knowledge/{project}/engineering/data/data_source.md` (project override) → `Read lib/core/knowledge/{platform}/engineering/data/data_source.md` (platform-base).
2. **Identify** whether this is a remote (API) or local (cache/DB) data source
3. **Locate** path per the impl doc's data source directory convention
4. **Create** the data source interface and implementation files following the impl doc pattern

## Rules

- DataSource depends on the platform's HTTP client or local storage — never on domain types directly
- Returns DTOs — never domain entities
- Error handling maps HTTP/storage errors to domain errors via the platform's error pattern

## Output

Confirm file path(s), list all methods with DTO return types, and confirm error mapping approach.
