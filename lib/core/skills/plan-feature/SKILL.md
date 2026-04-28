---
name: plan-feature
description: Plan then build a feature — invokes feature-orchestrator in plan-first mode. Spawns feature-planner for a reviewable plan, then executes with feature-worker on approval.
allowed-tools: Agent
---

Spawn `feature-orchestrator` using the Agent tool with the following prompt:

> **Trigger: plan-first**
>
> Go directly to `feature-planner` — do not ask the user whether to plan or build. After the user approves the plan, read plan.md and context.md from the run directory, then spawn `feature-worker` with both injected inline.
