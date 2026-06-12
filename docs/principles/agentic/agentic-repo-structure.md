> Author: Puras Handharmahua · 2026-04-09
> Related: [agentic-design-principles.md](agentic-design-principles.md)

## Delivery Mechanism

Distribution: **Claude Code Plugin** — two plugins ship from this repo.

| Plugin | Contains | Installed by |
|---|---|---|
| `cipherpol-aegis` | Agents + skills (all personas) | `install-plugin.sh --platform=<id>` |
| `cipherpol-8` | KMS MCP server (ChromaDB + knowledge) | `install-plugin.sh --platform=<id>` |

Plugins are built from `lib/plugins/*/build.sh` via `scripts/build-plugin.sh` and published to the marketplace at `hndhr/software-dev-agentic`. Platform and project IDs are defined in `cipherpol.json`.

`software-dev-agentic` is the single source of truth — agents, skills, and knowledge ship to downstream projects via the installed plugins. For the agent design principles that govern what goes into these files, see [agentic-design-principles.md](agentic-design-principles.md).

---

## Repository Structure

```
software-dev-agentic/
  lib/
    core/
      agents/           ← all persona agents (platform-agnostic)
        developer/
        debugger/
        auditor/
        qa/
      skills/           ← all skills (orchestrator + procedure)
      hooks/            ← shared hook scripts
    plugins/
      cipherpol-aegis/
        build.sh        ← assembles agents + skills from lib/core/
        build.config.json
      cipherpol-8/
        build.sh        ← assembles KMS server + ChromaDB from kms/
        build.config.json
  kms/
    knowledge-sources/  ← raw knowledge docs (universal/ + platform/ + projects/)
    domain/             ← KMS domain layer (schema, entities, use cases)
    data/               ← ChromaDB repository implementation
    application/        ← MCP server (kms_list, kms_fetch, kms_query, kms_upsert)
    db/                 ← local ChromaDB store (not committed)
    sources.yaml        ← registered knowledge sources
  .claude/
    agents/             ← internal tooling agents (NOT bundled)
    skills/             ← internal tooling skills (NOT bundled)
  scripts/
    build-plugin.sh
    install-plugin.sh
    plugin-lib.sh
  cipherpol.json        ← platform + project registry
  dist/plugins/         ← built plugin output (committed)
```

**`lib/` boundary:** Everything under `lib/` bundles into plugins and ships downstream. Everything outside `lib/` is build/repo tooling — never bundled.

**`.claude/` boundary:** `.claude/agents/` and `.claude/skills/` are internal tooling for maintaining this repo. They are NOT bundled into downstream plugins.

---

## Key Design Decisions

### 1. All Agents and Skills in `lib/core/`

**Decision:** Agents live in `lib/core/agents/` grouped by persona. Skills live in `lib/core/skills/` as named directories. Both are platform-agnostic — they contain no platform-specific paths, syntax, or framework references.

Platform awareness is handled at runtime via two mechanisms:
- **KMS** — agents load platform-specific conventions via `kms_list` → `kms_query` scoped to the current platform
- **Runtime platform param** — the calling skill passes `platform` explicitly in every worker spawn prompt

There is no `lib/platforms/` directory. All agents and skills ship to all platform installs via the same `cipherpol-aegis` plugin.

