# software-dev-agentic

> Claude Code toolkit for Clean Architecture projects — v10.4.0

A multi-platform agentic toolkit — agents, skills, hooks, and architecture reference docs for Clean Architecture projects. Distributed as a **Claude Code plugin**.

**Platforms:** Flutter · iOS (Swift/UIKit) · Android (Kotlin) · Web (Next.js 15)

---

## How it works

Agents are organized into **personas** — coherent workflow groups (developer, debugger, tracker, auditor, installer, qa). All personas ship to every platform plugin.

Knowledge is served by the **KMS** (ChromaDB-backed) — agents query `kms_list` → reason → `kms_fetch` at runtime. Project-specific context (feature inventory, deviations, API endpoints) is seeded per project via `/kms-seed`. Platform pattern knowledge (layers, conventions, patterns) ships pre-seeded inside the plugin.

---

## Setup — Plugin

### Install

From inside the downstream project directory:

```bash
curl -fsSL https://raw.githubusercontent.com/hndhr/software-dev-agentic/main/scripts/install-plugin.sh | bash -s -- --platform=flutter
```

Replace `flutter` with your platform. Available platforms:

| Plugin | Purpose |
|---|---|
| `sda-flutter` | Flutter / Dart / BLoC — agents, skills, hooks |
| `sda-ios-swift` | iOS / Swift / UIKit — agents, skills, hooks |
| `sda-android-kotlin` | Android / Kotlin — agents, skills, hooks |
| `sda-web-nextjs` | Web / Next.js 15 — agents, skills, hooks |
| `sda-kms` | KMS MCP server — knowledge store shared by all platforms |

> Install both a platform plugin and `sda-kms`. The platform plugin provides agents and skills; `sda-kms` serves the knowledge queries those agents rely on.

### Personal setup (no commits required)

The recommended approach — everything lives in gitignored or user-level files.

#### Step 1 — Platform plugin in `.claude/settings.local.json`

`.claude/settings.local.json` is gitignored by convention — add `enabledPlugins` here so the platform plugin activates only in this project without touching any committed file.

```json
{
  "enabledPlugins": {
    "sda-flutter@sda": true
  }
}
```

Replace `sda-flutter` with the plugin matching your platform.

#### Step 2 — `sda-kms` at user scope (once, machine-wide)

`sda-kms` is shared across all platforms — install it once at user scope and it's available in every project:

```bash
claude plugin enable sda-kms@sda --scope user
```

#### Step 3 — KMS MCP at user scope (once, machine-wide)

Register the KMS MCP server once and it applies globally:

```bash
claude mcp add kms --scope user bash -- -c \
  'latest=$(ls "$HOME/.claude/plugins/cache/sda/sda-kms" 2>/dev/null | sort -t. -k1,1n -k2,2n -k3,3n | tail -1) && exec bash "$HOME/.claude/plugins/cache/sda/sda-kms/$latest/kms/server.sh"'
```

Restart Claude Code to activate. Verify with `/kms-status`.

### Auto-install for teammates

Commit two files — teammates get the full setup automatically on first session.

#### Step 1 — `.claude/settings.json`

```json
{
  "extraKnownMarketplaces": {
    "sda": {
      "source": { "source": "github", "repo": "hndhr/software-dev-agentic" }
    }
  },
  "enabledPlugins": {
    "sda-flutter@sda": true
  }
}
```

Replace `sda-flutter` with the plugin matching your platform. `sda-kms` is installed at user scope (not per-project) — see the Personal setup section above.

#### Step 2 — `.mcp.json` (KMS)

Wires the KMS MCP server. The same config works for all platforms — it always points to `sda-kms`.

```json
{
  "mcpServers": {
    "kms": {
      "command": "bash",
      "args": ["-c", "latest=$(ls \"$HOME/.claude/plugins/cache/sda/sda-kms\" 2>/dev/null | sort -t. -k1,1n -k2,2n -k3,3n | tail -1) && exec bash \"$HOME/.claude/plugins/cache/sda/sda-kms/$latest/kms/server.sh\""]
    }
  }
}
```

Commit `.mcp.json` so teammates get the KMS wiring automatically. Verify with `/kms-status` after Claude Code restarts.

### Seed project knowledge

