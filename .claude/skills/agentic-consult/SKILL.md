---
name: agentic-consult
description: Consult on any agentic component — agents, skills, hooks, or MCPs — for adjustments, refactors, goal changes, design confusion, or migration. Interactive: reads current state, asks about intent, delivers a concrete recommendation. Optionally applies fixes via agentic-migrate-worker in consult-and-apply mode.
user-invocable: true
disable-model-invocation: true
tools: Agent, AskUserQuestion
---

## Arguments

```
/agentic-consult [subject]
```

- `subject` — optional. A persona name, a file path, a component type (`hooks`, `mcps`), or a plain description of the area. If omitted, the worker will ask.

## Steps

### 1 — Consult

Invoke `agentic-consult-worker`.

If `subject` was provided, pass it in the spawn prompt: `Subject: <subject>.`
If omitted, pass no arguments — the worker will ask interactively starting at Step 1.

The worker returns a recommendation block. Validate: response must contain a recommendation — STOP if no output.

### 2 — Ask apply mode

After the recommendation is shown to the user, ask:

> "How would you like to proceed?"

Options:
- **Consult only** — keep the recommendation as reference, no changes applied
- **Apply now** — spawn `agentic-migrate-worker` to apply the recommended fixes

If the user chooses **Apply now**:

### 3 — Apply (consult-and-apply mode)

Extract the target file path(s) from the recommendation.

Spawn `agentic-migrate-worker` with: `File: <file>. Context: <summary of recommendation>.`

Validate: response must contain a migration report — STOP if no output.

### 4 — Verify (apply mode only)

Spawn `agentic-arch-review-worker` with: `Scope: <migrated file path>. Check convention compliance.`

- Clean → confirm fix succeeded
- Violations remain → list as residual and suggest `/agentic-consult` again

### 5 — Report

Consultation summary + (if applied) migration report + verification result.
