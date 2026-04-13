# software-dev-agentic

> Claude Code toolkit for Clean Architecture projects — v3.2.0

A git submodule that wires AI agents, skills, hooks, and architecture reference docs into your project's `.claude/` directory. Version-controlled in one place, shared across projects.

**Platforms:** Web (Next.js 15) · iOS (Swift/UIKit) · Flutter *(stub)*

---

## How it works

Add this repo as a submodule under `.claude/software-dev-agentic/`. The setup script symlinks agents and skills into `.claude/agents/` and `.claude/skills/` — Claude Code picks them up automatically. Your project code stays untouched.

```
your-project/
  .claude/
    software-dev-agentic/   ← this repo (submodule)
    agents/ → symlinks into submodule
    skills/ → symlinks into submodule
    agents.local/           ← your project-specific overrides (never touched by sync)
```

---

## Setup

### Starting a new project

```bash
# 1. Create your project (example: Next.js)
npx create-next-app@latest my-app --typescript --tailwind --eslint --app --src-dir

cd my-app

# 2. Add the submodule
git submodule add https://github.com/mekaripaper/software-dev-agentic .claude/software-dev-agentic

# 3. Run interactive setup — pick the agents and skills you need
.claude/software-dev-agentic/scripts/setup-packages.sh --platform=web
# or
.claude/software-dev-agentic/scripts/setup-packages.sh --platform=ios
```

Open Claude Code, then prompt `setup-worker` — the agent will guide you through stack choices (DB, auth, UI library, test framework) and generate the seed files.

---

### Adding to an existing project

```bash
# From your project root:
git submodule add https://github.com/mekaripaper/software-dev-agentic .claude/software-dev-agentic

.claude/software-dev-agentic/scripts/setup-packages.sh --platform=web
# or
.claude/software-dev-agentic/scripts/setup-packages.sh --platform=ios
```

The script wires symlinks, copies `CLAUDE.md`, and sets up `settings.local.json`. Re-running is safe — existing files and local overrides are never overwritten.

Then open Claude Code and prompt `setup-worker` — the agent will guide you through the rest.

---

## Keeping up to date

```bash
.claude/software-dev-agentic/scripts/sync.sh
```

Pulls the latest, re-runs symlink setup (idempotent), and reminds you to commit the updated submodule pointer. Local overrides in `agents.local/` and `skills.local/` are never touched.

---

## What's included

### Agents

| Agent | Purpose |
|-------|---------|
| `feature-orchestrator` | Build a feature end-to-end across all layers |
| `backend-orchestrator` | Full-stack — Server Action + UseCase + DB layer |
| `issue-worker` | Create or pick up a GitHub issue, open branch |
| `arch-review-worker` | Audit a file or feature for Clean Architecture violations |
| `test-worker` | Generate tests for any layer |
| `debug-worker` | Trace a runtime error to its root cause |

### Skills (slash commands)

`/new-feature` · `/new-entity` · `/new-usecase` · `/new-viewmodel` · `/write-tests` · `/wire-di` · `/scaffold-repository` · `/new-server-action` · `/new-db-repository`

---

## Architecture

All agents and skills enforce a three-layer Clean Architecture:

```
Presentation  →  Domain  ←  Data
```

- **Domain** — pure TypeScript, zero external imports. Entities, use cases, repository interfaces.
- **Data** — implements domain interfaces. Remote data sources (Axios), DB data sources (ORM), mappers.
- **Presentation** — React components, ViewModel hooks, Server Actions. Depends only on domain.

Architecture reference docs live in `lib/platforms/<platform>/reference/` and `lib/core/reference/`.

---

## Design docs

- [Agentic Coding Assistant — Core Design Principles](https://jurnal.atlassian.net/wiki/spaces/~611df3da650a26006e44928d/pages/51126370416)
- [Shared Agentic Submodule Architecture — Cross-Platform Scaling](https://jurnal.atlassian.net/wiki/spaces/~611df3da650a26006e44928d/pages/51129909710)
