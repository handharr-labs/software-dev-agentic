---
name: tracker-adjust-ticket
description: Adjust a locally fetched Jira ticket (.md file) based on session discussion. Updates a single Session Adjustment section — never modifies other existing content.
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

2. Use `AskUserQuestion` to gather session context. Ask each of the following, one at a time:

   - "What progress was made during this session? (e.g. which layers or components were implemented)"
   - "Are there any blockers, decisions, or open questions from this session?"
   - "What is the current development status? (e.g. In Progress, Ready for Review, Blocked)"

3. Compose the adjustment section using the answers. Use today's date (ISO 8601) as the last-updated date.

   Do NOT edit, reorder, or remove any other existing content in the file.

4. Check if a `## Session Adjustment` section already exists in the file.

   - **If it exists:** replace the entire block (from the preceding `---` separator through the end of the section) with the updated content below.
   - **If it does not exist:** append the block at the end of the file.

   ```
   ---

   ## Session Adjustment — <YYYY-MM-DD>

   ### Progress

   <progress summary from step 2>

   ### Decisions & Open Questions

   <blockers, decisions, or open questions from step 2, or "None" if empty>

   ### Status

   <current development status from step 2>
   ```

5. Confirm to the user: "Ticket updated — session adjustment section updated. No other content was modified."

## Rules

- NEVER edit, reorder, or strip any content that already exists in the ticket file outside the Session Adjustment section.
- There is always exactly one `## Session Adjustment` section — update it in place, never append a second one.
- Use `Edit` to replace the existing section, or to append if none exists yet.
