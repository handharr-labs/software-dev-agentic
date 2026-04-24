> Author: Puras Handharmahua · 2026-04-08
> Related: Shared Agentic Submodule Architecture — Cross-Platform Scaling

## What is an Agentic Coding Assistant?

A coding assistant where Claude autonomously routes, decides, and executes based on natural language — without the user needing to know which tool, command, or workflow to invoke. The user describes intent. The assistant figures out the rest.

> No slash commands. No manual chaining. No context pollution.

---

## Design Goals

1. **Consistent agentics across platforms** — same agents, same principles, one source of truth
2. **Easy to maintain** — update once, all projects get it
3. **Open contribution model** — all engineers can explore, create, and PR new agents/skills
4. **Context efficiency** — no wasted tokens on irrelevant content
5. **Encouraging initiatives** — low barrier to propose new "personas" (orchestrators)

---

## Core Design Principles

### 1. Natural Language as the Entry Point

There are two valid entry points into the agentic system:

**A — Natural language routing (default):** Users describe what they want; Claude matches the intent to an agent's description and spawns it automatically. No slash commands, no manual chaining.

**B — Trigger skill:** A user-invocable skill (`user-invocable: true`) that explicitly spawns an agent workflow. Use this when the entry point is a specific, named operation — not open-ended intent. The skill owns the full entry sequence: routing (resume vs new run), context pre-loading from the runs directory, and spawning the agent with context already inlined. The agent handles the work.

> Agent descriptions must be precise and use vocabulary developers naturally say. Routing is only as good as the description.

> Not every request needs an agent. If a change is simple and localized (rename a variable, fix a typo, add an import), act directly — the cost of delegation exceeds the task itself.

**Skill-First Entry for Personas:**

Every persona must have exactly one primary entry agent. That agent must have a corresponding Type T trigger skill. The skill is the only supported entry path — direct agent invocation bypasses context loading and is unsupported.

| Role | Has trigger skill? | Spawned by |
|---|---|---|
| Persona entry agent (orchestrator, or single worker if no orchestrator) | Yes — required | User via trigger skill |
| Workers inside a persona | No | Orchestrator only |

The trigger skill owns three responsibilities before spawning the agent:
1. **Routing** — detect existing runs (resume vs new call) and ask the user when ambiguous
2. **Context pre-loading** — read `context.md` and `state.json` from the runs directory (cache hits in the same session) and inline them into the spawn prompt
3. **Spawn prompt construction** — pass the pre-loaded block so the agent can skip all cold pre-flight file reads

The agent detects the `Pre-loaded context` block in its prompt and jumps directly to the first pending phase. Without it, the agent warns that direct invocation is unsupported.

> **Adding a new persona:** create the entry agent + its trigger skill together. A persona without a trigger skill is incomplete.

---

### 2. Agents = Brain (Decision-Maker)

Agents are intelligent specialists, not task executors. Each agent:

- Assesses context before acting (does this file exist? which pattern applies?)
- Decides which procedure to execute
- Handles edge cases and branching logic
- Knows *what* to do and *when*

Agents stay lean — they don't embed step-by-step instructions. That belongs in skills.

**Orchestrators — Multi-Worker Coordinators:**

Orchestrators coordinate multiple worker agents using the `agents` field in frontmatter. Key rules:

- Spawn only relevant workers — never all of them
- Pass file paths between phases, never file contents

- Validate each worker's `## Output` before proceeding — STOP if missing or paths don't exist
- Never read the codebase directly — workers own their own context reads

**Agent Scope — Core vs Platform-specific:**

Agents have a second axis — where they live and what they know.

- **Core** (`lib/core/agents/`) — platform-agnostic. Work on any platform. Add here when the behaviour is identical across all platforms.
- **Platform-specific** (`lib/platforms/<platform>/agents/`) — exist only when the workflow diverges enough from core to need its own agent. Examples: iOS `test-orchestrator` (knows `xcodebuild`), iOS `pr-review-worker` (knows Swift/UIKit conventions). Do not add a platform agent unless a core agent + platform skills cannot handle it.

> For the full agent roster, see [persona-builder.md](persona/builder.md).

**DI at Skill Level:**

Workers are platform-agnostic protocol-definers. Skills are the platform-specific implementations of that protocol. A `domain-worker` calls `domain-create-entity` by name — on iOS that creates a Swift struct, on web a TypeScript interface. The worker never knows which platform it's on and doesn't need to.

