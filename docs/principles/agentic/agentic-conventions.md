> Author: Puras Handharmahua · 2026-04-08
> Related: [agentic-design-principles.md](agentic-design-principles.md) · [agentic-directory-structure.md](agentic-directory-structure.md) · [repo-structure.md](../repo-structure.md)

Component types, naming conventions, authoring rules, and decision rules for contributing agents, skills, and reference docs.

---

## The Agentic Stack

The agentic stack is the governing execution model for every persona in this system.

```
User
 │
 ▼
Orchestrator Skill (Type O)   ← user-facing entry; routes, pre-loads context, spawns agents
 │
 ▼
Agent(s)                      ← reasoning layer; strategist / planner / worker
 │
 ▼
Procedure Skill(s) (Type P)   ← implementation unit; called by agents, never by users
```

| Tier | Component | Role |
|---|---|---|
| **Entry** | Orchestrator Skill (Type O) | User-facing. Routes (resume vs new), pre-loads context, spawns agents, owns convergence loop and approval gate. |
| **Execution** | Agent (strategist / planner / worker) | Reasoning layer. Decides what to do; calls Procedure Skills for platform-specific artifact creation. |
| **Action** | Procedure Skill (Type P) | Implementation unit. One artifact type per skill. Called by agents only; contains no routing or decision logic. |

Both ends of the stack are Skills. The agent is the reasoning layer sandwiched between them — it cannot be invoked by a user and has no implementation logic of its own.

Not every persona uses all three tiers. Simple workflows may have only an Orchestrator Skill and a worker with no Procedure Skills. The stack scales down; it does not impose layers that don't serve the workflow.

The sections below define each component in detail.

---

## Component Types

> For the concrete directory layout referenced below (`lib/core/<persona>/`, `lib/core/shared/`, `.claude/`, etc.), see [agentic-directory-structure.md](agentic-directory-structure.md).

### Persona

A named group of related agents serving a coherent workflow.

Requirements:
- Lives in `lib/core/<persona>/agents/`
- Has at least one worker or strategist
- Agents within the group relate to and can depend on each other
- Requires a `.pkg` file for selective installation

Shipped to all downstream projects via plugin. Current personas: `developer`, `debugger`, `tracker`, `auditor`.

**Persona → SDLC role mapping:**

Each persona maps to a real-world role and the SDLC phase that role owns. The Orchestrator skills within a persona are the agentic equivalents of that role's actual workflows.

| SDLC Phase | Role | Persona | Status |
|---|---|---|---|
| Implementation | Software Engineer | `developer` | Live |
| Testing | QA Engineer | `qa` | Live |
| Other phases (Requirement, Design, Delivery) | — | — | Research |

A persona's Orchestrator skills directly mirror the role's day-to-day workflows. Adding a new phase means identifying its role, mapping its workflows, and building one Orchestrator skill per workflow — using the same 4 design questions.

> A persona is not just a folder. It represents a coherent workflow. Do not group unrelated agents into a persona subdirectory.

---

### Agents

#### By Role

Agent roles are descriptive, not prescriptive. A persona defines whatever agent structure fits its workflow — there is no required set of roles. The following are common patterns seen in existing personas, documented here as reference.

**Strategist — reasoning agent (developer persona pattern):**

A strategist is a pure reasoning agent. It decides what to do and returns structured Decision blocks — it never spawns agents or writes source files directly. Tool set: `Read`, `Glob`, `Grep` only.

- Accepts modes from the calling skill: `gather-intent`, `gather-intent-prefilled`, `process-findings`, `synthesize`, `execute-approved-plan`, `resume`
- Returns `Decision: spawn-planners` (which layers, why), `Decision: converged`, `Decision: spawn-worker`, or `Decision: blocked`
- In `synthesize` mode: writes `plan.md` and `context.md` to the runs directory — the only files a strategist may write
- The calling skill owns all agent spawning, the convergence loop, and user interaction

**Planner — read-only explorer (developer persona pattern):**

A planner explores one CLEAN layer and returns structured findings. It is always read-only with respect to source code.

