# Internal Agents

Internal tooling for maintaining this repo — convention review and component scaffolding. **Not symlinked to downstream projects.**

| Agent | Purpose |
|---|---|
| `arch-review-strategist` | Audit all agents and skills in this repo against the convention checklist |
| `agentic-arch-review-worker` | Review a specific scope (agent file, skill dir) for convention violations |
| `scaffold-worker` | Consult on and scaffold new agents, skills, or personas for this repo |

---

## Orchestration Model (current)

```
developer-feature-strategist  ← top-level, full-stack entry point
  ├── domain-worker           Phase 1 — Domain layer
  ├── data-worker             Phase 2 — Data layer
  └── pres-strategist       Phase 3 — Presentation + UI (sub-strategist)
        ├── presentation-worker   StateHolder
        └── developer-ui-worker     UI binding

developer-backend-strategist  ← backend-only entry point
  ├── domain-worker
  └── data-worker

pres-strategist             ← standalone entry point (when backend already exists)
  ├── presentation-worker
  └── developer-ui-worker

debugger-strategist  ← debug entry point
  └── debugger-worker
```

Workers are resolved by name at runtime from `.claude/agents/`. The correct platform implementation is wired by `setup-symlinks.sh --platform=<platform>` at project setup time.

---

## Extension

Add project-specific logic without touching shared files:
- Create `.claude/agents.local/extensions/<agent-name>.md` (delta only)
- Each agent ends with an extension hook that reads this file if present
