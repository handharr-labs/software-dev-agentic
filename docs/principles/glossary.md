> Author: Puras Handharmahua · 2026-06-13
> Related: [agentic/agentic-glossary.md](agentic/agentic-glossary.md) · [kms/kms-glossary-lite.md](kms/kms-glossary-lite.md) · [kms/kms-glossary.md](kms/kms-glossary.md)

## What This Doc Covers

A single, alphabetical index of every term coined — or given a project-specific meaning — across this project's modules. Each entry is a one-line definition with a pointer to its module glossary for more detail. Start here if you don't know which module a term belongs to; jump to the module glossary if you need the full picture.

---

## Index

| Term | Module | Definition |
|---|---|---|
| Agentic Stack | [Agentic](agentic/agentic-glossary.md) | The three-tier execution model: Orchestrator Skill (Type O) → Agent(s) → Procedure Skill(s) (Type P). |
| Artifact | [KMS](kms/kms-glossary-lite.md) | Named body of knowledge within a discipline — an open-ended folder name, e.g. `conventions`, `standard-architecture`. |
| Build-directly | [Agentic](agentic/agentic-glossary.md) | Deliberate opt-out where a worker makes layer decisions inline with no plan/gate — brand-new features only. |
| Cascade resolution | [KMS](kms/kms-glossary-lite.md) | Fallback order `project → platform → universal` when fetching a knowledge node. |
| Catalog file | [Agentic](agentic/agentic-glossary.md) | A `<name>-catalog.md` queryable symbol/component inventory — always `symbol-query`'d, never read in full. |
| CipherPol | [Agentic](agentic/agentic-glossary.md) | Name of this whole multi-platform agentic toolkit (this repo). |
| cipherpol-8 | [Agentic](agentic/agentic-glossary.md) | Plugin shipping the KMS MCP server (`cp8`) and pre-seeded ChromaDB. |
| cipherpol-aegis | [Agentic](agentic/agentic-glossary.md) | Plugin shipping all agents and skills (all personas) downstream. |
| Convergence loop | [Agentic](agentic/agentic-glossary.md) | Skill-owned loop: spawn agents → collect Decision block → spawn again until `converged`. |
| Decision block | [Agentic](agentic/agentic-glossary.md) | Structured strategist output — `Decision: spawn-planners`, `converged`, `spawn-worker`, `blocked`. |
| Discipline | [KMS](kms/kms-glossary-lite.md) | Role/work-area a knowledge artifact serves — `engineering`, `qa`, `design`, etc. |
| Disk-First Inter-Agent Communication | [Agentic](agentic/agentic-glossary.md) | Agents hand off via files on disk (`plan.md`, `context.md`, `state.json`) — never inline content between rounds. |
| Extension Point | [Agentic](agentic/agentic-glossary.md) | Standard end-of-agent hook: check `agents.local/extensions/<name>.md`. |
| kaku-worker | [Agentic](agentic/agentic-glossary.md#named-agents) | Generic executor that implements an approved `plan.md` end-to-end. |
| KMS | [KMS](kms/kms-glossary-lite.md) | Knowledge Management System — ChromaDB-backed knowledge store, queried via `cp8` MCP. |
| kms_fetch / kms_list / kms_query / kms_upsert | [KMS](kms/kms-glossary-lite.md) | The four MCP tools for exact retrieval, TOC browsing, semantic search, and manual seeding. |
| Knowledge Path | [KMS](kms/kms-glossary-lite.md) | The ordered tuple of Rosetta Stone terms (`scope` → `platform`/`project` → `discipline` → `artifact` → `topic` → `pattern`) that addresses a knowledge node. |
| Knowledge Path Structure | [KMS](kms/kms-glossary-lite.md) | The directory + heading convention every Knowledge Path is an instance of — `{scope}/[{platform}\|{project}]/{discipline}/{artifact}/{file}.md` plus `#`/`##` chunking. |
| Knowledge | [Agentic](agentic/agentic-glossary.md) | Theory/conventions stored in KMS, retrieved via `kms_*` tools — distinct from Reference. |
| lucci-planner | [Agentic](agentic/agentic-glossary.md#named-agents) | Generic codebase explorer that writes a `plan.md` for an arbitrary task — never modifies source. |
| Marketplace | [Agentic](agentic/agentic-glossary.md) | The Claude Code plugin marketplace (`hndhr/software-dev-agentic`) that this repo's Plugins are published to. |
| Mode | [Agentic](agentic/agentic-glossary.md) | A named section of an agent body, loaded only for a matching `mode:` from the calling skill. |
| Module | [Agentic](agentic/agentic-glossary.md) | A top-level sub-project of this repo, each with its own concerns — currently `kms/` and `lib/`. |
| Orchestrator Skill (Type O) | [Agentic](agentic/agentic-glossary.md) | User-facing entry skill — routes, pre-loads context, spawns agents, owns convergence + approval. |
| Pattern (aka Subtopic) | [KMS](kms/kms-glossary-lite.md) | A `##` heading — one retrievable concept, canonical across all platforms. |
| Persona | [Agentic](agentic/agentic-glossary.md) | A named group of related agents serving one coherent workflow, mapped to an SDLC role. |
| Planner | [Agentic](agentic/agentic-glossary.md) | Read-only explorer agent scoped to one CLEAN layer; returns findings. |
| plan.md / context.md / state.json | [Agentic](agentic/agentic-glossary.md) | The three state files passed between phases of a persona run. |
| Platform | [KMS](kms/kms-glossary-lite.md) | Which client platform a knowledge node applies to — `flutter`, `ios`, `android`, `web`. |
| Plugin | [Agentic](agentic/agentic-glossary.md) | A distributable unit built from `lib/plugins/*/build.sh` — `cipherpol-aegis` and `cipherpol-8`. |
| Procedure Skill (Type P) | [Agentic](agentic/agentic-glossary.md) | Thin (~10–30 line), agent-only, create-only skill — no routing or decision logic. |
| Project | [KMS](kms/kms-glossary-lite.md) | Specific downstream codebase a knowledge node is a deviation/inventory for. |
| Reference | [Agentic](agentic/agentic-glossary.md) | Extracted formats/contracts/templates reused across agents/skills — file-addressable, platform-agnostic. |
| Rosetta Stone | [KMS](kms/kms-glossary-lite.md) | The full term-to-path-to-metadata mapping table in `kms-glossary.md`. |
| saturn-jaygarcia | [Agentic](agentic/agentic-glossary.md#named-agents) | Type O skill pairing `lucci-planner` + `kaku-worker` into a plan-then-build flow. |
| Scope | [KMS](kms/kms-glossary-lite.md) | Cascade tier of a knowledge node — `universal`, `platform`, or `project`. |
| Scoping funnel | [KMS](kms/kms-glossary-lite.md) | `kms_list` narrowing order: `platform`/`project` → `discipline` → `artifact` → `topic` → `pattern`. |
| Search Protocol | [Agentic](agentic/agentic-glossary.md) | Decision-gate table for which tool (KMS, Grep, Read, Glob) to use for a given lookup. |
| Skill-First Entry | [Agentic](agentic/agentic-glossary.md) | Principle that trigger skills are the only supported entry path into a persona. |
| Strategist | [Agentic](agentic/agentic-glossary.md) | Pure-reasoning agent — decides and returns Decision blocks, never spawns agents or writes files. |
| symbol-query | [Agentic](agentic/agentic-glossary.md) | Canonical source lookup: `Grep <SymbolName>` → `Read(offset=line-5, limit=60)`. |
| Topic | [KMS](kms/kms-glossary-lite.md) | A `#` heading inside an artifact file — thematic grouping of related concepts. |
| Trigger Skill | [Agentic](agentic/agentic-glossary.md) | The Type O skill that is a persona's only supported entry path. |
| Ubiquitous language (pattern keys) | [Agentic](agentic/agentic-glossary.md) | One KMS concept = one `pattern` key, identical across all platforms. |
| Use / Extend / Override | [Agentic](agentic/agentic-glossary.md) | The three modes a downstream project can consume a shipped agent/skill in. |
| Worker | [Agentic](agentic/agentic-glossary.md) | Any agent that executes a plan and writes source files, regardless of role label. |

---

## Changelog

See git history for this file.
