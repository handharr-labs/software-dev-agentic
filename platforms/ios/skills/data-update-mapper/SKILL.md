---
name: data-update-mapper
description: |
  Update an existing Mapper to add/remove/fix field mappings after Entity or Response changes.
user-invocable: false
---

Update an existing Mapper following `.claude/reference/data.md §4.3`.

## Steps

1. **Read** the existing Mapper file completely
2. **Read** the current Entity and Response to identify all fields
3. **Apply targeted changes** — do not restructure unrelated code

## Common Update Scenarios

**New Entity field added:**
1. Add field to Response DTO (with CodingKeys if snake_case)
2. Add field to mapper call: `newField: response.newField.orEmpty()`

**Field renamed in Response (snake_case change):**
Update or add CodingKey in Response, then update mapper if property name changes.

**Field removed from Entity:**
Remove from mapper call. If Response still has it, leave Response untouched.

## Rules

- Every Entity field must appear in the mapper call — no silent defaults
- Use `.orEmpty()` / `.orZero()` / `.orFalse()` — never `?? ""`
- After updating mapper, verify Response DTO has the matching field with correct CodingKeys
- New code → V2 patterns. Existing code → keep its pattern.

## Output

List all changes made with file paths and line numbers. Flag any Entity field now missing from mapper.
