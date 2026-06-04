> Author: Puras Handharmahua · 2026-04-08
> Related: Shared Agentic Submodule Architecture — Cross-Platform Scaling

## What is an Agentic Coding Assistant?

A coding assistant where Claude autonomously routes, decides, and executes — without the user needing to know which tool, command, or workflow to invoke. Trigger skills are the only supported entry path: they own routing, context relay, and spawn prompt construction.

> Skills first. No manual chaining. No context pollution.

**Current scope:** This system today covers the **Implementation** process of the SDLC (build, debug, review, groom). The long-term goal is specialized agents across every process — Requirement, Design, Implementation, Testing, and Delivery. Expansion into other processes depends on the Collaboration and Distribution phases being resolved first.

---

## Design Goals

1. **Consistent agentics across platforms** — same agents, same principles, one source of truth
2. **Easy to maintain** — update once, all projects get it
3. **Open contribution model** — all engineers can explore, create, and PR new agents/skills
4. **Context efficiency** — no wasted tokens on irrelevant content
5. **Encouraging initiatives** — low barrier to propose new "personas" (strategists)

---

## System Components

Five building blocks compose every agentic workflow. Each has one defined job — no component does another's work.

| Component | Role | One-line rule |
|---|---|---|
| **Reference** | The Knowledge | Persistent facts — patterns, contracts, conventions. Loaded via KMS tools (`kms_list` → `kms_query`). Agents fall back to minimal codebase exploration when KMS is unavailable. Never embedded in agents or skills. |
| **Skill** | The Hands | Procedural instructions that run in the caller's session. Type O owns the entry workflow; Type P is a thin create-step called by agents. |
| **Agent** | The Brain | Isolated reasoning in its own context window. Handles ambiguity, makes decisions, returns structured output to the caller. |
| **MCP** | The Reach | Structured tool calls into external systems — Jira, Figma, IDE, build tools. Agents call MCP tools directly; no copy-paste relay. |
| **Hooks** | The Automation | Shell commands that fire on lifecycle events with no model involvement. For logic that must always run regardless of agent decisions. |

**Capability summary:**

| Capability | Reference | Skill | Agent | MCP | Hooks |
|---|---|---|---|---|---|
| LLM reasoning | — | — | ✓ | — | — |
| Isolated context window | — | — | ✓ | — | — |
| Runs in caller's context | — | ✓ | — | — | — |
| Uses Claude tools | — | ✓ | ✓ | — | — |
| Writes source files | — | ✓ | ✓ | — | — |
| Multiple invocation modes | — | — | ✓ | — | — |
| Spawns agents | — | ✓ | ✓ | — | — |
| Calls skills | — | ✓ | ✓ | — | — |
| Bridges external systems | — | — | — | ✓ | — |
| Grep-addressable knowledge | ✓ | — | — | — | — |
| Shell execution (no model) | — | — | — | — | ✓ |

Skills and Agents share tool access and file writes. What sets Agent apart is LLM reasoning and context isolation. Hooks and MCP are orthogonal — neither reasons nor reads files; they reach outward (MCP to external systems, Hooks to the local shell).

---

## Core Design Principles

### 1. Skill-First Entry

**Trigger skills are the only supported entry path.** A Type O skill owns the full entry sequence before any agent is spawned: routing (resume vs new run), context pre-loading from the runs directory, and building the spawn prompt with context already inlined. This eliminates cold pre-flight reads, gives the user clear options, and keeps orchestration efficient.

> Not every request needs an agent. If a change is simple and localized (rename a variable, fix a typo, add an import), act directly — the cost of delegation exceeds the task itself.

**Skill-First Entry for Personas:**

Every persona must have exactly one primary entry agent. That agent must have a corresponding Type O skill. The skill is the only supported entry path — direct agent invocation bypasses context loading and is unsupported.

| Role | Has trigger skill? | Spawned by |
|---|---|---|
| Persona entry agent (strategist, or single worker if no strategist) | Yes — required | User via trigger skill |
| Workers inside a persona | No | Strategist only |

