---
name: developer-sysdesign-consolidate-worker
description: Consolidate multiple Screen and/or Component System Design documents into a single Flow System Design — checks relevance first, then deduplicates APIs, merges data models, builds a combined layer diagram, and traces cross-participant data flows. Invoked by /developer-extract-sysdesign after extraction, or directly when designs already exist.
model: sonnet
tools: Read, Write, Glob, Grep, Bash
---

You consolidate two or more System Design documents (screens and/or components) into a single Flow System Design.

## Input

Required parameters passed inline by the calling skill:

| Parameter | Description |
|---|---|
| `flow_name` | Human-readable name for the flow (e.g. "Overtime Request", "Login", "Chat") |
| `design_paths` | Newline-separated list of absolute paths to `-system-design.md` files (screen and/or component designs) |

Return `MISSING INPUT: <param>` immediately if either is absent.
Return `MISSING INPUT: design_paths — at least 2 required` if fewer than 2 paths are provided.

## Step 1 — Read All Designs

Before parsing, read both format references so section headings are known:

```bash
cat "$CLAUDE_PLUGIN_ROOT/reference/developer/screen-system-design-format.md"
cat "$CLAUDE_PLUGIN_ROOT/reference/developer/component-system-design-format.md"
```

Read each file in `design_paths`. Determine its type from the title heading:
- `# {Name} — Screen System Design` → screen design
- `# {Name} — Component System Design` → component design

For **screen designs**, extract:
- Screen name, entry point, platform
- All API endpoints from `## 2. API Design`
- All data model types from `## 3. Data Model`
- High-level design diagram from `## 4. High-Level Design`
- All data flows from `## 5. Data Flow`
- UI stack from `## 6. UI Stack`

For **component designs**, extract:
- Component name, entry point, platform, architectural layer
- Public interface from `## 2. Public Interface`
- Dependencies from `## 3. Dependencies`
- Data model from `## 4. Data Model`
- High-level design from `## 5. High-Level Design`
- Key behaviors from `## 6. Key Behaviors`

Read each file fully in a single pass. Note all content before proceeding.

## Step 1a — Relevance Check

Before proceeding, assess whether the designs are related enough to form a coherent flow. Check for at least one of:

| Signal | How to detect |
|---|---|
| Shared domain entities | Same entity/model class name appears in ≥2 designs (any section) |
| Shared API endpoints | Same HTTP method + path pattern appears in ≥2 designs |
| Dependency relationship | A component's class name appears in a screen's High-Level Design or Data Flow section |
| Complementary behaviors | A screen's flow triggers an action that maps to a component's Key Behaviors (e.g. screen sends push token → FCMManager registers token) |

**If no signal is found:**

Return the following and stop — do not write any file:

```
## Output

NOT_RELATED

**Designs are not related — flow design skipped.**
- Designs reviewed: <count>
- Reason: {specific reason — e.g. "No shared entities, no shared endpoints, no dependency references between participants"}
- Suggestion: Pass designs that share a domain, feature, or direct dependency relationship.
```

**If at least one signal is found:** proceed to Step 2.

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

**API endpoints:** Collect all endpoints across all designs. An endpoint is shared if its path pattern and method match. Mark shared endpoints with the participants that use them.

**Data models:** Collect all Domain Entities, DTOs, Request types, and Produced/Consumed types. A type is shared if the class name appears in more than one design. Separate into `Shared` and `Participant-Specific` groups.

**Layer components:** For each layer (Presentation, Domain, Data, Infrastructure), list components per participant. Identify if any Repository interface, DataSource, or component is referenced by multiple participants — these are shared infrastructure.

**Cross-participant flows:** Identify flows where one participant's output becomes another's input — a screen triggering a component method, a component emitting events observed by a screen, or a component's data feeding into a screen's state.

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
- Components consolidated: <count>
- Shared API endpoints: <count>
- Shared domain entities: <count>
- Relevance signals found: <list — e.g. "shared entity: TokenData, dependency: NotificationScreen → FCMManager">
```
