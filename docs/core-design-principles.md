> Author: Puras Handharmahua · 2026-04-08
> Updated: 2026-04-17 — v34: pres-orchestrator promoted to sub-orchestrator of feature-orchestrator; orchestrator hierarchy example added to Taxonomy Taxonomy gaps closed — Type U (Utility) skill added; Repo skill scope added; Type × Scope intersection matrix added; Toolkit skill scope clarified as downstream-facing
> Synced with: software-dev-agentic v3.14.0
> Related: Shared Agentic Submodule Architecture — Cross-Platform Scaling

## What is an Agentic Coding Assistant?

A coding assistant where Claude autonomously routes, decides, and executes based on natural language — without the user needing to know which tool, command, or workflow to invoke. The user describes intent. The assistant figures out the rest.

> No slash commands. No manual chaining. No context pollution.

---

## Core Design Principles

### 1. Natural Language as the Entry Point

Agents are routed automatically by description matching — not by slash commands. Users describe what they want; Claude decides which agent handles it.

> Implication: Agent descriptions must be precise and use vocabulary developers naturally say. Routing is only as good as the description.

---

### 2. Agents = Brain (Decision-Maker)

Agents are intelligent specialists, not task executors. Each agent:

- Assesses context before acting (does this file exist? which pattern applies?)
- Decides which procedure to execute
- Handles edge cases and branching logic
- Knows *what* to do and *when*

Agents stay lean — they don't embed step-by-step instructions. That belongs in skills.

---

### 3. Skills = Hands (Thin Procedures)

Skills are focused, reusable workflow procedures. Each skill:

- Does one thing only
- References architecture docs — never embeds them
- Has no branching logic — agent decides which skill to call

Target: under 30 lines per skill

> Split by intent: `create-*` for new components, `update-*` for existing ones. Naming convention: `<layer>-<action>-<target>` — flat under `skills/`, prefixed by layer for logical grouping.

> Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files within the skill directory.

**By Caller — two categories:**

**Core-dependency skills** — called by core workers or orchestrators. Must be implemented by every platform that wants core agent support. Same name across platforms, different syntax per platform.

| Skill name | Called by | Must exist in |
|---|---|---|
| `domain-create-entity` | `domain-worker` (core) | all platforms |
| `domain-create-repository` | `domain-worker` (core) | all platforms |
| `domain-create-usecase` | `domain-worker` (core) | all platforms |
| `data-create-mapper` | `data-worker` (core) | all platforms |
| `data-create-datasource` | `data-worker` (core) | all platforms |
| `data-create-repository-impl` | `data-worker` (core) | all platforms |
| `pres-create-stateholder` | `presentation-worker` (core) | all platforms |
| `pres-create-screen` | `ui-worker` (core) | all platforms |
| `test-create-domain` | `test-worker` (core) | all platforms |
| `test-create-data` | `test-worker` (core) | all platforms |
| `test-create-presentation` | `test-worker` (core) | all platforms |

**Platform-specific skills** — called by platform agents only. Implemented only by the platform that owns the calling agent. Examples: iOS `review-pr` (called by iOS `pr-review-worker`), iOS `arch-check-ios`.

---

### 4. Context Isolation = Efficiency

Every agent runs in its own isolated context window — completely separate from the main session. This is the primary mechanism for token efficiency.

From the official docs:
> *"Preserve context by keeping exploration and implementation out of your main conversation"*

When `domain-worker` reads reference docs, scans existing files, and writes code — none of that touches your main session context. The main session only sees the result.

---

### 5. Preloaded Skills = Modular Agent Knowledge

Agents load their procedure skills at startup via the `skills` field.

From the official docs:
> *"Subagents with preloaded skills: full skill content is injected at startup"*

This gives agents full procedural knowledge without embedding it in their body. Same procedures are reusable across multiple agents. One definition, updated once.

**Token budget guideline:**
- Preload skills the agent needs in >50% of its invocations
- Load on demand (via `Read`) skills needed rarely or only in edge cases
- Monitor total preloaded size — if it exceeds ~500 lines, split the agent or move low-frequency skills to on-demand

