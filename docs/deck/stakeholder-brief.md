# We Gave Our Engineers an AI Team

> CipherPol — Engineering Stakeholder Brief
> April 2026

---

## The Problem

Building a feature used to look like this.

An engineer picks up a ticket. They spend the first hour reading existing code — understanding how the project is structured, what patterns to follow, where files should go. Then they write the feature: domain logic, data layer, API wiring, UI. They make decisions along the way that may or may not be consistent with how another engineer solved the same problem last week on a different product.

We have four platforms — **iOS**, **Flutter**, **Android**, and **Web**. Four codebases. Four sets of conventions. Four places where the same architecture decisions get made differently, drift over time, and create inconsistency that slows down every engineer who touches them next.

This is not a people problem. It is a **system problem**.

---

## What We Built

We built a shared AI engineering toolkit — **CipherPol** — that gives every engineer on every platform access to the same specialized AI team, following the same standards, every time.

It is not a chatbot. It is not autocomplete.

It is a **hierarchy of specialized AI agents** — each one an expert in a specific layer of how we build software — that work together to deliver complete features autonomously.

---

## How It Works

Think of it as a small engineering team, permanently on call.

```
You describe the feature
        ↓
  Tech Lead            ← understands the full picture, delegates the work
  ┌──────────────────────────────────────────────────┐
  │  Domain Engineer    ← business logic, use cases  │
  │  Data Engineer      ← APIs, database, mappers    │
  │  State Engineer     ← state management           │
  │  UI Engineer        ← screens and components     │
  └──────────────────────────────────────────────────┘
        ↓
  Complete feature, across all layers, ready for review
```

Each specialist knows exactly what they own, what they don't touch, and what quality looks like. The Tech Lead coordinates them in the right order, passes only what each needs, and reports back when the work is done.

**The engineer's job shifts from writing boilerplate to reviewing output.**

---

## How the Team Is Built

The AI team is organized into **personas** — purpose-built groups, each responsible for a specific kind of engineering work. A persona is not a single agent; it is a complete mini-team with its own specialists.

| Persona | What it handles |
|---|---|
| **Builder** | Feature development — domain logic, data layer, state management, UI |
| **Detective** | Debugging, performance analysis, root cause investigation |
| **Auditor** | Architecture review, standards enforcement |
| **Tracker** | Issue management, backlog, branch coordination |
| **Installer** | Project setup, platform wiring |

Within each persona, every agent has one of two roles:

**Orchestrators** are the coordinators. When you describe a task, the orchestrator takes it — breaks it into steps, delegates to the right specialists in the right order, and compiles the result. It never writes code itself. Its job is to make sure the right work reaches the right expert.

**Workers** are the specialists. Each worker owns exactly one layer of the codebase and nothing else. The Domain worker handles business logic. The Data worker handles APIs and databases. The State worker handles state management. The UI worker handles screens. A worker handed a task outside its layer will stop and hand it back — by design.

**Skills** are the step-by-step procedures that workers follow. Each skill does exactly one thing: create a use case, build a data mapper, wire a screen to its state container. Skills are what make the output consistent — the same steps, in the same order, on every platform, every time.

### Where the Knowledge Lives

The team's knowledge is organized in three tiers:

| Tier | What it holds | Lives in |
|---|---|---|
| **Universal rules** | Standards that apply to every task — architecture boundaries, naming conventions, quality gates | Skills — injected into workers at startup |
| **Specialist logic** | Each agent's own decision-making — when to act, what to check, how to handle edge cases | Agent body — orchestrators and workers |
| **Reference library** | Deep architectural knowledge loaded on demand — layer contracts, design patterns, platform conventions | Reference docs — consulted by workers when needed |

This structure keeps the team consistent without making every interaction expensive. Universal rules are always active. Specialist logic is scoped to the agent that needs it. The reference library is consulted only when the task requires it.

---

## See It In Action

Here is what building the **Leave Request** feature looks like with this system.

### The team

To keep this readable, here is how the AI specialists map to plain English roles:

| Role | Agent | What it owns |
|---|---|---|
| Tech Lead | `feature-orchestrator` | Coordinates the team, enforces layer order, opens the PR |
| Domain Engineer | `domain-worker` | Business logic — entities, rules, use cases. Zero framework dependencies. |
| Data Engineer | `data-worker` | Data layer — API integration, database, mappers |
| State Engineer | `presentation-worker` | State management — ViewModel / BLoC / StateHolder |
| UI Engineer | `ui-worker` | Screens and components, bound to the state contract |

### What the engineer types

> *"Build the leave request feature. Employees can submit a request, managers can approve or reject it, and the submitter gets notified of the outcome."*

That is the entire input. One sentence of intent.

### What happens next

The Tech Lead takes over. It asks three short clarifying questions — what data operations are needed, whether this is a new feature or an update, and whether the platform has a separate UI layer. Then it gets to work.

