---
name: feature-orchestrator
description: Build or update a feature across Clean Architecture layers. The agent decides whether to invoke feature-planner for a reviewable plan first, or proceed directly to worker execution.
allowed-tools: Agent
---

## Arguments

`$ARGUMENTS` — optional feature description provided at invocation time.

## Steps

Spawn `feature-orchestrator` with the following prompt:

> Feature description: <$ARGUMENTS>
>
> Before proceeding, check for an existing run or approved plan. If neither exists, ask the user: "Would you like to plan first (feature-planner) or build directly?" — then act accordingly.

If `$ARGUMENTS` is empty, pass an empty feature description — the agent will collect intake interactively.
