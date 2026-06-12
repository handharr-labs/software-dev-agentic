# Plan Document Format

Single source of truth for the `plan.md` schema used by the saturn-jaygarcia plan-then-build flow — written by `lucci-planner`, consumed by `kaku-worker` and `saturn-jaygarcia`.

---

## Schema <!-- 29 -->

```markdown
# Plan: <short title>

## Goal
<what success looks like, in 1-3 sentences>

## Context
<key files, existing patterns, and constraints discovered during exploration>

## Steps
1. <step description> — `<file path(s)>`
2. ...

## Files Affected
| Path | Change |
|---|---|
| <path> | create / modify / delete — <what changes> |

## Open Questions
(omit section entirely if none)
- <question>

## Risks / Notes
(omit section entirely if none)
- <risk or note>
```

---

## Section Contracts <!-- 10 -->

| Section | Required | Written by | Read by | Purpose |
|---|---|---|---|---|
| `## Goal` | always | lucci-planner | user | One-line success criteria shown during review |
| `## Context` | always | lucci-planner | user | Exploration findings — why the plan looks this way |
| `## Steps` | always | lucci-planner | kaku-worker | Ordered execution list |
| `## Files Affected` | always | lucci-planner | kaku-worker | Verification checklist after build |
| `## Open Questions` | conditional | lucci-planner | saturn-jaygarcia | If present, triggers a clarification + `revise` round before Approve/Discuss/Cancel is offered |
| `## Risks / Notes` | conditional | lucci-planner | user | Surfaced during review, no automated handling |