---

### 6. Three Skill Types

| Type | Config | Who triggers | Context cost | Use for |
|---|---|---|---|---|
| A — Internal procedure | `user-invocable: false` | Agent only | Zero | Standard build/update workflows |
| B — User-controlled | `disable-model-invocation: true` | User only | Zero | Destructive or side-effect operations |
| C — Default | *(no config)* | Both | Description always loaded | Intentionally avoided |

**Why no Type C:** Every default skill's description loads into the main session context. Type A and B both eliminate this overhead.

---

### 7. Three-Tier Knowledge Architecture

| Tier | Location | What goes here |
|---|---|---|
| 1 | `CLAUDE.md` | Universal rules applying to every task — naming, principles, build command. ~1 page max |
| 2 | Agent body | Decision logic for that agent only — what to do, when to do it |
| 3 | `.claude/reference/` | Shared deep reference — patterns, examples, conventions. Loaded on demand via Grep-first |

**Reference doc organization in software-dev-agentic:**
- `lib/core/reference/clean-arch/` — conceptual, language-agnostic principles. Linked to all platforms.
- `lib/platforms/<platform>/reference/` — platform-specific code patterns. Linked only to matching platform.

**Enforcement — Search Protocol (decision gate):**

Before any `Read` call, workers answer: "Do I need the full file, or just a specific symbol/section?"

| What you need | Tool |
|---|---|
| A specific class, function, or type | `Grep` for the name |
| A section of a reference doc | `Grep` for the section heading |
| The full file structure (style-matching a new file) | `Read` — justified |
| Whether a file exists | `Glob` |

Read a full file only when: (a) you need its complete structure to write a new matching file, or (b) Grep returned no results. Check `reference/index.md` first if uncertain which file covers a topic.

> Read:Grep ratio should stay below 3. A ratio above 6 is a P7 violation.

---

### 8. Orchestrators = Multi-Worker Coordinators

Orchestrators coordinate multiple worker agents using the `agents` field in frontmatter.

**How orchestrators work:**
1. User describes intent
2. Main session matches the orchestrator's description and spawns it
3. Orchestrator gathers intent from the user
4. Orchestrator spawns only the relevant workers with `isolation: worktree`
5. Workers execute in isolation — each reads its own project context independently
6. Orchestrator receives only the list of created file paths — never file contents
7. Orchestrator writes a state file (`.claude/runs/<run-id>/state.json`) after each phase — tracks completed phases and artifact paths so long sessions can recover without re-reading source files
8. For presentation→UI handoffs: `presentation-worker` writes the StateHolder contract to `.claude/runs/<run-id>/stateholder-contract.md` and returns only the path — the orchestrator passes the path (not the content) to `ui-worker`, which reads the file directly
9. Orchestrator synthesizes results and reports

| | Feature Orchestrator | Worker |
|---|---|---|
| `agents` field | Yes — lists available workers | No |
| Can spawn subagents? | Yes — only those in `agents` list | No — leaf node |
| Body content | Coordination + delegation | Domain expertise + execution logic |
| Model | `sonnet` | `haiku` (mechanical) or `sonnet` (complex) |
| Codebase reads | None — workers own their context | Yes — per worker's workflow |
| `isolation` on spawn | `worktree` (standard) | N/A |

**Agent Scope — Core vs Platform-specific:**

Agents have a second axis — where they live and what they know.

- **Core** (`lib/core/agents/`) — platform-agnostic. Work on any platform. Add here when the behaviour is identical across all platforms.
- **Platform-specific** (`lib/platforms/<platform>/agents/`) — exist only when the workflow diverges enough from core to need its own agent. Examples: iOS `test-orchestrator` (knows `xcodebuild`), iOS `pr-review-worker` (knows Swift/UIKit conventions). Do not add a platform agent unless a core agent + platform skills cannot handle it.

**Combined Matrix (Role × Scope):**

