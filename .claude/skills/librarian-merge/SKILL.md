---
name: librarian-merge
description: Consolidate two or more Feature Docs into one. Applies section merge strategies, runs audit, presents diff, and writes on approval. Archives originals on request.
user-invocable: true
allowed-tools: Read, Glob, Bash, AskUserQuestion, Agent
---

## Arguments

`$ARGUMENTS` — two or more Feature Doc paths under `.claude/reference/feature-docs/`, space-separated.

## Steps

### 1 — Resolve input paths

Parse paths from `$ARGUMENTS`. For each path:
- If the path exists: read it.
- If not found by exact path, glob under `.claude/reference/feature-docs/` and show matches via `AskUserQuestion`.

Require at least 2 docs. If fewer than 2 resolved, stop and tell the user.

### 2 — Confirm merge intent

Ask the user:
- What should the merged Feature Doc be named? (default: suggest the primary feature name)
- Output path (default: `.claude/reference/feature-docs/<merged-name>.md`)
- What to do with originals after merge: keep in `_archived/` subfolder, or delete.

If the output path already exists, warn and ask: overwrite or pick a new name.

### 3 — Spawn synthesizer in merge mode

Spawn `librarian-synthesizer-worker` in merge mode:

> **Mode: merge**
>
> principles_path: docs/principles/feature-doc-principles.md
>
> doc_1:
> <full text of first Feature Doc>
>
> doc_2:
> <full text of second Feature Doc>
>
> (repeat for additional docs)

The synthesizer applies section merge strategies from the principles doc:
- References: union
- API Contracts: union, deduplicate shared endpoints
- Data Model: merge entities, detect inheritance
- HLD: regenerate combined layer map
- Data Flow: re-stitch into single end-to-end flow
- Artifacts: union rows, deduplicate shared components
- Platform Variants: reconcile conflicts per platform
- Gotchas: union

Capture the merged draft.

### 4 — Spawn audit worker

Spawn `librarian-audit-worker`:

> principles_path: docs/principles/feature-doc-principles.md
>
> draft:
> <merged draft>

Capture findings.

### 5 — Present for review

Show the merged draft and audit findings. Highlight any conflicts or decisions the synthesizer made (e.g. divergent Platform Variants that were reconciled, data models that were merged). Human review before publish is a hard gate — HLD and Data Flow require judgment.

- `BLOCKED`: display violations. Ask user to correct before proceeding.
- `APPROVED_WITH_WARNINGS`: display warnings. Confirm before proceeding.
- `APPROVED`: proceed.

### 6 — Write on approval

Write merged draft to the confirmed output path.

### 7 — Handle originals

Based on user choice in Step 2:
- **Archive**: move originals to `.claude/reference/feature-docs/_archived/` (use `Bash` to `mv`).
- **Delete**: delete originals (use `Bash` to `rm`). Confirm before deleting.

Confirm: "Merged Feature Doc written to `<path>`. Originals archived/deleted."
