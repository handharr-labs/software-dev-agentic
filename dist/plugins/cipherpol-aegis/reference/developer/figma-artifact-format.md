# Figma Artifact Format

> Author: Puras Handharmahua · 2026-06-13
> Related: developer-figma-worker.md (writer); developer-pres-planner.md, developer-feature-worker.md, developer-ui-worker.md (readers); plan-format.md (`## Figma Alignment`)

Shared schema for Figma-derived artifacts written by `developer-figma-worker` to `<run_dir>/inputs/` and read during feature planning and build.

---

## `figma-<slug>.md` — Semantic Reference

One file per fetched Figma node/frame.

```markdown
---
source: <figma_url>
parent_frame: <parent frame or component set name>
state: <state name this node represents>
screenshot: <run_dir>/inputs/figma-<slug>-screenshot.png
screenshot_url: <screenshot_url>
layout_file: <run_dir>/inputs/figma-<slug>-layout.jsx
---

## <NodeName>
**Components:** <comma-separated component names — map JSX component names to UI element names>
**State:** <state this frame represents — e.g. empty, loading, content, error>
**Interactions:** <key interactions derived from event handlers, or "none">
**Tokens:** <key design token variables used — e.g. --color/primary, --spacing/md>
**Annotations:** <visible text labels, aria labels, designer notes>
```

### Companion Files

- `figma-<slug>-layout.jsx` — raw JSX from `get_design_context`, written verbatim, never truncated
- `figma-<slug>-screenshot.png` — downloaded screenshot. If the download fails, a `.png.failed` placeholder is written instead and `screenshot: null` is recorded in frontmatter

### Field Contracts

| Field | Read by | Purpose |
|---|---|---|
| `parent_frame`, `state` (frontmatter) | pres-planner | Screen grouping, `### Figma Alignment` table |
| `State`, `Interactions` (body) | pres-planner, feature-worker, ui-worker | StateHolder state field / event case derivation |
| `Components`, `Annotations` (body) | pres-planner, ui-worker | Layout transcript, UI element naming |
| `layout_file`, `screenshot` (frontmatter paths) | ui-worker only | Full JSX + visual reference for Screen/Component creation |
| `Tokens` (body) | ui-worker | Design token mapping during UI build |

`feature-worker` reads the `.md` body only (`State`, `Interactions`) — never `layout_file` or `screenshot`; those are the UI worker's concern.

---

## `figma-uistack-<screen-slug>.md` — Screen UI Stack

One file per screen cluster **and** one per overlay/dialog cluster, synthesized by `developer-figma-worker` in `group-frames` mode by merging all state frames belonging to that cluster into a single tree. Modeled on `screen-system-design-format.md` §6 (UI Stack).

```markdown
---
screen: <ScreenName>
type: screen | overlay
parent_screen: <ScreenName>   # only present when type: overlay
states:
  - state: <state name>
    file: <abs path to figma-<slug>.md>
    layout_file: <abs path to figma-<slug>-layout.jsx>
    screenshot: <abs path to figma-<slug>-screenshot.png>
  - ...
overlays: [<figma-uistack-*.md filename>, ...]   # only present when type: screen and one or more overlay clusters reference it as parent_screen
---

## <ScreenName> — UI Stack

### State Model
| State | Key Differences |
|---|---|
| <state> | <what changes visually vs other states — content, loading indicator, error banner, empty illustration, etc.> |

### Component Hierarchy

```
{ScreenClass}
  ├── {LoadingComponent}        ← state is <state>
  ├── {ErrorComponent}          ← state is <state>
  └── {ContentComponent}        ← state is <state>
        ├── {ChildComponent}
        └── {OverlayComponent}  ← see figma-uistack-<overlay-slug>.md
```

### Design Tokens
- <token>: <value>

### User Interactions
| Interaction | Triggers | Effect |
|---|---|---|
| <e.g. "Tap retry"> | <event/handler name from Interactions field> | <effect> |
```

