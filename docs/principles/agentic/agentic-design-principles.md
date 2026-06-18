> Author: Puras Handharmahua · 2026-04-08
> Related: [agentic-conventions.md](agentic-conventions.md) · [agentic-directory-structure.md](agentic-directory-structure.md) · [repo-structure.md](../repo-structure.md)

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
| **Reference** | The Contract | Extracted formats, patterns, and templates reused across agents/skills — keeps their bodies lean. File-addressable: `Read` in full for thin docs, `symbol-query` for catalogs. Never embedded in agents or skills. Platform-agnostic. See [Reference vs Knowledge](#reference-vs-knowledge). |
| **Skill** | The Hands | Procedural instructions that run in the caller's session. Type O (Orchestrator) is the user-facing entry tier of the agentic stack; Type P (Procedure) is the action tier called by agents. |
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
| File-addressable reference | ✓ | — | — | — | — |
| Shell execution (no model) | — | — | — | — | ✓ |

Skills and Agents share tool access and file writes. What sets Agent apart is LLM reasoning and context isolation. Hooks and MCP are orthogonal — neither reasons nor reads files; they reach outward (MCP to external systems, Hooks to the local shell).

### Reference vs Knowledge

Both terms describe persistent facts an agent loads — but via different mechanisms, with different scope. Don't conflate them:

| | **Reference** | **Knowledge** |
|---|---|---|
| What | Extracted format, contract, or template reused across agents/skills | Documentation, theory, patterns, project/platform context |
| Lives in | `lib/core/<persona>/reference/` (flat) or `lib/core/aegis/reference/<topic>/` (topic-grouped) | `kms/knowledge-sources/{universal,platform,projects}/` |
| Loaded via | `Read` in full (thin docs) or `symbol-query` (catalogs) | `kms_list` → `kms_fetch`/`kms_query` |
| Ships as | Plugin-bundled files at `reference/<persona-or-shared>/...` | Pre-seeded ChromaDB |
| Platform/project scope | Always agnostic | `scope=universal` is agnostic; `scope=platform`/`scope=project` are explicitly scoped |

**Corollary:** agents and skills under `lib/core/` are platform- and project-agnostic by default (see [repo-structure.md](../repo-structure.md)). Anything platform- or project-specific that an agent needs is **Knowledge** and belongs in KMS — never folded into `lib/core/*/reference/`, which stays a pure format/contract layer.

> **Catalog files** (`<name>-catalog.md`) are the one overlap: the catalog *format/schema* is Reference (shared, queryable structure), but its *populated content* is project-instance data — neither shared format nor KMS-managed theory.

See [kms-conventions.md](../kms/kms-conventions.md) for the full Knowledge metadata schema and retrieval protocol, and the Reference Docs tables in [agentic-conventions.md](agentic-conventions.md#reference-docs) for the Reference tier directory layout.

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

**Multiple Type O skills per persona are allowed** — as long as they all route through the same primary entry agent. Example: the developer persona has three Type O skills: `developer-build-feature` (direct build or resume), `developer-plan-build-feature` (planning-first workflow that runs a convergence planning loop → user approval → `feature-worker`), and `developer-build-from-ticket` (non-interactive CI/remote path — fetches a Jira ticket, runs the planning loop automatically, then `feature-worker` without any user prompts). All converge on the same executor; the rule guards against direct-invocation bypasses, not workflow variations.

A sub-agent used only as a step inside a Type O skill (e.g. `feature-planner` inside `developer-plan-build-feature`) does not need its own standalone trigger skill.

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
| **Knowledge** | Patterns always loaded in two steps: `kms_list` → `kms_query` for theory and documented conventions; codebase explore (grep for the most complete existing implementation) for live code patterns. Both are mandatory. See [Reference vs Knowledge](#reference-vs-knowledge) — this is KMS-managed Knowledge, distinct from file-addressable Reference docs. | Specialization is a loading decision — change what an agent loads, change what it knows. |
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

- **Core** (`lib/core/<persona>/agents/`) — platform-agnostic. Work on any platform. Add here when the behaviour is identical across all platforms.
- **Platform-specific** (`lib/platforms/<platform>/agents/`) — exist only when the workflow diverges enough from core to need its own agent. Examples: iOS `test-strategist` (knows `xcodebuild`), iOS `pr-review-worker` (knows Swift/UIKit conventions). Do not add a platform agent unless a core agent + platform skills cannot handle it.

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
| Knowledge patterns | `kms_list` → `kms_fetch`/`kms_query` (theory + conventions) + codebase explore (live code) — always both | `knowledge_scope` in agent frontmatter |
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

> Naming conventions for agents: see [agentic-conventions.md — Agent Naming Convention](agentic-conventions.md#agent-naming-convention).

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

**Preloading skills:**

Agents load their procedure skills at startup via the `skills` field — full skill content is injected at startup. This gives agents full procedural knowledge without embedding it in their body. Same procedures are reusable across multiple agents. One definition, updated once.

**Consuming shared agents, skills, and reference docs:**

Downstream projects consume agents, skills, and reference docs as plugin-bundled files — they work as-is via the standard workflow.

Pattern knowledge lives in `kms/knowledge-sources/` — agents load it via `kms_list` → `kms_query`; the structure is the contract, not grep offsets.

> Agentic stack model, component types, naming conventions, and orchestrator design checklist: see [agentic-conventions.md](agentic-conventions.md).

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

> For the internal reviewer setup, checklist, and severity levels, see [repo-structure.md — Convention Compliance System](../repo-structure.md#convention-compliance-system).

---

## Why This Architecture

| Goal | How it's achieved |
|---|---|
| Token efficiency | Isolated context; Search Protocol decision gate; disk-first inter-agent communication — findings written to disk, paths not content passed between phases, Orchestrator context stays clean across rounds |
| Modular knowledge | Skills preloaded, not embedded |
| Single source of truth | `reference/` file-addressed (`Read` or `symbol-query`), never duplicated |
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