- Restricted to read-only tools (`Glob`, `Grep`, `Read`)
- Scoped to its own layer's directories and artifact types
- Returns findings including `### Impact Recommendations` — which other layers are affected and why
- Spawned by the entry skill (not the strategist) based on the strategist's Decision block

Sub-planners are all leaf agents: they explore, report, and return. No further spawning.

> Strategists may spawn other strategists when the inner strategist represents a fully bounded sub-workflow. The outer strategist owns the top-level state file and final report.

#### By Scope

| Scope | Location | Ships downstream? |
|---|---|---|
| **Persona agent** | `lib/core/<persona>/agents/` | Yes — all platforms |
| **Platform agent** | `lib/platforms/<platform>/agents/` | Yes — matching platform only |
| **Project agent** | `.claude/agents.local/` | No — project-owned, not in this repo |

> Persona agents must be platform-agnostic (Critical per P6). The body must not contain:
> - Hardcoded platform paths: `src/domain/`, `src/data/`, `Talenta/Module/`, `lib/`, `app/`
> - Framework references as rules: `React`, `Next.js`, `RxSwift`, `UIKit`, `BLoC`, `axios`
> - Language-specific syntax as rules: `'use client'`, `readonly` (TypeScript), `BehaviorRelay`
>
> Platform knowledge must be delegated to a skill in `related_skills` — never embedded inline. Does not apply to files under `.claude/agents/`.

---

### Skills

#### By Invocation Type

| Type | Config | Who triggers | Use for |
|---|---|---|---|
| **P — Procedure** | `user-invocable: false` | Worker (agent) only | Thin create-only procedures |
| **O — Orchestrator** | `user-invocable: true` | User only | User entry point — owns and runs the workflow. Simple workflows do their own work; complex ones delegate to agents. |

> For automated bash execution without model involvement, use hooks in `settings.json` — not a skill.

**Why no default skill type (invocable by both user and agent):** Every default skill's description loads into the main session context on every turn. Types P and O eliminate this overhead.

**Orchestrator subtypes — by config:**

| Subtype | Config | Use for |
|---|---|---|
| Trigger | `user-invocable: true` + uses `Agent` tool | Entry point that spawns an agent workflow |
| Utility | `user-invocable: true`, no `Agent` tool | Self-contained interactive tool, runs with model |
| Destructive | `disable-model-invocation: true` | Pure bash, destructive or side-effect operations — user only |

#### By Scope

| Scope | Location | Ships downstream? |
|---|---|---|
| **Toolkit skill** | `lib/core/<persona>/skills/` | Yes — all platforms. Platform-agnostic, intended for use in downstream projects. |
| **Platform-contract skill** | `lib/platforms/<platform>/skills/contract/` | Yes — matching platform. Same name across all platforms; each implements for its syntax — called by persona workers. Bundled flat as `<name>/SKILL.md` in the plugin. |
| **Platform-only skill** | `lib/platforms/<platform>/skills/` (flat) | Yes — matching platform only. Called by platform agents. |
| **Project skill** | `.claude/skills.local/` | No — project-owned, not in this repo. |
| **Repo skill** | `.claude/skills/` | No — internal tooling only. Used by this repo's internal agents; never bundled into downstream plugins. |

> "Core-dependency skill" refers to platform-contract skills — skills all platforms must implement under the same name (`developer-domain-create-entity`, `developer-data-create-mapper`, etc.).

#### Valid Type × Scope Combinations

Not all combinations are meaningful. Use this as the decision gate when adding a new skill:

| Scope | P — Procedure | O — Orchestrator |
|---|---|---|
| Toolkit | — | ✓ |
| Platform-contract | ✓ | — |
| Platform-only | ✓ | ✓ |
| Project | ✓ | ✓ |
| Repo | ✓ | ✓ |

> Toolkit skills are always user-facing (Type O) — agents don't call them, workers call platform-contract skills instead. Platform-contract skills are always Type P — they're called by workers programmatically, never by users directly.

---

### Reference Docs

