---
name: data-update-mapper
description: Update an existing Mapper to add/remove/fix field mappings after Entity or DTO changes. Called by data-worker.
user-invocable: false
tools: Read, Edit, Glob
---

Update an existing Mapper following `reference/contract/builder/data.md` — Grep `## Mappers`.

## Steps

1. **Read** the existing Mapper file completely
2. **Read** the current Entity and DTO to identify all fields
3. **Apply targeted changes** — do not restructure unrelated code

## Common Update Scenarios

**New Entity field added:**
1. Add field to DTO (with snake_case key mapping if needed)
2. Add field to mapper: `newField: dto.new_field ?? defaultValue`

**Field renamed in DTO (snake_case change):**
Update the property access in the mapper `toEntity` method.

**Field removed from Entity:**
Remove from mapper call. If DTO still has it, leave DTO untouched.

## Rules

- Every Entity field must appear in the mapper call — no silent defaults
- Handle null/undefined optional fields explicitly (`.orEmpty()`, `.orZero()`, `?? ''`, etc.)
- After updating mapper, verify DTO has the matching field with correct naming
- Never remove existing mapper methods unless explicitly asked

## Output

List all changes made with file paths and line numbers. Flag any Entity field now missing from mapper.
