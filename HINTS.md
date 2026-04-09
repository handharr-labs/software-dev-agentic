# Hints — How to Use This Starter Kit

## What's Inside

| | Count |
|--|-------|
| Architecture docs (`reference/`) | 16 |
| Orchestrators (`agents/`) | 2 |
| Workers (`agents/`) | 6 |
| Skills — Type A, Internal (`skills/`) | 18 |
| Skills — Type B, User-triggered (`skills/`) | 4 |
| Hooks (`hooks/`) | 3 (impl import guard, lint on edit, use server warn) |
| `settings-template.json` | Base settings with hooks wired |
| Entry point | `README.md` |

---

## Starting a New Project

**Step 1 — Wire as a submodule**

```bash
git submodule add https://github.com/handharr-labs/web-agentic .claude/web-agentic
cd .claude
ln -s web-agentic/agents     agents
ln -s web-agentic/docs       docs
ln -s web-agentic/hooks      hooks
ln -s web-agentic/reference  reference
ln -s web-agentic/skills     skills
cd ..
chmod +x .claude/web-agentic/hooks/*.sh
cp .claude/web-agentic/settings-template.json .claude/settings.local.json
```

Or: open Claude Code in the new project and run `/setup-nextjs-project`.

**Step 2 — Copy and fill in CLAUDE.md**

```bash
cp .claude/web-agentic/CLAUDE-template.md CLAUDE.md
```

Replace every `[placeholder]` in CLAUDE.md.

**Step 3 — Say what you want**

Describe intent in natural language — Claude routes to the right agent:

> "Set up the project scaffold" → reads README.md and follows the AI Project Setup flow
> "Create the leave request feature" → `feature-orchestrator`
> "Add an entity for Employee" → `domain-worker`

---

## How Routing Works

Users describe intent. Claude matches to the right agent by description. No slash commands needed for building features.

```
"build the leave request feature"
  → feature-orchestrator
      → domain-worker (entity + repo + use cases)
      → data-worker (DTO + mapper + datasource + repo impl)
      → presentation-worker (ViewModel + View + DI wiring)
```

---

## Agent Hierarchy

```
Orchestrators (coordinate)
  feature-orchestrator  ← full feature, all layers
  backend-orchestrator  ← full-stack backend only

Workers (execute)
  domain-worker         ← entities, use cases, repository interfaces
  data-worker           ← DTOs, mappers, data sources, repo impls
  presentation-worker   ← ViewModel hooks, Views, Server Actions, DI
  test-worker           ← tests for any layer
  arch-review-worker    ← architecture audit
  debug-worker          ← error tracing
```

---

## User-Triggered Skills (Type B)

These require explicit invocation — Claude won't auto-trigger them.

| Command | What it does |
|---------|-------------|
| `/create-issue` | Create GitHub Issue + branch |
| `/pickup-issue NNN` | Pick up a PM-created issue |
| `/setup-nextjs-project` | Wire submodule + symlinks |
| `/release` | Cut a new version |

---

## Extending Without Modifying

To add project-specific logic on top of a shared agent or skill:

1. Create `.claude/agents.local/extensions/{agent-name}.md` (delta only — not a full copy)
2. The agent's extension hook reads it automatically

To override a shared agent entirely:
1. Create a real file at `.claude/agents/{agent-name}.md`
2. The symlink setup skips the shared version (`link_if_absent` guard)

---

## Updating the Starter Kit

```bash
.claude/web-agentic/scripts/sync.sh
```

Pulls latest, re-runs symlinks (local overrides are never touched), reminds you to commit the updated submodule pointer.

---

## Project-Specific Things Still to Define

| Decision | Where to configure |
|----------|--------------------|
| Styling / UI library | Install + configure in `app/layout.tsx` |
| Database / ORM | `src/lib/db.ts` + fill in ORM queries in DB DataSource stubs |
| Authentication | `src/lib/auth.ts` + update `src/lib/safe-action.ts` |
| Environment variables | `.env.local` — template in `reference/project-setup.md` |
| Error monitoring | Wrap `app/layout.tsx` with provider |
| Deployment target | `next.config.ts` output setting |

Full details: `reference/project-setup.md`
