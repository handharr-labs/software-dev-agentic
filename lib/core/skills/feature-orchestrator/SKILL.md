---
name: feature-orchestrator
description: Build or update a feature across Clean Architecture layers. Routes through feature-orchestrator agent — resumes an existing run or starts a new one.
allowed-tools: Bash, Read, AskUserQuestion, Agent
---

## Arguments

`$ARGUMENTS` — optional feature description.

## Steps

1. Find existing runs:
   ```bash
   find "$(git rev-parse --show-toplevel)/.claude/agentic-state/runs" -name "state.json" 2>/dev/null
   ```

2. **If runs exist:** call `AskUserQuestion`:
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
   - If user picks **Resume** → read `plan.md`, `context.md`, and `state.json` for that run → go to step 3
   - If user picks **Start new feature** → go to step 4

   **If no runs exist** → go to step 4

3. **Resume — spawn `feature-orchestrator` using the Agent tool with pre-loaded context** (substitute actual file contents):

   > **Trigger: resume**
   > Feature: <feature name from state.json>
   >
   > Pre-loaded context — do not re-read plan.md, context.md, or state.json:
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
   > Spawn `feature-worker` directly with this context. Skip Phase 0 and planning.

4. **New — spawn `feature-orchestrator` using the Agent tool:**

   > **Trigger: new**
   > Feature: <$ARGUMENTS, or empty if not provided>
   >
   > No existing run. If no feature description was given, ask the user for it. Then ask whether to plan first or build directly.
