---
name: backend-orchestrator
description: Build backend layers (domain + data) for a feature. Loads existing run context if available, then spawns backend-orchestrator.
allowed-tools: Bash, Read, AskUserQuestion, Agent
---

## Arguments

`$ARGUMENTS` — optional feature description.

## Steps

1. Find existing runs:
   ```bash
   find "$(git rev-parse --show-toplevel)/.claude/agentic-state/runs" -name "state.json" 2>/dev/null
   ```

2. **If runs exist:** use `AskUserQuestion`:
   - One option per found run: label `"Resume: <feature>"`, description `"next: <next_phase>"`
   - Always include: label `"Start new feature"`
   - If user picks **Resume** → read `state.json` and `context.md` (if present) for that run → go to step 3
   - If user picks **Start new** → go to step 4

   **If no runs exist** → go to step 4

3. **Resume — spawn `backend-orchestrator` using the Agent tool with pre-loaded context** (substitute actual file contents):

   > Feature: <feature name from state.json>
   >
   > Pre-loaded context — do not re-read these files from disk:
   >
   > **state.json**
   > <content>
   >
   > **context.md** *(omit this block if context.md does not exist)*
   > <content>
   >
   > Proceed directly to the next pending phase. Skip pre-flight reads for these files.

4. **New call — spawn `backend-orchestrator` using the Agent tool without context:**

   > Feature: <$ARGUMENTS, or empty if not provided>
   >
   > No existing run. If no feature description was given, ask the user for it.
