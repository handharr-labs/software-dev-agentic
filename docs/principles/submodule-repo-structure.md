> Author: Puras Handharmahua · 2026-04-09
> Related: Agentic Coding Assistant — Core Design Principles

## Delivery Mechanism

> **Distribution:** **Claude Plugin** — `install-plugin.sh --platform=<platform>` patches `enabledPlugins` in `.claude/settings.json`. Plugins are built from `lib/` via `build-plugin.sh` and published to the marketplace at `hndhr/software-dev-agentic`. For plugin config see `scripts/install-plugin.sh` and `.claude-plugin/marketplace.json`.

`software-dev-agentic` is the single source of truth — agents, skills, and reference docs ship to downstream projects via the built plugin. For the agent design principles that govern what goes into these files, see [core-design-principles.md](core-design-principles.md).

---

## Key Design Decisions

### 1. DI at Skill Level — All Workers in Core, Platform Knowledge in Skills

**Decision:** All core workers live in `lib/core/agents/` — fully platform-agnostic. Platform knowledge lives exclusively in skills (`lib/platforms/<platform>/skills/`). Platform-specific agents live in `lib/platforms/<platform>/agents/` only when the agent itself is inherently platform-specific.

> For the DI at Skill Level principle, see [core-design-principles.md — P2](core-design-principles.md#2-agents--brain-decision-maker).

**Core-dependency skills** — called by core workers. Must be implemented by every platform that wants core agent support. Same name across platforms, different syntax per platform. Located in `lib/platforms/<platform>/skills/contract/` — at setup time the `contract/` group is transparent and skills land flat in `.claude/skills/<name>/` downstream.

Naming pattern: `<layer>-<action>-<artifact>` (e.g. `<layer>-create-<artifact>`). Skills cover **new artifact creation only** — workers handle modifications to existing artifacts via direct `Read` + `Edit` with reference docs. Every platform must implement the full create-only set under the same names.

> The canonical list of required contract skills per persona: [`docs/contract/`](../contract/) — one file per persona (`builder-skill-contract.md`, `detective-skill-contract.md`, etc.).

**Platform-specific skills** — called by platform agents only. Implemented only by the platform that owns the calling agent.

> **New platform extensibility:** Adding a 4th platform (e.g., React Native, KMP) requires only `lib/platforms/<platform>/skills/` + `lib/platforms/<platform>/reference/` directories. No changes to any agents in `lib/core/agents/`.

---

### 2. Persona Grouping in `lib/core/agents/`

**Decision:** Agents in `lib/core/agents/` are grouped into persona subdirectories. Each persona represents a coherent workflow — agents within a group relate to and can depend on each other. Ungrouped agents (no peers yet) remain flat at `lib/core/agents/`.

Adding a new persona: Create `lib/core/agents/<persona>/`, add worker(s)/strategists, create `packages/<persona>.pkg`. The installer picks it up automatically — no script changes needed.

**Rationale:** Grouping by persona makes the directory self-documenting and enables selective installation. Engineers understand which agents serve their workflow before opening a single file.

---

### 3. Build-Time Platform Resolution — No `.claude/platform` File

**Decision:** The correct platform skill files are bundled at plugin build time via the `--platform=` flag. There is no `.claude/platform` file — platform identity is baked into the plugin itself. At runtime, strategists also pass `platform` explicitly in every worker spawn prompt so workers can resolve skill paths without relying on any ambient platform state.

**Rationale:** With workers being platform-agnostic files in `lib/core/agents/`, and skills being the platform-specific layer, the plugin build bundles the right skill implementations for the target platform. Workers resolve skills by name — the plugin provides the correct platform implementation automatically. The runtime platform parameter (`web`/`ios`/`flutter`/`android`) is still passed in every spawn prompt for workers that need to reference platform-specific conventions.

**Result:** The installed plugin exposes `<skill-name>/SKILL.md` pointing to the correct platform skill implementation (from `lib/platforms/<platform>/skills/contract/<skill-name>/`). Core workers are shared across all platforms. The worker calls the skill by name and gets the right platform implementation automatically.

---

### 4. Reference Docs — Core Theory + Platform Impl

**Decision:** Each topic ships as a file pair across two source locations:

- `lib/core/reference/code-architecture/<topic>-theory.md` — what the concept IS and why it exists. Platform-agnostic, single source of truth. Downstream: `.claude/reference/code-architecture/<topic>-theory.md`.
- `lib/platforms/<platform>/reference/code-architecture/<topic>-impl.md` — how to implement it in that platform's language and syntax. Downstream: `.claude/reference/code-architecture/<topic>-impl.md`.
- `lib/platforms/<platform>/reference/` (flat) — platform-specific patterns with no theory counterpart (e.g. `ssr.md`, `server-actions.md` for web). Lands flat as `.claude/reference/<name>.md`.
- `lib/core/reference/README.md` — placement rules for reference vs agent body vs skills.

**Rationale:** Theory is platform-agnostic — it belongs in `lib/core/` as a single source of truth. Impl files stay per-platform. The setup script links both: core reference lands at `.claude/reference/code-architecture/<topic>-theory.md` and platform impl lands at `.claude/reference/code-architecture/<topic>-impl.md`. Agents see a flat `code-architecture/` dir with both files and can Grep either without knowing the source.

**Reference subdir rule:** The `code-architecture/` subdir is preserved downstream. Unlike agents and skills (always flat), reference docs maintain their subdir structure. Any new subdir added under `lib/platforms/<platform>/reference/` is automatically preserved by the setup script.

Every file follows a strict heading structure: `#` platform+topic title, `##` canonical Terms (agent-greppable grep keys), `###` subsections. This makes `grep "^## Term"` deterministic across all platforms.

**Topic and Term vocabulary:**
- **Topic** — the subject area a reference file covers (e.g. `domain`, `data`, `presentation`). Not engineering-specific.
- **Term** — the canonical name for one concept within a topic. Each `##` heading is a Term. One Term = one name = one `##` heading across every platform. Platform dialect belongs in the body, never the heading.

See [core-design-principles.md — Reference vocabulary](core-design-principles.md#reference-vocabulary--topic-and-term) for the full decision table.

**Grep-first rule (P6 enforcement):** Workers Grep reference files by section keyword before reading in full. If uncertain which file covers a topic, check `reference/index.md` first.

---

### 5. `lib/` Boundary — Distributable vs Internal Content

**Decision:** All content that gets bundled into downstream plugins lives under `lib/`. Internal tooling stays at the repo root.

**Rationale:** The boundary is explicit and self-documenting. `lib/` = the library surface. Everything outside `lib/` is build/repo tooling. Engineers contributing a new agent know exactly which folder it belongs in without needing to know the implicit contract.

---

### 6. Three Modes: Use, Extend, Override

> For the principle, see [core-design-principles.md — P3](core-design-principles.md#3-skills--hands-thin-procedures).

**Agent extension pattern** — every shared agent ends with a standard hook:

```
After completing, check for `.claude/agents.local/extensions/<name>.md` — if it exists, read and follow its additional instructions.
```

Extension files contain only the delta — not a full copy. Updates to the submodule are inherited automatically; extensions just layer on top.

**Override** — create a real file in `agents.local/` (or `skills.local/`) with the same name as a shared agent/skill. The setup script's `link_if_absent` guard skips symlinking the shared version.

---

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
| Core agent platform-agnosticism | No hardcoded platform paths (`src/domain/`, `Talenta/Module/`, `lib/`, `app/`); no platform framework references as rules (`React`, `Next.js`, `RxSwift`, `UIKit`, `BLoC`, `axios`); no platform language syntax as rules (`'use client'`, `readonly`, `BehaviorRelay`); platform knowledge delegated to a skill | 🔴 Critical |
| Skill frontmatter | `name`, `description`, `user-invocable: false` present | 🔴 Critical |
| Reference reads in skills | Grep-first; no "Read completely"; all referenced paths match actual filenames | 🔴 Critical |
| Fix G | Template files contain only code generation hints — no explanatory/instructional comments | 🟡 Warning |
| Naming | `-strategist.md` / `-worker.md`; skill dirs follow `<layer>-<action>-<target>`; persona assignment correct | 🟢 Info |
| Prompt Clarity | No ambiguous scope ("create the X" without specifying interface vs implementation); no instructions spanning two CLEAN layers without a stop condition; no contradicting rules; failure paths specified. For deeper runtime reasoning analysis, run `prompt-debug-worker`. | 🟡 Warning |

**Severity levels:**
- 🔴 Critical — missing required frontmatter, broken reference path, "Read completely" violation, platform-specific content in a `lib/core/agents/` file
- 🟡 Warning — wrong model, missing Search Protocol/Output/Extension Point, missing `reference/index.md` hint, explanatory template comments, prompt clarity issues
- 🟢 Info — naming deviation, description could be more specific

**Platform-Agnosticism Rule for `lib/core/agents/`**

> Any `lib/core/agents/` file body that contains hardcoded platform paths, framework references (as rules), or language-specific syntax is a Critical violation. Platform knowledge must be delegated to a skill in `related_skills`.

---

## Folder Design Rationale

| Decision | Why |
|---|---|
| All workers in `lib/core/agents/` | DI at skill level — platform-agnostic brains |
| Persona subdirectories | Workflow cohesion; selective installation; self-documenting |
| `perf-worker.md` stays flat | No persona peers yet |
| `.claude/agents/` and `.claude/skills/` | Internal tooling — not downstream API surface |
| `lib/` boundary | Explicit distributable surface — everything under `lib/` bundles into plugins, everything outside is tooling |
| `arch-review-worker` platform-agnostic (P6) | Core workers must not embed platform knowledge |
| `setup-worker` in `lib/core/agents/installer/` | Platform-agnostic setup logic; delegates mechanical steps to platform setup skills |

---

## "What Goes Where" Decision Rule

| Content | Location | Reason |
|---|---|---|
| Core strategists | `software-dev-agentic/lib/core/agents/<persona>/` | Platform-agnostic coordination protocol, grouped by persona |
| Core workers | `software-dev-agentic/lib/core/agents/<persona>/` | Platform-agnostic CLEAN layer brains, grouped by persona |
| Tracker agents | `software-dev-agentic/lib/core/agents/tracker/` | Issue lifecycle management |
| Auditor agents | `software-dev-agentic/lib/core/agents/auditor/` | Architecture review — platform-agnostic CLEAN checker; delegates platform rules to skills |
| Installer agents | `software-dev-agentic/lib/core/agents/installer/` | Platform-agnostic project setup + onboarding; delegates mechanical steps to platform setup skills |
| Meta/observability agents | `software-dev-agentic/lib/core/agents/debugger/` | Performance analysis + agent prompt debugging |
| Internal repo tooling | `software-dev-agentic/agents/` | Convention reviewer — NOT bundled into downstream plugins |
| Platform-specific agents (`test-strategist`, `pr-review-worker`) | `software-dev-agentic/lib/platforms/<platform>/agents/` | Agent itself is inherently platform-specific |
| Core skills | `software-dev-agentic/lib/core/skills/` | Identical across platforms |
| Platform-contract skills | `software-dev-agentic/lib/platforms/<platform>/skills/contract/` | Same name on all platforms, platform-specific implementation; create-only (`create-*`) — no update skills; lands flat in `.claude/skills/<name>/` downstream |
| Platform-only skills | `software-dev-agentic/lib/platforms/<platform>/skills/` (flat) | Called by platform agents only |
| Internal repo skills | `software-dev-agentic/skills/` | Convention checklist, report formatter — NOT bundled into downstream plugins |
| Reference docs — theory | `software-dev-agentic/lib/core/reference/code-architecture/<topic>-theory.md` | What/why — single source of truth, platform-agnostic |
| Reference docs — impl | `software-dev-agentic/lib/platforms/<platform>/reference/code-architecture/<topic>-impl.md` | How in that language — platform-specific |
| Platform-specific reference docs | `software-dev-agentic/lib/platforms/<platform>/reference/` (flat) | Platform-unique patterns; lands flat in `.claude/reference/<name>.md` downstream |
| Project-specific agents | `.claude/agents.local/` | Only relevant to one project |
| Agent/skill extensions | `.claude/*/extensions/` | Additive delta, project-scoped |
| Agent memory | `.claude/agent-memory/` | Project-scoped institutional knowledge |
| `CLAUDE.md` | project root | Project-specific universal rules |
| `settings.json` | `.claude/` | Project-specific Claude config |

> Rule of thumb: if it describes CLEAN architecture theory → `lib/core/`. If it's platform implementation details → `lib/platforms/<platform>/skills/`. If it's project-specific quirks → `.claude/agents.local/`. If it only applies to reviewing or maintaining this repo's own files → `.claude/agents/` or `.claude/skills/`.

---

## Setup & Installation

```bash
# Build the plugin for a platform
software-dev-agentic/scripts/build-plugin.sh --platform=ios-talenta

# Install into a downstream project (patches enabledPlugins in .claude/settings.json)
software-dev-agentic/scripts/install-plugin.sh --platform=ios-talenta
```

**What `install-plugin.sh` does:**
1. Adds the marketplace (`hndhr/software-dev-agentic`) to global `~/.claude/settings.json` if absent
2. Patches `enabledPlugins` in the project's `.claude/settings.json` for `cipherpol-aegis` and `cipherpol-8`
3. Syncs the managed section in `CLAUDE.md`

**Adopting Updates**

```bash
# Rebuild and reinstall
software-dev-agentic/scripts/build-plugin.sh --platform=<platform>
software-dev-agentic/scripts/install-plugin.sh --platform=<platform>
```

**Post-install checklist:**
1. Edit `CLAUDE.md` — fill in `[AppName]` and stack placeholders
2. `git add .claude/ && git commit -m "chore: wire cipherpol (<version>)"`

---

## Repository Structure

**Per-Project Layout (after plugin install)**

```
/
  .claude/
    plugins/
      cipherpol-aegis/       ← plugin: core agents + platform skills + reference
      cipherpol-8/           ← plugin: supplementary agents
    agents.local/
      extensions/
    skills.local/
      extensions/
    settings.json
    CLAUDE.md
```

> Internal tooling (`.claude/agents/`, `.claude/skills/` in this repo) is never bundled into downstream plugins. Only content under `lib/` reaches downstream projects.

---

## Contribution Workflow

> **Collaboration phase:** The workflow below is the current, working approach — not a finalized model. Open questions remain: contribution workflow across platform teams, ownership model (core team vs. platform teams), versioning strategy (per-platform or unified), and the review process for changes that affect multiple platforms. These are being worked out in the Collaboration phase.

1. Engineer identifies a new agent/skill or improvement
2. PR to `software-dev-agentic` with the new/updated file (under `lib/core/` or `lib/platforms/<platform>/`)
3. Review by peers (same process as any code PR)
4. Merge to main + cut a release (`/release`)
5. Each project adopts: rebuild + reinstall the plugin (`build-plugin.sh` → `install-plugin.sh`)

---

## Related Links

- [Agentic Coding Assistant — Core Design Principles](https://jurnal.atlassian.net/wiki/spaces/~611df3da650a26006e44928d/pages/51126370416)
- CipherPol repository

---


## Changelog

See git history for this file.
