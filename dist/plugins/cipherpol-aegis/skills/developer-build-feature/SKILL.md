---
name: developer-build-feature
description: Feature executor — accepts a run_dir or any plan/spec document. Spawns a scope agent to decompose work into batches, then executes each batch with one or more parallel workers (feature or ui). Self-contained; does not depend on developer-plan-feature. Does not run tests.
user-invocable: true
allowed-tools: Agent, Bash, Read
---

## Orchestrator Contract

Only permitted direct operations:
- `Bash` — resolving and validating the input path
- `Read` — reading the plan doc

Never read source files, search the codebase, or write code. Scoping is delegated to the scope agent; implementation to worker agents.

## Step 1 — Resolve Input

`$ARGUMENTS` is a path to a **run directory** or a **plan/spec document**.

If `$ARGUMENTS` is empty, stop:
> No input provided. Pass a run_dir or plan/spec document.

```bash
if [ -d "$ARGUMENTS" ]; then
  ls "$ARGUMENTS/plan.md" 2>/dev/null
elif [ -f "$ARGUMENTS" ]; then
  echo "$ARGUMENTS"
fi
```

- Directory → `plan_doc = $ARGUMENTS/plan.md`, `run_dir = $ARGUMENTS`
- File → `plan_doc = $ARGUMENTS`, `run_dir = dirname($ARGUMENTS)`

If the resolved file does not exist, stop:
> Plan document not found at `<path>`.

Read `plan_doc`.

## Step 2 — Scope & Batch

Spawn an Agent with the following prompt, passing the full contents of `plan_doc`:

> You are a scoping agent. Review the plan/requirements below and decompose the work into execution batches.
>
> Rules:
> - If the steps are small and cohesive, return a single batch.
> - If the steps are large or span distinct layers/concerns, split into multiple batches — each independently executable.
> - Each batch may have multiple workers running in parallel. Worker types:
>   - `feature` — domain, data, pres, or app layer work
>   - `ui` — UI/widget/screen work only
> Return ONLY a YAML block in this exact shape:
>
> ```yaml
> batches:
>   - id: 1
>     description: "<what this batch covers>"
>     workers:
>       - type: feature
>         layer: domain|data|pres|app
>         focus: "<specific work for this worker>"
>       - type: ui
>         layer: ui
>         focus: "<specific work for this worker>"
> ```
>
> Plan doc:
> <plan_doc contents>

Parse the returned `batches` from the YAML block.

## Step 3 — Execute

Process each batch in `id` order.

**For each batch:**

**3a — Spawn all workers in the batch in parallel.** For each entry in `batch.workers`:
- `type: feature` → `developer-feature-worker`
- `type: ui` → `developer-ui-worker`

Prompt each worker:

> run_dir: \<run_dir\>
> batch: \<batch.id\> — \<batch.description\>
> layer: \<worker.layer\>
> focus: \<worker.focus\>

**3b — Checkpoint loop.** If a worker returns `## Context Checkpoint`, re-spawn it immediately with the same prompt. Repeat until it returns `## Layers Complete` (feature-worker) or `## Feature Complete` (ui-worker).