| | Orchestrator | Worker |
|---|---|---|
| **Core** | `feature-orchestrator` → `pres-orchestrator`, `debug-orchestrator`, `backend-orchestrator` | `domain-worker`, `data-worker`, `presentation-worker`, `ui-worker`, `test-worker`, `debug-worker`, `prompt-debug-worker`, `arch-review-worker`, `issue-worker`, `setup-worker`, `perf-worker` |
| **Platform** | iOS `test-orchestrator` | iOS `pr-review-worker` |

---

### 9. Delegation Threshold — Direct Action vs Agent Delegation

**Delegate when:** Task requires specialized knowledge or involves multiple files/cross-layer concerns. Always delegate to `feature-orchestrator` when a task touches >3 architectural layers — inline execution at that scope is a P9 violation.

**Act directly when:** Simple, localized change (rename a variable, fix a typo, add an import). Cost of delegation exceeds cost of the task itself.

> Rule: If the task takes fewer tokens to DO than to DELEGATE, do it directly.

---

### 10. Fail-Fast Precondition Validation

Agents validate preconditions before executing procedures — they never guess or proceed with assumptions.

Every agent must check:
- Does the target file/module exist? (before `update-*` skills)
- Does the target file/module NOT exist? (before `create-*` skills — avoid overwriting)
- Are required dependencies available?
- Is the correct pattern in use?

When preconditions fail: return a clear, actionable message — never partially execute.

---

### 11. Agent Memory Governance

**What to remember:** Confirmed patterns, module-specific conventions not in reference docs, recurring mistakes, user-confirmed preferences.

**What NOT to remember:** Current task details, anything already in `CLAUDE.md` or `reference/`, unverified single-file observations, git history.

**Hygiene rules:** Keep `MEMORY.md` under 200 lines; use topic files for detailed notes; review and prune stale memories.

---

### 12. Official Docs Compliance

Every design decision must comply with Claude Code's official documentation.

**Compliance checklist:**
- Skill directories follow `.claude/skills/<name>/SKILL.md` convention
- Agent files follow `.claude/agents/<name>.md` convention
- Frontmatter fields use only documented keys
- Memory scopes and permission modes use documented values

Known undocumented but functional fields: `agents` field — empirically verified to work; not in official spec. Use with awareness that it may change.

---

### 13. Agent Naming Convention

| Type | Suffix | Example |
|---|---|---|
| Orchestrator | `-orchestrator` | `feature-orchestrator.md`, `pres-orchestrator.md` |
| Worker | `-worker` | `domain-worker.md`, `data-worker.md` |

Format: `<domain>-<role>.md`

> The filename suffix tells you the agent type instantly — no need to open the file.

---

### 14. CLEAN Architecture, SOLID, and DRY — Cross-Platform Enforcement

**CLEAN Architecture — Layer-Aligned Agents**

| Layer | Worker | Skills |
|---|---|---|
| Domain | `domain-worker` | `domain-create-entity`, `domain-create-usecase`, `domain-create-repository`, `domain-create-service`, `domain-update-usecase` |
| Data | `data-worker` | `data-create-datasource`, `data-create-mapper`, `data-create-response`, `data-create-repository-impl`, `data-update-mapper` |
| Presentation | `presentation-worker`, `ui-worker` | `pres-create-stateholder`, `pres-update-stateholder`, `pres-create-screen`, `pres-create-component`, `pres-create-navigator`, `pres-update-screen` |
| Test | `test-worker` | `test-create-domain`, `test-create-data`, `test-create-presentation`, `test-update`, `test-fix` |

**SOLID via Agent Design:**
- **SRP:** Each worker handles exactly one layer; each skill does exactly one task
- **OCP:** New features add new agents/skills without modifying existing ones
- **DIP:** Workers define the protocol; platform skills are the implementations
- **DRY via Architecture:** Reference docs are the single source of truth — skills Grep section pointers, never embed content.

---

### 15. Convention Enforcement — Self-Auditing Architecture

The agentic system enforces its own conventions through automated review — the same principle applied recursively.

