# CipherPol Console Initiative

**Status:** Design — approved direction, not yet implemented
**Date:** 2026-07-03
**Author:** Puras Handharmahua
**Supersedes:** step 7 of the [KMS knowledge-management redesign](2026-07-03-kms-knowledge-management-redesign.md) (the KMS dashboard becomes one section of this console) and the rudimentary `cipherpol-8-kms/dashboard/` (Python `server.py` + `index.html`).

**Goal:** A single local web console for the *whole* CipherPol toolkit — not just the KMS. Browse and understand every agent and skill across the repo, visualize how they compose into personas/workflows, and drive the KMS (tree, lineage, retrieval playground, contribute) — all from one place.

---

## Decisions Locked

| Decision | Choice | Rationale |
|---|---|---|
| Runtime | **Two modes: local (full) + static (hosted)** | Local `next dev` = full features. A static export (DB-free sections) is publishable via **GitHub Actions → Pages**. One codebase, mode switched by env. |
| DB access | **Next → Python API (option A)** | ChromaDB persistent mode is Python-only; the JS client needs a server. Reuse the tested Python retrieval (cascade + layer scoping + contextual-embed) behind a thin local HTTP API. Never reimplement retrieval in TS. |
| Interactivity | **Browse + visualize (read-only)** | Agents/skills are code-like markdown edited via editor + git/PR. The console explains structure; it does not edit it. (KMS keeps its inherently-interactive playground + contribute — local only.) |
| Stack | **Next.js 15** | Matches the web platform standard; Server Components read the repo FS; route handlers give the local API. |
| Sections | Catalog · KMS · Personas/workflow · Hooks · Reference/docs · Plugins | All approved. |

## Deployment Modes

The console has a hard architectural split that maps directly onto the two deploy targets:

| | **Local** (`next dev`) | **Hosted** (GitHub Actions → Pages, `output: 'export'`) |
|---|---|---|
| Catalog · Personas · Plugins · Reference/docs | ✅ live FS reads | ✅ **statically pre-rendered** from the repo at CI build time |
| KMS playground · contribute | ✅ via local Python API | ⛔ omitted / shown read-only (no backend, no write) |
| Data source | filesystem + Python API | filesystem only (baked at build) |

**The rule that makes both work:** DB-free sections get their data from **build-time filesystem reads in Server Components** (never from `/api` fetches), so they statically export. Only the KMS section uses `/api` route handlers — which are excluded from the static export, so KMS is inherently local-only. `next.config` toggles `output: 'export'` via a `STATIC_EXPORT` env var; the KMS nav/section is hidden when that flag is set.

---

## Information Architecture

### 1. Catalog — agents + skills, repo-wide *(headline)*

Every agent and skill across the repo — **58 agents / 63 skills**:

| Source | Agents | Skills | Shipped as |
|---|---|---|---|
| `cipherpol-aegis/lib` (developer, qa, aegis) | 38 | 48 | `cipherpol-aegis` plugin |
| `cipherpol-9/lib` | 3 | 1 | `cipherpol-9` plugin |
| `.claude` | 17 | 14 | internal tooling (not shipped) |

- **List + filter** — by persona/source, type (agent/skill), `model`, `user-invocable`, orchestrator-vs-worker (has `agents:` frontmatter), shipped vs internal.
- **Detail** — parsed frontmatter (`name`, `description`, `model`, `tools`, `agents:`, `related_skills`, `user-invocable`, `allowed-tools`) + rendered body.
- **Relationship graph** — the high-value view (see *Relationship Model* below).

### 2. KMS

Absorbs the existing Python dashboard. Source tree · source→node lineage (`source_file` → the nodes it produced) · staleness (`sources.yaml` `last_seeded` vs file mtime) · **retrieval playground** (pick an agent scope filter — `platform`/`discipline`/`layer` — run `kms_query`, see what that agent would get) · **contribute** (drop a draft → `/kms-contribute` flow).

### 3. Personas / workflow map

Groups agents + skills into personas and renders each **trigger skill's end-to-end flow**: Type O skill → agent(s) → Type P skill(s). Makes the Agentic Stack legible without reading files.

