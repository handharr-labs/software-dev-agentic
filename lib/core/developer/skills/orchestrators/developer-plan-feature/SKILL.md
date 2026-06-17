---
name: developer-plan-feature
description: Plan then build a feature — optionally resolves external inputs (Jira, PRD, Figma, local .md), gathers intent via developer-feature-intent-strategist, runs the convergence planning loop (spawning only the needed layer planners per round), shows an interactive approval prompt, then executes with developer-feature-worker (Domain/Data/Pres/App) followed by developer-ui-worker (UI layer) on approval.
user-invocable: true
disable-model-invocation: true
allowed-tools: Agent, AskUserQuestion, Bash, Read, WebFetch
---

## Routing Contract

This skill is a pure router. Its only permitted direct operations:
- `Bash` — preflight existence checks and run-dir persistence writes only
- `Read` — only for explicit `.md` input files passed as formal arguments to this skill
- `WebFetch` — only for non-Figma URLs passed as formal arguments to this skill
- `AskUserQuestion` — approval prompts defined in each step

**Arguments are only what follows `/developer-plan-feature` on the invocation line.** The rest of the user's message (instructions, context, directory hints) is NOT processed by the skill — pass it verbatim to the strategist in Step 1. Do not read files, grep, or explore based on anything in the message body.

Never confirm, summarize, or add extra questions between steps. Route directly on the Decision block returned by the strategist.

Never read source files, search the codebase, or write code. All exploration, planning, and implementation is exclusively delegated to strategist / planner / worker agents.

## Preflight — Detect Existing Runs

```bash
find "$(git rev-parse --show-toplevel)/.claude/agentic-state/developer/runs" -maxdepth 2 -name "plan.md" 2>/dev/null
find "$(git rev-parse --show-toplevel)/.claude/agentic-state/developer/runs" -maxdepth 2 -name "figma-fetch-dir.txt" 2>/dev/null
```

Collect results as `found_plans` and `found_figma` (`figma-fetch-dir.txt` paths). **Do not route yet.** Pass them to Step 1 so the strategist sees the user's intent alongside any existing runs before making a routing decision.

## Preflight — Resolve Thinker Model

```bash
echo "$CIPHERPOL_THINKER_MODEL"
```

If the value is `cost-saving`, every `Agent` spawn of `developer-feature-intent-strategist`, `developer-feature-convergence-strategist`, or a layer planner (`developer-domain-planner`, `developer-data-planner`, `developer-pres-planner`, `developer-app-planner`) anywhere in this skill must pass `model: sonnet` as an override. Otherwise (unset, `optimized`, or any other value), omit the `model` parameter — each agent uses its frontmatter default (`opus`). This does not apply to `developer-figma-fetch-worker`, `developer-feature-worker`, or `developer-ui-worker`.

## Step 0 — Classify Inputs

Parse only the formal arguments passed on the invocation line. The skill only fetches things that require its network tools — local files and directories go to the strategist as raw paths.

| Pattern | Type | Action |
|---|---|---|
| URL containing `jira` or `atlassian`, or bare ticket ID (e.g. `PROJ-123`) | Jira ticket | Fetch inline via Atlassian MCP → `resolved_inputs` |
| Any other URL (including `figma.com`) | PRD / doc / design | Fetch inline via `WebFetch` → `resolved_inputs` (Figma page URLs) or add to `raw_paths` |
| Local path where `ls <path>/state.json` or `ls <path>/plan.md` returns results | Existing run dir | Set as `explicit_run_dir` — skip Step 1, route via inline checkpoint below |
| Local path where `ls <path>/frame_*/` returns results | Existing figma fetch dir | Set as `figma_fetch_dir` — skip Step 1.5 fetch. Write path to `<run_dir>/figma-fetch-dir.txt` after run_dir is known. |
| Local file path or directory path | Local content | Add to `raw_paths` — do not read |

If no arguments are provided, skip this step — proceed to Step 1 with `resolved_inputs = []` and `raw_paths = []`.

### Explicit run_dir checkpoint routing

If `explicit_run_dir` was set above, inspect disk state and route without calling the strategist for gather-intent:

