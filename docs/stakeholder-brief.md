# We Gave Our Engineers an AI Team

> software-dev-agentic — Engineering Stakeholder Brief
> April 2026

---

## The Problem

Building a feature used to look like this.

An engineer picks up a ticket. They spend the first hour reading existing code — understanding how the project is structured, what patterns to follow, where files should go. Then they write the feature: domain logic, data layer, API wiring, UI. They make decisions along the way that may or may not be consistent with how another engineer solved the same problem last week on a different product.

We have three platforms — **Web**, **iOS**, and **Flutter**. Three codebases. Three sets of conventions. Three places where the same architecture decisions get made differently, drift over time, and create inconsistency that slows down every engineer who touches them next.

This is not a people problem. It is a **system problem**.

---

## What We Built

We built a shared AI engineering toolkit — **software-dev-agentic** — that gives every engineer on every platform access to the same specialized AI team, following the same standards, every time.

It is not a chatbot. It is not autocomplete.

It is a **hierarchy of specialized AI agents** — each one an expert in a specific layer of how we build software — that work together to deliver complete features autonomously.

---

## How It Works

Think of it as a small engineering team, permanently on call.

```
You describe the feature
        ↓
  Project Manager AI        ← understands the full picture, delegates the work
  ┌─────────────────────────────────────────────┐
  │  Backend Engineer AI    ← domain logic       │
  │  Data Engineer AI       ← APIs and databases │
  │  Frontend Engineer AI   ← state management   │
  │  UI Engineer AI         ← screens and views  │
  └─────────────────────────────────────────────┘
        ↓
  Complete feature, across all layers, ready for review
```

Each specialist knows exactly what they own, what they don't touch, and what quality looks like. The Project Manager AI coordinates them in the right order, passes only what each needs, and reports back when the work is done.

**The engineer's job shifts from writing boilerplate to reviewing output.**

---

## The Results

We ran this in production across three products — **wehire**, **xpnsio**, and **talenta-iOS** — over four days in April 2026.

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

The system improves itself. Every session produces a performance report. Every performance report drives a toolkit update. Every toolkit update makes the next session better — across all three products simultaneously.

---

## What Makes This Different

### One toolkit, every platform

The same AI engineering team works on Web, iOS, and Flutter. The architectural rules are shared. Platform-specific knowledge — Swift syntax, TypeScript patterns, Dart conventions — is swapped in automatically based on the project.

An improvement made for wehire ships to xpnsio and talenta the same day.

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

**More platforms.** Flutter support is in progress. Android is on the roadmap. The architecture is built to add a new platform with no changes to the shared system.

**Broader scope.** The same agent model that builds features can be applied to performance analysis, security review, and migration automation.

**Shorter feedback loops.** The gap between "a developer describes intent" and "a feature is ready for review" continues to shrink.

---

## In One Sentence

We built a system where an engineer describes what they want to build, and a team of specialized AI agents builds it correctly — across every platform, at a fraction of the cost, every time.

---

*Prepared by Engineering · April 2026*
*Technical details: `docs/core-design-principles.md` · Performance data: `docs/agentic-performance-report-apr-2026.md`*