| Role | Protocol analogy | Platform-aware? |
|---|---|---|
| Orchestrators | Interface contract | No |
| Workers | Use-case logic | No |
| Skills | Concrete implementation | Yes |

**Layer Isolation — Bounded Knowledge and Authority:**

Each worker's knowledge and write authority is strictly bounded to its own CLEAN layer.

- A worker knows only the rules, patterns, and conventions of its layer
- A worker writes only to its layer's files — it never reads or modifies files owned by another layer
- Cross-layer knowledge (shared contracts, interfaces) lives in reference docs and skills, not in worker bodies
- If a task requires cross-layer work, the orchestrator coordinates multiple workers — it never asks one worker to reach into another layer

This keeps each worker's context small and its reasoning correct for its scope. When a worker receives out-of-scope work, it stops and names the correct worker instead of proceeding.

**Agent Memory Governance:**

**What to remember:** Confirmed patterns, module-specific conventions not in reference docs, recurring mistakes, user-confirmed preferences.

**What NOT to remember:** Current task details, anything already in `CLAUDE.md` or `reference/`, unverified single-file observations, git history.

**Hygiene rules:** Keep `MEMORY.md` under 200 lines; use topic files for detailed notes; review and prune stale memories.

**Agent Naming Convention:**

| Type | Suffix | Example |
|---|---|---|
| Orchestrator | `-orchestrator` | `feature-orchestrator.md`, `pres-orchestrator.md` |
| Worker | `-worker` | `domain-worker.md`, `data-worker.md` |

Format: `<domain>-<role>.md`

> The filename suffix tells you the agent type instantly — no need to open the file.

---

### 3. Skills = Hands (Thin Procedures)

Skills are focused, reusable workflow procedures. Each skill:

- Does one thing only
- References architecture docs — never embeds them
- Has no branching logic — agent decides which skill to call

Target: under 30 lines per skill

> Naming: `<layer>-<action>-<target>`. Split by intent: `create-*` for new, `update-*` for existing. Keep `SKILL.md` under 500 lines. Skills are either **core-dependency** (same name on all platforms) or **platform-specific** (one platform only) — see [persona-builder.md](persona/builder.md).

**Preloading skills:**

Agents load their procedure skills at startup via the `skills` field — full skill content is injected at startup. This gives agents full procedural knowledge without embedding it in their body. Same procedures are reusable across multiple agents. One definition, updated once.

**Token budget guideline:**
- Preload skills the agent needs in >50% of its invocations
- Load on demand (via `Read`) skills needed rarely or only in edge cases
- Monitor total preloaded size — if it exceeds ~500 lines, split the agent or move low-frequency skills to on-demand

**Three consumer modes:**

Downstream projects interact with shared agents and skills in one of three modes:

| Mode | Mechanism | When to use |
|---|---|---|
| **Use** | Shared symlink → submodule file | Works as-is — standard workflow |
| **Extend** | Shared symlink + `*.local/extensions/<name>.md` | Add behavior without losing submodule updates |
| **Override** | Real file in `*.local/` | Fundamentally different behavior needed |

Extension files contain only the delta — not a full copy. Updates to the submodule are inherited automatically.

