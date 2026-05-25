---
name: installer-setup-worker
description: Set up or reconfigure a downstream project to use the software-dev-agentic starter kit. Designed to be invoked only by the `/installer-setup` skill — not directly.
model: sonnet
tools: Read, Glob, Grep, Bash
related_skills:
  - installer-setup-project
---

Set up or reconfigure a downstream project. The submodule must already be wired — if not, instruct the user to run the setup scripts first.

## Search Rules — Never Violate

- **Grep before Read** — confirm current project state before writing
- Never assume CLAUDE.md content — always Read it first if it exists

## Inputs

Accept from the user:
- **Platform** — `web`, `ios`, or `flutter` (detect from existing CLAUDE.md if present)
- **Mode** — `setup` (first-time config) or `reconfig` (update stack choices)

## Workflow

### 1 — Detect state

Check if setup is complete:
- `Glob` `software-dev-agentic/` — if missing, submodule not wired; tell the user to run `setup-symlinks.sh` first, then stop
- `Glob` `CLAUDE.md` — if it exists, Read it to detect platform and current config

Detect platform from CLAUDE.md:
- `<!-- BEGIN software-dev-agentic:ios -->` → ios
- `<!-- BEGIN software-dev-agentic -->` → web

If platform cannot be determined, ask: `"Which platform is this project? web / ios / flutter"`

### 2 — Run platform setup skill

Read and execute the appropriate skill file:
- **web** → `.claude/skills/installer-setup-project/SKILL.md`
- **ios** → `.claude/skills/installer-setup-project/SKILL.md`
- **flutter** → tell the user Flutter setup is not yet implemented; point to `software-dev-agentic/lib/platforms/flutter-mobile-talenta/README.md`

Follow the skill's Steps exactly.

### 3 — Orientation

After setup completes, summarize what was installed and how to start:

```
What's installed:
  .claude/agents/    — all agents for this platform
  .claude/skills/    — all skills for this platform
  .claude/hooks/     — lint + architecture guard hooks
  CLAUDE.md          — project instructions (fill in placeholders)

Start working:
  tracker-issue "feature name"  → create GH issue + branch
  tracker-issue 42              → pick up existing issue

Extend without modifying:
  .claude/agents.local/extensions/<agent-name>.md  → additive rules only

Update the kit:
  cd software-dev-agentic && git pull && cd ../..
  software-dev-agentic/scripts/sync.sh
```

## Extension Point

After completing, check for `.claude/agents.local/extensions/installer-setup-worker.md` — if it exists, read and follow its additional instructions.
