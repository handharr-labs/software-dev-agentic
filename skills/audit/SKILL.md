---
name: audit
description: Audit the structural integrity of a persona, agent, or skill — verifies that referenced skills, agents, hook scripts, and reference docs exist on disk. Invokes agent-audit-worker.
user-invocable: true
tools: Agent
---

## Arguments

Parse the user's invocation:

```
/audit [scope]
```

- `scope` — optional. A persona name (`builder`, `detective`), a file path, or `full`. If omitted, the agent will ask.

## Steps

1. Invoke the `agent-audit-worker` agent.
2. If `scope` was provided, pass it in the spawn prompt: `Audit scope: <scope>.`
3. If omitted, pass no arguments — the agent will ask interactively.
