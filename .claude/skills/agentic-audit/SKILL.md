---
name: agentic-audit
description: Audit structural integrity and convention compliance of any agentic component — agents, skills, orchestrators, personas, hooks, or MCPs. Runs agentic-audit-worker and agentic-arch-review-worker in parallel, then compiles results.
user-invocable: true
disable-model-invocation: true
tools: Agent, AskUserQuestion
---

## Arguments

```
/agentic-audit [scope]
```

- `scope` — optional. A persona name (`developer`, `debugger`, `tracker`, `auditor`), a file path, a component type (`hooks`, `mcps`), or `full`. If omitted, ask the user.

## Steps

### 1 — Resolve scope

If `scope` was not provided, ask:

> "What scope to audit? Options: persona name (`developer`, `debugger`, `tracker`, `auditor`, `installer`), a specific file path, component type (`hooks`, `mcps`), or `full`."

### 2 — Run in parallel

Spawn both workers simultaneously — do not wait for one before starting the other:

- `agentic-audit-worker` with: `Scope: <scope>. Check structural integrity only.`
- `agentic-arch-review-worker` with: `Scope: <scope>. Check convention compliance only.`

### 3 — Validate

Before compiling:
- Does each response contain findings or an explicit PASS? — STOP and report if either returned no output.

### 4 — Report

```
## Agentic Audit — <scope>

### Structural Integrity (agentic-audit-worker)
<findings>

### Convention Compliance (agentic-arch-review-worker)
<findings>

### Routing
[BROKEN reference] → /agentic-scaffold to create the missing component
[CRITICAL/WARNING violation] → /agentic-consult to fix the violation
```
