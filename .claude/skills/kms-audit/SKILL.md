---
name: kms-audit
description: Audit all files in kms/knowledge-sources/ against kms-knowledge-source-rules.md — validates heading structure, naming conventions, duplicate slugs, and section size before seeding. Reports errors (block seeding) and warnings (degrade retrieval).
user-invocable: true
disable-model-invocation: true
---

## What This Does

Validates every file in `kms/knowledge-sources/` against the rules in `kms/docs/kms-knowledge-source-rules.md` before you run `/kms-seed`. Catches structural problems that would cause incorrect seeding or poor retrieval.

## Usage

```
/kms-audit                        — audit all files
/kms-audit engineering/           — audit one discipline directory
/kms-audit projects/flutter-mobile-talenta/  — audit one project
```

## Steps

1. Read `kms/docs/kms-knowledge-source-rules.md` to load the current rule set.

2. Resolve the target scope from args:
   - No args → `kms/knowledge-sources/` (all files)
   - Path arg → `kms/knowledge-sources/{arg}` (scoped)

3. Spawn `kms-source-audit-worker` with:
   - `target_path` — resolved absolute path
   - `rules_path` — `kms/docs/kms-knowledge-source-rules.md`

4. Print the audit report returned by the worker.

5. If any **Error**-severity findings exist:
   > ⛔ Fix errors before running `/kms-seed` — seeding will produce incorrect nodes.

   If only **Warning**-severity findings:
   > ⚠ Warnings found — seeding will work but retrieval quality may be degraded.

   If no findings:
   > ✓ All files pass — safe to run `/kms-seed`.
