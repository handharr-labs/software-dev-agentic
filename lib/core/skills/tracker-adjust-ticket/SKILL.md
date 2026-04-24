---
name: tracker-adjust-ticket
description: Adjust a locally fetched Jira ticket (.md file) based on session discussion. Appends a new section capturing development progress — never modifies existing content.
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

3. Compose the adjustment section using the answers. Use today's date (ISO 8601) as the section timestamp.

   Do NOT edit, reorder, or remove any existing content in the file.

4. Append the following block at the **end** of the file:

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

5. Confirm to the user: "Ticket updated — new session adjustment section appended. No existing content was modified."

## Rules

- NEVER edit, reorder, or strip any content that already exists in the ticket file.
- NEVER overwrite a previous `## Session Adjustment` section — always append a new one.
- Use `Edit` to append only — target the end of the file.
