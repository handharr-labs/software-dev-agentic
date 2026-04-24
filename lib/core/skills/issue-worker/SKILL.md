---
name: issue-worker
description: Create or pick up a GitHub Issue — opens the issue, creates a branch, and updates the local backlog.
allowed-tools: Agent
---

## Arguments

`$ARGUMENTS` — issue title (new issue) or issue number (pick up existing).

## Steps

Spawn `issue-worker` using the Agent tool with:

> <$ARGUMENTS>
