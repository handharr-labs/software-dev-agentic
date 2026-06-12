# Reference Taxonomy

This directory contains shared knowledge loaded on demand by workers and planners via Grep-first. Read this file before adding a new reference doc or deciding where a piece of knowledge belongs.

---

## What Belongs in Reference <!-- 12 -->

A piece of knowledge belongs here if it passes all three tests:

1. **Fact, not instruction** — it can be stated without saying "you". Invariants, contracts, architectural rules, naming conventions.
2. **Shared** — more than one agent or worker needs it.
3. **Stable** — it changes when the architecture changes, not when a workflow changes.

If it only makes sense addressed to a specific agent ("before writing, check X"), it belongs in the agent body, not here.

---

## What Belongs in the Agent Body <!-- 10 -->

Keep in the agent if:

- It is execution behavior: when to run, what to check, what to do on failure
- It is decision logic specific to that agent's workflow
- It references the agent's own preconditions, skill routing, or output format

---

## What Belongs in Skills <!-- 10 -->

Keep in skills if:

- It is step-by-step procedural instructions for writing a specific artifact
- It contains platform-specific syntax, file templates, or code examples
- It is only relevant during the act of writing, not during planning or review

---

## Directory Structure <!-- 26 -->

```
lib/core/reference/
  README.md              ← this file — taxonomy and placement rules
  builder/
    layer-contracts.md   ← artifact types, creation order, invariants per layer
    di-containers.md     ← DI registration patterns (language-agnostic)
    domain-purity.md     ← what must never enter the domain layer
  saturn-jaygarcia/
    plan-format.md       ← plan.md schema and section contracts (lucci-planner / kaku-worker / saturn-jaygarcia)

lib/platforms/<platform>/reference/
  domain.md              ← platform-specific entity/use case patterns
  data.md                ← platform-specific DTO/mapper/datasource patterns
  presentation.md        ← platform-specific StateHolder + screen patterns
  navigation.md          ← platform-specific navigation/coordinator patterns
  di.md                  ← platform-specific DI wiring
  index.md               ← index of all reference files for this platform
```

`lib/core/reference/` docs are language-agnostic — no code syntax, no framework names as rules.
`lib/platforms/<platform>/reference/` docs contain code examples and are linked only to that platform.

---

## How Agents Use This Directory <!-- 6 -->

- Always Grep by section heading (`^## SectionName`) before reading a full file — the heading line contains `<!-- N -->` (auto-maintained line count); use N as the `limit` in the subsequent `Read(file, offset=matched_line, limit=N)` call
- If uncertain which file covers a topic, Grep `reference/index.md` (platform level) or this README first
- Never Read a reference file in full speculatively — target the section you need
- After adding a new reference file, add an entry to the relevant `index.md` and this README's directory map
