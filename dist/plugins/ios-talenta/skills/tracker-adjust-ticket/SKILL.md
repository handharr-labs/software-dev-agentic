---
name: tracker-adjust-ticket
description: Adjust a locally fetched Jira ticket (.md file) based on session discussion. Updates only the Session Adjustment section — never touches any other content.
user-invocable: true
tools: Read, Edit, AskUserQuestion
---

## Arguments

`$ARGUMENTS` — optional path to the local ticket `.md` file.

## Precondition

If `$ARGUMENTS` is empty, use `AskUserQuestion` to ask:

> "What is the path to your local ticket file? (e.g. /path/to/TICKET-123.md)"

Verify the file exists before continuing. If it does not exist, report the path and stop.

## Steps

1. Read the ticket file at the provided path.

2. Extract the **Acceptance Criteria** from the ticket (any checklist items under an Acceptance Criteria heading). These will be duplicated into the Session Adjustment section as the authoritative checklist.

3. Use `AskUserQuestion` to gather session context. Ask each of the following, one at a time:

   - "What progress was made during this session? (e.g. which layers or components were implemented)"
   - "Any decisions made this session? (e.g. design choices, tradeoffs resolved)"
   - "Any open questions or blockers remaining?"
   - "What is the current development status? (e.g. In Progress, Ready for Review, Blocked)"
   - "Which work items were completed this session? List them so I can mark the checklist."

4. Compose the adjustment section using the answers. Use today's date (ISO 8601) as the last-updated date.

   - Copy every Acceptance Criteria item into `## Acceptance Criteria` as a checklist. Mark items checked (`- [x]`) only for those the user confirmed as done; leave the rest unchecked (`- [ ]`).
   - Populate `## Work Items` with a checklist of granular tasks worked on this session. Mark each item done (`- [x]`) if the user confirmed it completed; leave the rest `- [ ]`.
   - Write `## Decisions` as prose bullets — one bullet per decision, including the rationale.
   - Write `## Open Questions` as a checklist — one `- [ ]` item per unresolved question or blocker. Omit the section if empty.

   Do NOT edit, reorder, or remove any other existing content in the file.

5. Check if a `# Session Adjustment` section already exists in the file.

   - **If it exists:** replace the entire block (from the preceding `---` separator through the end of the section) with the updated content below.
   - **If it does not exist:** append the block at the end of the file.

   ```
   ---

   # Session Adjustment — <YYYY-MM-DD>

   ## Acceptance Criteria

   <checklist duplicated from the ticket's Acceptance Criteria; checked items reflect confirmed done work>

   ## Work Items

   <checklist of granular tasks worked on or completed this session>

   ## Progress

   <narrative summary of what was implemented this session>

   ## Decisions

   <prose bullets — one per decision with rationale; omit section if none>

   ## Open Questions

   <checklist of unresolved questions or blockers — omit section if none>

   ## Status

   <current development status>
   ```

6. Confirm to the user: "Ticket updated — Session Adjustment section written. No other content was modified."

## Rules

- NEVER edit, reorder, or strip any content outside the `## Session Adjustment` section. The only writable area is between the `---` separator and the end of that section.
- Always duplicate the Acceptance Criteria from the ticket body into the Session Adjustment section. When criteria change, update only the copy inside Session Adjustment — never the original.
- Always include a `## Work Items` checklist to track progress. Mark items `- [x]` as confirmed done, `- [ ]` otherwise.
- `## Decisions` and `## Open Questions` are always separate sections — never combined.
- Omit `## Decisions` if no decisions were made; omit `## Open Questions` if none remain.
- There is always exactly one `# Session Adjustment` section — update it in place, never append a second one.
- Use `Edit` to replace the existing section, or to append if none exists yet.
