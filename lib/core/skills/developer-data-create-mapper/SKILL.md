---
name: developer-data-create-mapper
description: Create a mapper that converts DTOs to domain entities and vice versa.
user-invocable: false
knowledge_scope: engineering
---

Create a Mapper following `lib/core/knowledge/{platform}/engineering/data/mapper.md`.

## Steps

1. **Fetch pattern** — `kms_fetch(discipline="engineering", topic="data", pattern="mapper", platform={platform}, project={project})` for the canonical pattern and path convention. **Fallback** if KMS unavailable: `Read lib/core/knowledge/{project}/engineering/data/mapper.md` (project override) → `Read lib/core/knowledge/{platform}/engineering/data/mapper.md` (platform-base).
2. **Confirm** both the DTO and domain entity exist before creating the mapper
3. **Locate** path per the impl doc's mapper directory convention
4. **Create** the mapper file following the impl doc pattern

## Rules

- Mapper contains only mapping logic — no business logic, no API calls
- Covers all fields — no silent field drops; use sensible defaults for optional → required mappings
- Bidirectional where needed (DTO → Entity and Entity → Payload)

## Output

Confirm file path and list all mapped fields with any non-trivial transformations noted.
