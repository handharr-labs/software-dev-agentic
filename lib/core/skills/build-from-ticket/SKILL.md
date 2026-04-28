---
name: build-from-ticket
description: One-shot feature build from a Jira ticket. Non-interactive — designed for remote AI tools (CI job, API caller). Pass a Jira ticket key or URL as the only argument. Fetches the ticket, derives planning inputs, plans, builds, then cleans up run state.
allowed-tools: Bash, Read, Agent
user-invocable: true
---

## Prerequisites

Requires a Jira MCP server configured in the session. Supported: `getJiraIssue` (official Atlassian MCP) or `mmpa_get_jira` (mmpa). If neither is available, stop immediately with a clear message.

## Arguments

`$ARGUMENTS` — Jira ticket key or URL (required). Example: `PROJ-123` or `https://company.atlassian.net/browse/PROJ-123`.

## Steps

### 1. Validate and Clear Previous Errors

If `$ARGUMENTS` is empty, write the error file and stop:

```bash
git rev-parse --show-toplevel
# write to <root>/.claude/agentic-state/runs/error.md
```

```
# Error: Missing Argument

build-from-ticket requires a Jira ticket key or URL.
Usage: /build-from-ticket PROJ-123
```

Otherwise, clear any stale error from a previous run before proceeding:

```bash
rm -f "$(git rev-parse --show-toplevel)/.claude/agentic-state/runs/error.md"
```

### 2. Fetch Ticket

Use the available Jira MCP tool to fetch the ticket key extracted from `$ARGUMENTS`. Prefer in order: `getJiraIssue` (official Atlassian MCP), `mmpa_get_jira` (mmpa) — use whichever is present in the session.

Extract:
- `summary` — ticket title
- `description` — full body
- `issuetype` — Bug, Story, Task, etc.
- `labels` and `components` — used to detect platform and module
- Acceptance criteria — look for `## AC`, `## Acceptance Criteria`, or `h2. AC` sections in description

### 3. Fail Fast on Thin Tickets

If description is empty **and** no acceptance criteria can be found:

```bash
git rev-parse --show-toplevel
# write to <root>/.claude/agentic-state/runs/error.md
```

```
# Error: Insufficient Ticket Content

Ticket: <key> — <summary>

Could not derive operations or scope. The ticket description must include one of:
- A `## AC` or `## Acceptance Criteria` section listing what the feature does
- Explicit HTTP operation keywords (GET, POST, PUT, DELETE, list, create, update, delete)

Add the missing content to the Jira ticket and retry.
```

Then stop.

### 4. Derive Planning Inputs

Inline — do not spawn an agent for this:

| Input | Rule |
|---|---|
| `feature` | Jira key + slugified summary, lowercased, hyphens. Example: `proj-123-user-profile` |
| `new-or-update` | `issuetype == Bug` or summary contains fix/update/change/modify → `update`; otherwise → `new` |
| `operations` | Scan AC + description for GET/list, GET/single, POST/create, PUT/update, DELETE. Default to all when ambiguous. |
| `separate-ui-layer` | Detect from labels or components (ios/android/flutter → `true`; web → `false`). Default `true`. |
| `platform` | Detect from labels, components, or project key prefix. Required — if undetectable, write `error.md` and stop. |

Hold the derived `feature` value — it is used verbatim in the cleanup step.

### 5. Spawn `auto-feature-planner`

Use the Agent tool. Inject the structured intent block and ticket context:

> **Jira ticket:** `<key>` — `<summary>`
>
> **Pre-filled intent (do not ask for any of these):**
> - feature: `<derived feature name>`
> - new-or-update: `<new|update>`
> - operations: `<comma-separated list>`
> - separate-ui-layer: `<true|false>`
> - platform: `<platform>`
>
> **Ticket context for planning:**
> <description>
>
> **Acceptance criteria:**
> <extracted AC block, or "None found — derive from description.">
>
> Treat all inputs as final. Auto-approve after writing plan.md and context.md.

### 6. Locate Run Directory

```bash
ls -t "$(git rev-parse --show-toplevel)/.claude/agentic-state/runs"/*/context.md 2>/dev/null | head -1
```

If not found, write `error.md` and stop:

```
# Error: Planner Produced No Plan

auto-feature-planner did not write context.md. Check the ticket content and retry.
Jira ticket: <key> — <summary>
```

### 7. Read Plan and Context

Read `plan.md` then `context.md` from the resolved run directory. Two reads, each once only.

### 8. Spawn `feature-worker`

Use the Agent tool with plan and context injected inline:

> Approved plan ready. Pre-loaded context below — do not re-read plan.md, context.md, or state.json.
>
> **plan.md**
> <content>
>
> **context.md**
> <content>
>
> Proceed directly to the first pending artifact.

### 9. Cleanup

After feature-worker completes (success or unrecoverable errors), delete the run directory using the `feature` name derived in step 4:

```bash
rm -rf "$(git rev-parse --show-toplevel)/.claude/agentic-state/runs/<feature>"
rm -f "$(git rev-parse --show-toplevel)/.claude/agentic-state/runs/error.md"
```
