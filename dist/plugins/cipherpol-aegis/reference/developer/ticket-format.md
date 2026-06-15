# Ticket Format

> Author: Puras Handharmahua · 2026-06-15
> Related: developer-prd-breakdown-worker.md (proposal writer), developer-ticket-write-worker.md (file writer), developer-breakdown-prd/SKILL.md (parser + orchestrator)

Single source of truth for two schemas used by the `/developer-breakdown-prd` flow:
1. `## Breakdown Proposal` — returned by `developer-prd-breakdown-worker`, parsed by the SKILL
2. `TICKET-NNN.md` — written by `developer-ticket-write-worker` to the run directory

---

## Breakdown Proposal Schema

Returned as the final output of `developer-prd-breakdown-worker`. The SKILL parses `tickets` from this block.

```
## Breakdown Proposal

**Summary:** N tickets | X SP

| # | Type | Title | SP |
|---|---|---|---|
| 1 | Story | ... | 3 |
| 2 | Task  | ... | 2 |
...

## Ticket Details

### 1. <Title>
**Type:** Story|Task|Sub-task
**Story Points:** N
**Description:**
<1–3 sentences: what this ticket delivers and why, sourced from the PRD>

**Acceptance Criteria:**
- [ ] <specific, testable criterion>
- [ ] <specific, testable criterion>
- [ ] <specific, testable criterion>

---

### 2. <Title>
...
```

### Breakdown Proposal Section Contracts

| Section | Required | Written by | Read by | Purpose |
|---|---|---|---|---|
| `**Summary:**` line | always | prd-breakdown-worker | SKILL (display) | Human-readable count and total SP |
| Summary table | always | prd-breakdown-worker | SKILL (parse tickets list) | Quick overview used to render the discussion table |
| `## Ticket Details` | always | prd-breakdown-worker | SKILL (parse each ticket object) | Full ticket data — description and AC per ticket |
| `**Type:**` | always | prd-breakdown-worker | ticket-write-worker | Determines Jira issue type and ticket file frontmatter |
| `**Story Points:**` | always | prd-breakdown-worker | ticket-write-worker | Fibonacci SP written to file frontmatter |
| `**Description:**` | always | prd-breakdown-worker | ticket-write-worker | PRD-sourced context written to `## Description` section |
| `**Acceptance Criteria:**` | always | prd-breakdown-worker | ticket-write-worker | Testable criteria written to `## Acceptance Criteria` section |

---

## TICKET-NNN.md Schema

Written by `developer-ticket-write-worker` to `<run_dir>/tickets/TICKET-NNN.md`. Index is zero-padded to 3 digits.

```markdown
---
type: Story|Task|Sub-task
story_points: N
---

# <Title>

## Description

<description>

## Acceptance Criteria

- [ ] <criterion>
- [ ] <criterion>
- [ ] <criterion>

## References

- Parent: <parent_key>
- PRD: <prd_source>
```

### TICKET-NNN.md Section Contracts

| Section | Required | Written by | Read by | Purpose |
|---|---|---|---|---|
| frontmatter (`type` / `story_points`) | always | ticket-write-worker | developer-jira-ticket-worker | Machine-readable metadata for Jira creation |
| `# <Title>` | always | ticket-write-worker | user, developer-jira-ticket-worker | Ticket summary line |
| `## Description` | always | ticket-write-worker | user, developer-jira-ticket-worker | PRD-sourced context for the implementer |
| `## Acceptance Criteria` | always | ticket-write-worker | user, developer-jira-ticket-worker | Testable done-criteria |
| `## References` | always | ticket-write-worker | user | Traceability — links ticket back to epic and PRD source |
