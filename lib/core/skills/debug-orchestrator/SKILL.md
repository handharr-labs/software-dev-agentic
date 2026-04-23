---
name: debug-orchestrator
description: Trigger the debug-orchestrator agent. Accepts an optional bug description, collects any missing intake (error message, expected vs actual behavior, entry point, platform), then hands off to the agent.
allowed-tools: Agent, AskUserQuestion
---

## Arguments

`$ARGUMENTS` — optional bug description provided at invocation time.

## Steps

1. If `$ARGUMENTS` is non-empty, treat it as the initial bug description.

2. Collect any intake fields not covered by the description. Ask only for what is missing — one question at a time:
   - Error message or stack trace (if not described)
   - Expected vs actual behavior (if not described)
   - Entry point — the action, method, or screen where the failure occurs (if not described)
   - Platform: `web`, `ios`, or `flutter` (if not described)

3. Spawn `debug-orchestrator` with all collected intake in the spawn prompt:

   > Bug description: <description>
   > Error message: <error>
   > Expected: <expected> / Actual: <actual>
   > Entry point: <entry-point>
   > Platform: <platform>
