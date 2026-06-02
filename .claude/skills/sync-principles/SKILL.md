---
name: sync-principles
description: Sync internal agents and skills after core-design-principles.md is updated — diffs the principles doc, collects internal files, and spawns principles-sync-worker to apply targeted updates.
user-invocable: true
tools: Bash, Glob, Agent
---

## Steps

### 1 — Get the diff

Run:
```bash
git diff HEAD -- docs/principles/core-design-principles.md
```

If empty (change already committed), run:
```bash
git diff HEAD~1 HEAD -- docs/principles/core-design-principles.md
```

If still empty, ask the user: "What changed in core-design-principles.md? Describe the principle(s) that were added, removed, or modified."

### 2 — Collect internal files

Glob the following:
- `.claude/agents/*.md` — all internal agent files
- `.claude/skills/*/SKILL.md` — all internal skill files

### 3 — Spawn sync worker

Spawn `principles-sync-worker` with:

```
Diff:
<diff from step 1 or user description>

Files to check:
<list from step 2, one path per line>
```

### 4 — Report

Surface the worker's output as-is — it includes what was changed and what was left untouched.