> See [Reference vs Knowledge](agentic-design-principles.md#reference-vs-knowledge) for the distinction between KMS-managed Knowledge and file-addressable Reference docs.

#### Knowledge (KMS)

| Scope | Location | Ships downstream? |
|---|---|---|
| **Platform-base knowledge** | `kms/knowledge-sources/engineering/{platform}-*.md` | Yes — via pre-seeded ChromaDB bundled in plugin. Theory + definition + code pattern per node. Shared across all projects on that platform. |
| **Project knowledge** | `kms/knowledge-sources/projects/{name}/` | Yes — via pre-seeded ChromaDB. Project-specific deviations only — created only when real divergence exists. |

#### Reference (lib/core)

| Scope | Location | Ships downstream? |
|---|---|---|
| **Shared reference** | `lib/core/shared/reference/<topic>/` | Yes — all personas, all platforms. Cross-cutting facts/contracts shared by multiple agents (e.g. `saturn-jaygarcia/plan-format.md`). Topic-grouped. Bundled to `reference/shared/<topic>/` in the plugin. |
| **Persona reference** | `lib/core/<persona>/reference/` | Yes — all platforms. Flat — no topic subfolders. Contains `<name>-catalog.md` (queryable symbol/component inventory — agents `symbol-query` these, never load in full) and cross-agent schema/contract docs (e.g. `plan-format.md`, `findings-format.md`). Bundled flat to `reference/<persona>/` in the plugin. |
| **Project reference** | `.claude/reference.local/` | No — project-owned, not in this repo. Overrides for project-specific conventions not in KMS. |

> **Runtime path from agent body:** `copy_reference` (in `scripts/plugin-lib.sh`) bundles `lib/core/<persona>/reference/**` (including `lib/core/shared/reference/`) into `dist/plugins/<name>/reference/<persona-or-shared>/**` at build time, preserving whatever structure exists under each `reference/` dir — flat for persona reference, topic-grouped for shared reference. Agents must reference these docs as `$CLAUDE_PLUGIN_ROOT/reference/<persona-or-shared>/<path>` — never `.claude/reference/...` (that path is project-owned via `.claude/reference.local/`, not plugin-shipped, and resolves against the downstream project root, not the plugin cache).

---

## Anatomy of a Persona

A persona is composed of layered components that connect user intent to executed code. Each layer has a defined role, authority boundary, and handoff contract.

```
User
 │
 ▼
Orchestrator Skill (Type O) — routes (resume vs new), pre-loads context, builds spawn prompt, owns convergence loop, spawns agents, approval
 │
 ▼  (gather-intent / decision round)
Strategist               — brain only; returns Decision blocks; never spawns agents or writes files
 │
 │  Decision: spawn-planners
 ▼
Trigger Skill              — spawns planners in parallel per round; accumulates findings
 │
 ▼  (sends findings back each round)
Strategist               — reads impact recommendations; decides: more rounds or converged?
 │
 │  Decision: converged → Trigger Skill synthesizes plan → user approval
 │  Decision: spawn-worker
 ▼
Trigger Skill              — spawns Worker with plan + context injected inline
 │
 ▼
Worker                     — reads plan, calls skills, writes source files, validates output
 │
 ▼
Skill(s)                   — concrete platform implementation (one per artifact type)
```

Not every persona uses all layers. A simple persona may have only a trigger skill + worker. A complex one adds a strategist, planners, and multiple workers. The anatomy is the same regardless of how many layers are present.

**Handoff contracts — what each layer passes to the next:**

| From → To | What is passed | What is never passed |
|---|---|---|
| Trigger Skill → Strategist | Intent / mode + accumulated findings (per round) | Raw file reads from the main session |
| Strategist → Trigger Skill | Structured Decision block (`spawn-planners`, `converged`, `spawn-worker`, `blocked`) | Agent spawns or file writes |
| Trigger Skill → Planner | Feature name, platform, module-path + mode instruction | Strategist's internal reasoning |
| Planner → Trigger Skill | Structured findings block including `### Impact Recommendations` | Source file paths or contents |
| Trigger Skill → Worker | `plan.md` + `context.md` injected inline | File paths only (contents always inlined) |
| Worker → Skill | Artifact name, target path, reference doc path | Cross-layer context |
| Worker → Trigger Skill | `## Output` section with Glob+Grep-verified paths | Partial or unverified paths |

**State files — written and read across the lifecycle:**

| File | Written by | Read by | Purpose |
|---|---|---|---|
| `state.json` | Strategist (after each phase) | Trigger skill (resume routing) | Phase completion + `next_phase` pointer |
| `plan.md` | Planner | Worker | Per-artifact execution instructions |
| `context.md` | Planner | Trigger skill (context relay) | Key symbols, conventions, existing artifacts |

> A persona without a trigger skill is incomplete. The trigger skill is the only supported entry path — it owns routing, context relay, and spawn prompt construction.

---

## Agent Naming Convention

Format: `<persona>-[descriptive]-<role>.md`

Every agent that belongs to a persona must be prefixed with the persona name. The role always comes last — it is a label for clarity, not a constraint. An optional freeform descriptive segment goes in the middle when the role alone is ambiguous within the persona.

| Segment | Rule | Example |
|---|---|---|
| `<persona>` | Required — persona name prefix | `developer`, `debugger` |
| `[descriptive]` | Optional — freeform, added when the role alone doesn't distinguish agents | `feature`, `rfc`, `domain` |
| `<role>` | Required — always last; describes the agent's function | `strategist`, `worker`, `writer` |

A persona can introduce any role label that clearly describes the agent's function.

| Pattern | Example | When to use |
|---|---|---|
| `<persona>-<descriptive>-<role>` | `developer-feature-strategist`, `developer-rfc-writer` | Agent inside a persona folder with multiple agents sharing the same role |
| `<persona>-<role>` | `debugger-worker`, `auditor-worker` | Agent inside a persona folder where the role alone is unambiguous |
| `<descriptive>-<role>` | `perf-worker`, `prompt-debug-worker` | Flat agent with no persona yet — persona prefix added when assigned |

> The filename tells you the persona and the agent's function at a glance — no need to open the file.

---

## Skill Naming Convention

**Procedure skills:** `<layer>-<action>-<target>`. Platform-contract skills use `create-*` for new artifact creation only — there are no `update-*` skills.

**Orchestrator skill naming — persona prefix rule:**

Every Type O skill that is the entry point for a persona must be prefixed with the persona name: `<persona>-<action>`. This makes the relationship between skill and persona explicit at a glance and prevents naming collisions as the persona roster grows.

| Pattern | Example | When to use |
|---|---|---|
| `<persona>-<action>` | `developer-build-feature`, `debugger-debug`, `auditor-arch-review` | Type O orchestrator skill that enters a persona workflow |
| `<persona>-<layer>-<action>-<target>` | `developer-domain-create-entity`, `developer-data-create-mapper` | Type P procedure skill called by a worker |

> Exception: standalone utility skills with no persona owner (e.g. `release`, `agentic-perf-review`) are named descriptively without a prefix until a persona is assigned.

---

## Choosing a Component Type <!-- 14 -->

Decision tree — apply in order when deciding what to add:

**Skill** — single focused procedure, no branching, under ~30 lines of instruction. No decision-making; the calling agent decides which skill to invoke.

**Worker** — specialist in one domain or CLEAN layer. Sequences skills, handles branching and edge cases, enforces preconditions. No coordination of other agents.

**Strategist** — coordinates multiple workers across phases. Never writes files directly — all writes go through workers. Has `agents:` frontmatter field.

**New Persona** — multiple related agents forming a coherent new workflow category not covered by existing personas (`developer`, `debugger`, `auditor`, `installer`). Requires: new subdirectory + `.pkg` file + at least one worker or strategist.

---

## Frontmatter — Required Fields <!-- 12 -->

**All agents:** `name`, `description`, `model`, `tools`

**Workers additionally:** `user-invocable: true|false`

**Strategists additionally:** `agents:` listing only the workers actually spawned

**Skills:** `name`, `description`, `user-invocable: false` (or omit only for user-facing skills)

---

## Model Selection <!-- 10 -->

| Role | Model | When |
|---|---|---|
| Strategist | `sonnet` | Always |
| Worker | `sonnet` | Default — any reasoning, decision-making, or architectural judgment |
| Worker | `haiku` | Only for truly mechanical leaf tasks with no architectural judgment |

---

## Required Sections by Role <!-- 30 -->

> "Worker" and "Strategist" below refer to functional categories, not literal role names. **Worker** means any agent that writes source files, regardless of its role label (`writer`, `planner`-turned-executor, etc.). **Strategist** means any agent that coordinates/spawns other agents without writing files itself. Apply the matching requirements based on what the agent does, not what it's called.

**Workers** must have these sections in their body:

| Section | Purpose |
|---|---|
| `## Search Rules` | Grep-before-Read decision gate table |
| `## Extension Point` | Hook at end: check `agents.local/extensions/<name>.md` |

Workers must also:
- Validate preconditions before writing (`create-*` → target must NOT exist; `update-*` → target MUST exist)
- Glob + Grep verify each output file before listing paths in the report

**Strategists** must have these sections in their body:

| Section | Purpose |
|---|---|
| Phase sections (`## Phase N`) | One per coordination phase |
| State file write | After each phase: `.claude/agentic-state/runs/<feature>/state.json` |
| Output validation | Glob each worker output path — STOP if missing |
| `## Extension Point` | Hook at end |

Strategists never use Edit, Write, or file-writing Bash — zero inline work.

**Extension Point — standard hook.** Every agent body must end with a `## Extension Point` heading reading: "After completing, check for `agents.local/extensions/<name>.md` — if it exists, read and follow its additional instructions."

For repo agents (`.claude/agents/`), the path is `.claude/agents.local/extensions/<name>.md`.

---

## Building an Orchestrator Skill

**Runtime environment:**

The Orchestrator skill runs in the main session context window — the same window the engineer is in. This is what gives it authority over routing, looping, and approval gates. It is also its primary constraint:

- Every spawned agent returns its result to the main context. Each round adds history.
- When context fills, Claude compacts it. Compaction is lossy — subsequent rounds reason on a summary of earlier decisions, not the full history.
- Pro context is 200K tokens. Design for minimal rounds: write findings to disk, pass paths not content.

Two capabilities the Orchestrator skill has that agents do not:

| Capability | What it means |
|---|---|
| **Parallel spawning** | Spawn N agents in one step — all run in isolated contexts simultaneously, same wall-clock time as one |
| **Convergence loop** | Own the loop state — spawn → collect Decision block → spawn again — until the strategist signals converged |

**Design checklist:**

Before writing a single instruction, answer four questions in this order:

1. **What's the goal?** → defines **Output**. Declare the structured result the skill expects back from agents — Decision blocks, findings format, verified paths. Routing logic depends on it; declare it first.
2. **What does it need?** → defines **Input**. Every required parameter, declared explicitly. Missing input = `MISSING INPUT: <param>` immediately — no guessing, no defaults.
3. **How does it run? Who's involved?** → defines **Agents + Loop**. Do you need a convergence loop? Which agents reason about what? Define modes, knowledge scope per agent, and how they communicate: Decision blocks in, findings files on disk out. Never pass content inline between rounds.
4. **Will 200K hold?** → **context budget check**. Estimate rounds × agent output size. If the workflow needs many rounds or large results, split into a second Orchestrator. One skill's structured output becomes the next one's input.

The order matters: Output → Input → Process → Budget. Designing output first prevents the skill from becoming a black box that returns whatever the agent feels like.

---

## Preloading Skills

Agents load their procedure skills at startup via the `skills` field — full skill content is injected at startup. This gives agents full procedural knowledge without embedding it in their body. Same procedures are reusable across multiple agents. One definition, updated once.

**Token budget guideline:**
- Preload skills the agent needs in >50% of its invocations
- Load on demand (via `Read`) skills needed rarely or only in edge cases
- Monitor total preloaded size — if it exceeds ~500 lines, split the agent or move low-frequency skills to on-demand

---

## User Confirmation Gates

Any agent with `AskUserQuestion` in its `tools` that reaches a confirm/decision gate — "apply these fixes?", "register this entry?", "re-run or skip?", "does this match what you wanted?" — must call `AskUserQuestion` directly. Never end the turn with the question as plain text.

**Why this matters:** plain text returns to whatever spawned the agent — an Orchestrator skill, a strategist, or another worker. That caller may answer the question on the user's behalf without ever surfacing the choice to the actual user. `AskUserQuestion` blocks for the real user regardless of call depth — it is the only mechanism guaranteed to reach them.

**Applies to:** any closed yes/no/choice gate before a write or before ending a workflow.

**Does not apply to:** open-ended information-gathering questions with no fixed option set (e.g. "what would you like to discuss?") — `AskUserQuestion` requires 2-4 concrete options, so these may remain plain text and rely on the calling skill to relay them.

---

## Reference Authoring Rules

> See [Reference vs Knowledge](agentic-design-principles.md#reference-vs-knowledge) — these rules govern Reference (`lib/core/*/reference/`), not KMS-managed Knowledge.

**Three-tier structure:**

| Tier | Location | What goes here |
|---|---|---|
| 1 | `CLAUDE.md` | Universal rules applying to every task — naming, principles, build command. ~1 page max |
| 2 | Agent body | Decision logic for that agent only — what to do, when to do it |
| 3 | `kms/knowledge-sources/` | Shared pattern knowledge — theory, definitions, code patterns. Loaded via `kms_list` → `kms_fetch`/`kms_query`. |

> Folder structure for reference docs: see [repo-structure.md](../repo-structure.md).

**Reference vocabulary — Topic and Pattern:**

All KMS terms (`scope`, `platform`, `project`, `discipline`, `artifact`, `topic`, `pattern`) are fully defined in [kms-glossary.md](../kms/kms-glossary.md) — read that doc for the canonical mapping. Summary for agent authors:

- **Artifact** — the named body of knowledge a reference doc covers (a directory under `{discipline}/`), e.g. `standard-architecture`, `conventions`, `feature-inventory`.
- **Topic** — a `#` heading inside an artifact file, grouping related concepts. Not engineering-specific: `domain` groups domain-layer patterns; `components` groups design components; `auth_flow` groups QA checklist items.
- **Pattern** — a `##` heading inside an artifact file — one self-contained, retrievable concept and the canonical concept name (same `pattern` key across all platforms for the same concept).

| Level | Example | Location |
|---|---|---|
| Platform-base | `# Domain` / `## Use Case` | `kms/knowledge-sources/platform/flutter/engineering/standard-architecture/standard-architecture.md` |
| Project-specific | `# Time Management` / `## Clock In/Out` | `kms/knowledge-sources/projects/mobile-talenta/feature-inventory/feature-inventory.md` |
| Pattern node | `use_case` under `topic=domain` | Stored in ChromaDB with `discipline`, `artifact`, `topic`, `pattern` metadata |
| Catalog file | queryable symbol/component inventory | `lib/core/<persona>/reference/<name>-catalog.md` |

**Agent knowledge loading — canonical flow (always both KMS + codebase):**
1. `kms_list(platform, discipline[, artifact, topic])` → scoped TOC, metadata only — agent reasons over what artifacts/topics/patterns exist, narrowing with `artifact`/`topic` as the TOC allows
2. Exact retrieval — once `artifact`, `topic`, and `pattern` are known from the TOC: `kms_fetch(discipline, artifact, topic, pattern, platform)` → guaranteed, cascade-resolved (`project → platform → universal`) full content
3. Semantic fallback — only when the exact `pattern` isn't known: `kms_query(text, platform, discipline, n_results)` → top-k nodes ranked by similarity, full content
4. Codebase explore — `Grep` for existing implementations of the relevant pattern (e.g., `class.*UseCase`, `class.*RepositoryImpl`) excluding `test/` paths → read the most complete match as live code reference

KMS provides theory and documented convention — prefer `kms_fetch` for guaranteed retrieval, `kms_query` only when the exact pattern is unknown. Codebase provides the live ground truth. Both KMS and codebase are loaded before any artifact decision.

> For the full term-to-parameter mapping and the `kms_list` → `kms_fetch` narrowing funnel, see [kms-glossary.md](../kms/kms-glossary.md#terms-as-a-scoping-funnel-for-retrieval).

**Placement decision rule — reference vs agent body:**

| Put it in reference if… | Keep it in the agent body if… |
|---|---|
| It is a fact true regardless of who reads it | It is an instruction specific to this agent's workflow |
| It is an invariant, contract, or architectural principle | It is a decision: when to run, what to check, what to do on failure |
| Multiple agents need the same knowledge | Only this agent needs it |
| Removing it from the agent would lose shared truth | Removing it from the agent would lose execution behavior |

> One-line test: can you state it as a rule without saying "you"? If yes — reference. If it only makes sense addressed to the agent — agent body.

**Search Protocol (decision gate):**

| What you need | Tool |
|---|---|
| Implementation patterns (theory, code) — exact `pattern` known | `kms_list` → `kms_fetch` (theory, guaranteed) + `Grep` codebase for most complete existing implementation (code) |
| Implementation patterns (theory, code) — exact `pattern` unknown | `kms_list` → `kms_query` (theory, ranked) + `Grep` codebase for most complete existing implementation (code) |
| A specific class, function, or type in source | `Grep` for the name |
| The full file structure (style-matching a new file) | `Read` — justified |
| Whether a file exists | `Glob` |

**`symbol-query` — canonical source lookup:**

| Flavor | Target | Mechanic |
|---|---|---|
| `symbol-query` | A class, function, or type in source | `Grep <SymbolName>` → `Read(offset=line-5, limit=60)` — expand only if the body exceeds the window |

**Canonical pattern names (ubiquitous language):**

KMS `pattern` values are the canonical name for one concept within a topic — the ubiquitous-language term used across all platforms. The same concept must use the same `pattern` key across all platforms.

```
discipline=engineering, topic=domain, pattern=use_case, platform=flutter
discipline=engineering, topic=domain, pattern=use_case, platform=ios
discipline=engineering, topic=domain, pattern=use_case, platform=web
```

One concept = one pattern key, everywhere. When adding a new node to the KMS, check whether the same concept exists for other platforms first. If it does, use that `pattern` key exactly. If it's net-new, choose a platform-agnostic term and apply it to all platforms that need it.

---

## Decision Rules

| Situation | Where it goes |
|---|---|
| New CLEAN-layer behaviour, same on all platforms | Core worker |
| New orchestration flow, same on all platforms | Core strategist |
| New code generation pattern for one platform | Platform-contract skill (same name, platform implements) → `lib/platforms/<platform>/skills/contract/` |
| Workflow too platform-specific for any core agent | Platform agent + platform skill → `lib/platforms/<platform>/skills/` (flat) |
| Architecture pattern knowledge (any topic) | `kms/knowledge-sources/engineering/{platform}-*.md` — theory + definition + code pattern per `##` section, seeded as KMS nodes. Project-specific deviations in `kms/knowledge-sources/projects/{name}/` |
| Queryable symbol/component inventory | `lib/core/<persona>/reference/<name>-catalog.md` — `### Symbol` entries; agents `symbol-query` by name directly |

**Planner vs Worker — when to use which:**

| Work profile | Recommended path |
|---|---|
| Contained, well-understood (1–3 artifacts, clear scope, single layer) | Worker directly — overhead of planning exceeds the benefit |
| Cross-layer feature build, multiple artifact types, or uncertain existing state | Planner first → worker — exploration cost is front-loaded, execution is zero-rework |
| Modification to an existing artifact (targeted edit) | Worker directly with context.md Key Symbols if available |
| Large-scale change across many modules or unknown conventions | Planner first — sub-planners explore in parallel, findings aggregated before a single line is written |

> The rule of thumb: if a worker would spend significant time exploring before it can execute, a planner is the better investment. If the scope is clear and bounded, skip the planner and go straight to the worker.

> **Build-directly is a deliberate opt-out, not a default.** It skips all layer isolation guarantees — `feature-worker` makes layer assignment decisions inline with no plan, no human gate, and no tool restriction. The resume routing gate limits the risk: build-directly is only reachable for brand-new features with no prior run. Any feature that was previously planned always resumes against its existing `plan.md` — the worker never re-makes layer decisions that were already validated.

---

## Changelog

See git history for this file.
