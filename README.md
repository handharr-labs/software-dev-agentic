# software-dev-agentic

> Claude Code toolkit for Clean Architecture projects — v3.15.0

A git submodule that wires AI agents, skills, hooks, and architecture reference docs into your project's `.claude/` directory. Version-controlled in one place, shared across all platforms and projects.

**Platforms:** Web (Next.js 15) · iOS (Swift/UIKit) · Flutter *(stub)*

---

## How it works

Add this repo as a submodule under `.claude/software-dev-agentic/`. The setup script symlinks agents and skills into `.claude/agents/` and `.claude/skills/` — Claude Code picks them up automatically. Your project code stays untouched.

```
your-project/
  .claude/
    software-dev-agentic/   ← this repo (submodule)
    agents/                 → symlinks into submodule
    skills/                 → symlinks into submodule
    agents.local/           ← your project-specific overrides (never touched by sync)
```

Agents are organized into **personas** — coherent workflow groups. You install only the personas you need.

---

## Setup

### Starting a new project

```bash
# 1. Create your project (example: Next.js)
npx create-next-app@latest my-app --typescript --tailwind --eslint --app --src-dir
cd my-app

# 2. Add the submodule
git submodule add https://github.com/mekaripaper/software-dev-agentic .claude/software-dev-agentic

# 3. Run interactive setup — pick the personas and skills you need
.claude/software-dev-agentic/scripts/setup-packages.sh --platform=web
# or
.claude/software-dev-agentic/scripts/setup-packages.sh --platform=ios
```

Open Claude Code, then describe what you want to build — agents are routed automatically.

---

### Adding to an existing project

```bash
git submodule add https://github.com/mekaripaper/software-dev-agentic .claude/software-dev-agentic

.claude/software-dev-agentic/scripts/setup-packages.sh --platform=web
# or
.claude/software-dev-agentic/scripts/setup-packages.sh --platform=ios
```

The script wires symlinks, copies `CLAUDE.md`, and sets up `settings.local.json`. Re-running is safe — existing files and local overrides are never overwritten.

---

## Keeping up to date

```bash
.claude/software-dev-agentic/scripts/sync.sh --platform=<platform>
```

Pulls the latest, re-runs symlink setup (idempotent), and reminds you to commit the updated submodule pointer. Local overrides in `agents.local/` and `skills.local/` are never touched.

---

## What's included

### Agents — by persona

**builder** — feature construction across CLEAN layers

| Agent | Purpose |
|---|---|
| `feature-orchestrator` | Build a feature end-to-end across all CLEAN layers |
| `backend-orchestrator` | Build domain + data layers when presentation exists or will be built separately |
| `pres-orchestrator` | Build StateHolder + UI when backend layers already exist |
| `domain-worker` | Create or update Domain layer — entities, use cases, repository interfaces |
| `data-worker` | Create or update Data layer — DTOs, mappers, data sources, repository impls |
| `presentation-worker` | Create or update the StateHolder (ViewModel / BLoC / Presenter) |
| `ui-worker` | Create or update screens and components bound to an existing StateHolder |
| `test-worker` | Generate tests for any CLEAN layer |

**detective** — debugging and performance analysis

| Agent | Purpose |
|---|---|
| `debug-orchestrator` | Investigate a bug through static analysis, form hypotheses, instrument code |
| `debug-worker` | Trace a runtime error or unexpected behavior to its root cause |
| `perf-worker` | Score agentic session performance across D1–D7 dimensions, write report |
| `prompt-debug-worker` | Diagnose why an agent underperformed by analyzing its system prompt |

**tracker** — issue and branch lifecycle

| Agent | Purpose |
|---|---|
| `issue-worker` | Create or pick up a GitHub issue, open the feature branch |

**auditor** — architecture compliance

| Agent | Purpose |
|---|---|
| `arch-review-worker` | Audit code for CLEAN Architecture violations — layer boundaries, entity purity, DI |

**installer** — project setup

| Agent | Purpose |
|---|---|
| `setup-worker` | Detect platform, scaffold the project, guide initial onboarding |

---

### Toolkit skills (slash commands)

Always installed regardless of persona selection.

| Skill | Purpose |
|---|---|
| `/release` | Cut a new release — bumps VERSION, prepends CHANGELOG entry, commits, tags |
| `/doctor` | Audit the software-dev-agentic setup in this project |
| `/agentic-perf-review` | Analyze agentic session performance, write a scored D1–D7 report |
| `/clear-runs` | Clear stale orchestrator run state from `.claude/agentic-state/runs/` |

---

## Architecture

All agents enforce a three-layer Clean Architecture:

```
Presentation  →  Domain  ←  Data
```

- **Domain** — pure business logic, zero framework imports. Entities, use cases, repository interfaces.
- **Data** — implements domain interfaces. Remote/DB data sources, mappers, repository implementations.
- **Presentation** — StateHolder (ViewModel / BLoC / Presenter), UI screens, navigation. Depends only on domain.

Platform skill implementations handle the language and framework specifics:

| Platform | Language | UI framework | State management |
|---|---|---|---|
| Web | TypeScript | Next.js 15 / React | Custom hooks |
| iOS | Swift | UIKit | ViewModel + Coordinator |
| Flutter | Dart | Flutter | BLoC *(stub)* |

Architecture reference docs live in `lib/core/reference/clean-arch/` (universal) and `lib/platforms/<platform>/reference/` (platform-specific).

---

## Design docs

Local source of truth (this repo):
- [`docs/core-design-principles.md`](docs/core-design-principles.md) — all 15 principles, full taxonomy, decision rules
- [`docs/shared-submodule-arch.md`](docs/shared-submodule-arch.md) — cross-platform submodule architecture

Published view (Confluence):
- [Agentic Coding Assistant — Core Design Principles](https://jurnal.atlassian.net/wiki/spaces/~611df3da650a26006e44928d/pages/51126370416)
- [Shared Agentic Submodule Architecture — Cross-Platform Scaling](https://jurnal.atlassian.net/wiki/spaces/~611df3da650a26006e44928d/pages/51129909710)

---

## .gitignore recommendations

Add to your downstream project's `.gitignore`:

```gitignore
# Claude Code — agentic state (delegation flags, session state, run artifacts)
.claude/agentic-state/
```

This directory holds delegation flags, session tracking, and per-feature orchestrator run state. It is local state and should not be committed.
