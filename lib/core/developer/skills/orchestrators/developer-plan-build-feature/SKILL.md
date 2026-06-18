---
name: developer-plan-build-feature
description: Plan then build a feature — invokes /developer-plan-feature (figma fetch + convergence planning loop + approval), then on approval invokes /developer-build-feature to execute the approved plan.
user-invocable: true
disable-model-invocation: true
allowed-tools: Skill
---

## Routing Contract

This skill is a pure router — it only invokes other skills. It performs no direct operations.

## Step 1 — Plan

Invoke `/developer-plan-feature` via the Skill tool, passing `$ARGUMENTS` verbatim.

Wait for it to complete. Read the `## Plan Output` block from its output — extract `run_dir`.

If no `## Plan Output` is present (plan was discarded or canceled), stop.

## Step 2 — Build

Invoke `/developer-build-feature` via the Skill tool, passing `<run_dir>` as the argument.