**The internal convention system** (root `agents/` and `skills/` — NOT symlinked to downstream projects):

**What `arch-check-conventions` enforces:**

| Category | Rule | Severity |
|---|---|---|
| Frontmatter | `name`, `description`, `model`, `tools` required | Critical |
| Model assignment | `haiku` for mechanical workers, `sonnet` for orchestrators | Warning |
| Orchestrators | `isolation: worktree` inline with each Spawn directive | Critical |
| Orchestrators | File paths only between phases | Critical |
| Orchestrators | Writes state file after each phase | Warning |
| Orchestrators | No Phase 2 codebase reads | Critical |
| Orchestrators | After delegation flag set, no direct Edit or Write — all file changes through workers | Critical |
| Workers | `## Search Protocol` section with decision gate table | Warning |
| Workers | `## Output` section before Extension Point | Warning |
| Workers | `## Extension Point` section at end | Warning |
| Workers | No "Read ... completely" | Critical |
| Core agent platform-agnosticism | No hardcoded platform paths, framework refs, or language syntax in `lib/core/agents/` body | Critical |
| Fix F | Multi-file `Reference:` lines mention `reference/index.md` | Warning |
| Fix G | Template files: code hints only, no explanatory comments | Warning |
| Naming | `-orchestrator`/`-worker.md`; skill dirs `<layer>-<action>-<target>` | Info |
| Prompt Clarity | No ambiguous scope ("create the X" without specifying interface vs implementation); no instructions spanning two CLEAN layers without a stop condition; no contradicting rules; failure paths specified. Run `prompt-debug-worker` for deeper runtime reasoning analysis. | Warning |

**Platform-agnosticism rule:**
> `lib/core/` agents are consumed by ALL platforms via symlink. Platform-specific rules embedded in a core worker silently mislead workers on other platforms. Any match of platform paths, framework names, or language syntax in a `lib/core/agents/` body is a Critical violation.

**The two distinct reviewers:**

| Reviewer | Reviews | Location |
|---|---|---|
| `agents/arch-review-worker.md` | Agent/skill files in *this repo* for convention compliance | Root `agents/` — internal only |
| `lib/core/agents/auditor/arch-review-worker.md` | Application code in *downstream projects* for CLEAN violations | Symlinked to all platforms |

**Doc sync system:** Design docs are synced manually after sessions that change structure or conventions. `docs-sync-worker` accepts a session delta description, verifies repo state, and applies targeted section updates. `docs-identify-changes` maps delta topics to stale sections. This enforces the principle: fix implementation first, then sync design docs.

---

## Taxonomy

### Agents — By Role

| Role | Subordinates | Can write files? | Has `agents` field? | Has `skills` field? |
|---|---|---|---|---|
| Orchestrator | Other orchestrators or workers | No — delegates all writes to workers | Yes | Typically no |
| Worker | Skills via `related_skills` | Yes | No | Yes — skills injected at startup |

> Orchestrators may spawn other orchestrators when the inner orchestrator represents a fully bounded sub-workflow. The outer orchestrator owns the top-level state file and final report. Example: `feature-orchestrator` spawns `pres-orchestrator` for the presentation+UI phase — `pres-orchestrator` skips state file writes when called as a sub-orchestrator.

### Agents — By Scope

| Scope | Location | Ships downstream? |
|---|---|---|
| **Persona agent** | `lib/core/agents/<persona>/` | Yes — all platforms |
| **Platform agent** | `lib/platforms/<platform>/agents/` | Yes — matching platform only |
| **Project agent** | `.claude/agents.local/` | No — project-owned, not in this repo |

> Persona agents must be platform-agnostic — no platform paths, framework references, or language syntax in the body (Critical per P15).

### Persona

A named group of related agents serving a coherent workflow.

Requirements:
- Lives in `lib/core/agents/<persona>/`
- Has at least one worker or orchestrator
- Agents within the group relate to and can depend on each other
- Requires a `.pkg` file for selective installation

Shared to all downstream projects via symlink. Current personas: `builder`, `detective`, `tracker`, `auditor`, `installer`.

