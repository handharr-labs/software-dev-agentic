> Author: Puras Handharmahua · 2026-06-13
> Related: [agentic-conventions.md](agentic-conventions.md) · [agentic-design-principles.md](agentic-design-principles.md) · [agentic-glossary.md](agentic-glossary.md) · [../repo-structure.md](../repo-structure.md)

What is where inside `lib/` and the agentic side of `.claude/` — the map. For naming conventions, component types, and authoring rules, see [agentic-conventions.md](agentic-conventions.md).

---

## `lib/core/<persona>/` — Persona Anatomy

```
lib/core/<persona>/
├── agents/             → strategists, planners, workers (see Agent Naming Convention)
├── skills/
│   ├── orchestrators/
│   │   └── <skill-name>/SKILL.md   → Type O — user-facing entry skills
│   └── procedures/
│       └── <skill-name>/SKILL.md   → Type P — thin, agent-only, create-only skills
├── hooks/              → lifecycle hooks (currently developer persona only)
└── reference/          → flat, persona-specific reference docs
    ├── <name>-catalog.md       → queryable symbol/component inventory — symbol-query, never read in full
    └── plan-format.md, findings-format.md, etc. → cross-agent schema/contract docs
```

Current personas: `developer`, `debugger`, `auditor`, `qa`, `installer`. Each lives at `lib/core/<persona>/` — see [Component Types — Persona](agentic-conventions.md#persona) for requirements.

---

## `lib/core/aegis/` — Cross-Cutting

```
lib/core/aegis/
├── agents/             → kaku-worker, lucci-planner, perf-worker, etc. — no persona prefix
├── skills/
│   ├── orchestrators/
│   │   ├── saturn-jaygarcia/    → Type O pairing lucci-planner + kaku-worker
│   │   ├── cipherpol-status/
│   │   ├── agentic-perf-review/
│   │   └── release-project/
│   └── procedures/
│       └── detect-platform/
└── reference/<topic>/  → topic-grouped, shared across personas (e.g. saturn-jaygarcia/plan-format.md)
```

---

## `lib/plugins/` — Plugin Definitions

```
lib/plugins/
├── cipherpol-aegis/
│   ├── build.sh           → assembles agents + skills from lib/core/*/agents, lib/core/*/skills/*/*/
│   └── build.config.json
└── cipherpol-8/
    ├── build.sh           → assembles KMS server + ChromaDB from kms/
    └── build.config.json
```

---

## `lib/ai-platforms/` — Non-Claude Agent Templates

```
lib/ai-platforms/
├── copilot/template.md
└── gemini/template.md
```

Templates for adapting this toolkit's conventions to other AI coding assistants. Not bundled into Claude Code plugins.

---

## `.claude/` — Internal Tooling (Not Bundled)

```
.claude/
├── agents/             → internal tooling agents (e.g. agentic-arch-review-worker, agentic-migrate-worker)
├── skills/             → internal tooling skills (e.g. agentic-arch-check-conventions)
└── settings.local.json
```

Not shipped to downstream plugins — see [repo-structure.md — `.claude/` boundary](../repo-structure.md#repository-structure).

---

---

## Runtime State (Downstream Projects Only)

Not part of this repo. See [agentic-runtime-structure.md](agentic-runtime-structure.md) for what lands on disk in a downstream project when a persona runs (`.claude/agentic-state/`, run directories, `state.json`, etc.).

---

## Changelog

See git history for this file.
