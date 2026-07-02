---
name: kms-contribute
description: Normalize loose knowledge drafts dropped in cipherpol-8-kms/knowledge-sources/_inbox/ into canonical KMS source files. Infers platform, discipline, layer, owner, area, and artifact from each draft, writes it at its canonical path with frontmatter, and reports for review. Does not seed — run /kms-seed after reviewing.
user-invocable: true
disable-model-invocation: true
allowed-tools: Agent
---

## Arguments

`$ARGUMENTS` — optional:
- _(none)_ — classify every draft in `_inbox/`
- `<filename>` — classify only that draft
- any other free text — treated as a classification `hint` passed to the workers (e.g. `flutter data-layer error handling`)

## Steps

### 1 — Parse arguments

If `$ARGUMENTS` names an existing `_inbox/` file, treat it as `draft_filter`; otherwise treat the text as a `hint`.

### 2 — Spawn orchestrator

Spawn `kms-contribute-orchestrator` with:

```
draft_filter: <filename or null>
hint:         <hint text or null>
```

### 3 — Report

Surface the orchestrator's per-draft summary and the next step (review the diff, delete processed `_inbox` drafts, run `/kms-seed`).
