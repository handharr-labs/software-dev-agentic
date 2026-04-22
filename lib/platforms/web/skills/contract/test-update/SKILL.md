---
name: test-update
description: Update existing StateHolder tests after StateHolder code changes — add missing tests, remove obsolete ones, update changed logic. Called by test-worker.
user-invocable: false
tools: Read, Edit, Glob
---

Update existing tests following `reference/contract/builder/testing.md`.

## Steps

1. **Read** the updated StateHolder completely
2. **Read** the existing test file completely
3. **Generate analysis report** comparing StateHolder vs tests
4. **Execute updates** in priority order

## Analysis Report Format

```markdown
# Analysis: [StateHolder] vs [TestFile]

## Executive Summary
- Queries/mutations in StateHolder: N
- Covered by tests: M
- Action required: K items

## Item-by-Item
### ✅ [queryName] — Covered
### ⚠️ [mutationName] — Partially Covered
  Missing: success path / error path / [branch]
### ❌ [fieldName] — Not Covered
```

## Execution Priority

1. **Critical**: Remove tests for removed queries/mutations/fields
2. **High**: Add tests for new queries/mutations
3. **Medium**: Update tests for changed logic or return shapes
4. **Low**: Rename tests to follow current naming convention

## Rules

- Do not rewrite passing tests — only update what changed
- Never modify production StateHolder code to make tests pass
- After removing a query/mutation, delete its tests + update mocks

**Pattern:** `reference/contract/builder/testing.md` — Grep `## ViewModel Hook Tests`

## Output

Show the analysis report, then list all changes made with file paths and line numbers.
