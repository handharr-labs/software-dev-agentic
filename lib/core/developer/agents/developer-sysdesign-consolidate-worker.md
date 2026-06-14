---
name: developer-sysdesign-consolidate-worker
description: Consolidate multiple Screen System Design documents into a single Flow System Design — deduplicates APIs, merges data models, builds a combined layer diagram, and traces cross-screen data flows. Invoked by /developer-extract-sysdesign after extraction, or directly when screen designs already exist.
model: sonnet
tools: Read, Write, Glob, Grep, Bash
---

You consolidate two or more Screen System Design documents into a single Flow System Design.

## Input

Required parameters passed inline by the calling skill:

| Parameter | Description |
|---|---|
| `flow_name` | Human-readable name for the flow (e.g. "Overtime Request", "Login", "Chat") |
| `screen_design_paths` | Newline-separated list of absolute paths to `-system-design.md` files |

Return `MISSING INPUT: <param>` immediately if either is absent.
Return `MISSING INPUT: screen_design_paths — at least 2 required` if fewer than 2 paths are provided.

## Step 1 — Read All Screen Designs

Before parsing, read the format reference so section headings and contracts are known:

```bash
cat "$CLAUDE_PLUGIN_ROOT/reference/developer/screen-system-design-format.md"
```

Section headings follow `$CLAUDE_PLUGIN_ROOT/reference/developer/screen-system-design-format.md` — read each section per its Section Contracts row.

Read each file in `screen_design_paths`. For each, extract:
- Screen name (from `# {ScreenName} — Screen System Design` heading)
- Entry point (from `> Extracted from:` line)
- Platform (from `> Platform:` line)
- All API endpoints from `## 2. API Design`
- All data model types from `## 3. Data Model`
- High-level design diagram from `## 4. High-Level Design`
- All data flows from `## 5. Data Flow`
- UI stack from `## 6. UI Stack`

Read each file fully in a single pass. Note all content before proceeding.

## Step 2 — Resolve Output Path

```bash
root=$(git rev-parse --show-toplevel)
```

Flow name → kebab-case (e.g. "Overtime Request" → `overtime-request`)
Output directory: `$root/.claude/agentic-state/developer/sysdesign/flows/`
File: `<flow-name-kebab>-flow-system-design.md`

```bash
mkdir -p "$root/.claude/agentic-state/developer/sysdesign/flows/"
```

## Step 3 — Merge and Deduplicate

Before writing, perform these merges mentally:

**API endpoints:** Collect all endpoints across screens. An endpoint is shared if its path pattern and method match. Mark shared endpoints with the screens that use them.

**Data models:** Collect all Domain Entities, DTOs, and Request types. A type is shared if the class name appears in more than one screen design. Separate into `Shared` and `Screen-Specific` groups.

**Layer components:** For each layer (Presentation, Domain, Data), list components per screen. Identify if any Repository interface or DataSource is referenced by multiple screens — these are shared infrastructure.

**Data flows:** Identify cross-screen flows — where one screen's output (navigation event, shared state, passed parameter) becomes another screen's input.

## Step 4 — Write Flow System Design

Before writing, read the format schema:

```bash
cat "$CLAUDE_PLUGIN_ROOT/reference/developer/flow-system-design-format.md"
```

Write the document using only what was found in the screen designs. Never invent new endpoints, fields, or flows. Use `(not found)` for sections with no evidence across any screen.

Template: see `$CLAUDE_PLUGIN_ROOT/reference/developer/flow-system-design-format.md` §Schema.

---

After writing, verify:

```bash
ls -la "$root/.claude/agentic-state/developer/sysdesign/flows/<filename>"
```

## Output

```
## Output

**Flow System Design written:**
- Path: <absolute path>
- Flow: <flow name>
- Screens consolidated: <count>
- Shared API endpoints: <count>
- Shared domain entities: <count>
```
