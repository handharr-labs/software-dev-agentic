# CipherPol

> Claude Code toolkit for Clean Architecture projects

A multi-platform agentic toolkit — agents, skills, and architecture knowledge for Clean Architecture projects. Distributed as **Claude Code plugins**.

**Platforms:** Flutter · iOS (Swift/UIKit) · Android (Kotlin) · Web (Next.js)

---

## How it works

Agents are organized into **personas** — coherent workflow groups (developer, debugger, tracker, auditor, qa). All personas ship in a single `cipherpol-aegis` plugin.

Platform-specific knowledge lives in the **KMS** (ChromaDB-backed MCP server, `cipherpol-8`). Agents query `kms_list` → `kms_query` at runtime, scoped to the project's platform. Project-specific context (feature inventory, deviations, API endpoints) is seeded per project via `/kms-seed`.

Platform is declared once in `settings.local.json` (`CIPHERPOL_PLATFORM`) and cross-checked against `CLAUDE.md`. Agents resolve it automatically — no per-platform plugin needed.

---

## Setup

### 1. Register marketplace (once per machine)

**CLI:**
```bash
claude plugin marketplace add hndhr/software-dev-agentic
```

**Manual** — add to `~/.claude/settings.json`:
```json
{
  "extraKnownMarketplaces": {
    "cipherpol": {
      "source": { "source": "github", "repo": "hndhr/software-dev-agentic" }
    }
  }
}
```

> **Migrating from `sda`?** Remove the old `sda` entry from `extraKnownMarketplaces` if present.

### 2. Enable plugins and configure env

Written by the installer. Edit manually to override any value. Use `.claude/settings.json` to share with the team or `.claude/settings.local.json` to keep it personal (gitignored).

```json
{
  "enabledPlugins": {
    "cipherpol-aegis@cipherpol": true,
    "cipherpol-8@cipherpol": true
  },
  "env": {
    "CIPHERPOL_PLATFORM": "flutter",
    "CIPHERPOL_PROJECT": "talenta"
  },
  "skillListingBudgetFraction": 0.03
}
```

| Key | Values | Purpose |
|---|---|---|
| `CIPHERPOL_PLATFORM` | `flutter` · `ios` · `android` · `web` | KMS scope for platform knowledge queries |
| `CIPHERPOL_PROJECT` | `talenta` · `jurnal` · `qontak-crm` · `qontak-chat` · any string | KMS scope for project-specific knowledge |
| `skillListingBudgetFraction` | `0.03` (recommended) | Fraction of context budget reserved for skill listing |

`CIPHERPOL_PLATFORM` and `CIPHERPOL_PROJECT` are read by every agent via `detect-platform` before making KMS calls. If both `env` and `CLAUDE.md` are set and disagree, the env var takes precedence and `/cipherpol-status` will flag the conflict.

### 3. Wire the KMS MCP server (user scope, once per machine)

`cipherpol-8` runs as an MCP server. Register it at user scope in `~/.claude.json` under `mcpServers`:

```json
"cp8": {
  "type": "stdio",
  "command": "bash",
  "args": [
    "-c",
    "latest=$(ls \"$HOME/.claude/plugins/cache/cipherpol/cipherpol-8\" 2>/dev/null | sort -t. -k1,1n -k2,2n -k3,3n | tail -1) && exec bash \"$HOME/.claude/plugins/cache/cipherpol/cipherpol-8/$latest/kms/server.sh\""
  ],
  "env": {}
}
```

| Env | Default | Purpose |
|---|---|---|
| `CP8_ENABLE_LOGGING` | `false` | Enable MCP server request/response logging |
| `CP8_LOG_MAX_MB` | `10` | Max log file size in MB before rotation |

Set these in `~/.claude/settings.json` under `env` to apply globally (see Step 3).

> **Migrating from `kms`?** Remove any `kms` entry from `.mcp.json` or `~/.claude.json` and replace with the `cp8` entry above.

### 4. Activate

Run `/reload-plugins` in Claude Code, then verify with `/cipherpol-status`.

### 5. Seed project knowledge

The plugin ships with platform-level patterns pre-seeded. Add your project's specific knowledge:

```bash
/kms-seed
```

Or extract directly from the codebase:

```bash
/kms-extract-codebase
```

### Updates

```
/plugin marketplace update cipherpol
```

---

## What's included

### Agents — by persona

**developer** — feature construction across CLEAN layers

| Agent | Purpose |
|---|---|
| `developer-feature-strategist` | Brain of the developer persona — decides which layer planners to spawn, synthesizes plan.md + context.md |
| `developer-feature-worker` | Execute an approved feature plan layer by layer |
| `developer-backend-worker` | Build Domain + Data layers directly |
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

---

### Skills — by persona

**developer**

| Skill | Purpose |
|---|---|
| `/developer-build-feature` | Build or resume a feature — plan-first or build-directly |
| `/developer-plan-feature` | Run convergence planning loop, show approval, then execute |
| `/developer-build-from-ticket` | One-shot build from a Jira ticket — non-interactive |
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

**utility**

| Skill | Purpose |
|---|---|
| `/installer-doctor` | Audit the plugin setup — plugin, KMS, CLAUDE.md, settings, gh auth |
| `/cipherpol-status` | Full CipherPol health check — platform, project, plugin versions, KMS connectivity, knowledge coverage |
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
```

#### 1b — Update Ticket Progress

```
Session update:

Work items completed:
- Migrated GetLocationListUseCase to new datasource pattern

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

/developer-groom-ticket path/to/TICKET-123.md
```

**Step 3 — Start a fresh session** (`/clear` or new Claude Code session).

**Step 4 — Plan and build**

```
Let's work on the work items in this ticket.

/developer-plan-feature path/to/TICKET-123.md
```

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

Platform pattern knowledge lives in ChromaDB (primary via KMS MCP). Agents always query with `platform=$CIPHERPOL_PLATFORM`.

---

## Repo structure

```
lib/
  core/
    agents/       ← all persona agents (flat in plugin)
    skills/       ← all skills (flat in plugin)
  plugins/
    cipherpol-aegis/     ← build.config.json + build.sh
    cipherpol-8/      ← build.config.json + build.sh
kms/              ← ChromaDB MCP server source
scripts/
  build-plugin.sh      ← discovers lib/plugins/*/build.sh and runs them
  install-plugin.sh    ← downstream project setup
  plugin-lib.sh        ← shared build helpers
cipherpol.json   ← canonical platform registry (id → kms_id + detection markers)
```

---

## Design docs

- [`docs/principles/core-design-principles.md`](docs/principles/core-design-principles.md) — architecture, taxonomy, decision rules
- [`docs/principles/kms-design-principles.md`](docs/principles/kms-design-principles.md) — KMS design, metadata schema, cascade resolution

---

## .gitignore recommendations

```gitignore
.claude/agentic-state/
.claude/settings.local.json
```
