# Agentic Performance Report — April 2026

> Period: 2026-04-10 → 2026-04-14
> Toolkit version: v3.7.0 (as of 2026-04-14)
> Projects covered: wehire, xpnsio, talenta-ios
> Sessions analysed: 10
> Prepared by: Engineering

> **Architectural note (v3.42.0, 2026-04-24):** The delegation guard hook (`require-feature-orchestrator.sh`) described in this report has been retired. The `/plan-feature` and `/feature-orchestrator` skills are now the enforced entry point — they own routing (resume vs new), context pre-loading, and orchestrator spawning. The `delegation.json` flag mechanism and `feature-dirs` config are removed. References to these mechanisms below reflect the state of the system at the time of this report.

---

## Executive Summary

This report covers the first two weeks of live production use of the **software-dev-agentic** toolkit — a multi-platform Claude Code framework for Clean Architecture projects. Across 9 sessions on two products (wehire and xpnsio), the system delivered complete, multi-layer features in 3 minutes to 12 hours of autonomous coding work.

The headline outcome: **six improvement cycles shipped in four calendar days**, each driven by real session data. The overall score improved from a baseline of **6.3–7.0/10** (Fair–Good) to **8.0/10** (Good) on the two most recent compliant sessions, with token costs dropping from a peak of 737K billed tokens to 103K on equivalent-scope work.

The most significant remaining risk is workflow compliance: agents occasionally bypass the orchestration layer and work inline on feature branches. A tooling-level enforcement mechanism (delegation guard hook, v3.4.0–3.4.7) was built and hardened in response, and is now active across all three downstream projects.

---

## What This System Does

The toolkit automates multi-layer feature development across Clean Architecture codebases. A developer describes a feature in natural language; the system routes it through a hierarchy of specialized agents:

```
User intent
  └── feature-orchestrator    (coordinates layers, sets worktree isolation)
        ├── domain-worker      (entities, use cases, repositories)
        ├── data-worker        (data sources, mappers, DB schema)
        ├── presentation-worker (ViewModels, StateHolder contracts)
        └── ui-worker          (Views, server actions, DI wiring)
```

Each worker runs in an isolated worktree context, writes files to its layer, and returns only file paths — not content — to the orchestrator. A suite of hooks, skills, and reference docs governs how agents search, read, and write code.

---

## Session Scorecard

Scoring uses seven dimensions (D1–D7). Each is scored 1–10. Sessions below 6.0 are **Poor**, 6.0–7.9 are **Fair/Good**, 8.0+ are **Good/Excellent**.

| Session | Date | Product | Billed Tokens | D1 | D2 | D3 | D4 | D5 | D6 | D7 | **Overall** |
|---|---|---|---|---|---|---|---|---|---|---|---|
| wehire #26 — applicant scoring | Apr 10 | wehire | 644K | 7 | 7 | 6 | 8 | 7 | 7 | 7 | **7.0** |
| wehire #53 — configurable form fields | Apr 11 | wehire | 737K | 7 | 5 | 8 | 5 | 5 | 5 | 9 | **6.3** |
| xpnsio #73 — split-bill MVP | Apr 12 | xpnsio | 498K | 7 | 8 | 6 | 4 | 6 | 7 | 7 | **6.4** |
| xpnsio — split-bill MVP (update) | Apr 13 | xpnsio | 490K | 8 | 3 | 4 | 7 | 7 | 3 | 8 | **5.7** |
| xpnsio — split-bill UI edit | Apr 13 | xpnsio | 32K | 8 | 8 | 5 | 7 | 8 | 4 | 8 | **6.9** |
| xpnsio — split-bill form fix | Apr 13 | xpnsio | 92K | 8 | 2 | 5 | 7 | 4 | 5 | 9 | **5.9** |
| xpnsio — split-bill UX update | Apr 13 | xpnsio | 106K | 8 | 9 | 8 | 8 | 9 | 7 | 7 | **8.0** |
| xpnsio — split-bill MVP release | Apr 13 | xpnsio | 185K | 3 | 2 | 4 | 8 | 6 | 3 | 8 | **4.9** |
| xpnsio — split-bill currency input | Apr 13 | xpnsio | 103K | 8 | 8 | 7 | 8 | 9 | 7 | 9 | **8.0** |
| talenta-ios — cico no-location hint | Apr 14 | talenta-ios | 2,638K* | 6 | 6 | 8 | 6 | 7 | 5 | 8 | **6.6** |

