---
name: saturn-jaygarcia
description: Plan then build any task — lucci-planner (opus) explores and writes plan.md to disk, you review/discuss/approve it, then kaku-worker (sonnet) executes unattended. Cheap opusplan-style hand-off — exploration never pollutes the main session.
user-invocable: true
allowed-tools: Agent, AskUserQuestion, Bash, Read
---

## Routing Contract

This skill is a pure router. Its only permitted direct operations:
- `Bash` — preflight existence checks, run-dir creation, slug generation
- `Read` — only `plan.md` from a run directory
- `AskUserQuestion` — resume routing and the approval gate
- `Agent` — spawning `lucci-planner` and `kaku-worker`

**`lucci-planner` and `kaku-worker` are agents — always spawn via the `Agent` tool. Never use the `Skill` tool for them.**

Never explore the codebase, read source files, or write code directly — all of that is delegated to `lucci-planner` / `kaku-worker`.

## Preflight — Detect Existing Runs

```bash
find "$(git rev-parse --show-toplevel)/.claude/agentic-state/runs/saturn-jaygarcia" -maxdepth 2 -name "plan.md" 2>/dev/null
```

If results found, `AskUserQuestion`:

```
question    : "Found existing plan(s). Resume one or start a new task?"
header      : "Resume"
multiSelect : false
options     : <one option per found plan.md, label = first line of "## Goal" section, description = run_dir>
              + "Start new", description: "Plan a new task from scratch"
```

**Resume an existing plan** → set `run_dir` to its directory. Skip to Step 2 (Present Plan).
**Start new** (or no existing runs found) → proceed to Step 1.

## Step 1 — New Plan

1. Generate a slug — prefer ticket ID from the current branch, fall back to task description:
   ```bash
   branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
   ticket=$(echo "$branch" | grep -oE '[A-Z]+-[0-9]+' | head -1)
   if [ -n "$ticket" ]; then
     slug="$ticket"
   else
     slug=$(echo "<task>" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-*//;s/-*$//' | cut -c1-50)
   fi
   run_dir="$(git rev-parse --show-toplevel)/.claude/agentic-state/runs/saturn-jaygarcia/$slug"
   mkdir -p "$run_dir"
   ```
2. Spawn `lucci-planner`:

   ```
   mode: plan
   task: <the user's message verbatim>
   run_dir: <run_dir>
   ```

3. Wait for `## Plan Written`. Proceed to Step 2.

## Step 2 — Present Plan

`plan.md` follows the schema in `.claude/reference/saturn-jaygarcia/plan-format.md` — `## Open Questions` is the only section this skill branches on, and is omitted entirely when there's nothing to ask.

1. `Read` `<run_dir>/plan.md` and show its full content to the user.

2. **If `## Open Questions` is present** — the planner couldn't proceed confidently on its own. **Do NOT resolve open questions yourself by reading source files or making assumptions — that violates the routing contract.** Ask the user about each item directly (conversationally, or `AskUserQuestion` if they're discrete choices) before offering the approval gate. Once answered, spawn `lucci-planner`:
   ```
   mode: revise
   run_dir: <run_dir>
   feedback: <the user's answers to each open question>
   ```
   Wait for `## Plan Written`, then restart Step 2 from the top (re-read the updated plan).

3. **Once `## Open Questions` is absent**, `AskUserQuestion`:

   ```
   question    : "Review the plan above. How do you want to proceed?"
   header      : "Plan Review"
   multiSelect : false
   options     :
     - label: "Approve",  description: "Build exactly as planned"
     - label: "Discuss",  description: "Ask questions or talk through changes before deciding"
     - label: "Cancel",   description: "Stop here — plan stays on disk for later resume"
   ```

   - **Approve** → proceed to Step 3.
   - **Discuss** → converse with the user inline for as many turns as needed. When the discussion settles, ask the user whether the plan itself needs to change:
     - **Plan needs updating** → spawn `lucci-planner`:
       ```
       mode: revise
       run_dir: <run_dir>
       feedback: <summary of the discussion / requested changes>
       ```
       Wait for `## Plan Written`, then restart Step 2 from the top (re-read the updated plan).
     - **No change needed** (discussion was just clarification) → return to step 3's `AskUserQuestion` without re-spawning.
   - **Cancel** → tell the user the plan is saved at `<run_dir>/plan.md` and can be resumed by re-running `/saturn-jaygarcia`. Stop.

## Step 3 — Build

**NEVER spawn `kaku-worker` without an explicit `Approve` selection from the user via `AskUserQuestion` in Step 2. Resolving open questions yourself is not approval.**

Spawn `kaku-worker`:

```
plan_path: <run_dir>/plan.md
run_dir: <run_dir>
```

Wait for `## Build Complete`. Relay its `### Files Changed` and `### Notes` to the user verbatim.