```bash
ls "<explicit_run_dir>/plan.md" 2>/dev/null
grep "^status:" "<explicit_run_dir>/plan.md" 2>/dev/null | head -1
python3 -c "
import json, sys
d = json.load(open('<explicit_run_dir>/state.json'))
layers = [k for k in ('domain','data','pres','app') if d.get(k)]
print('artifact_layers:', ','.join(layers))
" 2>/dev/null
cat "<explicit_run_dir>/figma-fetch-dir.txt" 2>/dev/null
```

Route:

| Disk state | Action |
|---|---|
| `plan.md` + `status: pending` | Set `run_dir = explicit_run_dir`. Proceed to Step 4 (Approve). |
| `plan.md` + `status: approved` | Set `run_dir = explicit_run_dir`. Proceed to Step 5 (Execute — batch resume skips complete batches). |
| No `plan.md` + state.json has ≥ 1 populated artifact layer | Set `run_dir = explicit_run_dir`. Restore `visited` from all populated layer keys (`domain`, `data`, `pres`, `app`) in state.json. Proceed directly to Step 2b (call strategist `process-findings`). |
| No `plan.md` + no populated artifact layers | Set `run_dir = explicit_run_dir`. Proceed to Step 1 — pass `run_dir` to the strategist so G1 skips the run-selection prompt and goes straight to G1b. |

Collect:
- `resolved_inputs` — successfully fetched remote items: `{ type, source, content }`
- `raw_paths` — local file and directory paths to hand to the strategist
- `failed_inputs` — remote items that could not be fetched: `{ type, source, reason }`

If `failed_inputs` is non-empty, call `AskUserQuestion`:

```
question    : "Some inputs couldn't be fetched: <list each with reason>. What would you like to do?"
header      : "Input Fetch"
multiSelect : false
options     :
  - label: "Continue",         description: "Proceed with the inputs that were successfully resolved"
  - label: "Provide manually", description: "Paste or describe the missing content before continuing"
  - label: "Cancel",           description: "Stop and retry after fixing the inputs"
```

**Continue** → proceed with `resolved_inputs` as-is.  
**Provide manually** → collect content from user, append to `resolved_inputs`. Then proceed.  
**Cancel** → stop.

## Step 1 — Gather Intent

Spawn `developer-feature-intent-strategist`:

> **Mode: gather-intent**
>
> **User message:**
> \<the full user message verbatim — includes any context, directory hints, or instructions the user provided\>
>
> <if found_plans or found_figma is non-empty, include:>
> **Existing runs:**
> \<found_plans list, or "(none)"\>
> **Existing figma groups:**
> \<found_figma list, or "(none)"\>
>
> <if resolved_inputs is non-empty, include:>
> **Resolved Inputs:**
> <for each item: "### <type> — <source>\n<content>">
>
> <if raw_paths is non-empty, include:>
> **Raw Paths:**
> \<list each path — strategist should read these to extract context and Figma URLs\>
>
> Ask the user for feature intent. Surface any existing runs and let the user choose to continue or start fresh. Return a Decision block when done.

Wait for the strategist to return. Route based on the Decision block:

- **`Decision: discard-partial`** → `rm -rf "<run_dir from decision>"`. Re-spawn strategist in `gather-intent` mode (same inputs, minus the discarded path from `found_plans`/`found_figma`).
- **`Decision: resume-execution`** with `plan_status: pending` → extract `run_dir`. Proceed to Step 4 (Approve).
- **`Decision: resume-execution`** with `plan_status: approved` → extract `run_dir`. Call `AskUserQuestion`:

  ```
  question    : "This plan was previously approved. How would you like to continue?"
  header      : "Resume Intent"
  multiSelect : false
  options     :
    - label: "Resume",      description: "Proceed to execution from where it left off"
    - label: "Extend",       description: "Extend the plan with new or changed requirements — completed work is preserved"
  ```

  **Resume** → proceed to Step 5 (Execute).  
  **Extend** → re-spawn strategist in `gather-intent` mode with the same inputs, passing `found_plans` and `found_figma` unchanged so the user can pick the run again or extend.
