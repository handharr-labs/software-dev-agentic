---
name: developer-groom-ticket
description: Groom a locally fetched Jira ticket against the codebase — maps acceptance criteria to Clean Architecture layers, identifies work items and open questions, then updates the ticket via developer-adjust-ticket. Run before /developer-plan-feature or /developer-plan-build-feature.
user-invocable: true
disable-model-invocation: true
allowed-tools: Agent, AskUserQuestion, Read, Bash
---

## Arguments

`$ARGUMENTS` — optional path to the local ticket `.md` file.

## Preflight — Resolve Thinker Model

```bash
echo "$CIPHERPOL_THINKER_MODEL"
```

If the value is `cost-saving`, every `Agent` spawn of `developer-groom-strategist` or a layer planner in this skill (Steps 2–4) must pass `model: sonnet` as an override. Otherwise (unset, `optimized`, or any other value), omit the `model` parameter — each agent uses its frontmatter default (`opus`).

## Step 1 — Resolve Ticket Path

If `$ARGUMENTS` is provided, use it as the ticket path.

If `$ARGUMENTS` is empty, call `AskUserQuestion`:

```
question    : "What is the path to your local ticket file? (e.g. /path/to/TICKET-123.md)"
header      : "Ticket path"
multiSelect : false
options     :
  - label: "Enter path", description: "Provide the absolute path to the ticket .md file"
```

Verify the file exists before continuing. If it does not exist, report the path and stop.

## Step 2 — Detect Scope

Spawn `developer-groom-strategist` with mode `detect-scope`:

> **Mode: detect-scope**
>
> **ticket-path:** <resolved absolute path>

Wait for the strategist to return a `Decision: spawn-planners` or `Decision: blocked`.

- **`Decision: blocked`** → surface the strategist's question to the user via `AskUserQuestion`. Then re-spawn `developer-groom-strategist` in `detect-scope` mode with the original prompt **plus** the user's clarification appended. Do NOT use `SendMessage` to resume the blocked agent.
- **`Decision: spawn-planners`** → extract `spawn`, `reason`, and `skipped` from the block. Call `AskUserQuestion`:

  ```
  question    : "Scope detected. Ready to explore these layers?

                 In scope:
                 <for each layer in spawn: "• <layer> — <reason>">

                 <if skipped is non-empty:>
                 Skipped:
                 <for each entry in skipped: "• <layer> — <reason>">"
  header      : "Scope"
  multiSelect : false
  options     :
    - label: "Looks correct", description: "Proceed with these layers"
    - label: "Adjust",        description: "Change which layers are explored before continuing"
  ```

  **Looks correct** → proceed to Step 3.  
  **Adjust** → ask the user what to add or remove. Re-spawn `developer-groom-strategist` in `detect-scope` mode with the user's correction appended to the prompt, then re-evaluate.

## Step 3 — Spawn Planners

Spawn each planner listed in the `Decision: spawn-planners` block **in parallel**, passing each the grooming-mode instruction:

> **Mode: grooming-only**
>
> Do NOT recommend artifacts to create. Do NOT produce plan-ready output. Omit `### Impact Recommendations`.
>
> Your task is discovery only:
> - What artifacts already exist for this feature area?
> - Which layer does this ticket touch?
> - What naming conventions are in use?
> - Are there any ambiguities or gaps — missing interfaces, inconsistent naming, unclear ownership?
>
> Return a short findings block. One finding per bullet — no prose paragraphs.

Also pass to each: feature name (from ticket title), platform (if detectable from ticket), module-path (if detectable).

Wait for all planners to complete.

## Step 4 — Synthesize and Update Ticket

Spawn `developer-groom-strategist` with mode `synthesize`:

> **Mode: synthesize**
>
> **ticket-path:** <resolved absolute path>
>
> **Planner Findings:**
> <paste all planner findings blocks>

The strategist produces the grooming summary and returns it.

Once the strategist completes, invoke `developer-adjust-ticket` directly with the ticket path — pass the grooming summary as session context so the skill can write the Session Adjustment section without asking the user again.