> A persona is not just a folder. It represents a coherent workflow. Do not group unrelated agents into a persona subdirectory.

### Skills — By Invocation Type

| Type | Config | Who triggers | Use for |
|---|---|---|---|
| **A — Regular** | `user-invocable: false` | Worker (agent) only | Standard build/update procedures |
| **B — Destructive** | `disable-model-invocation: true` | User only | Destructive or side-effect operations |
| **T — Trigger** | `user-invocable: true` + uses `Agent` tool | User only | Entry point that spawns an agent workflow |
| **U — Utility** | `user-invocable: true`, no `Agent` tool | User only | Self-contained interactive tool — runs with model, does not spawn agents |

> **Type T vs Type U:** Both are user-invocable and model-run. Type T spawns an agent workflow (`agentic-perf-review` → `perf-worker`). Type U does its own work directly (`doctor`, `clear-runs`, `release`).
>
> **Type B vs Type U:** Both are user-only. Type B disables model invocation entirely (pure bash, no reasoning). Type U runs with model invocation for interactive behaviour.

**Why no Type C (default — both user and agent):** Every default skill's description loads into the main session context on every turn. Types A, B, T, and U all eliminate this overhead.

### Skills — By Scope

| Scope | Location | Ships downstream? |
|---|---|---|
| **Toolkit skill** | `lib/core/skills/` | Yes — all platforms. Platform-agnostic, intended for use in downstream projects. |
| **Platform-contract skill** | `lib/platforms/<platform>/skills/` | Yes — matching platform. Same name across all platforms; each implements for its syntax — called by persona workers. |
| **Platform-only skill** | `lib/platforms/<platform>/skills/` | Yes — matching platform only. Called by platform agents. |
| **Project skill** | `.claude/skills.local/` | No — project-owned, not in this repo. |
| **Repo skill** | `skills/` (root) | No — internal tooling only. Used by this repo's internal agents; never symlinked to downstream projects. |

> "Core-dependency skill" used in earlier sections of this doc refers to platform-contract skills — skills all platforms must implement under the same name (`domain-create-entity`, `data-create-mapper`, etc.).

### Skills — Valid Type × Scope Combinations

Not all combinations are meaningful. Use this as the decision gate when adding a new skill:

| Scope | A — Regular | B — Destructive | T — Trigger | U — Utility |
|---|---|---|---|---|
| Toolkit | — | — | ✓ | ✓ |
| Platform-contract | ✓ | — | — | — |
| Platform-only | ✓ | ✓ | — | — |
| Project | ✓ | ✓ | ✓ | ✓ |
| Repo | ✓ | — | ✓ | ✓ |

> Toolkit skills are always user-facing (Type T or U) — agents don't call them, workers call platform-contract skills instead. Platform-contract skills are always Type A — they're called by workers programmatically, never by users directly.

---

## Decision Rules

| Situation | Where it goes |
|---|---|
| New CLEAN-layer behaviour, same on all platforms | Core worker |
| New orchestration flow, same on all platforms | Core orchestrator |
| New code generation pattern for one platform | Platform-contract skill (same name, platform implements) |
| Workflow too platform-specific for any core agent | Platform agent + platform skill |
| Architecture reference knowledge | `lib/platforms/<platform>/reference/` |

---

## Execution Examples

**Case 1: Direct Action** — "Add import RxSwift to this file" → single-line edit, no agent needed

**Case 2: Single-Layer Task** — "Create GetLeaveRequestListUseCase" → `domain-worker` spawned directly, assesses preconditions, sequences skills

**Case 3: Multi-Layer Task** — "Build the leave request feature" → `feature-orchestrator` coordinates 4 workers with `isolation: worktree`; passes file paths only; writes state file after each phase

**Case 4: Intelligent Selection** — "Create StateHolder, the UseCase already exists" → orchestrator spawns only `presentation-worker`

**Case 5: Type B Skill** — `/migrate-presentation CustomFormScreen` → explicit user trigger; prevents accidental migration

