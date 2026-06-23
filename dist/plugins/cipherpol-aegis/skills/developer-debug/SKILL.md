---
name: developer-debug
description: Trigger the developer-debug-strategist agent. Accepts an optional bug description, collects any missing intake (error message, expected vs actual behavior, entry point, platform), then hands off to the agent.
allowed-tools: Agent, AskUserQuestion
user-invocable: true
disable-model-invocation: false
---

## Arguments

`$ARGUMENTS` — optional bug description provided at invocation time.

## Steps

1. If `$ARGUMENTS` is non-empty, treat it as the initial bug description.

2. Collect any intake fields not covered by the description or visible context (e.g. open ticket). Ask only for what is missing — one question at a time:
   - Error message or stack trace (if not described)
   - Expected vs actual behavior (if not described)
   - Entry point — the action, method, or screen where the failure occurs (if not described)
   - Platform: `web`, `ios`, or `flutter` (if not described)
   - Target files or class names (if not already named in the description or ticket — skip this question if they are)
   - Available logs (paste any relevant log output, or "none" if unavailable)

3. Spawn `developer-debug-strategist` with all collected intake in the spawn prompt:

   > Bug description: <description>
   > Error message: <error>
   > Expected: <expected> / Actual: <actual>
   > Entry point: <entry-point>
   > Platform: <platform>
   > Target files: <comma-separated file paths or class names, or "unknown" if not identified>
   > Available logs: <pasted log output, or "none">
   > Investigation file: .claude/agentic-state/developer/debug/<timestamp>-<slug>.md

   The strategist must write or update the investigation file at `.claude/agentic-state/developer/debug/<timestamp>-<slug>.md` with its findings each round. Document format:

   ```bash
   cat "$CLAUDE_PLUGIN_ROOT/reference/developer/debug-investigation-format.md"
   ```

4. **Convergence loop** — repeat until the strategist returns `root_cause` and `fix_recommendation`:

   a. Ask the user whether to add debug logs to verify and reproduce the bug:
      - **Yes** — spawn `developer-debug-log-worker` with the strategist's output and collected intake to instrument the entry point
      - **No** — skip to step 4c

   b. Ask the user to reproduce the bug and paste the new logs collected after instrumentation.

   c. Re-spawn `developer-debug-strategist` with the updated logs and the path to the investigation file so it can build on prior findings.

   d. If the strategist output contains `root_cause` and `fix_recommendation` — exit the loop and surface both to the user. Otherwise return to 4a.

5. End the skill. The investigation file at `.claude/agentic-state/developer/debug/<timestamp>-<slug>.md` is the durable record of the session.
