# Feature Plan Document Format

> Author: Puras Handharmahua · 2026-06-13
> Related: developer-feature-convergence-strategist.md (writer), developer-feature-worker.md, developer-ui-worker.md (readers)

Single source of truth for the `plan.md` / `context.md` schema used by the developer-plan-build-feature flow — written by `developer-feature-convergence-strategist` (synthesize mode), consumed by `developer-feature-worker` and `developer-ui-worker`.

## Living Document Rules

- **Never replace** — `plan.md` and `context.md` are extended in-place, never rewritten from scratch. Git is the version history; no `plan-v*.md` archiving.
- **Completed rows are permanent** — any artifact row with `status: done` is never removed or reset. It documents what was built.
- **Re-evaluate appends** — when intent changes, the strategist adds new artifact rows and new batches (continuing the existing id sequence). Done rows are untouched.
- **`context.md` grows** — new discovered artifacts and key symbols are appended to existing sections; existing rows are only updated if a path or signature changed.

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

---

### plan.md Section Contracts

| Section | Required | Written by | Read by | Purpose |
|---|---|---|---|---|
| frontmatter (`feature`/`status`/`operations`/`separate-ui-layer`) | always | feature-strategist | feature-worker, ui-worker | Run-level metadata — drives layer selection and resume checkpoints |
| frontmatter `batches` | always | feature-strategist | developer-plan-build-feature skill | Ordered execution plan — each batch is a unit of work for one worker call; `status` updated live; re-evaluate appends new batches continuing the id sequence |
| `## Domain Layer` table | always | feature-strategist | feature-worker | Per-artifact tracking — rows appended on re-evaluate; `done` rows never removed |
| `## Data Layer` table | always | feature-strategist | feature-worker | Per-artifact tracking — rows appended on re-evaluate; `done` rows never removed |
| `## Presentation Layer` table | always | feature-strategist | feature-worker | Per-artifact tracking — rows appended on re-evaluate; `done` rows never removed |
| `## UI Layer` table | always | feature-strategist | ui-worker | Per-artifact tracking — rows appended on re-evaluate; `done` rows never removed |
| `## App Layer` table | always | feature-strategist | feature-worker | Per-concern tracking — rows appended on re-evaluate; `done` rows never removed |
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

## Discovered Artifacts

### Domain
| Artifact | Type | Path | Status |
|---|---|---|---|

### Data
| Artifact | Type | Path | Status |
|---|---|---|---|

### Presentation
| Artifact | Type | Path | Status |
|---|---|---|---|

### App
| Concern | File | Action | Notes |
|---|---|---|---|

## Naming Conventions
- Entity suffix: `<suffix>`
- UseCase suffix: `<suffix>`
- ViewModel/BLoC suffix: `<suffix>`
- File location pattern: `<ModuleName>/<Layer>/<Type>/`

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

---

### context.md Section Contracts

| Section | Required | Written by | Read by | Purpose |
|---|---|---|---|---|
| frontmatter (`feature`/`platform`/`module-path`) | always | feature-strategist | feature-worker, ui-worker | Run-level metadata — derives `project`/`platform` for convention lookups |
| `## Discovered Artifacts` (Domain/Data/Presentation/App) | always | feature-strategist | feature-worker, ui-worker | Existing artifact inventory — informs new-vs-exists routing per artifact |
| `## Naming Conventions` | always | feature-strategist | feature-worker, ui-worker | Naming and file-location conventions to follow for new artifacts |
| `## Figma Alignment` | conditional — only if pres-planner findings included a `### Figma Alignment` table | feature-strategist | ui-worker (also referenced by feature-worker for StateHolder state/interaction shape) | Maps screens/artifacts to their merged UI Stack file, source Figma files, states, and key interactions |
| `## Key Symbols` | conditional — omit for new-only features | feature-strategist | feature-worker, ui-worker | Existing signatures (constructor params, method signatures) for targeted edits to existing artifacts |
