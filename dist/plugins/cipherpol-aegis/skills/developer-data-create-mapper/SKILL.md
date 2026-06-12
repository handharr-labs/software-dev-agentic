---
name: developer-data-create-mapper
description: Create a mapper that converts DTOs to domain entities and vice versa.
user-invocable: false
knowledge_scope: engineering
---

Create a Mapper following the {platform} standard architecture, loaded from the KMS.

## Steps

1. **Load pattern** (fetch-by-topic — see `kms-conventions.md §Retrieval Protocol`):
   - `kms_list(discipline="engineering", artifact="standard-architecture", topic="data", platform={platform})` — scan the data TOC for the mapper pattern slug (e.g. `mapper`).
   - `kms_fetch(discipline="engineering", artifact="standard-architecture", topic="data", pattern="<mapper slug from list>", platform={platform})` — full content: naming, path convention, code pattern.
   - If the TOC has no mapper pattern, STOP and report a KMS seed gap for `{platform}/engineering/standard-architecture/data` — do not guess.
2. **Confirm** both the DTO and domain entity exist before creating the mapper
3. **Locate** path per the impl doc's mapper directory convention
4. **Create** the mapper file following the impl doc pattern

## Rules

- Mapper contains only mapping logic — no business logic, no API calls
- Covers all fields — no silent field drops; use sensible defaults for optional → required mappings
- Bidirectional where needed (DTO → Entity and Entity → Payload)

## Output

Confirm file path and list all mapped fields with any non-trivial transformations noted.