> Skills have four invocation types (A, B, T, U) — see [Taxonomy §Skills — By Invocation Type](#skills--by-invocation-type) for the full breakdown and decision rules.

---

### 4. Taxonomy

#### Persona

A named group of related agents serving a coherent workflow.

Requirements:
- Lives in `lib/core/agents/<persona>/`
- Has at least one worker or orchestrator
- Agents within the group relate to and can depend on each other
- Requires a `.pkg` file for selective installation

Shared to all downstream projects via symlink. Current personas: `builder`, `detective`, `tracker`, `auditor`, `installer`.

> A persona is not just a folder. It represents a coherent workflow. Do not group unrelated agents into a persona subdirectory.

#### Agents — By Role

| Role | Subordinates | Can write files? | Has `agents` field? | Has `skills` field? |
|---|---|---|---|---|
| Orchestrator | Other orchestrators or workers | No — delegates all writes to workers | Yes | Typically no |
| Worker | Skills via `related_skills` | Yes | No | Yes — skills injected at startup |

> Orchestrators may spawn other orchestrators when the inner orchestrator represents a fully bounded sub-workflow. The outer orchestrator owns the top-level state file and final report. Example: `feature-orchestrator` spawns `pres-orchestrator` for the presentation+UI phase — `pres-orchestrator` skips state file writes when called as a sub-orchestrator.

#### Agents — By Scope

| Scope | Location | Ships downstream? |
|---|---|---|
| **Persona agent** | `lib/core/agents/<persona>/` | Yes — all platforms |
| **Platform agent** | `lib/platforms/<platform>/agents/` | Yes — matching platform only |
| **Project agent** | `.claude/agents.local/` | No — project-owned, not in this repo |

> Persona agents must be platform-agnostic — no platform paths, framework references, or language syntax in the body (Critical per P6).

#### Skills — By Invocation Type

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

#### Skills — By Scope

| Scope | Location | Ships downstream? |
|---|---|---|
| **Toolkit skill** | `lib/core/skills/` | Yes — all platforms. Platform-agnostic, intended for use in downstream projects. |
| **Platform-contract skill** | `lib/platforms/<platform>/skills/contract/` | Yes — matching platform. Same name across all platforms; each implements for its syntax — called by persona workers. Lands flat in `.claude/skills/<name>/` downstream. |
| **Platform-only skill** | `lib/platforms/<platform>/skills/` (flat) | Yes — matching platform only. Called by platform agents. |
| **Project skill** | `.claude/skills.local/` | No — project-owned, not in this repo. |
| **Repo skill** | `.claude/skills/` | No — internal tooling only. Used by this repo's internal agents; never symlinked to downstream projects. |

> "Core-dependency skill" used in earlier sections of this doc refers to platform-contract skills — skills all platforms must implement under the same name (`domain-create-entity`, `data-create-mapper`, etc.).

#### Skills — Valid Type × Scope Combinations

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


### 5. Context Isolation = Efficiency

Every agent runs in its own isolated context window — completely separate from the main session. This is the primary mechanism for token efficiency.

From the official docs:
> *"Preserve context by keeping exploration and implementation out of your main conversation"*

When a worker reads reference docs, scans existing files, and writes code — none of that touches your main session context. The main session only sees the result.

**Context cost by component:**

| Component | Context cost | Mechanism |
|---|---|---|
| Core agents (descriptions) | ~3–5 lines each in main session | Agent tool definition |
| Platform-specific agents (descriptions) | ~3–5 lines each in main session | Agent tool definition |
| Preloaded skills | Loaded at worker startup only | `skills` field |
| Reference docs | 1 Grep call per section needed | Grep-first in worker body |
| `agents.local/extensions/` | 1 Read call (conditional) | Extension hook in shared agent |
| Dead weight (unselected groups) | Zero | Persona groups not linked if not selected |
| Orchestrator context accumulation | Minimal — file paths only | Workers return paths, not content; state file prevents re-reads |
| Context relay (trigger skills) | Zero cold reads on resume | Skill reads `context.md` + `state.json` from runs directory (cache hit — same session), passes inline to spawn prompt; orchestrator detects pre-loaded block and skips pre-flight file reads entirely |

**Context relay pattern:**

When a trigger skill spawns an orchestrator, it pre-loads the runs context into the spawn prompt rather than letting the orchestrator re-read files cold. The skill runs in the root agent's context — if `context.md` and `state.json` were written earlier in the same session, they are already in the prompt cache (cache reads at $0.30/MTok). The orchestrator receives context on its first token and jumps directly to execution.

This eliminates the orchestrator's cold pre-flight penalty (cache misses at $3.75/MTok for cache creation, $3.00/MTok for full input) while keeping the disk files as the authoritative source for workers.

---

### 6. Knowledge Architecture

**Three-tier structure:**

| Tier | Location | What goes here |
|---|---|---|
| 1 | `CLAUDE.md` | Universal rules applying to every task — naming, principles, build command. ~1 page max |
| 2 | Agent body | Decision logic for that agent only — what to do, when to do it |
| 3 | `.claude/reference/` | Shared deep reference — patterns, examples, conventions. Loaded on demand via Grep-first |

> Folder structure for reference docs: see [submodule-repo-structure.md](submodule-repo-structure.md).

**Placement decision rule — reference vs agent body:**

| Put it in reference if… | Keep it in the agent body if… |
|---|---|
| It is a fact true regardless of who reads it | It is an instruction specific to this agent's workflow |
| It is an invariant, contract, or architectural principle | It is a decision: when to run, what to check, what to do on failure |
| Multiple agents need the same knowledge | Only this agent needs it |
| Removing it from the agent would lose shared truth | Removing it from the agent would lose execution behavior |

> One-line test: can you state it as a rule without saying "you"? If yes — reference. If it only makes sense addressed to the agent — agent body.

**Enforcement — Search Protocol (decision gate):**

Before any `Read` call, workers answer: "Do I need the full file, or just a specific symbol/section?"

| What you need | Tool |
|---|---|
| A specific class, function, or type | `Grep` for the name |
| A section of a reference doc | `Grep` for the section heading |
| The full file structure (style-matching a new file) | `Read` — justified |
| Whether a file exists | `Glob` |

Read a full file only when: (a) you need its complete structure to write a new matching file, or (b) Grep returned no results. Check `reference/index.md` first if uncertain which file covers a topic.

> Read:Grep ratio should stay below 3. A ratio above 6 is a P6 violation.

---



### 7. Fail-Fast Precondition Validation

Agents validate preconditions before executing procedures — they never guess or proceed with assumptions.

**Workers check on entry (`## Input`):**
- Are all required spawn parameters present? — return `MISSING INPUT: <param>` immediately if not
- Is the task within this worker's layer scope? — STOP and name the correct worker if not

**Workers check before writing (`## Preconditions`):**
- Does the target file/module exist? (before `update-*` skills)
- Does the target file/module NOT exist? (before `create-*` skills — avoid overwriting)
- Are required dependencies available?

**Workers check before returning (`## Output`):**
- Does each created file exist on disk? (`Glob`)
- Does each file contain the expected primary class or function? (`Grep`)
- Only list paths that pass both checks

**Orchestrators check after each worker spawn:**
- Does the worker response contain an `## Output` section?
- Do all listed paths exist on disk?
- If either check fails: STOP — do not proceed to the next phase

When any check fails: return a clear, actionable message — never partially execute or silently continue.

---


### 8. Official Docs Compliance

Every design decision must comply with Claude Code's official documentation.

**Compliance checklist:**
- Skill directories follow `.claude/skills/<name>/SKILL.md` convention
- Agent files follow `.claude/agents/<name>.md` convention
- Frontmatter fields use only documented keys
- Memory scopes and permission modes use documented values

Known undocumented but functional fields: `agents` field — empirically verified to work; not in official spec. Use with awareness that it may change.

---


### 9. Convention Enforcement — Self-Auditing Architecture

The agentic system enforces its own conventions through automated review — the same principle applied recursively. Convention compliance tooling audits agent and skill files for structural violations before they reach downstream consumers.

> For the internal reviewer setup, checklist, and severity levels, see [submodule-repo-structure.md — Convention Compliance System](submodule-repo-structure.md#convention-compliance-system).

---


## Decision Rules

| Situation | Where it goes |
|---|---|
| New CLEAN-layer behaviour, same on all platforms | Core worker |
| New orchestration flow, same on all platforms | Core orchestrator |
| New code generation pattern for one platform | Platform-contract skill (same name, platform implements) → `lib/platforms/<platform>/skills/contract/` |
| Workflow too platform-specific for any core agent | Platform agent + platform skill → `lib/platforms/<platform>/skills/` (flat) |
| Architecture reference knowledge (cross-platform standard) | `lib/platforms/<platform>/reference/contract/<persona>/` — grouped by persona; accessible as `.claude/reference/contract/<persona>/<name>.md` downstream |
| Architecture reference knowledge (platform-specific) | `lib/platforms/<platform>/reference/` (flat) |

> For execution examples and the current agent roster, see [persona-builder.md](persona/builder.md).

---

## Why This Architecture

| Goal | How it's achieved |
|---|---|
| Token efficiency | Isolated context; Search Protocol decision gate; Haiku for mechanical workers; file paths only between phases; orchestrator state files prevent mid-run re-reads; context relay — skill pre-loads warm-cache runs context into spawn prompt, eliminating orchestrator cold pre-flight reads |
| Modular knowledge | Skills preloaded, not embedded |
| Single source of truth | `reference/` Grep-accessed, never duplicated |
| Safe destructive operations | `disable-model-invocation: true` on Type B |
| Reusability | Same skill preloaded into multiple workers |
| Maintainability | Update one skill → all workers get the update |
| Multi-platform scalability | Add `lib/platforms/<platform>/skills/` — no agent changes |
| Selective installation | Persona `.pkg` files |
| Self-enforcing conventions | Internal arch-reviewer catches violations before downstream consumers |
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

## Changelog

See [changelog-core-design-principles.md](changelog-core-design-principles.md).
