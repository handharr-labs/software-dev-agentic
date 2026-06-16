---
name: developer-extract-sysdesign
description: Extract a System Design document from one or more screen entry points, or consolidate existing screen system designs into a flow design. Single screen → Screen System Design. Multiple screens → parallel extraction then Flow System Design. Multiple existing .md designs → consolidation only.
user-invocable: true
disable-model-invocation: true
allowed-tools: Agent, AskUserQuestion, Bash
---

## Routing Contract

This skill is a pure router. Its only permitted direct operations:
- `Bash` — resolve project root (`git rev-parse --show-toplevel`), detect existing sysdesign files
- `AskUserQuestion` — ask for flow name when consolidating multiple screens

Never read source files, grep, or explore — all code reading and writing is done by workers.

## Input

Arguments passed after `/developer-extract-sysdesign`:

| Pattern | Classified as |
|---|---|
| Source file path(s) — `.dart`, `.swift`, `.kt`, `.tsx`, `.ts`, `.vue` | Screen entry point(s) → extract |
| File path(s) ending in `-system-design.md` | Existing screen designs → consolidate only |
| No arguments | Error — ask for input |

If no arguments are provided, call `AskUserQuestion`:

```
question    : "Provide one or more screen file paths (e.g. login_screen.dart) or existing -system-design.md files to process."
header      : "Input"
```

Stop if the user does not provide valid paths.

## Step 1 — Classify Inputs

Parse arguments. Classify each path by extension:
- `extracted_paths` → source files (`.dart`, `.swift`, `.kt`, `.tsx`, `.ts`, `.vue`)
- `provided_md_paths` → existing system design files (`*-system-design.md`)

Detect platform per source file from extension:
- `.dart` → `flutter`
- `.swift` → `ios`
- `.kt` → `android`
- `.tsx`, `.ts`, `.vue` → `web`

## Step 2 — Extract (skip if no source files)

Spawn one `developer-sysdesign-extract-worker` per source file path **in parallel** (single Agent call):

```
screen_path: <absolute path>
platform: <detected from extension>
```

Wait for all workers. Each returns `## Output` with the written system design path. Collect as `new_screen_paths`.

If any worker fails, surface the failure — do not silently skip.

## Step 3 — Route on Total

Collect `all_paths = new_screen_paths + provided_md_paths`.

**If `len(all_paths) == 1`:**
Surface the output path to the user:
```
Screen system design written: <path>
```
Done.

**If `len(all_paths) > 1`:**
Ask for a flow name:

```
question    : "What should this flow be called? This becomes the title of the consolidated Flow System Design (e.g. 'Overtime Request', 'Login', 'Chat')."
header      : "Flow Name"
```

Spawn `developer-sysdesign-consolidate-worker`:

```
flow_name: <user input>
screen_design_paths:
  - <path 1>
  - <path 2>
  ...
```

Wait for the worker to return `## Output`. Surface the flow design path:

```
Flow system design written: <path>
Screen designs included: <count>
```