The trigger skill owns three responsibilities before spawning the agent:
1. **Routing** — detect existing runs (resume vs new call) and ask the user when ambiguous
2. **Context pre-loading** — read `plan.md`, `context.md`, and `state.json` from the runs directory and inline them into the spawn prompt
3. **Spawn prompt construction** — pass the pre-loaded block so the agent can skip all cold pre-flight file reads

The agent detects the `Pre-loaded context` block in its prompt and jumps directly to the first pending phase. Without it, the agent warns that direct invocation is unsupported.

**Multiple Type O skills per persona are allowed** — as long as they all route through the same primary entry agent. Example: the developer persona has three Type O skills: `developer-build-feature` (direct build or resume), `developer-plan-feature` (planning-first workflow that runs a convergence planning loop → user approval → `feature-worker`), and `developer-build-from-ticket` (non-interactive CI/remote path — fetches a Jira ticket, runs the planning loop automatically, then `feature-worker` without any user prompts). All converge on the same executor; the rule guards against direct-invocation bypasses, not workflow variations.

A sub-agent used only as a step inside a Type O skill (e.g. `feature-planner` inside `developer-plan-feature`) does not need its own standalone trigger skill.

> **Adding a new persona:** create the entry agent + its trigger skill together. A persona without a trigger skill is incomplete.

---

### 2. Agents = Brain (Decision-Maker)

Agents are intelligent specialists, not task executors. Each agent:

- Assesses context before acting (does this file exist? which pattern applies?)
- Decides which procedure to execute
- Handles edge cases and branching logic
- Knows *what* to do and *when*

Agents stay lean — they don't embed step-by-step instructions. That belongs in skills.

**Agent Anatomy — Five Parts:**

Every agent is built from the same five parts. Together they make agent behavior observable, debuggable, and independently replaceable.

| Part | What it is | Why it matters |
|---|---|---|
| **Input** | Declared parameters the agent requires to start — mode, feature name, platform, file paths. Missing input → `MISSING INPUT: <param>` immediately. | Explicit inputs make agents predictable and debuggable. |
| **Knowledge** | Patterns always loaded in two steps: `kms_list` → `kms_query` for theory and documented conventions; codebase explore (grep for the most complete existing implementation) for live code patterns. Both are mandatory. | Specialization is a loading decision — change what an agent loads, change what it knows. |
| **Reasoning** | The LLM applies thinking, deciding, and branching to inputs and loaded knowledge. Handles ambiguity and edge cases that no fixed script can anticipate. | The part no deterministic tool can replace today — but the slot can be swapped in the future. |
| **Output** | Declared and structured: `Decision:` blocks, `## Findings`, `## Output` with Glob+Grep-verified paths. The calling skill routes on it without ambiguity. | Structured output makes the calling skill's routing deterministic. |
| **Modes** | An agent can be invoked in different modes. Each mode loads only the instruction lines relevant to that invocation — the rest are never read. | One agent body, multiple contexts of use, minimal per-invocation cost. |

**Debugging surface — if an agent behaves wrong, exactly one of these five parts is the root cause:**

| Symptom | Where to look |
|---|---|
| Agent starts wrong, misses context, or acts on wrong scope | Input |
| Agent doesn't know the right patterns or uses wrong conventions | Knowledge |
| Agent makes wrong decisions or draws wrong conclusions | Reasoning |
| Agent returns incomplete, unparseable, or unexpected result | Output |
| Agent behaves inconsistently across different invocations | Mode |

Each part is independently replaceable — swapping knowledge retrieval from Grep to vector search, or reasoning from LLM to a deterministic rule engine for well-understood decisions, requires no changes to the other parts.

**Modes:**

Modes are how one agent serves multiple invocation contexts while staying lean. Each mode is a named section in the agent body. The calling skill passes `mode: <name>` in the spawn prompt; the agent reads only the instructions for that mode.

Example — `developer-feature-strategist` has four modes:
- `gather-intent` — ask the engineer what to build, surface existing runs, return `Decision: spawn-planners`
- `process-findings` — read planner findings from disk, decide: more rounds or converged?
- `synthesize` — write `plan.md` and `context.md` from all findings, return summary
- `resume` — pick up an in-progress run, skip completed phases, continue from last state

