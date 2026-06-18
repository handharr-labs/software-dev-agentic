---
name: developer-plan-feature
description: Plan a feature — resolves external inputs (Jira, PRD, Figma, local .md), gathers intent via developer-feature-intent-strategist, runs the convergence planning loop (spawning only the needed layer planners per round), and shows an interactive approval prompt. On approval, writes plan.md with status: approved and outputs a ## Plan Output block with run_dir. Usable standalone or invoked by /developer-plan-build-feature.
user-invocable: true
allowed-tools: Agent, AskUserQuestion, Bash, Read, WebFetch, developer-fetch-figma
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
find "$(git rev-parse --show-toplevel)/.claude/agentic-state/developer/feature-plans" -maxdepth 2 -name "plan.md" 2>/dev/null
find "$(git rev-parse --show-toplevel)/.claude/agentic-state/developer/feature-plans" -maxdepth 2 -name "figma-fetch-dir.txt" 2>/dev/null
```

Collect results as `found_plans` and `found_figma` (`figma-fetch-dir.txt` paths). **Do not route yet.** Pass them to Step 1 so the strategist sees the user's intent alongside any existing runs before making a routing decision.

## Preflight — Resolve Thinker Model

```bash
echo "$CIPHERPOL_THINKER_MODEL"
```

If the value is `cost-saving`, every `Agent` spawn of `developer-feature-intent-strategist`, `developer-feature-convergence-strategist`, or a layer planner (`developer-domain-planner`, `developer-data-planner`, `developer-pres-planner`, `developer-app-planner`) anywhere in this skill must pass `model: sonnet` as an override. Otherwise (unset, `optimized`, or any other value), omit the `model` parameter — each agent uses its frontmatter default (`opus`). This does not apply to `developer-figma-fetch-worker`.

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
| `plan.md` exists (any status) | Set `run_dir = explicit_run_dir`. Proceed to Step 1 — pass `run_dir` to the strategist so it skips the run-selection prompt and goes straight to gathering updated intent. |
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
- **`Decision: resume-execution`** (any `plan_status`) → extract `run_dir` and `open_questions` from the Decision block. Set `update_mode = true`. Read `raw_docs` from context.md:

  ```bash
  python3 -c "
  import re, sys
  try:
      import yaml
      with open('<run_dir>/context.md') as f:
          m = re.match(r'^---\n(.*?)\n---', f.read(), re.DOTALL)
      if m:
          d = yaml.safe_load(m.group(1))
          for r in d.get('raw_docs', []):
              print(r['path'] + ' — ' + r['description'])
  except: pass
  " 2>/dev/null
  ```

  Set `raw_docs` from the script's output (empty list if context.md absent). Restore `figma_groups` from `<run_dir>/figma-fetch-dir.txt` → `figma-groups.json` if present.

  Proceed to Step 1.2 (Figma prompt), then Step 2 (convergence loop). The loop will run with `update_mode: true` — planners focus on `open_questions`.
- **`Decision: spawn-planners`** → extract `feature`, `platform`, `module_path`, `run_dir`. If `update_mode: true` also extract `open_questions`, `figma_groups`. Extract `pending_figma_urls` (may be empty). Initialize `visited = []`, `round = 1` — **ignore any `round:` value present in the Decision block itself.** The loop always starts counting at 1 on every orchestrator invocation. Proceed to Step 1.2.

## Step 1.2 — Optional Figma Prompt

Skip this step if `pending_figma_urls` is non-empty OR `figma_fetch_dir` is already set.

Call `AskUserQuestion`:

```
question    : "Do you want to include Figma designs in this feature plan?"
header      : "Figma"
multiSelect : false
options     :
  - label: "Yes — fetch now",          description: "Run /developer-fetch-figma inline to fetch frames"
  - label: "Yes — I have a fetch dir", description: "I already have a figma_fetch_dir path"
  - label: "No",                       description: "Proceed with requirement docs only"
