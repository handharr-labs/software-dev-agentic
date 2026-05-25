---
name: builder-build-feature
description: Build or update a feature across Clean Architecture layers. Resumes an existing run or starts a new one via the builder-plan-feature flow.
user-invocable: true
allowed-tools: Bash, Read, AskUserQuestion, Agent
---

## Arguments

`$ARGUMENTS` — optional feature description.

## Steps

### 1 — Check for existing runs

```bash
find "$(git rev-parse --show-toplevel)/.claude/agentic-state/runs" -name "state.json" 2>/dev/null
```

### 2 — If runs exist: ask which to resume

Call `AskUserQuestion`:

```
question    : "Which feature would you like to work on?"
header      : "Feature"
multiSelect : false
options     :
  (one entry per found run, values from state.json)
  - label: "Resume: <feature>", description: "Next artifact: <next_artifact>"
  (always include)
  - label: "Start new feature", description: "Begin a fresh feature from scratch"
```

- **Resume** → read `plan.md`, `context.md`, and `state.json` for that run → go to Step 3
- **Start new feature** → go to Step 4

**If no runs exist** → go to Step 4.

### 3 — Resume

Spawn `builder-feature-worker` directly with the pre-loaded context:

> Approved plan ready. Pre-loaded context below — do not re-read plan.md, context.md, or state.json.
>
> **plan.md**
> <content>
>
> **context.md**
> <content>
>
> **state.json**
> <content>
>
> Proceed directly to the next pending artifact. Skip completed artifacts listed in state.json.

### 4 — New feature

Call `AskUserQuestion`:

```
question    : "How would you like to proceed?"
header      : "Feature"
multiSelect : false
options     :
  - label: "Plan first",     description: "Review and approve a plan before building"
  - label: "Build directly", description: "Skip planning — gather intent inline and go straight to building"
```

**Plan first** → invoke the `/builder-plan-feature` skill with `$ARGUMENTS`. This skill owns the full planning loop and approval flow.

**Build directly** → spawn `builder-feature-orchestrator` with mode `gather-intent`:

> **Mode: gather-intent**
>
> Feature description: <$ARGUMENTS, or empty>
>
> After gathering intent, proceed directly to synthesize without running the planning convergence loop. Use safe defaults: spawn all four layer planners, accept their findings as-is, write plan.md with status approved.

Wait for the orchestrator to finish synthesizing. Read `plan.md` and `context.md` from the run directory, then spawn `builder-feature-worker`:

> Approved plan ready. Pre-loaded context below — do not re-read plan.md, context.md, or state.json.
>
> **plan.md**
> <content>
>
> **context.md**
> <content>
>
> Proceed directly to the first pending artifact.
