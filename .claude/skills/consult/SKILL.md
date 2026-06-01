---
name: consult
description: Consult on a persona, agent, or skill structure — for adjustments, refactors, goal changes, or design confusion. Invokes agent-consult-worker which reads current state, asks about intent, and delivers a concrete recommendation with a handoff to the right tool.
user-invocable: true
tools: Agent
---

## Arguments

```
/consult [subject]
```

- `subject` — optional. A persona name (`developer`, `debugger`), a file path, or a plain description of the area. If omitted, the worker will ask.

## Steps

Invoke `agent-consult-worker` now.

If `subject` was provided, pass it in the spawn prompt: `Subject: <subject>.`
If omitted, pass no arguments — the worker will ask interactively starting at Step 1.