The plugin ships with platform-level patterns pre-seeded. To add your project's specific knowledge (feature inventory, API endpoints, deviations):

```bash
/kms-seed
```

Or extract directly from the codebase:

```bash
/kms-extract-codebase
```

### Updates

```
/plugin marketplace update sda
```

---

## What's included

### Agents — by persona

**developer** — feature construction across CLEAN layers

| Agent | Purpose |
|---|---|
| `developer-feature-strategist` | Brain of the developer persona — decides which layer planners to spawn, synthesizes plan.md + context.md. Never spawns agents or writes files directly. |
| `developer-feature-worker` | Execute an approved feature plan layer by layer |
| `developer-backend-worker` | Build Domain + Data layers directly — entities, use cases, mappers, datasources, repository impls |
| `developer-ui-worker` | Create or update screens and components bound to an existing StateHolder |
| `developer-test-worker` | Route test generation to the correct layer procedure |
| `developer-domain-planner` | Discover Domain layer — entities, use cases, repository interfaces. Read-only. |
| `developer-data-planner` | Discover Data layer — DTOs, mappers, datasources, repository impls. Read-only. |
| `developer-pres-planner` | Discover Presentation layer — StateHolders, screens, components. Read-only. |
| `developer-app-planner` | Discover App layer — DI, routing, module, analytics, feature flags. Read-only. |
| `developer-groom-strategist` | Groom a Jira ticket against the codebase |
| `developer-rfc-writer` | Write RFC + breakdown from converged plan |
| `developer-figma-worker` | Extract Figma design context and write alignment files |

**debugger** — debugging and root cause analysis

| Agent | Purpose |
|---|---|
| `debugger-strategist` | Coordinate debug investigation — static analysis then runtime instrumentation |
| `debugger-worker` | Trace a runtime error through CLEAN layers to its root cause |
| `debugger-log-worker` | Add or remove debug log statements for a specific investigation |

**tracker** — issue and ticket lifecycle

| Agent | Purpose |
|---|---|
| `tracker-issue-worker` | Create or pick up a GitHub issue, open the feature branch, update backlog |
| `tracker-jira-ticket-worker` | Create Jira tickets under an epic from a platform breakdown list |

**auditor** — architecture compliance

| Agent | Purpose |
|---|---|
| `auditor-arch-review-worker` | Audit code for CLEAN Architecture violations — layer boundaries, entity purity, naming conventions |

**qa** — test case and automation generation

| Agent | Purpose |
|---|---|
| `qa-testcase-worker` | Generate mobile UI test cases from Jira tickets, PRDs, or Figma designs |
| `qa-automation-worker` | Translate test case CSVs into Maestro YAML automation scripts |

**installer** — project setup

| Agent | Purpose |
|---|---|
| `installer-setup-worker` | Detect platform, scaffold the project, guide initial onboarding |

---

### Skills — by persona

**developer**

| Skill | Purpose |
|---|---|
| `/developer-build-feature` | Build or resume a feature — plan-first or build-directly |
| `/developer-plan-feature` | Run convergence planning loop, show approval, then execute |
| `/developer-build-from-ticket` | One-shot build from a Jira ticket — non-interactive, designed for CI |
| `/developer-backend` | Build Domain + Data layers only |
| `/developer-rfc` | Write RFC + breakdown from a Jira epic |
| `/developer-groom-ticket` | Groom a locally fetched Jira ticket against the codebase |
| `/developer-clear-runs` | Remove stale run state from `.claude/agentic-state/runs/` |

**debugger**

| Skill | Purpose |
|---|---|
| `/debugger-debug` | Trigger debug investigation — static analysis then optional instrumentation |

**tracker**

| Skill | Purpose |
|---|---|
| `/tracker-jira-ticket` | Create Jira tickets under an epic from a platform breakdown list |
| `/tracker-issue` | Create or pick up a GitHub issue, create branch, update backlog |
| `/tracker-adjust-ticket` | Update the Session Adjustment section of a locally fetched ticket |

**auditor**

| Skill | Purpose |
|---|---|
| `/auditor-arch-review` | Audit code for CLEAN Architecture violations |

**qa**

| Skill | Purpose |
|---|---|
| `/qa-generate-testcase` | Generate mobile UI test cases from Jira, Confluence, or Figma |
| `/qa-generate-automation` | Generate Maestro YAML automation scripts from test case CSVs |