### 4. Hooks

Configured hooks from `settings.json` (+ any hook scripts) — what fires on which events. *(Note: no `settings.json` hooks found in-repo today; this section may start empty and is a placeholder for when hooks are added.)*

### 5. Reference & docs

Browse `docs/principles`, `docs/initiatives`, and `reference/` contracts — the design docs alongside the code they govern, with cross-links.

### 6. Plugins / build status

The three plugins (`cipherpol-aegis`, `cipherpol-9`, `cipherpol-8`) from `*/plugin/build.config.json` + `.claude-plugin/marketplace.json` — versions and what each bundles (which personas' agents/skills, the KMS DB, etc.).

---

## Relationship Model (the graph)

Nodes: agents, skills, personas. Edges derived from frontmatter/convention:

| Edge | Source of truth |
|---|---|
| orchestrator → sub-agent | agent frontmatter `agents:` list |
| skill → agent (spawns) | skill body references + `related_skills` |
| agent ↔ skill (pairing) | `related_skills` frontmatter |
| persona ⊃ agent/skill | directory (`lib/{persona}/…`) |
| trigger skill → workflow | Type O skill → its agents → Type P skills |

This turns the implicit "Agentic Stack" (Orchestrator Skill → Agent(s) → Procedure Skill) into an explicit, clickable map.

---

## Architecture

```
console/                      ← new Next.js 15 app at repo root
  app/
    catalog/                  ← agent+skill list, detail, graph
    kms/                      ← tree, lineage, staleness, playground, contribute
    personas/  hooks/  docs/  plugins/
    api/
      catalog/route.ts        ← parses frontmatter across lib dirs + .claude (live FS read)
      kms/route.ts            ← proxies to the KMS backend (reuse dashboard/server.py logic or the cp8 use cases)
      contribute/route.ts     ← writes _inbox / triggers classify
  lib/
    frontmatter.ts            ← the one parser: (path) → {frontmatter, body, source, persona}
    graph.ts                  ← builds nodes+edges from parsed frontmatter
```

- **Data is read live from the filesystem** on each request (control panel, not a build artifact) — the catalog always reflects the working tree.
- **KMS API** reuses the existing repository/use-case layer (the current `dashboard/server.py` already wraps `kms_list`/`kms_fetch`/`kms_query`) — the Next API route shells to it or a small FastAPI, so retrieval logic stays single-sourced in Python.
- One **frontmatter parser** feeds Catalog, Personas, and Plugins — no duplicated parsing.

---

## Build Milestones (each independently runnable)

1. **Scaffold** — Next.js 15 app at `console/`, layout + section nav, `frontmatter.ts` parser, `next dev` runs.
2. **Catalog** — list + filter + detail view over the live-parsed agents/skills. (Highest value; delivers the user's headline ask first.)
3. **Relationship graph** — `graph.ts` + a graph view (orchestrator→agents, persona groupings).
4. **KMS section** — port/reuse the Python dashboard behind an API route: tree, lineage, staleness, retrieval playground, contribute.
5. **Personas / workflow map** — trigger-skill flow view built on the graph.
6. **Plugins + Reference/docs + Hooks** — the lighter sections.
7. **GitHub Actions → Pages** — a workflow that `STATIC_EXPORT=1 next build`s the DB-free sections and publishes to Pages, so the catalog/graph/docs are browsable without cloning. (The static-capable design from milestones 1–6 makes this a config + workflow step, not a rewrite.)

---

## Open Questions

- **KMS backend wiring** — Next API route shells to the existing `dashboard/server.py`, or stand up a small FastAPI exposing the use cases? (Leaning: thin FastAPI so the console has a clean HTTP contract; retire the ad-hoc `server.py`.)
- **Graph rendering** — a dependency-free SVG/force layout vs a library. Must stay self-contained if any part is ever exported as an Artifact. (Leaning: lightweight in-app SVG.)
- **Location** — `console/` at repo root (proposed) vs under an existing dir. Root keeps it clearly repo-wide.
- **`.claude` internal vs shipped** — surface both but clearly badge internal-only tooling so it's not confused with distributed capability.
