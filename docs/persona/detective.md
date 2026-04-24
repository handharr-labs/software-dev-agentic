> Related: Core Design Principles · Shared Agentic Submodule Architecture · detective-agent-design.md

## What is the Detective Persona?

The **detective** persona is the root cause investigation workflow. It applies the scientific debugging method to find and surface bugs — without fixing them.

Its governing principle: **diagnosis and treatment are separate concerns.** Detective finds the wound; a different agent closes it.

Location: `lib/core/agents/detective/`

---

## Governing Theory

Detective is built on **Scientific Debugging**, formalized by Andreas Zeller in *Why Programs Fail* (2009). The core idea: debugging is not intuition — it is hypothesis-driven experimentation. A bug is a cause-effect chain from a root defect to an observable failure. The job is to narrow that chain systematically until the defect is isolated.

Zeller's method applied to this persona:

| Step | In theory | In detective |
|---|---|---|
| Observe | Collect the failure — input, output, symptom | Entry point, expected vs actual, layer where symptom appears |
| Hypothesize | Form a falsifiable claim about the defect | 2–3 ranked hypotheses from static analysis |
| Predict | State what evidence would confirm or deny the claim | Exact log points that would confirm each hypothesis |
| Experiment | Run the system and collect evidence | `debug-log-worker` instruments, user reproduces |
| Conclude | Accept, refine, or reject the hypothesis | `debug-worker` interprets logs, reports root cause |

Two constraints enforced from the theory:

1. **Never skip to Conclude** — instrumentation without a hypothesis produces noise, not signal
2. **Separation of diagnosis and treatment** — finding the defect and fixing it are distinct cognitive tasks; mixing them produces guesses dressed as fixes

---

## Anatomy

The detective persona follows the scientific debugging sequence strictly. Each agent owns one step and stops.

```
User (natural language)
 │
 ▼
debug-orchestrator            — static analysis; forms 2–3 ranked, falsifiable hypotheses
 │
 ▼
debug-log-worker (MODE=add)   — inserts hypothesis-tagged log statements at predicted failure points
 │
 [user reproduces the bug in the running app]
 │
 ▼
debug-worker                  — interprets log output; concludes root cause
 │
 ▼
debug-log-worker (MODE=remove) — strips all instrumentation before commit
```

**Key structural constraint — tool isolation:**

`Edit` lives exclusively in `debug-log-worker`. `debug-orchestrator` and `debug-worker` are physically read-only. No diagnostic agent can alter logic — only log statements, only via the designated instrumenter.

**Short-circuit path:**

When the root cause is statically visible (e.g. a silent catch block in plain view), `debug-orchestrator` routes directly to `debug-worker` — no instrumentation cycle needed. `debug-log-worker` is skipped entirely.

**Handoff boundary:**

Detective terminates with a `ROOT CAUSE` report. The user decides the next action — invoking a builder worker, applying a trivial inline fix, or escalating. Detective never chooses or invokes the fix agent.

---

## Step-to-Agent Mapping

| Scientific Debugging Step | Agent |
|---|---|
| Observe + Hypothesize | `debug-orchestrator` — static analysis, ranked hypotheses |
| Predict + Experiment | `debug-log-worker` — MODE=add, inserts hypothesis-tagged logs |
| Conclude | `debug-worker` — interprets log output, reports root cause |
| Cleanup | `debug-log-worker` — MODE=remove, strips all logs before commit |

---

## Agent Roster

| Role | Agent | Responsibility |
|---|---|---|
| Orchestrator | `debug-orchestrator` | Static analysis, hypothesis formation, instrumentation coordination |
| Worker | `debug-worker` | Traces runtime errors through CLEAN layers to root cause |
| Worker | `debug-log-worker` | Adds and removes debug instrumentation logs in source files |

---

## Tool Boundary Rule

`Edit` lives exclusively in `debug-log-worker`. All other detective agents are read-only by design.

| Agent | Tools | Can write files? |
|---|---|---|
| `debug-orchestrator` | Read, Glob, Grep | No |
| `debug-worker` | Read, Glob, Grep | No |
| `debug-log-worker` | Read, Edit, Glob, Grep | Yes — log statements only |

This is a structural guarantee: the orchestrator and worker physically cannot modify code. Only `debug-log-worker` can, and only to insert or remove log statements — never to change logic.

---

## Handoff

Detective always terminates with a `ROOT CAUSE` report from `debug-worker`:

```
ROOT CAUSE   [one sentence]
LAYER        [DI / Domain / Data / Presentation]
EVIDENCE     [file path — what the code does vs what it should do]
FIX          [exact change needed]
PREVENT      [the CLEAN rule that was violated]
```

This report is the input to the next agent — typically a builder worker (`domain-worker`, `data-worker`, `presentation-worker`) or a direct edit if the fix is trivial. Detective does not choose or invoke the fix agent; the user decides what to do with the findings.

---

## Execution Examples

**Silent failure** — "Form submission does nothing after tapping the button"
```
debug-orchestrator         ← traces call chain statically, forms 2–3 hypotheses
  └─ debug-log-worker      ← MODE=add, instruments StateHolder + use case entry/exit
     [user reproduces]
  └─ debug-worker          ← interprets logs, reports: "Use case never called — event not wired in DI"
  └─ debug-log-worker      ← MODE=remove, strips instrumentation before commit
```

**Root cause visible statically** — "Repository returns null but no error is thrown"
```
debug-worker               ← reads repository + data source, finds silent catch block
                           ← reports root cause directly, no instrumentation needed
```

**Unknown crash location** — stack trace spans multiple layers
```
debug-orchestrator         ← maps stack trace to CLEAN layers, identifies likely layer
  └─ debug-worker          ← traces from crash site outward, finds DI binding mismatch
```

---

## CLEAN, SOLID, and DRY

**CLEAN via Investigation:** Detective traces bugs through CLEAN layer boundaries — Presentation → Domain → Data. Layer violations (wrong imports, leaking dependencies, wrong-direction calls) are a first-class failure mode it looks for, not just a side observation.

**SOLID via Agent Design:**
- **SRP:** Each agent has one job — orchestrator hypothesizes, worker traces, log-worker instruments
- **OCP:** New platform workers extend detective without modifying existing agents
- **ISP:** Tool access is scoped by role — read-only agents never receive `Edit`

**DRY:** The `ROOT CAUSE` report format is defined once in `debug-worker` and never re-implemented elsewhere. All investigation paths converge to the same output contract.

---

## Future Scaling

Two planned expansions — neither implemented yet:

**Platform workers** — platform-specific debugging methodology for Flutter, iOS, and Android. Each knows its runtime's log format, package ecosystem, and common failure patterns. `debug-orchestrator` would route to the relevant platform worker based on context.

**Feature reference docs** — domain knowledge for complex cross-platform features (e.g. Live Tracking, Clock In/Out). Stored in `lib/core/reference/features/` with greppable per-platform sections. Platform workers read only their section — one `Grep`, not a full file `Read`.

See `docs/detective-agent-design.md` for the full design rationale.

---

## Open Items

| # | Topic | Status |
|---|---|---|
| 1 | Platform workers (Flutter, iOS, Android) | Not started — design decided, implementation pending |
| 2 | Feature reference docs structure | Not started — structure decided, no docs written yet |
| 3 | `debug-orchestrator` routing update | Needed once platform workers exist |
| 4 | Where platform workers live — `detective/` vs `lib/platforms/<platform>/agents/` | Open question |