- **`Decision: spawn-planners`** → extract `feature`, `platform`, `module_path`, `run_dir`. If `update_mode: true` also extract `completed_artifacts`, `open_questions`, `figma_groups`. Extract `pending_figma_urls` (may be empty). Initialize `visited = []`, `round = 1` — **ignore any `round:` value present in the Decision block itself.** The loop always starts counting at 1 on every orchestrator invocation. Proceed to Step 1.5 (if `pending_figma_urls` non-empty) or Step 2.

## Step 1.5 — Fetch Figma Inputs (skip if `pending_figma_urls` is empty AND `figma_fetch_dir` already set)

**If `figma_fetch_dir` was set in Step 0** (user passed an existing fetch dir), write the pointer and jump to Step 1.5b:

```bash
echo "$figma_fetch_dir" > "<run_dir>/figma-fetch-dir.txt"
```

Spawn `developer-figma-validate-worker` with all `pending_figma_urls`:

> figma_urls: \<newline-separated URLs\>

Read `## Figma Validate Output`. Set `figma_fetch_dir` from the block. Write the pointer:

```bash
echo "$figma_fetch_dir" > "<run_dir>/figma-fetch-dir.txt"
```

If `invalid` is non-empty, call `AskUserQuestion`:

```
question    : "Some Figma URLs are invalid: <list each with reason>. What would you like to do?"
header      : "Figma URLs"
multiSelect : false
options     :
  - label: "Continue",  description: "Proceed with the valid frames only"
  - label: "Cancel",    description: "Stop and fix the URLs first"
```

**Cancel** → stop.

Read the validated frame list:

```bash
cat "<figma_fetch_dir>/pending-frames.json"
```

Spawn one `developer-figma-fetch-worker` per entry — pass `figma_url`, `feature`, and `figma_fetch_dir`. **Spawn all workers in parallel** (single Agent tool call).

Collect results into `figma_resolved` (workers that returned `## Figma Worker Output` blocks) and `figma_failed` (errors). If `figma_failed` is non-empty, call `AskUserQuestion`:

```
question    : "Some frames couldn't be fetched: <list each with reason>. What would you like to do?"
header      : "Figma Fetch"
multiSelect : false
options     :
  - label: "Continue",  description: "Proceed with the frames that were successfully fetched"
  - label: "Cancel",    description: "Stop and retry after fixing the inputs"
```

**Cancel** → stop.

### Step 1.5b — Verify Figma Grouping (skip if `figma_resolved` is empty)

Spawn `developer-figma-group-worker`:

> figma_fetch_dir: \<figma_fetch_dir\>
> platform: \<platform\>

Wait for the `## Figma Groups` output block. Extract `groups` as `figma_groups`, `review` (may be absent), and `ds_available` (may be absent — treat missing as `false`).

Build the grouping summary:
```
<for each group with type: screen:>
• <screen> — states: <comma-separated state names><if overlays present:>, overlays: <comma-separated overlay screen names>
<for each group with type: overlay:>
• <screen> (overlay of <parent_screen>) — states: <comma-separated state names>
<if review present:>

Needs your eye:
<for each review entry:>
• <frame>: <reason>
```

Call `AskUserQuestion`:

```
question    : "Figma frames grouped into screens. Does this look correct?

               <grouping summary>"
header      : "Figma Screens"
multiSelect : false
options     :
  - label: "Correct",  description: "Grouping looks right — proceed to planning"
  - label: "Adjust",   description: "The grouping needs changes before we continue"
```

**Correct** → store `figma_groups` and proceed.

**Adjust** → ask the user to describe corrections (which frames belong to which screen, any renames). Apply to `figma_groups`. Then proceed.

`figma_groups` structure carried forward:
```
[
  {
    screen: "<parent_frame>",
    type: "screen" | "overlay",
    parent_screen: "<screen name>",      // only present when type: overlay
    uistack_file: "<abs-path-to-figma-uistack-*.md>",
    states: [
      { state: "<state>", file: "<abs-path-to-.md>", layout_file: "<abs-path-to--layout.jsx>", screenshot: "<url>" },
      ...
    ]
  },
  ...
]
```

### Step 1.5c — Align UI Stacks to Design System (skip if `ds_available` is false or absent)

If `ds_available` is false or not present in the `## Figma Groups` block, skip this step entirely.