**Case 6: Debug Flow** — "Why is form submission silently failing?" → `debug-orchestrator` gathers context, spawns `debug-worker`

**Case 7: Cross-Platform Feature** — same CLEAN pattern, each codebase's `domain-worker` applies platform-specific skill

**Case 8: Standalone Worker** — "Review my branch before PR" → `pr-review-worker` directly, no orchestrator

**Case 9: Convention Audit** — "Run arch-review-orchestrator for lib/core" → spawns workers per scope with `isolation: worktree`; `arch-generate-report` formats findings

**Case 10: Doc Sync** — "Sync the docs — we added X and Y this session" → `docs-sync-worker` fetches current pages, runs `docs-identify-changes`, applies targeted updates

**Case 11: Project Setup** — "Set up this project with the starter kit" → `setup-worker` detects platform, runs `setup-nextjs-project` or `setup-ios-project` skill, provides orientation

**Case 12: Flutter Domain Entity Creation** — "Create a LeaveRequest entity for Flutter"

```
feature-orchestrator (core orchestrator)
  └─ domain-worker   (core worker)       ← knows the rules
        └─ domain-create-entity          ← flutter skill, knows the syntax
```

The worker knows the rules (no framework imports, single responsibility). The skill knows the syntax (Dart, `@freezed`, file naming).

**Case 13: iOS PR Review** — "Review my PR before merging"

```
pr-review-worker    (iOS platform worker)  ← iOS-specific workflow
  └─ review-pr      (iOS platform skill)   ← Swift/UIKit conventions
```

`review-pr` is not a core-dependency skill — only the iOS platform worker calls it, so it only needs to exist for iOS.

**Case 14: Agent Prompt Debugging** — "Why did domain-worker create an implementation instead of an interface?"

```
perf-worker        ← scores session D1–D7
  D2: 5/10         ← worker invocation anomaly flagged
prompt-debug-worker ← reads perf-report + domain-worker.md
  → surfaces ambiguous "create the repository" instruction
  → suggests rewrite with explicit scope
```

---

## Agent Count Summary

| Category | `lib/core/agents/` (shared) | `lib/platforms/ios/agents/` | `lib/platforms/web/agents/` |
|---|---|---|---|
| Orchestrators | 4 in `builder/` + 1 in `detective/` | 1 (`test-orchestrator`) | — |
| Workers | 8 in `builder/` + **2 in `detective/`** + 1 in `tracker/` + 1 in `auditor/`\* + 1 in `installer/` + 1 flat | 1 (`pr-review-worker`) | — |
| Skills (Type A) | — | 29 | 29 |
| Skills (Type B) | — | 2 | 0 |

\* `arch-review-worker` in `lib/core/agents/auditor/` is platform-agnostic — delegates web rules to `arch-check-web` (W1–W6) and iOS rules to `arch-check-ios` (I1–I4).

**Detective persona workers:** `debug-worker`, `prompt-debug-worker`

**Internal repo tooling** (NOT symlinked to downstream projects):

| Component | Location | Purpose |
|---|---|---|
| `arch-review-orchestrator`, `arch-review-worker`, `docs-sync-worker` | `agents/` (root) | Convention review + design doc sync |
| `arch-check-conventions`, `arch-generate-report`, `docs-identify-changes` | `skills/` (root) | Convention checklist, report formatter, delta mapper |

---

## Folder Design Rationale

| Decision | Why |
|---|---|
| All workers in `lib/core/agents/` | DI at skill level — platform-agnostic brains |
| Persona subdirectories | Workflow cohesion; selective installation; self-documenting |
| `perf-worker.md` stays flat | No persona peers yet |
| Root `agents/` and `skills/` | Internal tooling — not downstream API surface |
| `lib/` boundary | Explicit distributable surface — everything under `lib/` ships, everything outside is tooling |
| `arch-review-worker` platform-agnostic (P15) | Core workers must not embed platform knowledge |
| `docs-sync-worker` in root `agents/` | Maintains this repo's design docs — not relevant to downstream consumers |
| `setup-worker` in `lib/core/agents/installer/` | Platform-agnostic setup logic; delegates mechanical steps to platform skills |

