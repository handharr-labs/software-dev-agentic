# Session Adjustment Format

> Author: Puras Handharmahua · 2026-06-16
> Related: developer-adjust-ticket-gather-worker.md (producer), developer-adjust-ticket-write-worker.md (consumer), developer-adjust-ticket/SKILL.md (orchestrator)

Single source of truth for two schemas used by the `/developer-adjust-ticket` flow:
1. `## Context Block` — assembled by the orchestrator (`SKILL.md`): gather-worker contributes `TICKET_PATH`, `TICKET_ID`, `ACCEPTANCE_CRITERIA`; orchestrator adds session fields via `AskUserQuestion`. Consumed by `developer-adjust-ticket-write-worker`.
2. `## Session Adjustment Section` — written by `developer-adjust-ticket-write-worker` into the ticket `.md` file

---

## Context Block Schema

Assembled by the orchestrator and passed verbatim as the `context` input to `developer-adjust-ticket-write-worker`. The gather-worker produces the first three fields; the orchestrator fills in the session fields from user answers.

```
TICKET_PATH: <absolute path to the .md file>
TICKET_ID: <e.g. TICKET-123>
ACCEPTANCE_CRITERIA:
<one line per AC item, original text preserved>
END_AC
PROGRESS: <narrative of what was implemented this session>
DECISIONS: <decisions made, or "none">
OPEN_QUESTIONS: <unresolved questions or blockers, or "none">
STATUS: <current development status, e.g. In Progress>
COMPLETED_ITEMS: <AC items confirmed done this session, or "none">
BUGS: <bugs found this session, or "none">
```

### Context Block Field Contracts

| Field | Required | Written by | Read by | Purpose |
|---|---|---|---|---|
| `TICKET_PATH` | always | gather-worker | write-worker | Identifies which file to edit |
| `TICKET_ID` | always | gather-worker | write-worker | Used in the confirmation output line |
| `ACCEPTANCE_CRITERIA` … `END_AC` | always | gather-worker | write-worker | AC items copied verbatim into the Session Adjustment checklist |
| `PROGRESS` | always | orchestrator | write-worker | Source for `## Progress` narrative and `## Work Items` checklist |
| `DECISIONS` | always | orchestrator | write-worker | Source for `## Decisions`; section omitted when value is "none" |
| `OPEN_QUESTIONS` | always | orchestrator | write-worker | Source for `## Open Questions`; section omitted when value is "none" |
| `STATUS` | always | orchestrator | write-worker | Written verbatim to `## Status` |
| `COMPLETED_ITEMS` | always | orchestrator | write-worker | Used to mark AC checklist items `- [x]`; "none" leaves all unchecked |
| `BUGS` | always | orchestrator | write-worker | Source for `## Bugs`; section omitted when value is "none" |

---

## Session Adjustment Section Schema

Written by `developer-adjust-ticket-write-worker` into the ticket `.md` file. Appended at the end if absent; replaces the existing block (from its preceding `---` separator) if present. There is always exactly one such section.

```markdown
---

# Session Adjustment — <YYYY-MM-DD>

## Acceptance Criteria

- [x] <completed criterion>
- [ ] <incomplete criterion>

## Work Items

- [x] <completed task>
- [ ] <in-progress or unstarted task>

## Progress

<narrative summary of what was implemented this session>

## Decisions

- <decision and rationale>

## Open Questions

- [ ] <unresolved question or blocker>

## Bugs

- [ ] <bug found this session>

## Status

<current development status>
```

### Session Adjustment Section Contracts

| Section | Required | Omit when | Written by | Purpose |
|---|---|---|---|---|
| `## Acceptance Criteria` | always | — | write-worker | Full AC checklist; checked items reflect confirmed done work |
| `## Work Items` | always | — | write-worker | Granular task checklist derived from `PROGRESS` |
| `## Progress` | always | — | write-worker | Narrative of what was implemented |
| `## Decisions` | conditional | `DECISIONS` is "none" | write-worker | Prose bullets — one per decision with rationale |
| `## Open Questions` | conditional | `OPEN_QUESTIONS` is "none" | write-worker | Checklist of unresolved questions or blockers |
| `## Bugs` | conditional | `BUGS` is "none" | write-worker | Checklist of bugs found this session |
| `## Status` | always | — | write-worker | Current development status |
