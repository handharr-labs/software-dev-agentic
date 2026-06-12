---
name: agentic-scaffold
description: Interactively design and scaffold a new agentic component — skill, worker, strategist, or persona. Scoped to creating new components only; use /agentic-consult for changes to existing ones. Runs agentic-scaffold-worker then verifies the output with agentic-arch-review-worker.
user-invocable: true
disable-model-invocation: true
tools: Agent
---

## Steps

### 1 — Scaffold

Spawn `agentic-scaffold-worker`. The worker gathers all intent interactively — pass no pre-filled arguments.

Validate: response must contain an `## Output` section with scaffolded file path(s) — STOP if missing.

### 2 — Verify

Spawn `agentic-arch-review-worker` with: `Scope: <each scaffolded file path>. Check convention compliance.`

- Clean → confirm component is convention-compliant
- Violations → list as residual with hint: run `/agentic-consult` to fix

### 3 — Report

Scaffold report + convention check result.