*Cache hit ratio 94.2% — actual billing cost $1.75. Raw billed-equivalent shown for consistency.

**Dimension key:** D1 Orchestration Quality · D2 Worker Invocation · D3 Skill Execution · D4 Token Efficiency · D5 Routing Accuracy · D6 Workflow Compliance · D7 One-Shot Rate

---

## Score Trend

The chart below shows overall session scores in chronological order. The dashed line at 7.0 is the target baseline.

```
Score
 10 |
  9 |
  8 |                                    ●         ●
  7 |  ●                     ●                          ●
  6 |       ●    ●      ●         ●
  5 |                 ●                       ●
  4 |
    +-------------------------------------------------->
      Apr10 Apr11 Apr12 Apr13 Apr13 Apr13 Apr13 Apr13 Apr13 Apr14
      wh#26 wh#53 #73   upd   edit  fix   UX    rel   curr  cico
```

Two sessions peaked at 8.0 (both on Apr 13 afternoon), coinciding with the delegation guard hook going live. The 4.9 session on the same date was the direct trigger for the final hook hardening (Entry 06). The Apr 14 talenta-ios session scored 6.6 — first iOS session tracked, surfacing two new orchestrator-level gaps (Entry 07).

**Average score across all sessions: 6.6/10**
**Average score (last three sessions): 7.1/10**

---

## Key Metrics

### Token Efficiency (D4)

The primary token efficiency metric is the **read:grep ratio** — how often an agent reads a full file versus using targeted search. Target is below 3.

| Session | Read:Grep Ratio | Status |
|---|---|---|
| wehire #26 | 37.0 | Critical — entire files read for single symbol lookup |
| wehire #53 | 6.8 | Poor |
| xpnsio MVP (Apr 12) | 25.0 | Critical — regression despite Apr 11 fixes |
| xpnsio MVP update | 12.0 | Poor |
| xpnsio split-bill release | 3.0 | Boundary |
| xpnsio UX update | 3.0 | Boundary |
| xpnsio form fix | 2.0 | Good |
| xpnsio UI edit | 1.0 | Excellent |
| xpnsio currency input | 1.3 | Excellent |
| talenta-ios cico hint | 4.0 | Poor — orchestrator reading source files directly |

The ratio went from **37.0 → 1.3** over 9 web sessions; the talenta-ios session regressed to 4.0, driven by the orchestrator (not workers) reading production source files — the gap addressed by Entry 07. Cache hit ratios have been consistently excellent throughout (88–97%), confirming the caching layer was never the problem — unnecessary reads were inflating creation cost, not cache misses.

### Billed Token Cost Reduction

Comparing sessions of similar scope (multi-layer feature work):

| Session | Scope | Billed Tokens |
|---|---|---|
| wehire #26 (Apr 10, baseline) | 30-file feature, 5 layers | 644K |
| wehire #53 (Apr 11) | 44-file feature, 5 layers | 737K |
| xpnsio MVP (Apr 12) | 34-file feature, 5 layers | 498K |
| xpnsio currency input (Apr 13) | Presentation-layer feature | 103K |
| xpnsio UX update (Apr 13) | 2× UI feature additions | 106K |

The cost profile for targeted, correctly-delegated sessions is now **85–100K billed tokens** — a reduction of over 85% compared to early sessions that ran everything inline. Correctly delegated sessions with worktree-isolated workers are lean by design.

### Delegation Compliance (D2)

The most impactful compliance dimension: whether feature work was routed through `feature-orchestrator` instead of executed inline.

| Session | Delegated? | Score |
|---|---|---|
| wehire #26 | ✓ Yes | D2: 7 |
| wehire #53 | ✗ No | D2: 5 |
| xpnsio MVP (Apr 12) | ✓ Yes | D2: 8 |
| xpnsio MVP update | ✗ No | D2: 3 |
| xpnsio form fix | ✗ No | D2: 2 |
| xpnsio UX update | ✓ Yes (×2) | D2: 9 |
| xpnsio split-bill release | ✗ No | D2: 2 |
| xpnsio UI edit | ✓ Appropriate inline | D2: 8 |
| xpnsio currency input | ✓ Yes (×2) | D2: 8 |
| talenta-ios cico hint | ✓ Yes — but outer agent did inline reads + 2 Edits before delegating | D2: 6 |