### Field Contracts

| Field | Read by | Purpose |
|---|---|---|
| `states` (frontmatter) | pres-planner, ui-worker | Maps each branch of the Component Hierarchy back to its source frame's `.md` / `layout_file` / `screenshot` |
| `type`, `parent_screen`, `overlays` | pres-planner, ui-worker | Distinguishes standalone screens from overlay components (dialogs, filters, bottom sheets) and links them to their host screen |
| `Component Hierarchy` | pres-planner, ui-worker | Single merged tree across all states — primary structural reference for Screen/Component artifacts |
| `State Model`, `User Interactions` | pres-planner, feature-worker | Source for StateHolder state fields and event cases |
| `Design Tokens` | ui-worker | Token mapping during UI build |

---

## Worker Output Blocks

Returned by `developer-figma-worker` to its caller (`developer-plan-feature`).

### Single Node

```
## Figma Worker Output
source: <figma_url>
file: <run_dir>/inputs/figma-<slug>.md
layout_file: <run_dir>/inputs/figma-<slug>-layout.jsx
screenshot: <run_dir>/inputs/figma-<slug>-screenshot.png
parent_frame: <parent frame or component set name>
state: <state name this node represents>
components: <comma-separated list of notable component names>
notes: <1–2 sentences on design-level observations relevant to implementation>
```

### Section Node

Returned instead of the single-node output when the fetched node is a `<section>` containing unfetched child `<frame>` elements:

```
## Figma Section Detected
source: <figma_url>
section_name: <section name from Figma response>
fileKey: <fileKey>
child_frames:
  - id: <frame_id>  name: <frame_name>
  - id: <frame_id>  name: <frame_name>
  ...
```

The caller expands each child frame into its own `developer-figma-worker` call (one per child, in parallel).

### Group-Frames Mode

Returned after all frame workers for a run have completed, when `developer-figma-worker` is called with `mode: group-frames`:

```
## Figma Groups
ds_available: true | false
ds_artifacts: [<design-system artifact names found — e.g. mekari-pixel>]   # omit when ds_available: false
groups:
  - screen: <cluster name derived from visual structure>
    type: screen | overlay
    parent_screen: <ScreenName>   # only present when type: overlay
    uistack_file: <abs-path-to-figma-uistack-*.md>
    states:
      - state: <inferred state name>
        file: <abs-path-to-figma-*.md>
        layout_file: <abs-path-to-figma-*-layout.jsx>
        screenshot: <abs-path-to-figma-*-screenshot.png>
review:
  - frame: <figma-*.md filename>
    reason: <one line — e.g. "Visually ambiguous between X and Y — placed by parent_frame hint">
```

Omit the `review` key entirely if no frames needed tiebreaking. Omit `ds_available`/`ds_artifacts` entirely if `platform` was not passed to group-frames mode (signals: skip Step 1.5c in the orchestrator).

---

## Section Contracts

| Artifact | Written by | Read by | Purpose |
|---|---|---|---|
| `figma-<slug>.md` + companions | figma-worker | pres-planner, feature-worker, ui-worker | Per-frame design reference |
| `figma-uistack-<screen-slug>.md` | figma-worker (group-frames mode) | pres-planner, ui-worker | Merged per-screen/overlay component hierarchy, state model, and interactions |
| `## Figma Worker Output` | figma-worker | plan-feature skill | Single-node fetch result |
| `## Figma Section Detected` | figma-worker | plan-feature skill | Triggers child-frame expansion |
| `## Figma Groups` | figma-worker (group-frames mode) | plan-feature skill, feature-strategist | Screen/state clustering + uistack file paths → `figma_groups` |
| `### Figma Alignment` table | pres-planner findings | feature-strategist → `## Figma Alignment` in context.md (see plan-format.md) | Maps artifacts to Figma files, UI Stack file, states, and key interactions |