Each invocation loads only its mode's instruction block. Without modes, all instruction blocks load on every call — wasted tokens for context the agent never uses in that invocation.

**Strategists — Brain-Only Decision Makers:**

Strategists are pure reasoning agents — they decide what to do and return structured decision blocks to the calling skill. The skill executes: it spawns agents, accumulates results, and loops. Key rules:

- Return structured decision blocks (`Decision: spawn-planners`, `Decision: converged`, `Decision: spawn-worker`, `Decision: blocked`) — never spawn agents directly
- Never write or edit source files — all writes go through agents spawned by the skill

**Agent Scope — Core vs Platform-specific:**

Agents have a second axis — where they live and what they know.

- **Core** (`lib/core/agents/`) — platform-agnostic. Work on any platform. Add here when the behaviour is identical across all platforms.
- **Platform-specific** (`lib/platforms/<platform>/agents/`) — exist only when the workflow diverges enough from core to need its own agent. Examples: iOS `test-strategist` (knows `xcodebuild`), iOS `pr-review-worker` (knows Swift/UIKit conventions). Do not add a platform agent unless a core agent + platform skills cannot handle it.

> For the full agent roster, see [developer.md](persona/developer.md).

**DI at Skill Level:**

Workers are platform-agnostic protocol-definers. Skills are the platform-specific implementations of that protocol. A `domain-worker` calls `developer-domain-create-entity` by name — on iOS that creates a Swift struct, on web a TypeScript interface. The worker never knows which platform it's on and doesn't need to.


| Role | Protocol analogy | Platform-aware? |
|---|---|---|
| Strategists | Interface contract | No |
| Planners | Requirements analysis | No |
| Workers | Use-case logic | No |
| Skills | Concrete implementation | Yes |


**Context Isolation = Efficiency:**

Every agent runs in its own isolated context window — completely separate from the main session. This is the primary mechanism for token efficiency.

From the official docs:
> *"Preserve context by keeping exploration and implementation out of your main conversation"*

When a worker reads reference docs, scans existing files, and writes code — none of that touches your main session context. The main session only sees the result.

| Component | Context cost | Mechanism |
|---|---|---|
| Core agents (descriptions) | ~3–5 lines each in main session | Agent tool definition |
| Platform-specific agents (descriptions) | ~3–5 lines each in main session | Agent tool definition |
| Preloaded skills | Loaded at worker startup only | `skills` field |
| Knowledge patterns | `kms_list` → `kms_query` (theory + conventions) + codebase explore (live code) — always both | `knowledge_scope` in agent frontmatter |
| `agents.local/extensions/` | 1 Read call (conditional) | Extension hook in shared agent |
| Dead weight (unselected groups) | Zero | Persona groups not linked if not selected |
| Strategist context accumulation | Minimal — disk-based hand-offs | Agents write findings to disk; skill passes paths not content; state file prevents re-reads |

**Disk-First Inter-Agent Communication:**

Agents communicate via files on disk — never by passing content inline through the Orchestrator skill's context window. State, plans, and findings are written to disk between phases; the calling skill relays paths, not content. This keeps the main context clean regardless of how many rounds the workflow takes.

**Fail-Fast Precondition Validation:**

Agents validate preconditions before executing procedures — they never guess or proceed with assumptions.

**Workers check on entry (`## Input`):**
- Are all required spawn parameters present? — return `MISSING INPUT: <param>` immediately if not
- Is the task within this worker's layer scope? — STOP and name the correct worker if not

**Workers check before writing (`## Preconditions`):**
- Does the target file/module NOT exist? (before `create-*` skills — avoid overwriting)
- For direct edits to existing artifacts: confirm the file exists before `Read` + `Edit`
- Are required dependencies available?

**Workers check before returning (`## Output`):**
- Does each created file exist on disk? (`Glob`)
- Does each file contain the expected primary class or function? (`Grep`)
- Only list paths that pass both checks

**Strategists check after each worker spawn:**
- Does the worker response contain an `## Output` section?
- Do all listed paths exist on disk?
- If either check fails: STOP — do not proceed to the next phase