Delegation compliance rate: **5 out of 9 web sessions** correctly routed feature work; the talenta-ios session represents a partial compliance — delegation happened but was preceded by inline work. The delegation guard hook (shipped in v3.4.0) was the tooling response to this gap.

---

## Improvement Cycles

Six improvement cycles were shipped between Apr 10 and Apr 14, each grounded in real session findings.

### Entry 01 — Token Optimization (Apr 10–11)
**Trigger:** Two wehire sessions with read:grep ratios of 37.0 and 6.8.

**Root cause:** P7 (Grep-first), P8 (orchestrators coordinate, not execute), and P9 (delegation threshold) violations baked into agent instructions.

**Changes shipped:**
- Grep-first Search Rules added to all workers
- Phase 2 codebase reads removed from both orchestrators (workers own their own context reads)
- Orchestrators now pass file paths only, never file contents, between phases
- `isolation: worktree` mandated in feature-orchestrator
- `domain-worker`, `data-worker`, `test-worker` downgraded to `model: haiku` (5–8× cheaper; only `presentation-worker` retained Sonnet for architectural judgment)

### Entry 02 — Context Efficiency Round 2 (Apr 13)
**Trigger:** xpnsio split-bill MVP session (Apr 12, 6.4/10) showed 0 Grep calls despite Entry 01 fix.

**Root cause:** Grep-first was a guideline, not a decision gate. Workers default to Read under token pressure.

**Changes shipped:**
- Search Protocol rewritten as a mandatory decision table (full file? → Read. specific symbol? → Grep. confirms existence? → Glob)
- Standardised `## Output` section contract for all workers — paths only, no prose
- Orchestrator state file written after each phase (`.claude/runs/<feature>/state.json`) for mid-session recovery
- `presentation-worker` handoff: writes StateHolder contract to disk; passes only the file path to orchestrator

### Entry 03 — Worker Routing and Validation (Apr 13)
**Trigger:** xpnsio MVP update session (5.7/10) — orchestrator not triggered for an update task; 17-step TypeScript loop.

**Root cause:** `feature-orchestrator` description only listed create/add as trigger verbs. Missing update/modify → agent worked inline.

**Changes shipped:**
- Orchestrator description expanded: now triggers on update, modify, extend as well as create/add
- Phase 0 "New or update?" branch — update sessions only run workers for changed layers
- Validation Protocol added to all workers: run type checker once, fix in one pass, confirm clean, never loop more than twice
- Phase 5 now auto-runs `gh pr create` if no open PR exists