**installer**

| Skill | Purpose |
|---|---|
| `/installer-setup` | Set up or reconfigure a project to use this toolkit |
| `/installer-doctor` | Audit the toolkit setup — plugin, KMS, CLAUDE.md, settings, gh auth |
| `/installer-sync` | Pull the latest updates and re-link agents and skills |
| `/installer-update` | Sync to latest then verify the full installation end-to-end |

**utility**

| Skill | Purpose |
|---|---|
| `/kms-status` | Check KMS server health, ChromaDB node count, and knowledge coverage |
| `/kms-seed` | Seed ChromaDB from registered knowledge sources |
| `/kms-extract-codebase` | Scan a local project repo and extract project-reality docs into KMS |
| `/agentic-perf-review` | Score a Claude session on D1–D7 dimensions, write a report |
| `/release` | Cut a new release — bumps VERSION, prepends CHANGELOG, commits, tags |

---

## Recommended Workflows

### Workflow 1 — Tracker Persona

#### 1a — Create Jira Tickets from PRD

**What you need:** Atlassian MCP authenticated · Jira epic key · platform breakdown list

```
/tracker-jira-ticket

epic_key: PROJ-1234
cloud_id: yourcompany.atlassian.net
project_key: PROJ
prd_source: https://yourcompany.atlassian.net/wiki/spaces/ENG/pages/123456789/Feature+PRD

breakdown:
- [ADR] [UI+API] Show location marker on map: 2 days
- [iOS] [UI+API] Show location marker on map: 2 days
- [ADR] [UI] Show location accuracy perimeter: 1 day
- [iOS] [UI] Show location accuracy perimeter: 1 day
```

The worker parses the breakdown, fetches the PRD, generates structured Jira descriptions, shows a preview table, and creates all tickets under the epic.

#### 1b — Update Ticket Progress

```
Session update:

Work items completed:
- Migrated GetLocationListUseCase to new datasource pattern

Decisions:
- Replaced old caching layer entirely

/tracker-adjust-ticket path/to/TICKET-123.md
```

---

### Workflow 2 — Developer Persona: Groom then build

**Step 1 — Fetch the ticket locally** via Atlassian MCP.

**Step 2 — Groom the ticket**

```
We have some things to address:

1. Cache mechanism in Connection.swift — keep, improve, or replace?
2. Some APIs still use the old pattern — need migration
3. Force call bypassing TTL — pass force: Bool from presentation to data layer

/developer-groom-ticket path/to/TICKET-123.md
```

**Step 3 — Start a fresh session** (`/clear` or new Claude Code session).

**Step 4 — Plan and build**

```
Let's work on the work items in this ticket.

/developer-plan-feature path/to/TICKET-123.md
```

Claude reads the groomed ticket, runs the convergence planning loop, presents a plan for approval, then executes layer by layer — Domain → Data → Presentation → UI.

**Step 5 — Update ticket progress**

```
/tracker-adjust-ticket path/to/TICKET-123.md
```

---

## Architecture

All agents enforce Clean Architecture:

```
Presentation  →  Domain  ←  Data
```

- **Domain** — pure business logic, zero framework imports. Entities, use cases, repository interfaces.
- **Data** — implements domain interfaces. Remote/DB data sources, mappers, repository implementations.
- **Presentation** — StateHolder (ViewModel / BLoC / Presenter), UI screens, navigation. Depends only on domain.

| Platform | Language | State management |
|---|---|---|
| Flutter | Dart | BLoC / Cubit |
| iOS | Swift | ViewModel + Coordinator |
| Android | Kotlin | Presenter |
| Web | TypeScript | Custom hooks |

Platform pattern knowledge lives in `lib/core/knowledge/` (fallback) and ChromaDB (primary via KMS MCP).

---

## Design docs

- [`docs/principles/core-design-principles.md`](docs/principles/core-design-principles.md) — full architecture, taxonomy, decision rules
- [`docs/principles/kms-design-principles.md`](docs/principles/kms-design-principles.md) — KMS design, metadata schema, cascade resolution
- [`docs/principles/submodule-repo-structure.md`](docs/principles/submodule-repo-structure.md) — repo structure and distribution model

---

## .gitignore recommendations

```gitignore
.claude/agentic-state/
```
