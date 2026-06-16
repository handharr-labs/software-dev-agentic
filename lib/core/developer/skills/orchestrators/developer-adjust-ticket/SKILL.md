---
name: developer-adjust-ticket
description: Adjust one or more locally fetched Jira ticket files based on session discussion. Gathers context per ticket then writes the Session Adjustment section for each.
user-invocable: true
disable-model-invocation: true
allowed-tools: Agent, AskUserQuestion
---

## Arguments

`$ARGUMENTS` — optional. One or more absolute paths to local ticket `.md` files, space-separated.

## Steps

### Step 1 — Collect Ticket Paths

If `$ARGUMENTS` is provided, parse paths from it.

Otherwise, ask:
> "How many tickets did you work on this session?"

Then for each ticket (1..N), ask:
> "Path to ticket <N>? (e.g. /path/to/TICKET-123.md)"

Verify each path exists before continuing. Report any missing paths and stop.

### Step 2 — Gather Context (sequential)

For each ticket path, spawn `developer-adjust-ticket-gather-worker`:

> Gather session context for ticket at: `<ticket_path>`

Collect the structured context block from each. Do **not** spawn the next gather worker until the previous one completes — each worker asks the user questions interactively.

### Step 3 — Write Sections (per ticket)

For each ticket, spawn `developer-adjust-ticket-write-worker` with:

- `ticket_path` — the ticket file path
- `context` — the structured context block from Step 2
- `date` — today's date in ISO 8601

### Step 4 — Done

Report:
> "Done — Session Adjustment updated for <N> ticket(s): <list of ticket IDs>"
