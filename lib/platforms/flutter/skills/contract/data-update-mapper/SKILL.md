---
name: data-update-mapper
description: Update an existing Mapper and/or Model — add/remove/rename fields to match API or entity changes.
user-invocable: false
---

Update a Mapper and/or Model following `.claude/reference/contract/builder/data.md ## DTOs` and `## Mappers sections`.

## Steps

1. **Read** the Model file completely — understand current fields
2. **Read** the Mapper file completely — understand current mappings
3. **Read** the Entity file — confirm which entity fields need to be populated
4. **Edit** Model: add/remove/rename fields, update `@JsonKey` annotations
5. **Edit** Mapper: update `toEntity()` to handle new/changed fields
6. **Run** `dart run build_runner build --delete-conflicting-outputs` — remind the user if generated files are stale

Rules:
- All new Model fields must be nullable
- New Mapper fields need explicit null defaults — never `model.newField!`
- If removing a Model field, check all call sites: `Grep` for the field name
- After editing, run `flutter analyze` to surface breakage

## Output

Confirm both file paths and list the changes: fields added, removed, renamed, and default value choices.