---

## Why This Architecture

| Goal | How it's achieved |
|---|---|
| Token efficiency | Isolated context; Search Protocol decision gate; Haiku for mechanical workers; file paths only between phases; orchestrator state files prevent mid-run re-reads |
| Modular knowledge | Skills preloaded, not embedded |
| Single source of truth | `reference/` Grep-accessed, never duplicated |
| Safe destructive operations | `disable-model-invocation: true` on Type B |
| Reusability | Same skill preloaded into multiple workers |
| Maintainability | Update one skill → all workers get the update |
| Multi-platform scalability | Add `lib/platforms/<platform>/skills/` — no agent changes |
| Selective installation | Persona `.pkg` files |
| Self-enforcing conventions | Internal arch-reviewer catches violations before downstream consumers |
| Design doc fidelity | `docs-sync-worker` keeps Confluence in sync after every structural session |
| Clear distributable boundary | `lib/` = ships downstream; everything outside = internal tooling |
| Agent prompt quality | `prompt-debug-worker` surfaces ambiguous instructions when perf scores flag low D1–D7 |

---

## Official Documentation

| Topic | URL |
|---|---|
| Subagents | https://code.claude.com/docs/en/sub-agents |
| Skills | https://code.claude.com/docs/en/skills |
| Context window | https://code.claude.com/docs/en/context-window |
| Agent Teams | https://code.claude.com/docs/en/agent-teams |
| Hooks | https://code.claude.com/docs/en/hooks |
| MCP | https://code.claude.com/docs/en/mcp |
| Memory & CLAUDE.md | https://code.claude.com/docs/en/memory |
| Settings | https://code.claude.com/docs/en/settings |
| Permissions | https://code.claude.com/docs/en/permissions |

---

## Implementation Reference

- **talenta-ios** — 4 orchestrators, 7 workers, 27 skills. Content mirrored in `lib/platforms/ios/`.
- **mobile-talenta (Flutter)** — 7 agents, 9 skills. BLoC-based, get_it + injectable DI.
- **talenta-mobile-android** — 7 agents, 7 skills. MVP-based, Dagger 2 DI, RxJava 3.
- **software-dev-agentic v3.14.0** — Core: 15 agents across 5 persona groups (builder, detective, tracker, auditor, installer) under `lib/core/`. Platforms: web (29 Type A skills), ios (2 platform agents, 29 Type A + 2 Type B skills), all under `lib/platforms/`. Internal: 3 agents, 3 skills at repo root.
- **wehire, xpnsio** — web projects consuming software-dev-agentic as a git submodule.

> **Breaking:** downstream projects must re-run setup scripts after updating the submodule pointer.

---

## Changelog

**v34 — 2026-04-17 · software-dev-agentic v3.15.0**
- `pres-orchestrator` promoted to sub-orchestrator of `feature-orchestrator` — `feature-orchestrator` now delegates Phase 3 entirely to `pres-orchestrator` instead of spawning `presentation-worker`/`ui-worker` directly
- `feature-orchestrator`: `agents:` field updated (removed `presentation-worker`, `ui-worker`; added `pres-orchestrator`); Phase 3 rewritten; Phase 4 (UI) removed; Phase 5 renumbered to Phase 4
- `pres-orchestrator`: dual-mode added — standalone (full gather + state file) vs sub-orchestrator (Grep provided paths, skip state file); P8 Combined Matrix updated to show `feature-orchestrator → pres-orchestrator` hierarchy
- Taxonomy: orchestrator-of-orchestrators note updated with concrete example

