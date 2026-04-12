---
name: docs-identify-changes
description: Given a session delta description and current Confluence doc content, identify which sections are stale and need updating. Called by docs-sync-worker before applying updates.
user-invocable: false
tools: Glob, Grep
---

Given the session delta and the current doc content, return a list of stale sections per doc.

## Section Map

Use this to translate session delta topics → affected doc sections.

### Shared Submodule Architecture doc

| Changed topic | Affected sections |
|---|---|
| New agents added to `core/agents/` | "What Goes Where" table, Repository Structure, Per-Project Layout |
| New persona group created | Key Design Decision 2 (Persona Grouping), "What Goes Where", Repository Structure, Setup & Installation |
| New platform added | Key Design Decision 1 (DI at Skill Level), Repository Structure |
| Scripts (`setup-packages.sh`, `setup-symlinks.sh`) changed | Setup & Installation |
| New skills added to `platforms/<platform>/skills/` | "What Goes Where", Per-Project Layout |
| Internal tools added to root `agents/` or `skills/` | "What Goes Where", Convention Compliance System, Repository Structure |
| Convention checklist updated | Convention Compliance System |
| New design decision | Key Design Decisions (add new entry) |
| Principle added to Core Design Principles doc | Relationship to Core Design Principles table |
| Open item resolved | Open Items table |
| Reference doc structure changed | Key Design Decision 4 (Reference Docs Split) |

### Core Design Principles doc

| Changed topic | Affected sections |
|---|---|
| New principle added | Principles list, "Why This Architecture" table |
| Agent added or removed from `core/agents/` | Agent Count Summary, software-dev-agentic Structure, Implementation Reference |
| Agent moved to a different persona group | Agent Count Summary, software-dev-agentic Structure |
| New skills added | Agent Count Summary (skill counts), Implementation Reference |
| New platform skill added | Agent Count Summary, software-dev-agentic Structure |
| Worker rewritten (e.g. platform-agnostic refactor) | Relevant principle body, Agent Count Summary footnote |
| Folder structure changed | software-dev-agentic Structure, Folder Design Rationale table |
| New execution example | Execution Examples |
| Internal tooling added | Agent Count Summary (internal tooling table), software-dev-agentic Structure |

## Output Format

Return a structured list — one block per doc:

```
DOC: <doc name>
  STALE: <section name> — <reason>
  STALE: <section name> — <reason>
  UNCHANGED: <all other sections>

DOC: <doc name>
  ...
```

## Rules

- Map each item in the session delta to one or more rows in the Section Map above
- If a delta item doesn't match any row, flag it as `UNMAPPED: <item>` — the worker will decide
- Be conservative: only mark a section STALE if the delta clearly affects it
- Do not read or fetch the docs yourself — the caller passes the content
