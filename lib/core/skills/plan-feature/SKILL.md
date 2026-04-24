---
name: plan-feature
description: Plan then build a feature — invokes feature-planner for reviewable planning, then hands off to feature-orchestrator for execution.
allowed-tools: Bash, Read, AskUserQuestion, Agent
---

1. Spawn `feature-planner` using the Agent tool. Pass no arguments — it gathers intent interactively.

2. After it completes, find the context file it just wrote:
   ```bash
   ls -t "$(git rev-parse --show-toplevel)/.claude/agentic-state/runs"/*/context.md 2>/dev/null | head -1
   ```

3. **If no context.md is found** (plan was discarded or planner did not complete normally):
   - Stop. Do not spawn feature-orchestrator.
   - Inform the user: "No approved plan found. Run `/plan-feature` again when ready."

4. **If context.md is found**, call `AskUserQuestion`:
   ```
   question    : "Plan approved. What would you like to do next?"
   header      : "Next step"
   multiSelect : false
   options     :
     - label: "Build now",     description: "Spawn feature-orchestrator to execute the plan immediately"
     - label: "Review first",  description: "Read plan.md before building — run /feature-orchestrator when ready"
   ```
   - If user picks **Review first** → stop. The plan is at `.claude/agentic-state/runs/<feature>/plan.md`.
   - If user picks **Build now** → continue to step 5.

5. Read that `context.md` and the `state.json` in the same directory.

6. Spawn `feature-orchestrator` using the Agent tool with the following prompt, substituting actual file contents:

   > Approved plan ready. Pre-loaded context below — do not re-read context.md or state.json.
   >
   > **context.md**
   > <content>
   >
   > **state.json**
   > <content>
   >
   > Proceed directly to the first pending phase.
