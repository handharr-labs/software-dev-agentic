---
name: developer-groom-ticket
description: Consult on a locally fetched Jira ticket — drives a back-and-forth discussion to clarify the problem statement, identify work items, surface decisions and open questions, then updates the ticket via developer-adjust-ticket. Run before /developer-plan-feature or /developer-plan-build-feature.
user-invocable: true
disable-model-invocation: true
allowed-tools: Agent, AskUserQuestion, Read, Bash
---

## Arguments

`$ARGUMENTS` — optional path to the local ticket `.md` file.

## Preflight — Resolve Thinker Model

```bash
echo "$CIPHERPOL_THINKER_MODEL"
```

If the value is `cost-saving`, the `Agent` spawn of `developer-groom-strategist` in Step 3 must pass `model: sonnet` as an override. Otherwise (unset, `optimized`, or any other value), omit the `model` parameter — the agent uses its frontmatter default (`opus`).

## Step 1 — Resolve Ticket Path

If `$ARGUMENTS` is provided, use it as the ticket path.

If `$ARGUMENTS` is empty, call `AskUserQuestion`:

```
question    : "What is the path to your local ticket file? (e.g. /path/to/TICKET-123.md)"
header      : "Ticket path"
multiSelect : false
options     :
  - label: "Enter path", description: "Provide the absolute path to the ticket .md file"
```

Verify the file exists before continuing. If it does not exist, report the path and stop.

## Step 2 — Bug Detection Gate

Read the ticket file. If the ticket type, title, or description indicates a bug (e.g. type is "Bug", title contains "fix", "broken", "error", "crash", description contains error messages or stack traces), surface a routing question via `AskUserQuestion`:

```
question    : "This ticket looks like a bug report. Would you like to start a debug investigation instead of grooming?"
header      : "Bug detected"
multiSelect : false
options     :
  - label: "Start debugging",    description: "Route to /developer-debug with this ticket's context"
  - label: "Continue grooming",  description: "Proceed with ticket consultation as normal"
```

**Start debugging** → invoke `developer-debug` with the bug description extracted from the ticket (title + description + error messages). Once `developer-debug` completes (returns `root_cause` and `fix_recommendation`), proceed to Step 3 — pass the debug findings as additional context to the strategist so the consultation loop can incorporate them.

**Continue grooming** → proceed to Step 3.

If the ticket does not look like a bug, skip this step entirely.

## Step 3 — Consultation Loop

Spawn `developer-groom-strategist` with the ticket path and any debug findings:

> **ticket-path:** <resolved absolute path>
>
> <if debug findings exist from Step 2:>
> **Debug Findings:**
> Root cause: <root_cause from developer-debug>
> Fix recommendation: <fix_recommendation from developer-debug>
> Investigation file: <path to the investigation .md>

The strategist reads the ticket and codebase, then returns a `Decision: discuss` block containing a `summary` (what it understands so far) and `questions` (what needs clarification).

Surface the strategist's output to the user via `AskUserQuestion`:

```
question    : "<strategist summary>

               Questions:
               <for each question: "• <question>">

               How would you like to proceed?"
header      : "Discussion"
multiSelect : false
options     :
  - label: "Answer above",  description: "Provide answers or clarifications"
  - label: "Wrap up",       description: "Problem statement and work items are clear — produce final summary"
```

**Answer above** → the user types clarifications. Re-spawn `developer-groom-strategist` with the original prompt **plus** all prior discussion context and the user's new answers appended. Do NOT use `SendMessage` — each round is a fresh agent spawn. Loop continues.

**Wrap up** → re-spawn `developer-groom-strategist` one final time with mode `summarize` and the full discussion history. The strategist returns a `Decision: summarize` block containing the grooming summary. Surface it to the user for confirmation:

```
question    : "<grooming summary>

               Does this capture the problem and work items correctly?"
header      : "Confirm"
multiSelect : false
options     :
  - label: "Looks good",       description: "Finalize and update the ticket"
  - label: "Needs adjustment", description: "Continue discussing — something is off"
```

**Looks good** → proceed to Step 4.

**Needs adjustment** → the user provides corrections. Return to the consultation loop — re-spawn the strategist in default mode with the full context plus corrections.

### Context Relay Between Rounds

Each re-spawn must include the **full discussion history** so the strategist has continuity:

```
ticket-path: <resolved absolute path>

Discussion history:
---
Round 1 — Strategist:
<strategist output from round 1>

Round 1 — User:
<user response from round 1>
---
Round 2 — Strategist:
<strategist output from round 2>

Round 2 — User:
<user response from round 2>
---
...

Latest user input:
<current user response>
```

## Step 4 — Update Ticket

Once the user confirms, invoke `developer-adjust-ticket` directly with the ticket path — pass the converged grooming summary as session context so the skill can write the Session Adjustment section without asking the user again.
