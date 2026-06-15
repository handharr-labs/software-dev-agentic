---
name: developer-fetch-figma
description: Standalone Figma fetch pipeline — fetches frames via Figma MCP, groups them by visual structure, and optionally aligns UI Stacks to the design system. Outputs a figma_fetch_dir that can be passed directly to /developer-plan-feature to skip re-fetching.
user-invocable: true
allowed-tools: Agent, AskUserQuestion, Bash
---

## Routing Contract

Pure router. Permitted direct operations:
- `Bash` — reading pending-frames.json, frame completion globs
- `AskUserQuestion` — prompts defined in each step

Never read source files, fetch URLs, or write code. All work is delegated to `developer-figma-validate-worker`, `developer-figma-fetch-worker`, `developer-figma-group-worker`, and `developer-uistack-align-worker`.

## Step 0 — Classify Inputs

**First action — always run this Bash before anything else:**

```bash
echo "${CIPHERPOL_PLATFORM:-}"
```

If the output is `flutter`, `ios`, or `web` → set `platform` from it immediately. Do not ask the user about platform in Step 1.

Then parse formal arguments on the invocation line:

| Pattern | Type | Action |
|---|---|---|
| `figma.com` URL | Figma frame or section URL | Add to `pending_figma_urls` |
| Local path where `ls <path>/frame_*/` returns results | Existing figma fetch dir | Set as `figma_fetch_dir` — skip Step 2 (go straight to Step 3) |
| `--platform=<value>` | Platform slug | Override `platform` with this value |

If no arguments are provided and `platform` was resolved from env, `pending_figma_urls` is empty and `figma_fetch_dir` is unset — proceed to Step 1 to collect URLs.

## Step 1 — Gather Info

Ask only for what is not already set from Step 0.

**If `platform` is still unset after Step 0** (no env var, no `--platform` arg):

```
question    : "Which platform are these frames targeting?"
header      : "Platform"
multiSelect : false
options     :
  - label: "flutter",  description: "Flutter / Dart"
  - label: "ios",      description: "Swift / UIKit"
  - label: "web",      description: "Next.js / TypeScript"
  - label: "Skip",     description: "Don't run design system alignment"
```

`Skip` → set `platform = null` (design system check will be omitted in Step 4).

**If `pending_figma_urls` is empty and `figma_fetch_dir` is not set:**

```
question    : "Paste one or more Figma frame or section URLs (one per line), or provide the path to an existing figma fetch directory."
header      : "Figma Input"
multiSelect : false
options     :
  - label: "Paste URLs",      description: "I have Figma URLs to fetch"
  - label: "Existing fetch dir", description: "I already have a fetched directory to reuse"
```

Collect the user's input and populate `pending_figma_urls` or `figma_fetch_dir` accordingly.

## Step 2 — Validate, Expand, and Fetch Frames

**Skip this step entirely if `figma_fetch_dir` is already set** — go to Step 3.

Spawn `developer-figma-validate-worker` with all `pending_figma_urls`:

> figma_urls: \<newline-separated URLs\>

Read `## Figma Validate Output`. Set `figma_fetch_dir` from the block. If `invalid` is non-empty, call `AskUserQuestion`:

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

**Partial-fetch check** — determine which frames still need fetching:

```bash
find "<figma_fetch_dir>/frame_"* -name "figma-*.md" 2>/dev/null | sed 's|.*/frame_||' | sed 's|/.*||' | sort -u
```

This returns the sanitized nodeIds (colon → dash) of already-completed frames. Cross-reference against `pending-frames.json` entries (converting each entry's `nodeId` colons to dashes) to build `remaining_frames` — entries whose sanitized nodeId is not in the completed set.

If `resume_mode = true` and `remaining_frames` is empty → all frames already done, skip to Step 3.

Otherwise spawn fetch workers only for entries in `remaining_frames`. Log: "Skipping <N> already-fetched frames, fetching remaining <M>."

Spawn one `developer-figma-fetch-worker` per `remaining_frames` entry — pass `figma_url` and `figma_fetch_dir`. **Spawn all workers in parallel** (single Agent tool call).

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

## Step 3 — Group Frames

**Skip if `figma_resolved` is empty** (only applies when reusing an existing `figma_fetch_dir` that already has groups confirmed — jump to Step 4 directly if `figma_groups` was carried in from Step 0 detection. Otherwise run grouping on the existing frames.)

Spawn `developer-figma-group-worker`:

> figma_fetch_dir: \<figma_fetch_dir\>
> platform: \<platform — omit if null\>

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
  - label: "Correct",  description: "Grouping looks right — proceed"
  - label: "Adjust",   description: "The grouping needs changes before we continue"
```

**Correct** → store `figma_groups` and proceed.

**Adjust** → ask the user to describe corrections (which frames belong to which screen, any renames). Apply to `figma_groups`. Then proceed.

**Persist figma_groups to disk** — write immediately after grouping is confirmed:

```bash
cat > "<figma_fetch_dir>/figma-groups.json" << 'EOF'
<figma_groups as JSON>
EOF
```

## Step 4 — Align UI Stacks to Design System

**Skip if `ds_available` is false, absent, or `platform` is null.**

If `partial_align = true`, use the unaligned UIStack file paths collected in Step 0b. Otherwise collect the `uistack_file` path from every entry in `figma_groups`. Spawn one `developer-uistack-align-worker` per uistack file **in parallel** (single Agent tool call):

> uistack_file: \<abs path to figma-uistack-*.md\>
> platform: \<platform\>
> figma_fetch_dir: \<figma_fetch_dir\>

Collect all `## UIStack Align Output` blocks. Aggregate `flagged` items across all workers.

## Step 5 — Report

Surface the result to the user:

```
Figma fetch complete.

Fetch directory: <figma_fetch_dir>

Screens:
<for each group with type: screen:>
• <screen> (<N> states)<if overlays:>, overlays: <comma-separated>
<for each group with type: overlay:>
• <screen> (overlay of <parent_screen>, <N> states)

<if flagged items exist:>
⚠ Design System Gaps (<N> items): some components could not be matched. See `### Design System Alignment` in each uistack file.

To use in a feature plan:
  /developer-plan-feature <figma_fetch_dir>
```

Stop.