When any check fails: return a clear, actionable message — never partially execute or silently continue.

**Agent Naming Convention:**

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

### 3. Skills = Hands (Thin Procedures)

Skills are focused, reusable workflow procedures. Each skill:

- Does one thing only
- References architecture docs — never embeds them
- Has no branching logic — agent decides which skill to call

**Skill size rule — contain no more than the type demands:**

| Type | Natural size | Reason |
|---|---|---|
| P — Procedure | Short — ~10–30 lines | Thin create-only procedure; logic belongs in the worker |
| O — Orchestrator | Scales with workflow complexity | Owns the full runtime — may do its own work or delegate to agents. Grows with the workflow it drives. |

There is no universal line limit. The constraint is not length — it is scope. A skill that grows because it is doing what a worker should do is wrong. A skill that grows because its type genuinely requires more steps is correct.

> Naming: `<layer>-<action>-<target>`. Platform-contract skills use `create-*` for new artifact creation only — there are no `update-*` skills. Skills are either **core-dependency** (same name on all platforms) or **platform-specific** (one platform only) — see [developer.md](persona/developer.md).

**Orchestrator skill naming — persona prefix rule:**

Every Type O skill that is the entry point for a persona must be prefixed with the persona name: `<persona>-<action>`. This makes the relationship between skill and persona explicit at a glance and prevents naming collisions as the persona roster grows.

| Pattern | Example | When to use |
|---|---|---|
| `<persona>-<action>` | `developer-build-feature`, `debugger-debug`, `auditor-arch-review` | Type O orchestrator skill that enters a persona workflow |
| `<persona>-<layer>-<action>-<target>` | `developer-domain-create-entity`, `developer-data-create-mapper` | Type P procedure skill called by a worker |

> Exception: standalone utility skills with no persona owner (e.g. `release`, `agentic-perf-review`) are named descriptively without a prefix until a persona is assigned.

**Orchestrator skill — runtime environment:**

The Orchestrator skill runs in the main session context window — the same window the engineer is in. This is what gives it authority over routing, looping, and approval gates. It is also its primary constraint:

- Every spawned agent returns its result to the main context. Each round adds history.
- When context fills, Claude compacts it. Compaction is lossy — subsequent rounds reason on a summary of earlier decisions, not the full history.
- Pro context is 200K tokens. Design for minimal rounds: write findings to disk, pass paths not content.

Two capabilities the Orchestrator skill has that agents do not:

| Capability | What it means |
|---|---|
| **Parallel spawning** | Spawn N agents in one step — all run in isolated contexts simultaneously, same wall-clock time as one |
| **Convergence loop** | Own the loop state — spawn → collect Decision block → spawn again — until the strategist signals converged |

**Building an Orchestrator skill — design checklist:**

Before writing a single instruction, answer four questions in this order:

1. **What's the goal?** → defines **Output**. Declare the structured result the skill expects back from agents — Decision blocks, findings format, verified paths. Routing logic depends on it; declare it first.
2. **What does it need?** → defines **Input**. Every required parameter, declared explicitly. Missing input = `MISSING INPUT: <param>` immediately — no guessing, no defaults.
3. **How does it run? Who's involved?** → defines **Agents + Loop**. Do you need a convergence loop? Which agents reason about what? Define modes, knowledge scope per agent, and how they communicate: Decision blocks in, findings files on disk out. Never pass content inline between rounds.
4. **Will 200K hold?** → **context budget check**. Estimate rounds × agent output size. If the workflow needs many rounds or large results, split into a second Orchestrator. One skill's structured output becomes the next one's input.

The order matters: Output → Input → Process → Budget. Designing output first prevents the skill from becoming a black box that returns whatever the agent feels like.

**Preloading skills:**

Agents load their procedure skills at startup via the `skills` field — full skill content is injected at startup. This gives agents full procedural knowledge without embedding it in their body. Same procedures are reusable across multiple agents. One definition, updated once.

**Token budget guideline:**
- Preload skills the agent needs in >50% of its invocations
- Load on demand (via `Read`) skills needed rarely or only in edge cases
- Monitor total preloaded size — if it exceeds ~500 lines, split the agent or move low-frequency skills to on-demand