Collect the `uistack_file` path from every entry in `figma_groups`. Spawn one `developer-uistack-align-worker` per uistack file **in parallel** (single Agent tool call):

> uistack_file: \<abs path to figma-uistack-*.md\>
> platform: \<platform\>
> figma_fetch_dir: \<figma_fetch_dir\>

Collect all `## UIStack Align Output` blocks. Aggregate `flagged` items across all workers. If any items are flagged, carry the summary forward — it will be appended to the Step 4 approval prompt so the engineer sees design-system gaps before approving the plan.

**Persist figma_groups to disk** — write immediately after grouping is confirmed:

```bash
cat > "<figma_fetch_dir>/figma-groups.json" << 'EOF'
<figma_groups as JSON>
EOF
```

Initialize:
- `visited` = [] (empty set of explored layers)
- `all_findings` = [] (accumulated planner findings across all rounds)
- `round` = 1

Proceed to Step 2. Do not read widget files, grep the codebase, or write any code — all exploration, planning, and implementation is done by planners and workers.

## Step 2 — Planning Convergence Loop

**Reset session counters.** Always set `round = 1` and `visited = []` here, regardless of `update_mode` or what state.json contains from prior sessions. The convergence loop is session-local and has no relation to run history — any `round:` value returned by the strategist's Decision block must never be used to seed this counter.

Repeat until the strategist returns `Decision: converged` or `Decision: blocked`.

**Reset state.json planning section and persist raw_docs** at the start of the first round (round = 1). Always overwrite planning — history from prior sessions is not carried forward. Always write `raw_docs` with the current session's `raw_paths` (empty list if none):

```bash
python3 - <<'EOF'
import json, os, re
path = "<run_dir>/state.json"
d = json.load(open(path)) if os.path.exists(path) else {}
d["planning"] = {"rounds": []}
raw_docs = []
for p in [<raw_paths as Python list, or []>]:
    desc = os.path.basename(p)
    try:
        with open(p) as f:
            for line in f:
                line = line.strip()
                if line:
                    desc = re.sub(r'^#+\s*', '', line)[:120]
                    break
    except:
        pass
    raw_docs.append({"path": p, "description": desc})
d["raw_docs"] = raw_docs
json.dump(d, open(path, "w"), indent=2)
EOF
```

### 2a — Spawn planners for this round

From the current `Decision: spawn-planners` block, read the `spawn:` list. Spawn each listed planner **in parallel** (single Agent tool call with all planners in that round):

- `developer-domain-planner` — if `domain` is in the spawn list
- `developer-data-planner` — if `data` is in the spawn list
- `developer-pres-planner` — if `pres` is in the spawn list
- `developer-app-planner` — if `app` is in the spawn list

