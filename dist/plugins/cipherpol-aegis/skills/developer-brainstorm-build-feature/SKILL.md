---
name: developer-brainstorm-build-feature
description: Brainstorm then build a feature — invokes /developer-brainstorming (explore context + clarify + design + spec approval), then on approval invokes /developer-build-feature to execute against the written spec.
user-invocable: true
disable-model-invocation: true
allowed-tools: Skill
---

## Routing Contract

This skill is a pure router — it only invokes other skills. It performs no direct operations.

## Step 1 — Brainstorm

Invoke `/developer-brainstorming` via the Skill tool, passing `$ARGUMENTS` verbatim.

Wait for it to complete. Read the `## Brainstorm Output` block from its output — extract `spec_path`.

If no `## Brainstorm Output` is present (brainstorming was canceled or the user chose a non-feature execution path), stop.

## Step 2 — Build

Invoke `/developer-build-feature` via the Skill tool, passing `<spec_path>` as the argument.