```
Tech Lead
│
├── 1. Hands off to Domain Engineer
│      → Creates the LeaveRequest entity (pure business model, no framework)
│      → Creates the repository interface (defines data contract, no implementation)
│      → Creates three use cases:
│           SubmitLeaveRequestUseCase
│           ApproveLeaveRequestUseCase
│           RejectLeaveRequestUseCase
│      ✓ Done. Returns file paths.
│
├── 2. Hands off to Data Engineer
│      → Creates the API response model (mirrors the server payload)
│      → Creates the mapper (translates API data into domain model)
│      → Creates the data source (the actual API call)
│      → Creates the repository implementation (fulfils the domain contract)
│      ✓ Done. Returns file paths.
│
├── 3. Hands off to State Engineer + UI Engineer
│      State Engineer → Creates the state container
│                        Flutter: LeaveRequestBloc (events + states + BLoC)
│                        iOS:     LeaveRequestViewModel (ObservableObject + Combine)
│                        (wires use cases, owns UI state, handles events)
│      UI Engineer    → Creates the screen
│                        (observes state, dispatches events, handles navigation)
│      ✓ Done. Returns file paths.
│
└── Tech Lead compiles the result, opens a pull request.
```

### What comes out

A complete, production-ready feature across all layers — ready for the engineer to review:

| What was created | Who created it |
|---|---|
| `LeaveRequest` entity | Domain Engineer |
| `LeaveRequestRepository` interface | Domain Engineer |
| `SubmitLeaveRequestUseCase` | Domain Engineer |
| `ApproveLeaveRequestUseCase` | Domain Engineer |
| `RejectLeaveRequestUseCase` | Domain Engineer |
| API response model + mapper | Data Engineer |
| Data source + repository implementation | Data Engineer |
| `LeaveRequestBloc` (Flutter) / `LeaveRequestViewModel` (iOS) | State Engineer |
| Leave request screen + navigation | UI Engineer |
| Pull request opened, linked to ticket | Tech Lead |

Every file follows our architecture standards. Every layer only knows what it's supposed to know. No shortcuts, no drift.

**Total engineer time invested: one sentence and a code review.**

---

## The Results

We ran this in production across three mobile products — **talenta-iOS** (Swift/UIKit), **xpnsio** (Flutter), and **wehire** (Flutter) — over four days in April 2026.

### Speed

> A 34-file, 5-layer feature — domain logic, database, API, UI, all wired together — delivered in a single session.

That same feature would have taken a senior engineer 2–3 days. It now takes one session.

### Cost

We measure AI compute cost in tokens — the unit of work an AI model charges for.

| Week | Cost per feature session |
|---|---|
| Baseline (Apr 10) | 737,000 tokens |
| After 4 days of tuning | 103,000 tokens |

**85% reduction in AI compute cost in four calendar days.**

Not from switching to a cheaper model. From building the system correctly — specialists working in isolation, sharing only what they need to share.

### Quality

We score every session across 7 dimensions: how well the AI coordinated, routed work, followed standards, and got it right the first time. Scale is 1–10.

| Period | Average Score |
|---|---|
| First sessions | 6.3 / 10 |
| After one week | 8.0 / 10 |

The system improves itself. Every session produces a performance report. Every performance report drives a toolkit update. Every toolkit update makes the next session better — across all three mobile products simultaneously.

---

## What Makes This Different

### One toolkit, every platform

The same AI engineering team works on iOS, Flutter, Android, and Web. The architectural rules are shared. Platform-specific knowledge — Swift syntax, Dart/BLoC conventions, Kotlin patterns, TypeScript/Next.js conventions — is swapped in automatically based on the project.

An improvement made for talenta-iOS ships to all other platforms the same day.

### It enforces our standards automatically

Every feature built through this system follows our architecture. The AI agents don't know how to cut corners on it — it's not in their instructions.

This means less time in code review catching architecture drift. Less time onboarding engineers onto "how we do things here." Less technical debt accumulating quietly in the codebase.

### It compounds

The first week produced 6 rounds of improvements. Each round made the system measurably better. The more we use it, the better it gets — and every improvement is shared instantly across all products.

---

## What This Means for the Business

**We ship faster.** Features that took days take sessions.

**We ship consistently.** The same standards, every platform, every time.

**We scale without proportional headcount.** The AI team handles the repeatable, structured work. Engineers handle judgment, product decisions, and review.

**Our AI costs are going down, not up.** As the system matures, it becomes more efficient — not more expensive.

---

## Where We're Going

The toolkit today covers feature development, debugging, testing, and architecture review.

What's next:

**All four platforms active.** iOS, Flutter, Android, and Web are all live — same shared architecture, same agent team, same standards across all codebases. Reference docs are established and aligned to each platform's actual conventions.

**Broader scope.** The same agent model that builds features can be applied to performance analysis, security review, and migration automation.

**Shorter feedback loops.** The gap between "a developer describes intent" and "a feature is ready for review" continues to shrink.

---

## In One Sentence

We built a system where an engineer describes what they want to build, and a team of specialized AI agents builds it correctly — across every platform, at a fraction of the cost, every time.

---

*Prepared by Engineering · April 2026*
*Technical details: `docs/principles/core-design-principles.md`*
