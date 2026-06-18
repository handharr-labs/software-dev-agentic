---
name: developer-build-feature
description: Universal feature executor — accepts a run_dir, plan.md, or any design/spec document. If the input already has a batches frontmatter (produced by /developer-plan-feature), executes directly. Otherwise routes through /developer-plan-feature first to produce the structured plan, then executes. Entry point for post-brainstorming execution and all /developer-plan-* outputs.
user-invocable: true
disable-model-invocation: true
allowed-tools: Agent, AskUserQuestion, Bash, Read, Skill
---

## Routing Contract

This skill is a pure router. Its only permitted direct operations:
- `Bash` — resolving and validating the input path
- `Read` — re-reading plan.md and context.md before each worker spawn
- `AskUserQuestion` — unit test prompt in Step 3

Never read source files, search the codebase, or write code. All planning is delegated to `/developer-plan-feature`; all implementation to worker agents.

## Step 1 — Resolve Plan

`$ARGUMENTS` is a path to one of: a **run directory**, a **`plan.md` file**, or any **design/spec document** (e.g. a brainstorming output).

If `$ARGUMENTS` is empty, stop:
> No plan provided. Pass a run_dir, plan.md, or spec path. Run `/developer-plan-feature` to create a plan first.

```bash
if [ -d "$ARGUMENTS" ]; then
  grep "^batches:" "$ARGUMENTS/plan.md" 2>/dev/null | head -1
elif [ -f "$ARGUMENTS" ]; then
  grep "^batches:" "$ARGUMENTS" 2>/dev/null | head -1
fi
```

**If `batches` is present** → derive `run_dir`:
- Directory → `run_dir = $ARGUMENTS`
- File → `run_dir = dirname($ARGUMENTS)`

Proceed to Step 2.

**If `batches` is absent** (design doc, spec, or bare idea) → invoke `/developer-plan-feature` via the Skill tool, passing `$ARGUMENTS` verbatim.

Wait for it to complete. Read the `## Plan Output` block — extract `run_dir`.

If no `## Plan Output` is present (plan was discarded or canceled), stop.

Proceed to Step 2 with the `run_dir` from `## Plan Output`.

## Step 2 — Execute

`plan.md` is the single source of truth for execution state — update batch statuses live as work progresses.

Read `batches` from `<run_dir>/plan.md` frontmatter. Process each batch in `id` order where `status != complete`.

**For each batch:**

**2a — Mark in progress.** Set the batch's `status` to `in_progress` in `plan.md` frontmatter.

**2b — Determine worker by `layer`:**
- `layer: ui` → `developer-ui-worker`
- all others (`domain`, `data`, `pres`, `app`) → `developer-feature-worker`

**2c — Spawn the worker.** Re-read `plan.md` and `context.md` from disk before each spawn.

Also extract `raw_docs` from `state.json` (if present) before spawning any worker.

For `developer-feature-worker`:

> Pre-loaded context below — do not re-read plan.md, context.md, or state.json.
>
> **plan.md**
> \<content\>
>
> **context.md**
> \<content\>
>
> \<if raw_docs is non-empty:\>
> **Reference docs:**
> \<for each entry: "<path> — <description>"\>
> `Read` the relevant doc(s) for ground-truth details (endpoint paths, request/response shapes, field names) before implementing any artifact. Do not rely solely on plan.md/context.md if a doc covers the artifact.
> \<end if\>
>
> **Batch:** Process only these artifacts: \<batch.artifacts comma-separated\>. Skip any already complete in plan.md.
>
> Proceed directly to the first pending artifact in this batch.

For `developer-ui-worker` — also extract `stateholder_contract` from `state.json` first:

> Pre-loaded context below — do not re-read plan.md, context.md, or state.json.
>
> **plan.md**
> \<content\>
>
> **context.md**
> \<content\>
>
> **Stateholder contract path:** \<stateholder_contract from state.json, or "none" if null\>
>
> \<if raw_docs is non-empty:\>
> **Reference docs:**
> \<for each entry: "<path> — <description>"\>
> `Read` the relevant doc(s) for ground-truth details (UI stack specs, component structure, field names) before implementing any artifact. Do not rely solely on plan.md/context.md if a doc covers the artifact.
> \<end if\>
>
> **Batch:** Process only these artifacts: \<batch.artifacts comma-separated\>. Skip any already complete in plan.md.
>
> \<if ## Figma Alignment section is present in context.md, include — otherwise omit\>
> **Figma Instruction:** For every Screen and Component artifact, before writing any code:
> 1. Look up the artifact in the `## Figma Alignment` table in context.md above to get its `UI Stack` and `Figma Files`
> 2. `Read` the `UI Stack` file (`figma-uistack-*.md`) first — this is the merged Component Hierarchy, State Model, and User Interactions for this artifact (and any overlay components it mounts). Use this as the structural blueprint
> 3. For each state referenced in the UI Stack's `states` frontmatter: `Read` its `.md`, `layout_file` JSX (full file, no truncation), and `screenshot` `.png` (mandatory — visual inspection required before implementing)
> 4. For any overlay referenced (`← see figma-uistack-*.md`), repeat steps 2–3 for that overlay's UI Stack when implementing the overlay's Component artifact
>
> Proceed directly to the first pending UI artifact in this batch.

**2d — Checkpoint loop (fallback).** If the worker returns `## Context Checkpoint` instead of its completion signal, immediately re-spawn the same worker type without user interaction:

> Resuming from context checkpoint. Pre-loaded context below — do not re-read plan.md, context.md, or state.json.
>
> **plan.md**
> \<content — re-read from disk\>
>
> **context.md**
> \<content — re-read from disk\>
>
> \<if raw_docs is non-empty:\>
> **Reference docs:**
> \<for each entry: "<path> — <description>"\>
> `Read` the relevant doc(s) for ground-truth details before implementing any artifact.
> \<end if\>
>
> **Batch:** Process only these artifacts: \<batch.artifacts minus completed_artifacts from state.json\>. Skip any already complete in plan.md.
>
> **Resume from:** \<next_artifact from checkpoint block\>
> **State file:** \<state_file from checkpoint block\>
>
> \<for ui-worker: include Stateholder contract path and Figma Instruction as above\>
>
> Read state.json, skip completed artifacts, proceed directly to next_artifact.

Repeat until the worker returns `## Layers Complete` (feature-worker) or `## Feature Complete` (ui-worker).

**2e — Mark complete.** Set the batch's `status` to `complete` in `plan.md` frontmatter.

Proceed to Step 3 after all batches are complete.

## Step 3 — Unit Tests

Read `state.json` from the run directory. Extract all paths under `domain`, `data`, and `presentation` keys — these are the unit-testable artifacts. Skip `ui` and `app`.

If `state.json` is absent (plan not produced by `developer-plan-feature`), skip this step.

Call `AskUserQuestion` immediately — do NOT describe choices in prose:

```
question    : "Run unit tests for created artifacts?"
header      : "Unit Tests"
multiSelect : false
options     :
  - label: "Yes",  description: "Generate unit tests for all created artifacts via developer-test-worker"
  - label: "Skip", description: "I'll run tests manually later"
```

**Yes** → spawn `developer-test-worker`:

> target: <comma-separated artifact paths from state.json>
> platform: <platform from plan.md frontmatter>

**Skip** → surface the paths as a reminder:

> Tests not generated. Run when ready:
> `/developer-test-worker` — targets: <paths>
