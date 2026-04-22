---
name: domain-update-usecase
description: Update an existing UseCase — add params fields, change return type, or wire a new repository method.
user-invocable: false
---

Update an existing UseCase following `.claude/reference/contract/builder/domain.md ## Use Cases section`.

## Steps

1. **Read** the target UseCase file completely — understand its current Params and return type
2. **Read** the repository interface to verify the method being called still exists and matches
3. **Edit** the UseCase file — update Params fields, repository call, or return type as needed
4. **Check** whether the Params class also needs updating (separate class or nested)

Rules:
- Never change the class name — callers depend on it
- If adding a required Params field, search for all call sites: `Grep` for the UseCase class name
- Params classes remain pure Dart — no freezed, no `@JsonKey`
- After editing, run `flutter analyze` to surface broken call sites

## Output

Confirm file path, list what changed (fields added/removed/renamed, return type changes), and flag any call sites that need updating.
