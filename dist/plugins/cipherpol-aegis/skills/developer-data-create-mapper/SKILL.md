---
name: developer-data-create-mapper
description: Create a mapper that converts DTOs to domain entities and vice versa.
user-invocable: false
knowledge_scope: engineering
---

Create a Mapper following the {platform} standard architecture in `kms/knowledge-sources/engineering/{platform}-standard-architecture.md`.

## Steps

1. **Fetch pattern** — `kms_query(text="data mapper naming convention code pattern", platform={platform}, discipline="engineering", n_results=3)` for the canonical pattern and path convention. **Fallback** if no results: Read `kms/knowledge-sources/engineering/{platform}-standard-architecture.md` and locate the relevant section.
2. **Confirm** both the DTO and domain entity exist before creating the mapper
3. **Locate** path per the impl doc's mapper directory convention
4. **Create** the mapper file following the impl doc pattern

## Rules

- Mapper contains only mapping logic — no business logic, no API calls
- Covers all fields — no silent field drops; use sensible defaults for optional → required mappings
- Bidirectional where needed (DTO → Entity and Entity → Payload)

## Output

Confirm file path and list all mapped fields with any non-trivial transformations noted.