**v33 — 2026-04-17 · software-dev-agentic v3.15.0**
- Taxonomy gaps closed: Type U (Utility) skill added — user-invocable, model-run, self-contained, no agent spawning; `doctor`, `clear-runs`, `release` classified as Type U
- Repo skill scope added — root `skills/` internal tooling, never ships downstream; `arch-check-conventions`, `arch-generate-report`, `docs-identify-changes` classified here
- Skill Type × Scope intersection matrix added — decision gate for valid combinations when adding new skills
- Toolkit skill scope clarified: ships downstream, intended for use in downstream projects (not this repo's internal operations)
- `release` skill description fixed: was "software-dev-agentic starter kit" specific, now generic downstream-project release tool

**v32 — 2026-04-17 · software-dev-agentic v3.15.0**
- Taxonomy section added — replaces the minimal "Agent & Skill Hierarchy" table with full formal definitions
- Agents by Role: Orchestrator / Worker with subordinate clarification; orchestrator-of-orchestrators constraint added
- Agents by Scope: Persona agent / Platform agent / Project agent formally named
- Persona: formal definition — coherent workflow requirement, `.pkg` file requirement, minimum one worker/orchestrator
- Skills by Invocation Type: Type T (Trigger) formalized — `user-invocable: true` + `Agent` tool, distinct from Type B; `agentic-perf-review` cited as canonical example
- Skills by Scope: Toolkit skill / Platform-contract skill / Platform-only skill / Project skill named; "core-dependency skill" cross-referenced as alias for platform-contract skill

**v31 — 2026-04-17 · software-dev-agentic v3.14.0**
- `prompt-debug-worker` added to `lib/core/agents/detective/` — diagnoses why an agent underperformed by analyzing its system prompt against the trajectory from a perf-worker report; surfaces ambiguous instructions, missing context, and contradicting rules
- `perf-worker` updated: new Step 5 flags low D1–D7 scores and points to `prompt-debug-worker` with the exact agent file path to debug
- P15 `arch-check-conventions`: Prompt Clarity Check category added (Warning severity) — flags ambiguous scope, missing stop conditions, contradicting rules, undefined failure paths
- Agent Count Summary updated: detective workers 1→2 (total core workers 13→14)
- P8 Combined Matrix updated: `prompt-debug-worker` added to Core workers
- Execution Example Case 14 added: agent prompt debugging flow

**v30 — 2026-04-16 · software-dev-agentic v3.4.6**
- P3: "By Caller" skill dependency classification added — core-dependency skills (must exist on all platforms) vs platform-specific skills (platform-agent-only); explicit table mapping skill → caller → platform coverage required
- P8: Agent Scope (Core vs Platform-specific) added with rule "Do not add a platform agent unless a core agent + skills cannot handle it"; Combined Matrix (Role × Scope) added
- Decision Rules table added (before Execution Examples)
- Execution Examples: Cases 12 (Flutter entity creation) and 13 (iOS PR review) added

**v29 — 2026-04-14 · software-dev-agentic v3.4.6**
- P15 arch-check-conventions table — Orchestrators row updated: `isolation: worktree` in Constraints → `isolation: worktree` inline with each Spawn directive (Critical); new Critical rule added: After delegation flag set, no direct Edit or Write — all file changes through workers
- "Synced with" updated to v3.4.6

**v28 — 2026-04-13 · software-dev-agentic v3.0.1**
- P7: "Search Rules" bullet replaced with Search Protocol decision gate table
- P8: Added steps 7–8 — orchestrator writes state file; `presentation-worker` writes StateHolder contract to handoff file
- P15 arch-check-conventions: Workers row updated; Orchestrators row updated

**v27 — 2026-04-12 · software-dev-agentic v3.0.0**
- `lib/` boundary introduced; all path references updated

**v26 — 2026-04-12 · software-dev-agentic v2.1.0**
- `installer/` persona group added; `setup-ios-project` skill added

**v25 — 2026-04-12 · software-dev-agentic v2.0.0**
- `docs-sync-worker` + `docs-identify-changes` added to internal tooling

**v24 — 2026-04-12 · software-dev-agentic v2.0.0**
- Principle 15 added: Convention Enforcement — self-auditing architecture

**v23 — 2026-04-12 · software-dev-agentic v1.2.x**
- `core/agents/` grouped into persona subdirectories

**v22 and earlier** — See git history in the software-dev-agentic repository.
