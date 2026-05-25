---
name: librarian-generate
description: Generate a new Feature Doc from a PRD, Confluence URL, or Jira ticket ID. Synthesizes, audits, and writes to .claude/reference/feature-docs/ on approval.
user-invocable: true
allowed-tools: Read, Glob, Bash, AskUserQuestion, Agent
---

## Arguments

`$ARGUMENTS` — one of: local `.md` file path, Confluence URL, or Jira ticket ID (e.g. `HR-421`).

## Steps

### 1 — Resolve PRD input

Detect input type from `$ARGUMENTS`:

| Pattern | Action |
|---|---|
| `.md` file path | `Read` the file directly |
| Confluence URL | Attempt `mmpa_get_confluence_page` if mmpa is configured; otherwise prompt user to paste the content |
| Jira ticket ID (e.g. `HR-421`) | Attempt `mmpa_get_jira` + `mmpa_get_confluence_by_ticket` if mmpa is configured; otherwise prompt user to paste PRD content |
| Empty | Ask user: "Paste the PRD content, or provide a file path, URL, or Jira ticket ID." |

mmpa is a personal tool — always fall back gracefully if unavailable. Prompt the user to paste content before blocking.

### 2 — Confirm feature name and output path

Ask the user to confirm:
- Feature name (default: derived from PRD title or Jira ticket)
- Output path (default: `.claude/reference/feature-docs/<kebab-case-name>.md`)

If the target path already exists, warn the user and ask: overwrite, or abort.

### 3 — Spawn synthesizer

Spawn `librarian-synthesizer-worker` in generate mode:

> **Mode: generate**
>
> principles_path: docs/principles/feature-doc-principles.md
>
> PRD content:
> <resolved PRD text>

Capture the returned draft.

### 4 — Spawn audit worker

Spawn `librarian-audit-worker`:

> principles_path: docs/principles/feature-doc-principles.md
>
> draft:
> <synthesizer draft>

Capture the findings block.

### 5 — Present for review

Show the draft and audit findings to the user:

- If verdict is `BLOCKED`: display violations. Do not proceed to write. Ask the user to correct the draft or provide missing information, then re-run the synthesizer and audit.
- If verdict is `APPROVED_WITH_WARNINGS`: display warnings. Ask the user to confirm they have reviewed them before proceeding.
- If verdict is `APPROVED`: proceed.

### 6 — Write on approval

On user approval, write the draft to the confirmed output path using the `Write` tool.

Confirm: "Feature Doc written to `<path>`."
