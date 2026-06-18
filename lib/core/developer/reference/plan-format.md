# Feature Plan Document Format

> Author: Puras Handharmahua · 2026-06-13
> Related: developer-feature-convergence-strategist.md (writer), developer-feature-worker.md, developer-ui-worker.md (readers)

Single source of truth for the `plan.md` / `context.md` schema used by the developer-plan-build-feature flow — written by `developer-feature-convergence-strategist` (synthesize mode), consumed by `developer-feature-worker` and `developer-ui-worker`.

## Living Document Rules

- **Never replace** — `plan.md` and `context.md` are extended in-place, never rewritten from scratch. Git is the version history; no `plan-v*.md` archiving.
- **Done rows are removed from the body** — when a batch's `status` moves to `complete` in the frontmatter, its artifact rows are removed from the plan.md body. The frontmatter batch is the permanent record of what was built; the body shows only work remaining.
- **Re-evaluate appends** — when intent changes, the strategist adds new artifact rows (pending only) and new batches (continuing the existing id sequence). Done rows already removed from the body are not restored.
- **`context.md` grows** — new key symbols are appended to existing sections; existing rows are only updated if a path or signature changed.
- **No history headers** — do not write `> Update round N` or similar commentary in plan.md. Round progression is captured by git history, not inline headers.

---

## plan.md Schema

```markdown
---
feature: <name>
status: pending
operations: [get-list, get-single, post, put, delete]
separate-ui-layer: true | false
batches:
  - { id: 1, layer: domain, artifacts: [ArtifactName, ...], status: pending }
  - { id: 2, layer: data,   artifacts: [ArtifactName, ...], status: pending }
  - { id: 3, layer: pres,   artifacts: [ArtifactName, ...], status: pending }
  - { id: 4, layer: app,    artifacts: [ConcernName, ...],  status: pending }
  - { id: 5, layer: ui,     artifacts: [ArtifactName, ...], status: pending }
---

# Feature Plan: <name>

## Domain Layer
| Artifact | Type | Status | Progress | Notes |
|---|---|---|---|---|

## Data Layer
| Artifact | Type | Status | Progress | Notes |
|---|---|---|---|---|

## Presentation Layer
| Artifact | Type | Status | Progress | Notes |
|---|---|---|---|---|

## UI Layer
| Artifact | Type | Status | Progress | Notes |
|---|---|---|---|---|

## App Layer
| Concern | File | Action | Progress | Notes |
|---|---|---|---|---|

## Skipped Layers
<list any layers skipped and why>

## Risks and Notes
<anything the engineer should review before approving>
```

**Body visibility rule:** Only rows with `status: pending` or `status: in-progress` appear in the body tables. Completed artifacts are tracked exclusively in the `batches` frontmatter — remove their rows from the body when the batch is marked complete.

**Notes column:** One line maximum. For `create` artifacts: the key implementation constraint (pattern to follow, field shape, non-obvious behavior). For `patch`/`exists` artifacts: the target file path (module-relative) and exactly what to add or change. Never repeat information already in the Type column or derivable from layer contracts.

---

### plan.md Section Contracts

| Section | Required | Written by | Read by | Purpose |
|---|---|---|---|---|
| frontmatter (`feature`/`status`/`operations`/`separate-ui-layer`) | always | feature-strategist | feature-worker, ui-worker | Run-level metadata — drives layer selection and resume checkpoints |
| frontmatter `batches` | always | feature-strategist | developer-plan-build-feature skill | Ordered execution plan — each batch is a unit of work for one worker call; `status` updated live; re-evaluate appends new batches continuing the id sequence; completed batches remain in frontmatter permanently |
| `## Domain Layer` table | always | feature-strategist | feature-worker | Pending artifact rows only — appended on re-evaluate; removed when batch completes |
| `## Data Layer` table | always | feature-strategist | feature-worker | Pending artifact rows only — appended on re-evaluate; removed when batch completes |
| `## Presentation Layer` table | always | feature-strategist | feature-worker | Pending artifact rows only — appended on re-evaluate; removed when batch completes |
| `## UI Layer` table | always | feature-strategist | ui-worker | Pending artifact rows only — appended on re-evaluate; removed when batch completes |
| `## App Layer` table | always | feature-strategist | feature-worker | Pending concern rows only — appended on re-evaluate; removed when batch completes |
| `## Skipped Layers` | always | feature-strategist | user | Explains layers omitted from the plan, surfaced during approval |
| `## Risks and Notes` | always | feature-strategist | user | Surfaces review items the engineer should consider before approving |

---

## context.md Schema

```markdown
---
feature: <name>
platform: <platform>
module-path: <detected module path>
---

## Figma Alignment
(omit this section entirely if no `### Figma Alignment` table was found in planner findings)

Referenced `Figma Files` (`figma-*.md`) and `UI Stack` (`figma-uistack-*.md`) follow the schema in `figma-artifact-format.md`.

| Screen (parent_frame) | Artifact | UI Stack | Figma Files | States | Key Interactions |
|---|---|---|---|---|---|
<rows copied verbatim from pres-planner's ### Figma Alignment table>

## Key Symbols
(omit entirely for new-only features)

### <FileName> (<artifact type>)
- constructor_params: <param>: <Type>, ...
- execute_signature / primary_method_signature: ...
```

**What belongs in context.md:**
- `## Key Symbols` — constructor signatures, method signatures, and field shapes for existing artifacts that workers call into. One entry per artifact that has `status: exists` or `status: patch` in plan.md. Omit for net-new artifacts.
- `## Figma Alignment` — maps screen/component artifacts to their UI Stack file and source Figma frames. Required when the pres planner found Figma data.

**What does not belong in context.md:**
- Artifact file paths — tracked in `state.json` under `artifacts.<layer>`
- Naming conventions — loaded by workers from KMS via `shared-kms-load`
- Discovered artifact inventories — the plan.md `Status` column (`create`/`exists`/`patch`) drives new-vs-exists routing

---

### context.md Section Contracts

| Section | Required | Written by | Read by | Purpose |
|---|---|---|---|---|
| frontmatter (`feature`/`platform`/`module-path`) | always | feature-strategist | feature-worker, ui-worker | Run-level metadata — derives `project`/`platform` for convention lookups |
| `## Figma Alignment` | conditional — only if pres-planner findings included a `### Figma Alignment` table | feature-strategist | ui-worker (also referenced by feature-worker for StateHolder state/interaction shape) | Maps screens/artifacts to their merged UI Stack file, source Figma files, states, and key interactions |
| `## Key Symbols` | conditional — omit for new-only features | feature-strategist | feature-worker, ui-worker | Existing signatures (constructor params, method signatures) for targeted edits to existing artifacts |