Pass to each planner: feature name, platform, module-path, run_dir (from strategist's gather-intent or review-resume output).

**If `raw_docs` in state.json is non-empty**, also pass:
- `raw_docs` — list of `{ path, description }` entries. Planners must `Read` each path for ground-truth details (endpoint paths, UI stack specs, etc.) before producing findings. Format when passing: one entry per line as `<path> — <description>`.

**If `update_mode` is true** (resume path with new intent), also pass:
- `open_questions` — the user's stated issues from the Decision block, verbatim. Planners use these to focus on what needs fixing rather than doing a full greenfield sweep.
- `completed_artifacts` — list of already-built artifact names. Planners treat these as locked: report `exists` status, do not propose recreating them.

For `developer-pres-planner` specifically — if `figma_groups` was established in Step 1.5b or Step R0, also pass:
- The full `figma_groups` structure (screen → states + file paths) — do NOT inline file contents

**Record spawn in state.json** before dispatching — write the round entry with each planner set to `spawned`:

```bash
python3 - <<'EOF'
import json, sys
path = "<run_dir>/state.json"
d = json.load(open(path))
d["planning"]["rounds"].append({"round": <N>, "planners": {<layer>: "spawned", ...}})
json.dump(d, open(path, "w"), indent=2)
EOF
```

Wait for all planners in this round to complete.

Proceed to 2b — the strategist validates findings and updates state.json.

### 2b — Send findings to strategist

Spawn `developer-feature-convergence-strategist`:

> **Mode: process-findings**
>
> Round: <N>
> Visited layers: <comma-separated list from visited set>
> run_dir: <run_dir>
> update_mode: <true | false>
>
> <if update_mode is true, include:>
> **existing_plan:**
> \<content of the archived plan-vN.md — re-read from disk if not already in context\>
>
> **existing_context:**
> \<content of the archived context-vN.md — re-read from disk if not already in context\>
>
> **completed_artifacts:** \<comma-separated list\>
> \<end if\>
>
> findings_dir: <run_dir>/findings/

Wait for the strategist's decision block.

- **`Decision: spawn-planners`** → increment `round`, go back to 2a
- **`Decision: synthesized`** → plan.md and context.md are already written; skip Step 3 and proceed directly to Step 4
- **`Decision: blocked`** → present the strategist's question to the user via `AskUserQuestion`, send the answer back to strategist as a follow-up `process-findings` call, then re-evaluate

**Max rounds guard:** If `round` reaches 6 without convergence, stop the loop and surface to the user:
> "Planning could not converge after 5 rounds. Open questions: <list from last blocked decision>. Please clarify before retrying."

## Step 3 — Synthesize Plan (fallback only)

> **When reached:** This step is only reached if the strategist returned `Decision: synthesized` is NOT yet used — e.g., in a future `discuss-more` re-synthesis triggered from Step 4. The normal convergence path skips here because `Decision: synthesized` from Step 2b means plan.md and context.md are already on disk.

Spawn `developer-feature-convergence-strategist` with mode `synthesize`:

> **Mode: synthesize**
>
> \<if update_mode is true:\>
> **update: true**
>
> **existing_plan:**
> \<content of current plan.md — read from disk\>
>
> **existing_context:**
> \<content of current context.md — read from disk\>
>
> **completed_artifacts:** \<comma-separated list\>
> \<end if\>
>
> findings_dir: <run_dir>/findings/

Wait for the strategist to return the plan summary and write plan.md + context.md.

## Step 4 — Approve

Call `AskUserQuestion` immediately after synthesis — do NOT describe choices in prose:

```
question    : "What would you like to do with this plan?<if flagged items from Step 1.5c exist:>

               ⚠ Design System Gaps (<N> items): some UI Stack components could not be matched to the design system or codebase. See `### Design System Alignment` in each uistack file for details.
               <end if>"
header      : "Plan"
multiSelect : false
options     :
  - label: "Approve",      description: "Execute this plan with developer-feature-worker"
  - label: "Discuss more", description: "I have questions or changes before this plan is finalized"
  - label: "Discard",      description: "Cancel and delete this plan"
```

**Approve** → proceed to Step 5.

**Discuss more** → address the engineer's questions inline. If the plan itself needs revision, re-run Step 3 (re-synthesize) with the updated requirements added to the findings context. Then call `AskUserQuestion` again with the same three options.

**Discard** → delete the most recent run directory:

```bash
rm -rf "$(git rev-parse --show-toplevel)/.claude/agentic-state/developer/runs/<feature>"
```

Stop.

## Step 5 — Execute

Update `status` in `plan.md` frontmatter from `pending` to `approved`. `plan.md` is the single source of truth for execution state — update batch statuses live as work progresses.

Read `batches` from `plan.md` frontmatter. Process each batch in `id` order where `status != complete`.

**For each batch:**

**5a — Mark in progress.** Set the batch's `status` to `in_progress` in `plan.md` frontmatter.

**5b — Determine worker by `layer`:**
- `layer: ui` → `developer-ui-worker`
- all others (`domain`, `data`, `pres`, `app`) → `developer-feature-worker`

**5c — Spawn the worker.** Re-read `plan.md` and `context.md` from disk before each spawn.

Also extract `raw_docs` from `state.json` before spawning any worker.

For `developer-feature-worker`:

> Pre-loaded context below — do not re-read plan.md, context.md, or state.json.
>
> **plan.md**
> \<content\>
>
> **context.md**
> \<content\>
>
> \<if raw_docs is non-empty:\>
> **Reference docs:**
> \<for each entry: "<path> — <description>"\>
> `Read` the relevant doc(s) for ground-truth details (endpoint paths, request/response shapes, field names) before implementing any artifact. Do not rely solely on plan.md/context.md if a doc covers the artifact.
> \<end if\>
>
> **Batch:** Process only these artifacts: \<batch.artifacts comma-separated\>. Skip any already complete in plan.md.
>
> Proceed directly to the first pending artifact in this batch.

For `developer-ui-worker` — also extract `stateholder_contract` from `state.json` first:

> Pre-loaded context below — do not re-read plan.md, context.md, or state.json.
>
> **plan.md**
> \<content\>
>
> **context.md**
> \<content\>
>
> **Stateholder contract path:** \<stateholder_contract from state.json, or "none" if null\>
>
> \<if raw_docs is non-empty:\>
> **Reference docs:**
> \<for each entry: "<path> — <description>"\>
> `Read` the relevant doc(s) for ground-truth details (UI stack specs, component structure, field names) before implementing any artifact. Do not rely solely on plan.md/context.md if a doc covers the artifact.
> \<end if\>
>
> **Batch:** Process only these artifacts: \<batch.artifacts comma-separated\>. Skip any already complete in plan.md.
>
> \<if ## Figma Alignment section is present in context.md, include — otherwise omit\>
> **Figma Instruction:** For every Screen and Component artifact, before writing any code:
> 1. Look up the artifact in the `## Figma Alignment` table in context.md above to get its `UI Stack` and `Figma Files`
> 2. `Read` the `UI Stack` file (`figma-uistack-*.md`) first — this is the merged Component Hierarchy, State Model, and User Interactions for this artifact (and any overlay components it mounts). Use this as the structural blueprint
> 3. For each state referenced in the UI Stack's `states` frontmatter: `Read` its `.md`, `layout_file` JSX (full file, no truncation), and `screenshot` `.png` (mandatory — visual inspection required before implementing)
> 4. For any overlay referenced (`← see figma-uistack-*.md`), repeat steps 2–3 for that overlay's UI Stack when implementing the overlay's Component artifact
>
> Proceed directly to the first pending UI artifact in this batch.

**5d — Checkpoint loop (fallback).** If the worker returns `## Context Checkpoint` instead of its completion signal, immediately re-spawn the same worker type without user interaction:

> Resuming from context checkpoint. Pre-loaded context below — do not re-read plan.md, context.md, or state.json.
>
> **plan.md**
> \<content — re-read from disk\>
>
> **context.md**
> \<content — re-read from disk\>
>
> \<if raw_docs is non-empty:\>
> **Reference docs:**
> \<for each entry: "<path> — <description>"\>
> `Read` the relevant doc(s) for ground-truth details before implementing any artifact.
> \<end if\>
>
> **Batch:** Process only these artifacts: \<batch.artifacts minus completed_artifacts from state.json\>. Skip any already complete in plan.md.
>
> **Resume from:** \<next_artifact from checkpoint block\>
> **State file:** \<state_file from checkpoint block\>
>
> \<for ui-worker: include Stateholder contract path and Figma Instruction as above\>
>
> Read state.json, skip completed artifacts, proceed directly to next_artifact.

Repeat until the worker returns `## Layers Complete` (feature-worker) or `## Feature Complete` (ui-worker).

**5e — Mark complete.** Set the batch's `status` to `complete` in `plan.md` frontmatter.

Proceed to Step 6 after all batches are complete.

## Step 6 — Unit Tests

Read `state.json` from the run directory. Extract all paths under `domain`, `data`, and `presentation` keys — these are the unit-testable artifacts. Skip `ui` and `app`.

Call `AskUserQuestion` immediately — do NOT describe choices in prose:

```
question    : "Run unit tests for created artifacts?"
header      : "Unit Tests"
multiSelect : false
options     :
  - label: "Yes",  description: "Generate unit tests for all created artifacts via developer-test-worker"
  - label: "Skip", description: "I'll run tests manually later"
```

**Yes** → spawn `developer-test-worker`:

> target: <comma-separated artifact paths from state.json>
> platform: <platform from plan.md frontmatter>

**Skip** → surface the paths as a reminder:

> Tests not generated. Run when ready:
> `/developer-test-worker` — targets: <paths>