> For the platform-agnosticism rule, see [agentic-design-principles.md — P2](agentic-design-principles.md#2-agents--brain-decision-maker).

---

### 2. Two-Plugin Split — Agents vs Knowledge

**Decision:** `cipherpol-aegis` and `cipherpol-8` are separate plugins with separate installation and update cycles.

| Plugin | What it is | When to rebuild |
|---|---|---|
| `cipherpol-aegis` | Agents + skills | New agent, skill, or persona |
| `cipherpol-8` | KMS server + ChromaDB | New knowledge source or KMS code change |

**Rationale:** Knowledge updates (seeding new docs into ChromaDB) should not require rebuilding the agents plugin. The two plugins are independently versioned and can be updated separately.

`cipherpol-8` bundles the full KMS Python package and a pre-seeded ChromaDB database. The MCP server starts on demand — no manual server management.

---

### 3. KMS as the Knowledge Layer

**Decision:** Implementation patterns, architectural conventions, and SDLC knowledge live in `kms/knowledge-sources/` and are retrieved by agents via MCP tools — not by grepping flat reference files.

Three tiers in `kms/knowledge-sources/`:

```
universal/              → general principles (SOLID, Clean Architecture, SDLC-wide)
  └─ {discipline}/
       └─ {artifact}/
platform/               → platform implementation conventions
  └─ {platform}/        → flutter | ios | android | web
       └─ {discipline}/
            └─ {artifact}/
projects/               → project-specific deviations only
  └─ {project-name}/
       └─ {artifact}/
```

Agents always query with explicit `platform` and `project` filters. The cascade resolves `project → platform → universal` — agents always get the most specific matching knowledge.

> For KMS design rationale see [kms-design-principles.md](../kms/kms-design-principles.md). For path conventions, metadata schema, and retrieval protocol see [kms-conventions.md](../kms/kms-conventions.md). For seeding strategy see [kms-seeding.md](../kms/kms-seeding.md).

---

### 4. Persona Grouping in `lib/core/agents/`

**Decision:** Agents are grouped into persona subdirectories. Each persona represents a coherent workflow — agents within a group relate to and can depend on each other. Ungrouped agents (no peers yet) remain flat at `lib/core/agents/`.

Adding a new persona: Create `lib/core/agents/<persona>/`, add worker(s)/strategists. The `cipherpol-aegis` build bundles all agents in `lib/core/agents/` automatically — no build config changes needed.

---

### 5. `cipherpol.json` — Platform and Project Registry

**Decision:** Platform IDs, KMS IDs, detection markers, and project mappings are defined in a single `cipherpol.json` at the repo root. `install-plugin.sh` reads this file to resolve `--platform` and `--project` args — no hardcoded values in scripts.

```json
{
  "platforms": [
    { "id": "flutter", "kms_id": "flutter", "label": "Flutter / Dart / BLoC", "detection_markers": ["pubspec.yaml"] },
    { "id": "ios-swift", "kms_id": "ios", "label": "iOS / Swift / UIKit" }
  ],
  "projects": [
    { "id": "mobile-talenta", "kms_id": "mobile-talenta", "platform": "flutter" }
  ]
}
```

Adding a new platform or project: add an entry to `cipherpol.json`. No script changes needed.

---

### 6. Three Modes: Use, Extend, Override

> For the principle, see [agentic-design-principles.md — P3](agentic-design-principles.md#3-skills--hands-thin-procedures).

Downstream projects interact with shipped agents and skills in one of three modes:

**Extend** — add behavior without touching the plugin. Every shared agent ends with:
```
After completing, check for `.claude/agents.local/extensions/<name>.md` — if it exists, read and follow its additional instructions.
```
Extension files contain only the delta. Plugin updates are inherited automatically.

**Override** — create a real file in `agents.local/` or `skills.local/` with the same name. The plugin's version is ignored for that file.

**Local directories:**

| Directory | Override | Extend | Notes |
|---|---|---|---|
| `agents.local/` | ✓ | ✓ via `extensions/` | Workers check `extensions/<name>.md` at the end of their run |
| `skills.local/` | ✓ | — | Replaces the whole skill dir |

---

## Convention Compliance System

CipherPol enforces its own conventions through an automated internal review system. This is separate from the downstream code reviewer (`lib/core/agents/auditor/arch-review-worker.md`) — the internal system reviews *agent and skill files in this repo*, not *application code in downstream projects*.

**Two Distinct Reviewers**

| Reviewer | Location | Audits |
|---|---|---|
| `arch-review-strategist` + `arch-review-worker` | `.claude/agents/` | Agent `.md` files and `SKILL.md` files in this repo — convention compliance |
| `arch-review-worker` | `lib/core/agents/auditor/` | Application code in downstream projects — CLEAN Architecture violations |

> Why separate locations? `.claude/agents/` and `.claude/skills/` are this repo's internal tooling — they are NOT bundled into downstream plugins. `lib/core/agents/` and `lib/core/skills/` ARE bundled. The distinction prevents internal review tooling from polluting downstream project contexts.

**What `arch-check-conventions` enforces:**

| Category | Rules | Severity |
|---|---|---|
| Frontmatter | `name`, `description`, `model`, `tools` required; `model: sonnet` for all workers (haiku only for truly mechanical leaf tasks) | 🔴 Critical / 🟡 Warning |
| Strategists | `agents:` lists only spawned workers; body passes only file paths between phases; writes state file after each phase; no Phase 2 codebase reads; no direct Edit or Write — file changes always through workers; explicit output validation after each spawn — STOP if `## Output` missing or paths don't exist | 🔴 Critical |
| Workers | `## Input` section with required params table and `MISSING INPUT` STOP condition; `## Scope Boundary` section with owned-layer declaration and delegation table; `## Task Assessment` section — skill vs direct edit gate; `## Skill Execution` section — platform path resolution, Read SKILL.md, follow; `## Search Protocol` with decision gate table; `## Output` section with Glob + Grep verification before listing paths; `## Extension Point` at end; no "Read ... completely" on reference docs | 🔴 Critical / 🟡 Warning |
| Core agent platform-agnosticism | No hardcoded platform paths (`src/domain/`, `Talenta/Module/`, `lib/`, `app/`); no platform framework references as rules (`React`, `Next.js`, `RxSwift`, `UIKit`, `BLoC`, `axios`); no platform language syntax as rules (`'use client'`, `readonly`, `BehaviorRelay`); platform knowledge delegated to KMS | 🔴 Critical |
| Skill frontmatter | `name`, `description`, `user-invocable: false` present | 🔴 Critical |
| Reference reads in skills | Grep-first; no "Read completely"; all referenced paths match actual filenames | 🔴 Critical |
| Fix G | Template files contain only code generation hints — no explanatory/instructional comments | 🟡 Warning |
| Naming | `-strategist.md` / `-worker.md`; skill dirs follow `<layer>-<action>-<target>`; persona assignment correct | 🟢 Info |
| Prompt Clarity | No ambiguous scope; no instructions spanning two CLEAN layers without a stop condition; no contradicting rules; failure paths specified | 🟡 Warning |

**Severity levels:**
- 🔴 Critical — missing required frontmatter, broken reference path, "Read completely" violation, platform-specific content in a `lib/core/agents/` file
- 🟡 Warning — wrong model, missing Search Protocol/Output/Extension Point, prompt clarity issues
- 🟢 Info — naming deviation, description could be more specific

---

## "What Goes Where"

| Content | Location |
|---|---|
| Persona agents (strategists, planners, workers) | `lib/core/agents/<persona>/` |
| Flat utility agents (no persona yet) | `lib/core/agents/` |
| Internal tooling agents (not shipped) | `.claude/agents/` |
| All skills (orchestrator + procedure) | `lib/core/skills/<skill-name>/` |
| Internal tooling skills (not shipped) | `.claude/skills/<skill-name>/` |
| Architecture + SDLC knowledge | `kms/knowledge-sources/{universal,platform,projects}/` |
| Plugin definitions | `lib/plugins/<plugin-name>/` |
| Project-specific agents | `.claude/agents.local/` |
| Agent behavior extensions | `.claude/agents.local/extensions/<name>.md` |
| `CLAUDE.md` | downstream project root |
| `settings.json` | downstream `.claude/` |

> Rule of thumb: is it shipped to downstream projects? → `lib/core/`. Is it knowledge agents query at runtime? → `kms/knowledge-sources/`. Is it tooling for maintaining this repo only? → `.claude/`.

---

## Setup & Installation

```bash
# Build all plugins
scripts/build-plugin.sh

# Build a specific plugin
scripts/build-plugin.sh --target=cipherpol-aegis
scripts/build-plugin.sh --target=cipherpol-8

# Install into a downstream project
scripts/install-plugin.sh --platform=flutter
scripts/install-plugin.sh --platform=ios-swift --project=talenta-ios

# Test a built plugin locally
claude --plugin-dir dist/plugins/cipherpol-aegis
```

**What `install-plugin.sh` does:**
1. Resolves platform + project from `cipherpol.json`
2. Adds the marketplace (`hndhr/software-dev-agentic`) to global `~/.claude/settings.json` if absent
3. Patches `enabledPlugins` in the project's `.claude/settings.json` for `cipherpol-aegis` and `cipherpol-8`
4. Syncs the managed section in `CLAUDE.md` with platform and project context

**Adopting updates:**
```bash
git pull                                        # pull latest from this repo
scripts/build-plugin.sh                         # rebuild both plugins
scripts/install-plugin.sh --platform=<platform> # reinstall into project
```

---

## Contribution Workflow

1. Engineer identifies a new agent/skill or improvement
2. PR to `software-dev-agentic` with the new/updated file under `lib/core/`
3. Review by peers (same process as any code PR)
4. Merge to main + cut a release (`/release`)
5. Each project adopts: rebuild + reinstall (`build-plugin.sh` → `install-plugin.sh`)

---

## Related Links

- [Agentic Coding Assistant — Core Design Principles](https://jurnal.atlassian.net/wiki/spaces/~611df3da650a26006e44928d/pages/51126370416)
- CipherPol repository

---

## Changelog

See git history for this file.
