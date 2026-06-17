---
name: developer-breakdown-requirement
description: Break down a requirement into Jira tickets — accepts PRD, Figma UI stack, or other requirement sources, proposes a ticket breakdown for discussion and confirmation, writes approved tickets as local markdown files, and optionally pushes to Jira.
user-invocable: true
disable-model-invocation: true
allowed-tools: Agent, AskUserQuestion, Bash, WebFetch
---

## Routing Contract

This skill is a pure router. Its only permitted direct operations:
- `Bash` — run-dir creation only
- `WebFetch` — only for non-Figma, non-Confluence URLs passed as formal arguments
- `AskUserQuestion` — discussion and approval prompts defined in each step

Never read source files, search the codebase, or write ticket files directly. All fetching, analysis, and file writing is delegated to workers.

## Step 0 — Classify Inputs

Parse `$ARGUMENTS`. Collect:
- `parent_key` — Jira parent key: parent_key (e.g. `PROJ-1234`) for Stories/Tasks, or a Story/Task key (e.g. `PROJ-456`) for Sub-tasks
- `prd_source` — Confluence URL/ID, local `.md` path, or pasted text
- `figma_url` — optional Figma URL

If no arguments are provided, proceed with empty values — the breakdown worker will ask interactively.

For any generic (non-Figma, non-Confluence) URL in `prd_source`: fetch inline via `WebFetch` and store as `prd_content`. Otherwise pass `prd_source` raw to the worker.

## Step 1 — Create Run Directory

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
SLUG=$(echo "<parent_key>" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
run_dir="$(git rev-parse --show-toplevel)/.claude/agentic-state/developer/breakdown/${SLUG}-${TIMESTAMP}"
mkdir -p "$run_dir/tickets"
echo "$run_dir"
```

## Step 2 — Confirm Breakdown Strategy

Present the default strategy and ask the user to confirm or override before the worker begins.

Show inline:

```
Default breakdown strategy:

 1. State management — 1 ticket for all BLoC / ViewModel / Presenter + domain models, state classes, events
 2. Shared components — 1 ticket for all reusable widgets, design-system wrappers, cross-screen UI pieces
 3. Screens — 1 ticket per screen (UI, state-holder wiring, screen-specific components)
 4. Infrastructure — 1 ticket each for routing/DI setup, native iOS integration, native Android integration, etc.
```

Call `AskUserQuestion`:

```
question    : "Use this breakdown strategy?"
header      : "Strategy"
multiSelect : false
options     :
  - label: "Use default",  description: "Apply the strategy above"
  - label: "Custom",       description: "Describe your own grouping rules"
```

**Use default** → pass the strategy text to the worker as `breakdown_strategy`.

**Custom** → ask the user to describe their preferred grouping. Pass their description as `breakdown_strategy` instead.

## Step 3 — Analyze and Propose

Spawn `developer-prd-breakdown-worker`:

> parent_key: \<parent_key\>
> prd_source: \<prd_content if already fetched, otherwise raw prd_source\>
> figma_url: \<figma_url or "(none)"\>
> run_dir: \<run_dir\>
> breakdown_strategy: \<confirmed or custom strategy from Step 2\>

Wait for the worker to return a `## Breakdown Proposal` block. Extract:
- `tickets` — ordered list: `{ index, type, title, story_points, description, acceptance_criteria }`
- `summary` — N tickets | X SP string

## Step 4 — Discuss

Show the proposal table inline before calling `AskUserQuestion`:

```
Proposed breakdown: <summary>

 #   Type      SP   Title
─────────────────────────────────────────────────────
 1   Story      3   ...
 2   Task       2   ...
 ...
```

Call `AskUserQuestion`:

```
question    : "Does this breakdown look right?"
header      : "Ticket Breakdown"
multiSelect : false
options     :
  - label: "Approve",  description: "Write these as local markdown files"
  - label: "Adjust",   description: "Change scope, split, merge, or rename tickets"
  - label: "Cancel",   description: "Stop without writing anything"
```

**Approve** → proceed to Step 5.

**Cancel** → stop.

**Adjust** → ask the user to describe the changes. Re-spawn `developer-prd-breakdown-worker` with the original inputs plus:

> feedback: \<user's adjustment instructions\>
> previous_proposal: \<the previous ## Breakdown Proposal block verbatim\>

Return to top of Step 4 with the new proposal.

## Step 5 — Write Ticket Files

Read `ticket_count` from `tickets`. Extract `breakdown_level` from the `## Breakdown Proposal` header.

**If `ticket_count` ≤ 8** — spawn 1 `developer-ticket-write-worker`:

> run_dir: \<run_dir\>
> parent_key: \<parent_key\>
> prd_source: \<prd_source\>
> breakdown_level: \<breakdown_level\>
> tickets: \<full tickets list as JSON\>

**If `ticket_count` > 8** — spawn one `developer-ticket-write-worker` per ticket in parallel (single Agent tool call):

> run_dir: \<run_dir\>
> parent_key: \<parent_key\>
> prd_source: \<prd_source\>
> breakdown_level: \<breakdown_level\>
> tickets: \<single-element JSON array containing this ticket\>

Wait for all workers to confirm. Show written paths:

```
Written <N> ticket files to <run_dir>/tickets/

  TICKET-001.md — <title>
  TICKET-002.md — <title>
  ...
```

## Step 6 — Push to Jira (optional)

Call `AskUserQuestion`:

```
question    : "Push these tickets to Jira now?"
header      : "Jira"
multiSelect : false
options     :
  - label: "Yes",   description: "Create tickets under the parent_key via Atlassian MCP"
  - label: "Later", description: "Keep as local files — run /developer-jira-ticket when ready"
```

**Later** → show:

> Tickets saved. Run `/developer-jira-ticket` and pass the parent_key key and the local ticket files when ready.

**Yes** → spawn `developer-jira-ticket-worker` with:

> parent_key_key: \<parent_key\>
> prd_source: \<prd_source\>
> figma_links: \<figma_url, or omit if none\>
> breakdown: \<tickets formatted as breakdown lines: "- [TYPE] Title: N days"\>

The worker will interactively ask for any missing Jira connection details (cloud_id, project_key).