```

**No** → proceed to Step 2 (skip Step 1.5).

**Yes — I have a fetch dir** → ask: `"Paste the figma_fetch_dir path."` Collect as `figma_fetch_dir`. Proceed to Step 1.5.

**Yes — fetch now** → execute `developer-fetch-figma` skill via the Skill tool. When it completes, extract `figma_fetch_dir` from the `Fetch directory:` line in its output. Use as `figma_fetch_dir`. Proceed to Step 1.5.

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

**Derive `raw_docs`** at the start of the first round (round = 1) — held as a session-local variable. Skip if `raw_docs` was already restored from context.md in the resume path above.

```bash
python3 - <<'EOF'
import os, re, json
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
print(json.dumps(raw_docs))
EOF
```

Store the output as the session-local `raw_docs` list.

### 2a — Spawn planners for this round

From the current `Decision: spawn-planners` block, read the `spawn:` list. Spawn each listed planner **in parallel** (single Agent tool call with all planners in that round):

- `developer-domain-planner` — if `domain` is in the spawn list
- `developer-data-planner` — if `data` is in the spawn list
- `developer-pres-planner` — if `pres` is in the spawn list
- `developer-app-planner` — if `app` is in the spawn list

Pass to each planner: feature name, platform, module-path, run_dir (from strategist's gather-intent or review-resume output).

**If `raw_docs` is non-empty**, also pass:
- `raw_docs` — list of `{ path, description }` entries. Planners must `Read` each path for ground-truth details (endpoint paths, UI stack specs, etc.) before producing findings. Format when passing: one entry per line as `<path> — <description>`.

**If `update_mode` is true** (resume path with new intent), also pass:
- `open_questions` — the user's stated issues from the Decision block, verbatim. Planners use these to focus on what needs fixing rather than doing a full greenfield sweep.

For `developer-pres-planner` specifically — if `figma_groups` was established in Step 1.5b or Step R0, also pass:
- The full `figma_groups` structure (screen → states + file paths) — do NOT inline file contents

Track `spawned_planners` as a session-local list — the layers dispatched in this round (e.g. `[domain, data, pres, app]`). This is passed to the strategist in Step 2b.

Wait for all planners in this round to complete.

Proceed to 2b.

### 2b — Send findings to strategist

Spawn `developer-feature-convergence-strategist`:

> **Mode: process-findings**
>
> Round: <N>
> Visited layers: <comma-separated list from visited set>
> Spawned planners: <comma-separated list from spawned_planners>
> run_dir: <run_dir>
> update_mode: <true | false>
>
> <if update_mode is true, include:>
> **existing_plan:**
> \<content of the archived plan-vN.md — re-read from disk if not already in context\>
>
> **existing_context:**
> \<content of the archived context-vN.md — re-read from disk if not already in context\>
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
> raw_docs:
> \<list each as "\<path\> — \<description\>", or "(none)"\>
>
> \<if update_mode is true:\>
> **update: true**
>
> **existing_plan:**
> \<content of current plan.md — read from disk\>
>
> **existing_context:**
> \<content of current context.md — read from disk\>
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
  - label: "Approve",      description: "Mark plan as approved and hand off for execution"
  - label: "Discuss more", description: "I have questions or changes before this plan is finalized"
  - label: "Discard",      description: "Cancel and delete this plan"
```

**Approve** → Update `plan.md` frontmatter: set `status: approved` and add `context_doc: context.md` (relative path — points to the sibling context.md in the same run_dir). Output:

```
## Plan Output
run_dir: <run_dir>
status: approved
context_doc: context.md
```

Stop.

**Discuss more** → address the engineer's questions inline. If the plan itself needs revision, re-run Step 3 (re-synthesize) with the updated requirements added to the findings context. Then call `AskUserQuestion` again with the same three options.

**Discard** → delete the most recent run directory:

```bash
rm -rf "$(git rev-parse --show-toplevel)/.claude/agentic-state/developer/feature-plans/<feature>"
```

Stop.
