---
name: feature-orchestrator
description: Build or update a feature across Clean Architecture layers. Loads run context from disk and passes it inline — orchestrator skips cold pre-flight reads.
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
     - label: "Resume: <feature>", description: "Next phase: <next_phase>"
     (always include)
     - label: "Start new feature", description: "Begin a fresh feature from scratch"
   ```
   - If user picks **Resume** → read `context.md` and `state.json` for that run → go to step 3
   - If user picks **Start new feature** → go to step 4

   **If no runs exist** → go to step 4

3. **Resume — spawn `feature-orchestrator` using the Agent tool with pre-loaded context** (substitute actual file contents):

   > Feature: <feature name from state.json>
   >
   > Pre-loaded context — do not re-read context.md or state.json:
   >
   > **context.md**
   > <content>
   >
   > **state.json**
   > <content>
   >
   > Proceed directly to the next pending phase. Skip pre-flight reads for these files.

4. **New call — spawn `feature-orchestrator` using the Agent tool without context:**

   > Feature: <$ARGUMENTS, or empty if not provided>
   >
   > No existing run. If no feature description was given, ask the user for it. Then ask: "Would you like to plan first (recommended) or build directly?"
