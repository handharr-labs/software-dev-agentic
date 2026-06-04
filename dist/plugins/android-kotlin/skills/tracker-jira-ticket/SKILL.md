---
name: tracker-jira-ticket
description: Create Jira tickets under an epic from a platform breakdown list — fetches PRD and optional Figma context, generates requirement-focused descriptions, and creates tickets via Atlassian MCP.
user-invocable: true
allowed-tools: Agent
---

## Arguments

`$ARGUMENTS` — optional. Pass epic key, PRD source, and/or breakdown inline. If omitted, the worker will ask interactively.

## Steps

Spawn `tracker-jira-ticket-worker` with:

> <$ARGUMENTS>
