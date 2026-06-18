---
name: developer-build-from-ticket
description: One-shot feature build from a Jira ticket. Non-interactive — designed for remote AI tools (CI job, API caller). Pass a Jira ticket key or URL as the only argument. Fetches the ticket, derives planning inputs, runs the convergence planning loop automatically, builds, then cleans up run state.
allowed-tools: Bash, Read, Agent
user-invocable: true
disable-model-invocation: true
---

## Prerequisites

Requires a Jira MCP server configured in the session. Supported: `getJiraIssue` (official Atlassian MCP) or `mmpa_get_jira` (mmpa). If neither is available, stop immediately with a clear message.

## Arguments

`$ARGUMENTS` — Jira ticket key or URL (required). Example: `PROJ-123` or `https://company.atlassian.net/browse/PROJ-123`.

## Step 1 — Validate and Clear Previous Errors

If `$ARGUMENTS` is empty, write the error file and stop:

```bash
git rev-parse --show-toplevel
# write to <root>/.claude/agentic-state/developer/feature-plans/error.md
```

```
# Error: Missing Argument

developer-build-from-ticket requires a Jira ticket key or URL.
Usage: /developer-build-from-ticket PROJ-123
```

Otherwise clear any stale error from a previous run:

```bash
rm -f "$(git rev-parse --show-toplevel)/.claude/agentic-state/developer/feature-plans/error.md"
```

## Step 2 — Fetch Ticket

Use the available Jira MCP tool to fetch the ticket key extracted from `$ARGUMENTS`. Prefer in order: `getJiraIssue`, `mmpa_get_jira`.

Extract:
- `summary` — ticket title
- `description` — full body
- `issuetype` — Bug, Story, Task, etc.
- `labels` and `components` — used to detect platform and module
- Acceptance criteria — look for `## AC`, `## Acceptance Criteria`, or `h2. AC` sections in description

## Step 3 — Fail Fast on Thin Tickets

If description is empty **and** no acceptance criteria can be found, write `error.md` and stop:

```
# Error: Insufficient Ticket Content

Ticket: <key> — <summary>

Could not derive operations or scope. The ticket description must include one of:
- A `## AC` or `## Acceptance Criteria` section listing what the feature does
- Explicit HTTP operation keywords (GET, POST, PUT, DELETE, list, create, update, delete)

Add the missing content to the Jira ticket and retry.
```

## Step 4 — Derive Planning Inputs

Inline — do not spawn an agent for this:

| Input | Rule |
|---|---|
| `feature` | Jira key + slugified summary, lowercased, hyphens. Example: `proj-123-user-profile` |
| `new-or-update` | `issuetype == Bug` or summary contains fix/update/change/modify → `update`; otherwise → `new` |
| `operations` | Scan AC + description for GET/list, GET/single, POST/create, PUT/update, DELETE. Default to all when ambiguous. |
| `separate-ui-layer` | Detect from labels or components (ios/android/flutter → `true`; web → `false`). Default `true`. |
| `platform` | Detect from labels, components, or project key prefix. Required — if undetectable, write `error.md` and stop. |

Hold the derived `feature` value — it is used verbatim in the cleanup step.

## Step 5 — Gather Intent (Non-Interactive)

Spawn `developer-feature-intent-strategist` with mode `gather-intent-prefilled`:

> **Mode: gather-intent-prefilled**
>
> **Pre-filled intent (do not ask for any of these):**
> - feature: `<derived feature name>`
> - new-or-update: `<new|update>`
> - operations: `<comma-separated list>`
> - separate-ui-layer: `<true|false>`
> - platform: `<platform>`
>
> **Ticket context (use for artifact naming and Risks/Notes):**
> <description>
>
> **Acceptance criteria:**
> <extracted AC block, or "None found — derive from description.">

Wait for `Decision: spawn-planners`. Initialize:
- `visited` = []
- `all_findings` = []
- `round` = 1

## Step 6 — Planning Convergence Loop (Automated)

Repeat until `Decision: converged` or `Decision: blocked`.

### 6a — Spawn planners for this round

Spawn each planner listed in the `Decision: spawn-planners` block **in parallel**. Pass feature name, platform, module-path to each.

Add spawned layers to `visited`. Append findings to `all_findings`.

### 6b — Send findings to strategist

Spawn `developer-feature-convergence-strategist`:

> **Mode: process-findings**
>
> Round: <N>
> Visited layers: <comma-separated>
>
> **Accumulated Findings:**
> <all_findings content>

- `Decision: spawn-planners` → increment `round`, go to 6a
- `Decision: synthesized` → plan.md and context.md are already written; extract `run_dir`, skip Step 7, proceed directly to Step 8
- `Decision: blocked` → write `error.md` with the blocked question and stop:

```
# Error: Planning Blocked

<question from Decision: blocked>

Resolve the ambiguity in the Jira ticket and retry.
```

**Max rounds guard:** If `round` reaches 4, write `error.md` and stop:

```
# Error: Planning Did Not Converge

Planning could not converge after 3 rounds. Add more detail to the Jira ticket and retry.
```

## Step 7 — Synthesize Plan (fallback only)

> **When reached:** This step is not reached in the normal convergence path — `Decision: synthesized` from 6b means plan.md and context.md are already on disk and synthesis happened inline within the strategist.

## Step 8 — Execute

Update `status` in `plan.md` frontmatter from `pending` to `approved`.

Read `plan.md` and `context.md` from `run_dir` (extracted in Step 6b). Then spawn `developer-feature-worker`:

> Approved plan ready. Pre-loaded context below — do not re-read plan.md, context.md, or state.json.
>
> **plan.md**
> <content>
>
> **context.md**
> <content>
>
> Proceed directly to the first pending artifact.

## Step 9 — Cleanup

After `developer-feature-worker` completes (success or unrecoverable error):

```bash
rm -rf "$(git rev-parse --show-toplevel)/.claude/agentic-state/developer/feature-plans/<feature>"
rm -f "$(git rev-parse --show-toplevel)/.claude/agentic-state/developer/feature-plans/error.md"
```
