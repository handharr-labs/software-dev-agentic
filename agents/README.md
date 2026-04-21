# Internal Agents

Internal tooling for maintaining this repo — convention review and component scaffolding. **Not symlinked to downstream projects.**

| Agent | Purpose |
|---|---|
| `arch-review-orchestrator` | Audit all agents and skills in this repo against the convention checklist |
| `arch-review-worker` | Review a specific scope (agent file, skill dir) for convention violations |
| `scaffold-worker` | Consult on and scaffold new agents, skills, or personas for this repo |

---

## Orchestration Model (current)

```
feature-orchestrator          ← top-level, full-stack entry point
  ├── domain-worker           Phase 1 — Domain layer
  ├── data-worker             Phase 2 — Data layer
  └── pres-orchestrator       Phase 3 — Presentation + UI (sub-orchestrator)
        ├── presentation-worker   StateHolder
        └── ui-worker             UI binding

backend-orchestrator          ← backend-only entry point
  ├── domain-worker
  └── data-worker

pres-orchestrator             ← standalone entry point (when backend already exists)
  ├── presentation-worker
  └── ui-worker

debug-orchestrator            ← debug entry point
  └── debug-worker
```

Workers are resolved by name at runtime from `.claude/agents/`. The correct platform implementation is wired by `setup-symlinks.sh --platform=<platform>` at project setup time.

---

## Extension

Add project-specific logic without touching shared files:
- Create `.claude/agents.local/extensions/<agent-name>.md` (delta only)
- Each agent ends with an extension hook that reads this file if present
