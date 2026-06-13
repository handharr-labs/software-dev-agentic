> Author: Puras Handharmahua · 2026-06-13
> Related: [agentic-design-principles.md](agentic-design-principles.md) · [agentic-conventions.md](agentic-conventions.md) · [agentic-repo-structure.md](agentic-repo-structure.md) · [../glossary.md](../glossary.md)

## What This Doc Covers

Short, one-line definitions for terms coined — or given a project-specific meaning — by the agentic architecture in this repo. If a term below feels unfamiliar while reading another agentic doc, this is the lookup. For the full mapping of KMS-specific vocabulary (`scope`, `platform`, `discipline`, `artifact`, `topic`, `pattern`), see [kms-glossary-lite.md](../kms/kms-glossary-lite.md).

---

## Glossary

| Term | Definition |
|---|---|
| **Agentic Stack** | The governing three-tier execution model for every persona: Orchestrator Skill (Type O) → Agent(s) (strategist/planner/worker) → Procedure Skill(s) (Type P). |
| **CipherPol** | The name of this whole multi-platform agentic toolkit (this repo, `software-dev-agentic`). |
| **cipherpol-aegis** | The plugin that ships all agents and skills (all personas) to downstream projects. |
| **cipherpol-8** | The plugin that ships the KMS MCP server (`cp8`) and pre-seeded ChromaDB. |
| **Persona** | A named group of related agents serving one coherent workflow (e.g. `developer`, `debugger`, `auditor`, `qa`). Maps to a real-world SDLC role. |
| **Strategist** | A pure-reasoning agent. Decides what to do and returns a `Decision:` block — never spawns agents or writes source files itself. |
| **Planner** | A read-only explorer agent scoped to one CLEAN layer. Returns structured findings, including `### Impact Recommendations`. |
| **Worker** | An agent that executes a plan and writes source files — regardless of its specific role label (`writer`, `feature-worker`, etc.). |
| **Orchestrator Skill (Type O)** | The user-facing entry skill for a persona. Routes resume-vs-new, pre-loads context from disk, spawns agents, owns the convergence loop and approval gate. |
| **Procedure Skill (Type P)** | A thin (~10–30 line), agent-only, create-only skill. No routing or decision logic. Called by workers, never by users. |
| **Trigger Skill** | The Type O skill that is a persona's *only* supported entry path. A persona without one is incomplete. |
| **Reference** | Extracted formats, contracts, and templates reused across agents/skills (`lib/core/*/reference/`). File-addressable, platform-agnostic, never embedded inline. |
| **Knowledge** | Documentation, theory, and conventions stored in KMS (`kms/knowledge-sources/`), retrieved via `kms_list`/`kms_fetch`/`kms_query`. Distinct from Reference — see [Reference vs Knowledge](agentic-design-principles.md#reference-vs-knowledge). |
| **Decision block** | The structured output a strategist returns to its calling skill — `Decision: spawn-planners`, `Decision: converged`, `Decision: spawn-worker`, `Decision: blocked`. |
| **Convergence loop** | The skill-owned loop: spawn agents → collect Decision block → spawn again — until the strategist signals `converged`. |
| **Disk-First Inter-Agent Communication** | Agents hand off via files on disk (`plan.md`, `context.md`, `state.json`) — the calling skill relays paths, never inlines content between rounds. |
| **Skill-First Entry** | The principle that trigger skills are the only supported entry path into a persona — direct agent invocation is unsupported. |
| **Extension Point** | The standard hook every agent body ends with: check `agents.local/extensions/<name>.md` and follow any additional instructions found there. |
| **symbol-query** | The canonical lookup pattern for a class/function/type in source: `Grep <SymbolName>` → `Read(offset=line-5, limit=60)`. |
| **Catalog file** | A `<name>-catalog.md` reference doc — a queryable symbol/component inventory. Always `symbol-query`'d, never read in full. |
| **Search Protocol** | The decision-gate table dictating which tool (KMS, Grep, Read, Glob) to use for a given kind of lookup. |
| **plan.md / context.md / state.json** | The three state files passed between phases of a persona run — per-artifact instructions, key symbols/conventions, and phase-completion pointer, respectively. |
| **Build-directly** | A deliberate opt-out: a worker makes layer-assignment decisions inline with no plan, no human gate, no tool restriction. Only reachable for brand-new features with no prior run. |
| **Use / Extend / Override** | The three modes a downstream project can use to consume a shipped agent or skill — as-is, with an additive delta file, or with a full local replacement. |
| **Mode** (agent mode) | A named section of an agent body, loaded only when the calling skill passes a matching `mode:` — keeps one agent body serving multiple invocation contexts. |
| **Ubiquitous language** (pattern keys) | The rule that one KMS concept = one `pattern` key, used identically across every platform. |

---

## Named Agents

A few cross-cutting agents use non-descriptive proper names — worth a pointer if you encounter them:

| Name | What it is |
|---|---|
| **lucci-planner** | Generic codebase explorer that writes a `plan.md` for an arbitrary task — never modifies source. |
| **kaku-worker** | Generic executor that reads an approved `plan.md` and implements it end-to-end. |
| **saturn-jaygarcia** | The Type O skill that pairs `lucci-planner` + `kaku-worker` into a plan-then-build flow for arbitrary tasks. |

---

## Changelog

See git history for this file.
