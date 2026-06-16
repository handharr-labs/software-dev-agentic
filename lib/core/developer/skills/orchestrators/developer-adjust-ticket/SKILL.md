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

### Step 2 — Gather and Collect Context (per ticket, sequential)

For each ticket, complete all three sub-steps before moving to the next ticket.

**2a. Read ticket** — spawn `developer-adjust-ticket-gather-worker`:

> Read ticket at: `<ticket_path>`

Collect the partial context block (TICKET_PATH, TICKET_ID, ACCEPTANCE_CRITERIA…END_AC).

**2b. Dynamic question loop** — gather session context using `AskUserQuestion`. Prefix every question header with `[<TICKET_ID>]`. Hard cap: **10 questions total**.

**Anchor questions** — always ask these first, in order:

1. `What progress was made this session?`
   Options: `"Partially implemented"`, `"Mostly implemented"`, `"Fully implemented"` — user may detail via Other.

2. `What is the current development status?`
   Options: `"In Progress"`, `"Ready for Review"`, `"Blocked"`, `"Done"`

3. `Which Acceptance Criteria were completed this session?`
   Description: list every AC item from step 2a so the user can reference them.
   Options: `"None"`, `"All"`, `"Some — list them (use Other)"`

**Follow-up loop** — after each answer (including anchor answers), evaluate the current context against all required fields (`PROGRESS`, `STATUS`, `COMPLETED_ITEMS`, `DECISIONS`, `OPEN_QUESTIONS`, `BUGS`). Ask one targeted follow-up if:

- A field is still unfilled **and** the session context makes it plausible (e.g. if progress mentions issues → ask about bugs; if status is `Blocked` → ask about open questions; if progress mentions tradeoffs → ask about decisions).
- An answer is too vague to fill its field reliably (e.g. "some things" as a progress answer → ask which components specifically).

**Do not** ask about a field if prior answers already imply its value (e.g. smooth progress with no issues mentioned → `BUGS: none`, no follow-up needed). Default unfilled optional fields to `"none"` if no follow-up is warranted.

**Terminate** when all required fields can be filled with reasonable confidence, or when the question count reaches 10 — whichever comes first.

**2c. Assemble context block** — combine the partial context from 2a with the answers from 2b into a full context block per the schema in `$CLAUDE_PLUGIN_ROOT/reference/developer/session-adjustment-format.md`.

### Step 3 — Write Sections (per ticket)

For each ticket, spawn `developer-adjust-ticket-write-worker` with:

- `ticket_path` — the ticket file path
- `context` — the full context block assembled in Step 2c
- `date` — today's date in ISO 8601

### Step 4 — Done

Report:
> "Done — Session Adjustment updated for <N> ticket(s): <list of ticket IDs>"