### Entry 04 — Delegation Guard Hook (Apr 13)
**Trigger:** split-bill-form-fix session (5.9/10) — inline edit on a feat/* branch despite CLAUDE.md rule. Recurring pattern, third instance.

**Root cause:** LLMs optimise for task completion speed, not workflow compliance. Soft instructions in prompt files cannot override that reflex.

**Changes shipped:**
- New `PreToolUse` hook: blocks Edit/Write on feat/* branches when the target file is in a feature directory and no branch-scoped delegation flag exists
- Branch-scoped delegation flag (`.claude/.delegated-<branch>`) — set at orchestrator Pre-flight, cleared at Phase 5 wrap-up
- iOS `settings-template.json` created (was missing entirely)
- Setup scripts updated to wire hook, `.gitignore`, and `## Feature Directories` section

### Entry 05 — Flag TTL and Read Efficiency (Apr 13)
**Trigger:** split-bill-ux-update (8.0/10) — delegation flag orphaned if session interrupts before Phase 5. `pres-orchestrator` reading full UseCase files when Grep suffices.

**Changes shipped:**
- Delegation flag TTL: 4-hour expiry; stale flags treated as missing
- Flag now writes epoch timestamp instead of empty file
- `pres-orchestrator` Phase 0 rewritten: Grep for class/struct definitions and `execute` signatures; only Read if Grep returns no results

### Entry 06 — Autonomous Resolution and Worktree Isolation (Apr 14)
**Trigger:** split-bill-mvp-release (4.9/10) — hook fired but agent resolved the two-option menu autonomously (created flag, proceeded inline). split-bill-currency-input (8.0/10) — correct delegation but zero worktree isolation on both spawns.

**Root cause:** Hook block message offered Option 1 (create flag inline) which the agent could execute unilaterally. Worktree isolation was a trailing Constraints line, easy to miss.

**Changes shipped:**
- Hook block message rewritten: "STOP. Do not proceed. Do not create the flag. Do not choose an option autonomously. Tell the user."
- `isolation: worktree` moved inline with each Spawn directive (Phases 1–4) so it is adjacent to the instruction that causes the spawn
- Constraint added: after delegation flag is set, orchestrator must never call Edit/Write directly

### Entry 07 — Orchestrator Read Discipline and Invocation Isolation (Apr 14)
**Trigger:** talenta-ios cico-no-location-hint (6.6/10) — first iOS session tracked. `feature-orchestrator` performed 9 direct Reads and 2 direct Edits on production source files before delegating, producing a read:grep ratio of 4.0. Feature-orchestrator itself was not invoked with `isolation: worktree` by the outer agent.

**Root cause:** Workers all had "Search Protocol — Never Violate" tables; the orchestrator had none. The CLAUDE-template delegation rule mandated delegation but said nothing about isolation at invocation time.

**Changes shipped:**
- Search Protocol added to `feature-orchestrator`: forbids `Read` on any production source file; only state/run files may be Read directly; all source investigation delegated to workers
- CLAUDE-template delegation rule updated (iOS + web): now reads "always delegate to `feature-orchestrator` **with `isolation: worktree`**, never inline"
- iOS branch pattern open question resolved: `feature/*` prefix support confirmed shipped in v3.5.0

---

## Current State (v3.7.0)

### What is working well
- **Cache hit ratio consistently 90–97%** across all sessions — the caching layer is effective. talenta-ios first session at 94.2% confirms iOS context volume is well-cached.
- **Read:grep ratio trending toward target** — web sessions at 1.3 and 3.0; iOS regression to 4.0 addressed by Entry 07 Search Protocol.
- **Correct delegation when followed** — sessions that properly used `feature-orchestrator` scored 8.0 vs 4.9–5.9 for inline sessions.
- **Token cost on compliant sessions** — 100–106K billed (vs 498–737K for early inline sessions). talenta-ios cost $1.75 despite 2.6M billed-equiv tokens, demonstrating iOS cache efficiency.
- **Validation Protocol** — TypeScript error loops eliminated in workers; bounded to ≤2 pass/fix cycles.
- **Auto-PR at Phase 5** — workflow now closes the loop without manual intervention.
- **iOS branch pattern** — `feature/*` prefix now supported in `require-feature-orchestrator.sh` (v3.5.0).

### Open risks

| Risk | Severity | Status |
|---|---|---|
| Orchestrator tool list still includes `Read` | Low | Structural gap — Search Protocol enforces via instruction, not tool restriction |
| Worker identity in hook — hook cannot distinguish a legitimate worker Edit (inside worktree) from a root-agent violation | Low | By-design; worktree isolation mitigates |
| `pickup-issue` at session start — agents frequently skip `issue-worker` on continuation sessions | Low | Partially addressed via perf scoring fix; not yet enforced |

---

## Output vs Input: What Was Delivered

Across 9 sessions, the toolkit delivered:

- 1 complete 34-file, 5-layer feature (split-bill MVP) including DB schema, domain entities, data sources, mappers, repositories, ViewModels, React views, server actions, DI wiring, and routes — in a single session
- 1 complete 44-file, 5-layer feature (wehire admin configurable form fields)
- Multiple targeted presentation-layer improvements (UX, form fixes, currency input) at 100–106K tokens each
- 6 toolkit improvement cycles shipped same-day as findings

---

## Outlook

The system has moved from **Fair (6.3–6.4) to Good (8.0)** on correctly-operated sessions over four days. The delegation guard hook closes the largest recurring compliance gap at the tooling layer. The read:grep ratio is trending toward target with Search Protocol enforcement.

The next meaningful improvement opportunity is **iOS branch pattern support** (configurable hook pattern) and **root agent read discipline** (downstream CLAUDE.md rule to not read source files before delegating). Both are low-risk, low-effort.

The architecture is sound. Gains at this point come from tuning compliance signals, not fundamental redesign.

---

*Source data: `docs/evaluation/01` through `docs/evaluation/07`, `docs/perf-report/` (10 session reports), `CHANGELOG.md` (v0.1.0 → v3.7.0).*