**Three consumer modes:**

Downstream projects interact with shared agents, skills, and reference docs in one of three modes:

| Mode | Applies to | Mechanism | When to use |
|---|---|---|---|
| **Use** | agents, skills, reference | Shared symlink → submodule file | Works as-is — standard workflow |
| **Extend** | agents only | Shared symlink + `agents.local/extensions/<name>.md` | Add behavior without losing submodule updates |
| **Override** | agents, skills, reference | Real file in `*.local/` | Fundamentally different behavior needed |

Extension files contain only the delta — not a full copy. Updates to the submodule are inherited automatically.

Reference docs are override-only (no extension mechanism). Pattern knowledge lives in `kms/knowledge-sources/` — agents load it via `kms_list` → `kms_query`; the structure is the contract, not grep offsets.

**Local directories and their scope:**

| Directory | Override | Extend | Notes |
|---|---|---|---|
| `agents.local/` | ✓ | ✓ via `extensions/` | Workers check `extensions/<name>.md` at the end of their run |
| `skills.local/` | ✓ | — | Replace the whole skill dir |
| `reference.local/` | ✓ | — | Shadows platform/core reference docs; override-only by design |

> Skills have invocation types (A, T, U) — see [Taxonomy §Skills — By Invocation Type](#skills--by-invocation-type) for the full breakdown and decision rules.

---

### 4. MCP = Reach (External Systems)

MCP turns external tools into first-class agent inputs. Agents call MCP tool functions directly — no copy-paste, no stale screenshots, no information lost in relay.

**The boundary:** Skills reach the codebase. MCP reaches everything else.

| Before MCP | With MCP |
|---|---|
| "Paste the Jira ticket so I can understand the requirements." | Agent fetches the ticket directly — description, AC, linked issues, comments. |
| "Paste the Figma design or take a screenshot of each screen." | Agent pulls design data, component specs, and layout files from Figma directly. |
| "Run the build and paste the error so I can see what's failing." | Agent triggers the build, reads the result, and acts on it — no relay needed. |

**MCP servers in use today:**

| Server | Reaches into |
|---|---|
| `Atlassian` | Jira tickets · Confluence pages · Bitbucket PRs |
| `ide` | Live diagnostics · in-editor code execution |
| `Figma` | Design data · component specs · asset export |
| `XcodeBuildMCP` | Build · test · simulate · screenshot on iOS |

**When to use MCP vs skills:**
- **MCP** — when the agent needs data or actions from an external system (Jira, Figma, CI, IDE diagnostics). No file in the repo can provide it.
- **Skills** — when the agent needs to read or write the codebase, load reference patterns, or call platform-specific create procedures.

MCP tools are just tool calls — any agent with the right server configured can reach any external system, with no special wiring in the agent body.

---

### 5. Hooks = Automation (No Model)

Hooks are shell commands that execute at defined lifecycle events — with no model involvement. They enforce logic that must always run regardless of what the agent decides to do.

**Four events:**

| Event | Fires when |
|---|---|
| `PreToolUse` | Before a tool call executes — can intercept or block |
| `PostToolUse` | After a tool call completes — can react or validate |
| `Stop` | When the agent session ends |
| `Notification` | On agent lifecycle notifications |

**When to use hooks vs skills:**

| Use hooks when… | Use skills when… |
|---|---|
| Logic must always run, regardless of agent decisions | Logic is part of the agent's workflow |
| No LLM reasoning needed — pure shell | Reasoning, branching, or tool calls are required |
| Validation or safety guard on every tool call | A procedure triggered explicitly by the agent |
| Enforcing conventions the agent shouldn't bypass | Generating or modifying artifacts |

> Hooks are configured in `settings.json` — they are not part of the agent or skill file. A skill that should "always run" is the wrong tool; use a hook.

---

### 6. Convention Enforcement — Self-Auditing Architecture

The agentic system enforces its own conventions through automated review — the same principle applied recursively. Convention compliance tooling audits agent and skill files for structural violations before they reach downstream consumers.

> For the internal reviewer setup, checklist, and severity levels, see [submodule-repo-structure.md — Convention Compliance System](submodule-repo-structure.md#convention-compliance-system).

---

## Reference

**Three-tier structure:**

| Tier | Location | What goes here |
|---|---|---|
| 1 | `CLAUDE.md` | Universal rules applying to every task — naming, principles, build command. ~1 page max |
| 2 | Agent body | Decision logic for that agent only — what to do, when to do it |
| 3 | `kms/knowledge-sources/` | Shared pattern knowledge — theory, definitions, code patterns. Loaded via `kms_list` → `kms_query`. |

> Folder structure for reference docs: see [submodule-repo-structure.md](submodule-repo-structure.md).

**Reference vocabulary — Topic and Term:**

Reference docs are organized around two levels:

- **Topic** — the subject area a knowledge directory covers. Not engineering-specific: `domain` covers domain layer patterns; `components` covers design components; `unit_testing` covers QA patterns. One topic directory per platform.
- **Pattern** — one concrete concept within a topic. Each pattern is a self-contained `.md` file with `## Theory`, `## Definition`, `## Code Pattern` sections. The filename is the pattern key.

| Level | Example | Location |
|---|---|---|
| Platform-base | `engineering/flutter-standard-architecture.md` | `kms/knowledge-sources/engineering/` — shared across all projects on that platform |
| Project-specific | `projects/flutter-mobile-talenta/deviations.md` | `kms/knowledge-sources/projects/{name}/` — deviations only |
| Pattern node | `use_case` under `topic=domain` | Stored in ChromaDB with `discipline`, `topic`, `pattern` metadata |
| Catalog file | queryable symbol/component inventory | `lib/core/reference/<topic>/<name>-catalog.md` |

**Agent knowledge loading — canonical flow (always both):**
1. `kms_list(platform, discipline)` → scoped TOC, metadata only — agent reasons over what topics exist
2. `kms_query(text, platform, discipline, n_results)` → theory, definitions, and documented patterns with full content
3. Codebase explore — `Grep` for existing implementations of the relevant pattern (e.g., `class.*UseCase`, `class.*RepositoryImpl`) excluding `test/` paths → read the most complete match as live code reference

KMS provides theory and documented convention. Codebase provides the live ground truth. Both are loaded before any artifact decision.

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
| Implementation patterns (theory, code) | `kms_list` → `kms_query` (theory) + `Grep` codebase for most complete existing implementation (code) |
| A specific class, function, or type in source | `Grep` for the name |
| The full file structure (style-matching a new file) | `Read` — justified |
| Whether a file exists | `Glob` |

**`symbol-query` — canonical source lookup:**

| Flavor | Target | Mechanic |
|---|---|---|
| `symbol-query` | A class, function, or type in source | `Grep <SymbolName>` → `Read(offset=line-5, limit=60)` — expand only if the body exceeds the window |

**Authoring rule — canonical pattern names (ubiquitous language):**

KMS `pattern` values are **Terms** — the canonical name for one concept within a topic. The same concept must use the same `pattern` key across all platforms.

```
discipline=engineering, topic=domain, pattern=use_case, platform=flutter
discipline=engineering, topic=domain, pattern=use_case, platform=ios
discipline=engineering, topic=domain, pattern=use_case, platform=web
```

One concept = one pattern key, everywhere. Platform-specific content lives in the node body, not in the key.

When adding a new node to the KMS, check whether the same concept exists for other platforms first. If it does, use that `pattern` key exactly. If it's net-new, choose a platform-agnostic term and apply it to all platforms that need it.

---

## Taxonomy

### Persona

A named group of related agents serving a coherent workflow.

Requirements:
- Lives in `lib/core/agents/<persona>/`
- Has at least one worker or strategist
- Agents within the group relate to and can depend on each other
- Requires a `.pkg` file for selective installation

Shared to all downstream projects via symlink. Current personas: `developer`, `debugger`, `tracker`, `auditor`, `installer`.

**Persona → SDLC role mapping:**

Each persona maps to a real-world role and the SDLC phase that role owns. The Orchestrator skills within a persona are the agentic equivalents of that role's actual workflows.

| SDLC Phase | Role | Persona | Status |
|---|---|---|---|
| Implementation | Software Engineer | `developer` | Live |
| Testing | QA Engineer | `qa` | Live |
| Other phases (Requirement, Design, Delivery) | — | — | Research |

A persona's Orchestrator skills directly mirror the role's day-to-day workflows. For example: a developer breaks down an Epic into an RFC (`/developer-rfc`) then builds the feature from that RFC (`/developer-plan-feature`). A QA engineer breaks down a PRD or RFC into test cases (`/qa-generate-testcase`). Adding a new phase means identifying its role, mapping its workflows, and building one Orchestrator skill per workflow — using the same 4 design questions.

> A persona is not just a folder. It represents a coherent workflow. Do not group unrelated agents into a persona subdirectory.

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
| **Persona agent** | `lib/core/agents/<persona>/` | Yes — all platforms |
| **Platform agent** | `lib/platforms/<platform>/agents/` | Yes — matching platform only |
| **Project agent** | `.claude/agents.local/` | No — project-owned, not in this repo |

> Persona agents must be platform-agnostic — no platform paths, framework references, or language syntax in the body (Critical per P6).

### Skills

#### By Invocation Type

| Type | Config | Who triggers | Use for |
|---|---|---|---|
| **P — Procedure** | `user-invocable: false` | Worker (agent) only | Thin create-only procedures |
| **O — Orchestrator** | `user-invocable: true` | User only | User entry point — owns and runs the workflow. Simple workflows do their own work; complex ones delegate to agents. |

> For automated bash execution without model involvement, use hooks in `settings.json` — not a skill.

**Why no default skill type (invocable by both user and agent):** Every default skill's description loads into the main session context on every turn. Types P and O eliminate this overhead.

#### By Scope

| Scope | Location | Ships downstream? |
|---|---|---|
| **Toolkit skill** | `lib/core/skills/` | Yes — all platforms. Platform-agnostic, intended for use in downstream projects. |
| **Platform-contract skill** | `lib/platforms/<platform>/skills/contract/` | Yes — matching platform. Same name across all platforms; each implements for its syntax — called by persona workers. Lands flat in `.claude/skills/<name>/` downstream. |
| **Platform-only skill** | `lib/platforms/<platform>/skills/` (flat) | Yes — matching platform only. Called by platform agents. |
| **Project skill** | `.claude/skills.local/` | No — project-owned, not in this repo. |
| **Repo skill** | `.claude/skills/` | No — internal tooling only. Used by this repo's internal agents; never symlinked to downstream projects. |

> "Core-dependency skill" used in earlier sections of this doc refers to platform-contract skills — skills all platforms must implement under the same name (`developer-domain-create-entity`, `developer-data-create-mapper`, etc.).

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

### Reference Docs

#### By Scope

| Scope | Location | Ships downstream? |
|---|---|---|
| **Platform-base knowledge** | `kms/knowledge-sources/engineering/{platform}-*.md` | Yes — via pre-seeded ChromaDB bundled in plugin. Theory + definition + code pattern per node. Shared across all projects on that platform. |
| **Project knowledge** | `kms/knowledge-sources/projects/{name}/` | Yes — via pre-seeded ChromaDB. Project-specific deviations only — created only when real divergence exists. |
| **Core catalog** | `lib/core/reference/<topic>/` | Yes — all platforms. Contains `<name>-catalog.md` — queryable symbol/component inventory. Agents `symbol-query` these; never load in full. |
| **Project reference** | `.claude/reference.local/` | No — project-owned, not in this repo. Overrides for project-specific conventions not in KMS. |

---

## Anatomy

### Anatomy of a Persona

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

Not every persona uses all layers. A simple persona may have only a trigger skill + worker. A complex one adds an strategist, planners, and multiple workers. The anatomy is the same regardless of how many layers are present.

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

## Decision Rules

| Situation | Where it goes |
|---|---|
| New CLEAN-layer behaviour, same on all platforms | Core worker |
| New orchestration flow, same on all platforms | Core strategist |
| New code generation pattern for one platform | Platform-contract skill (same name, platform implements) → `lib/platforms/<platform>/skills/contract/` |
| Workflow too platform-specific for any core agent | Platform agent + platform skill → `lib/platforms/<platform>/skills/` (flat) |
| Architecture pattern knowledge (any topic) | `kms/knowledge-sources/engineering/{platform}-*.md` — theory + definition + code pattern per `##` section, seeded as KMS nodes. Project-specific deviations in `kms/knowledge-sources/projects/{name}/` |
| Queryable symbol/component inventory | `lib/core/reference/<topic>/<name>-catalog.md` — `### Symbol` entries; agents `symbol-query` by name directly |

**Planner vs Worker — when to use which:**

| Work profile | Recommended path |
|---|---|
| Contained, well-understood (1–3 artifacts, clear scope, single layer) | Worker directly — overhead of planning exceeds the benefit |
| Cross-layer feature build, multiple artifact types, or uncertain existing state | Planner first → worker — exploration cost is front-loaded, execution is zero-rework |
| Modification to an existing artifact (targeted edit) | Worker directly with context.md Key Symbols if available |
| Large-scale change across many modules or unknown conventions | Planner first — sub-planners explore in parallel, findings aggregated before a single line is written |

> The rule of thumb: if a worker would spend significant time exploring before it can execute, a planner is the better investment. If the scope is clear and bounded, skip the planner and go straight to the worker.

> **Build-directly is a deliberate opt-out, not a default.** It skips all layer isolation guarantees — `feature-worker` makes layer assignment decisions inline with no plan, no human gate, and no tool restriction. The resume routing gate limits the risk: build-directly is only reachable for brand-new features with no prior run. Any feature that was previously planned always resumes against its existing `plan.md` — the worker never re-makes layer decisions that were already validated.

> For execution examples and the current agent roster, see [developer.md](persona/developer.md).

---

## Why This Architecture

| Goal | How it's achieved |
|---|---|
| Token efficiency | Isolated context; Search Protocol decision gate; disk-first inter-agent communication — findings written to disk, paths not content passed between phases, Orchestrator context stays clean across rounds |
| Modular knowledge | Skills preloaded, not embedded |
| Single source of truth | `reference/` Grep-accessed, never duplicated |
| Safe destructive operations | Use hooks in `settings.json` for automated bash execution without model involvement |
| Reusability | Same skill preloaded into multiple workers |
| Maintainability | Update one skill → all workers get the update |
| Multi-platform scalability | Add `lib/platforms/<platform>/skills/` — no agent changes |
| Selective installation | Persona `.pkg` files |
| Self-enforcing conventions | Internal arch-reviewer catches violations before downstream consumers |
| Clear distributable boundary | `lib/` = ships downstream; everything outside = internal tooling |
| Agent prompt quality | `prompt-debug-worker` surfaces ambiguous instructions when perf scores flag low D1–D7 |

---

## Limitations — Why Not End-to-End

Cross-persona, end-to-end automation (product → design → developer → QA in a single uninterrupted run) is the long-term goal but not yet achievable. Four constraints shape the current boundary:

| Limitation | Impact | Design response |
|---|---|---|
| **Context window** | A full cross-team workflow fills the main context. Compaction at the final step = degraded output. | Persona-scoped Orchestrators; disk-based hand-offs between personas. |
| **Token billing** | A billing cap or timeout mid-workflow orphans the Orchestrator. No clean auto-recovery without human re-entry. | Approval gates at natural hand-off points; state files for resume. |
| **Supervision** | Agents aren't mature enough for unsupervised cross-team execution. Human review at each hand-off catches drift between what was intended and what was produced. | Explicit approval steps after each Orchestrator completes. |
| **Gaps** | No agreed input/output contract between teams (product → design → developer → QA) yet. Agents can't bridge a gap that hasn't been defined. | Define I/O contracts per hand-off before building the connecting Orchestrator. |

Each limitation is a research problem, not a permanent constraint. Context efficiency, resume protocols, maturity metrics, and cross-team I/O contracts are all active areas of work.

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

See git history for this file.
