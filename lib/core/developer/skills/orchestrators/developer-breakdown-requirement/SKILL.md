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
- `AskUserQuestion` — discussion and approval prompts defined in each step

Never read source files, fetch URLs directly, search the codebase, or write ticket files. All fetching, analysis, and file writing is delegated to workers.

## Step 0 — Classify Inputs

Parse `$ARGUMENTS`. Collect:
- `parent_key` — Jira issue key or URL (e.g. `PROJ-1234` or `https://*.atlassian.net/browse/PROJ-1234`)
- `prd_source` — Confluence URL/ID, Jira URL/key, generic URL, local `.md` path, or pasted text
- `figma_url` — optional Figma URL
- `figma_fetch_dir` — optional path to an existing figma fetch directory (from `/developer-fetch-figma`)

If no arguments are provided, ask interactively:

```
question    : "What are the inputs for this breakdown?"
header      : "Inputs"
multiSelect : false
options     :
  - label: "Provide now",  description: "I'll give you the parent key and PRD source"
  - label: "Skip",         description: "Proceed with no pre-loaded context"
```

## Step 0a — Resolve Sources

Spawn **two** `developer-doc-resolve-worker` agents in parallel (single Agent tool call) — one for `parent_key`, one for `prd_source`. Skip a worker if the corresponding input is empty.

**parent_key worker:**
> source: \<parent_key\>
> purpose: parent_key

**prd_source worker:**
> source: \<prd_source\>
> purpose: prd_source

Read each `## Doc Resolve Result` or `## Doc Resolve Error` block:

- `parent_key` result: extract `resolved_key` (use as the canonical `parent_key` going forward) and note `title`. If it returned a Jira issue, store the `content` as `parent_context` — pass to the breakdown worker as supplementary context.
- `prd_source` result: store `content` as `prd_content` — this is the resolved PRD text passed to the breakdown worker.

**If either worker returns `## Doc Resolve Error`:**

Call `AskUserQuestion` once per failed source:

```
question    : "Could not fetch <source> (<error>). How would you like to provide this?"
header      : "Fetch Failed"
multiSelect : false
options     :
  - label: "Paste content",     description: "I'll paste the text directly"
  - label: "Provide new URL",   description: "Try a different URL or path"
  - label: "Skip",              description: "Proceed without this source"
```

- **Paste content** → collect pasted text, use as `prd_content` / `parent_key`.
- **Provide new URL** → collect new URL or path, re-spawn `developer-doc-resolve-worker` once. If it fails again, offer Paste or Skip only.
- **Skip** → proceed without that source.

## Step 0c — Optional Figma Fetch

Skip this step if `figma_fetch_dir` is already provided.

Call `AskUserQuestion`:

```
question    : "Do you want to include Figma designs in this breakdown?"
header      : "Figma"
multiSelect : false
options     :
  - label: "Yes — I have a fetch dir",  description: "I already ran /developer-fetch-figma and have a figma_fetch_dir path"
  - label: "No",                        description: "Proceed with requirement docs only"
```

**No** → set `figma_fetch_dir = "(none)"` and continue.

**Yes — I have a fetch dir** → ask: `"Paste the figma_fetch_dir path."` Collect the reply as `figma_fetch_dir` and continue.

> If you haven't fetched Figma frames yet, run `/developer-fetch-figma <url>` first — it outputs a `figma_fetch_dir` path you can pass back here.

## Step 0b — Confirm Breakdown Level

Call `AskUserQuestion`:

```
question    : "What is <parent_key><if title is known: ' — <title>'>? This determines the ticket format produced."
header      : "Breakdown Level"
multiSelect : false
options     :
  - label: "Epic",          description: "Breaking an Epic into Stories / Tasks — each ticket gets a full System Design section"
  - label: "Story / Task",  description: "Breaking a Story or Task into Sub-tasks — each ticket gets a System Context pointer to the parent"
```

Store the answer as `breakdown_level`:
- **Epic** → `breakdown_level = epic_to_tickets`
- **Story / Task** → `breakdown_level = ticket_to_subtasks`

Pass `breakdown_level` to the breakdown worker in Step 3 and to all write workers in Step 5. The breakdown worker must not re-infer it — use the confirmed value.

## Step 1 — Create Run Directory

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
SLUG=$(echo "<parent_key>" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
run_dir="$(git rev-parse --show-toplevel)/.claude/agentic-state/developer/breakdown/${SLUG}-${TIMESTAMP}"
mkdir -p "$run_dir/tickets"
echo "$run_dir"
```

## Step 2 — Confirm Breakdown Strategy

Present the default strategy for the confirmed `breakdown_level` and ask the user to confirm or override.

**If `breakdown_level = epic_to_tickets`**, show:

```
Default breakdown strategy (Epic → Stories / Tasks):

 1. State management — 1 ticket for all BLoC / ViewModel / Presenter + domain models, state classes, events
 2. Shared components — 1 ticket for all reusable widgets, design-system wrappers, cross-screen UI pieces
 3. Screens — 1 ticket per screen (UI, state-holder wiring, screen-specific components)
 4. Infrastructure — 1 ticket each for routing/DI setup, native iOS integration, native Android integration, etc.
```

**If `breakdown_level = ticket_to_subtasks`**, show:

```
Default breakdown strategy (Story / Task → Sub-tasks):

 1. Domain models — 1 sub-task for entities, DTOs, request/response types
 2. Repository + data source — 1 sub-task for interface, impl, remote/local data sources, mappers
 3. State management — 1 sub-task for BLoC / ViewModel / Presenter + state classes + events
 4. Shared components — 1 sub-task for reusable widgets and design-system wrappers scoped to this ticket
 5. Screens — 1 sub-task per screen (UI widget, state-holder wiring, screen-specific components)
 6. Routing / DI — 1 sub-task for route registration and dependency injection wiring
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

> parent_key: \<resolved parent_key\>
> breakdown_level: \<breakdown_level confirmed in Step 0b\>
> prd_source: \<prd_content — resolved plain text from Step 0a\>
> parent_context: \<parent_context from Step 0a, or "(none)"\>
> figma_url: \<figma_url or "(none)"\>
> figma_fetch_dir: \<figma_fetch_dir or "(none)"\>
> run_dir: \<run_dir\>
> breakdown_strategy: \<confirmed or custom strategy from Step 2\>

Wait for the worker to return a `## Breakdown Proposal` block. Extract:
- `tickets` — ordered list: `{ index, type, title, story_points, description, system_design, system_context, acceptance_criteria }`
- `summary` — N tickets | X SP string
- `breakdown_level` — carried through from the proposal header (must match Step 0b value)

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
