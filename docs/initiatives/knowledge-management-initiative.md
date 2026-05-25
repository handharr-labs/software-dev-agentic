# Knowledge Management System Initiative

**Status:** Planning
**Goal:** Build a structured feature knowledge base — stored in Confluence, continuously updated, queryable — covering API contracts, data models, high-level design, data flows, and platform-specific artifacts across native and Flutter hybrid apps.

---

## Problem

Feature knowledge currently lives in engineers' heads, scattered PRDs, and one-off Confluence pages with no consistent schema. This causes:
- Repeated questions to original authors
- Onboarding friction — no canonical reference per feature
- Tribal knowledge lost on team rotation
- No machine-readable format to feed future tooling (search, RAG, agent context)

---

## Knowledge Article Schema

```
Feature: <name>
Summary: <1-2 sentences, non-technical>

References
  - PRD:    <Confluence link>
  - Figma:  <Figma file/frame link>
  - Jira:   <ticket ID + link>
  - BE Contract: <Confluence or Postman link>
  - Other:  <analytics spec, A/B test doc, etc.>

API Contracts
  - Endpoint, method, request/response shape
  - Link to BE contract doc (or inline if none exists)

Data Model
  - Entity name, fields, types (platform-agnostic)

High Level Design (optional — omit if not available)
  - Layer map: Layer | Responsibility | Components
  - Dependency direction noted
  - For hybrid-in-native: shows Native Shell → FlutterEngine → FlutterModule boundary
  - Diagram: <Figma or image link, if exists>

Data Flow
  - Numbered steps, end-to-end

Artifacts (per platform)
  - iOS Native:     <ViewController, Manager, etc.>
  - Android Native: <Activity, ViewModel, etc.>
  - Flutter:        <BLoC, UseCase, Repository, Widget>

Platform Variants
  - iOS:     [pre-Clean] <structural pattern — e.g. screen-per-type, ViewController → Manager>
  - Android: [Clean] <structural pattern — e.g. unified screen, UseCase → Repository>
  - Flutter: [Clean] <structural pattern, or "same as Android" if aligned>
  (omit platforms where no divergence exists; use [pre-Clean] / [Clean] on every entry)

Gotchas / Known Constraints
  - Platform quirks, workarounds, performance traps (1-3 bullets)
```

### Scoping Model

Three tiers:

```
Feature Group     → HLD only, no implementation detail
  Sub-feature     → full Feature Doc (default unit)
    _shared/      → shared screens/components referenced by multiple sub-features
```

**Default: one article per screen or sub-feature.** No upfront merge decision needed — create small, merge later when the pattern becomes obvious.

**Merge signals** — two articles are worth merging when:
- Always referenced together in the same context
- Data models have inheritance (one entity extends another)
- The HLD of one is incomplete without the other
- The architectural handoff (bridge, engine, deeplink) IS the key story

**Merge vs separate examples:**

| Feature | Scope | Why |
|---|---|---|
| TimeOff List + Detail | Merged | Native → Flutter bridge is the story; data model shared |
| Overtime Request + Detail | Merged | Same pattern |
| LiveAttendance: ClockIn/Out | Separate | Own state machine, own result screen variants |
| LiveAttendance: Async | Separate | Own offline behavior, independent complexity |
| LiveAttendance (group) | Group article | HLD only, links to all sub-features |

### Design Decisions

**Platform artifacts as a flat table** — One row per architectural layer, one column per platform. Platform-agnostic concept in column 1, platform-specific class/file names across. Enables diff when native and Flutter diverge.

**Flutter hybrid module in native HLD** — The HLD explicitly shows the bridge boundary (`Native Shell → FlutterEngine → FlutterModule`). This is the highest-value part for hybrid apps — integration bugs concentrate at the handoff point. The Flutter module's own HLD lives as a child article or embedded sub-section.

**Platform Variants vs Artifacts** — Artifacts captures *names* (class, file). Platform Variants captures *structure* — screen count, navigation pattern, architectural pattern, why platforms diverged. Example: iOS has 4 separate ViewControllers for each attendance result type; Android has 1 Activity handling all types via state. Same business logic, intentionally different structure. Omit the section entirely when platforms are structurally aligned.

**Inconsistent architecture — document what exists, mark the gap** — List only artifacts that actually exist. Do not invent Clean layers that aren't there. Use `[pre-Clean]` in Platform Variants to mark platforms that haven't adopted Clean Architecture yet. `[Clean]` for platforms that have. This makes tech debt visible and searchable — a Confluence search for `[pre-Clean]` produces a prioritized migration backlog per feature per platform. When a platform is migrated, update the article and the marker drops.

**Gotchas section is mandatory** — This is where tribal knowledge lives. Without it the KMS becomes reference-only and people still ask the original author.

---

## Agentic Integration

### Persona: `librarian`

A new standalone persona — separate from `builder`. Distinct workflow (document existing features) vs builder (implement new ones). Feature Docs produced by `librarian` are consumed by `builder` — same relationship as `tracker` → `builder`.

**Agent roster** (internal — lives in `.claude/`, not shipped downstream):

```
.claude/agents/
  librarian-feature-orchestrator.md   ← routes generate/scan/merge/audit intents
  librarian-ios-worker.md
  librarian-android-worker.md
  librarian-flutter-worker.md
  librarian-synthesizer-worker.md
  librarian-audit-worker.md

.claude/skills/
  librarian-explain/SKILL.md
  librarian-generate/SKILL.md
  librarian-scan/SKILL.md
  librarian-merge/SKILL.md
```

**Skill workflows (Type W):**

| Skill | Intent | Input | Output |
|---|---|---|---|
| `librarian-generate` | New feature — has PRD or Jira ticket | PRD file / URL / ticket ID | Feature Doc written to `.claude/reference/feature-docs/` |
| `librarian-scan` | Existing feature — backfill from code | Feature name + local repo paths | Feature Doc written (or `[pending-scan]` entries filled) |
| `librarian-merge` | Two docs worth consolidating | 2+ Feature Doc paths | Merged Feature Doc written, originals archived |
| `librarian-explain` | Understand a feature | Feature name or Feature Doc path | Explanation in conversation — no file written |

`librarian-audit-worker` is internal only — called before every write, never user-invocable.

> All skills follow **Skill-First Entry** (see `docs/principles/core-design-principles.md`) — the skill owns routing, worker spawning, and user approval. Workers are never invoked directly.

---

### `librarian-generate` (Type W)

Entry point for new features. Triggered manually or on ticket pickup.

Accepts PRD input in three ways — skill detects which is provided:

| Input | How it's read |
|---|---|
| Local `.md` file path | `Read` tool — works for all engineers |
| Confluence URL (personal mmpa only) | `mmpa_get_confluence_page` — only if mmpa is configured |
| Jira ticket ID (personal mmpa only) | `mmpa_get_jira` + `mmpa_get_confluence_by_ticket` — only if mmpa is configured |

> **mmpa is a personal tool** — not a team dependency. Skills that use it must always provide a non-mmpa fallback path.

1. Resolve PRD input (local file, mmpa fetch if available, or prompt user to paste)
2. Spawn `librarian-synthesizer-worker` → extract schema from PRD content
3. Run `librarian-audit-worker` — block on violations, surface warnings
4. Present draft for human review
5. On approval: write to `.claude/reference/feature-docs/<feature-name>.md`

---

### `librarian-scan` (Type W)

Entry point for backfilling existing features that predate the KMS.

**Workers:**

| Worker | Repo | Extracts |
|---|---|---|
| `librarian-ios-worker` | iOS repo | Class names per layer, API call sites, data models, `[pre-Clean]`/`[Clean]` marker |
| `librarian-android-worker` | Android repo | Class names per layer, API call sites, data models, `[pre-Clean]`/`[Clean]` marker |
| `librarian-flutter-worker` | Flutter module repo | BLoC, UseCase, Repository, Widget names + data flow |
| `librarian-synthesizer-worker` | — | Merges worker findings into Feature Doc schema |

**Platform-aware flow:**
1. Accept feature name or Jira ticket ID, plus optional `--ios/--android/--flutter=<path>` flags
2. Use repo paths from flags; omitted platforms are treated as unconfigured
3. If existing Feature Doc at `.claude/reference/feature-docs/<name>.md` → read it, find `[pending-scan]` platforms
4. Spawn only needed workers in parallel (available repos / pending platforms only)
5. Pass findings to `librarian-synthesizer-worker`
6. Run `librarian-audit-worker` — block on violations, surface warnings
7. Present draft (or diff for existing doc) for human review
8. On approval: write to `.claude/reference/feature-docs/<feature-name>.md`

**`[pending-scan]` pattern** — missing platforms are marked explicitly, not silently omitted:

```
Artifacts (per platform)
  - iOS:     TimeOffListVC, TimeOffListService
  - Android: [pending-scan]
  - Flutter: TimeOffDetailBloc, TimeOffDetailPage
```

Next session: skill reads the doc, detects `[pending-scan]` on Android, spawns only `librarian-android-worker`. The doc grows incrementally without re-scanning covered platforms.

**Repo input — local only.** All repos must be checked out locally. No remote fetching (no Bitbucket API, no git clone). Workers scan via `Read`/`Grep` on local filesystem paths.

**Repo paths are passed as flags — no CLAUDE.md config required:**
```
/librarian-scan time-off --ios=../ios-app --android=../android-app --flutter=../flutter-module
```

Omitted platforms are marked `[pending-scan]`, not an error. Run the skill again with the missing flag once that repo is available.

**Risk:** Code grepping gives *what exists*, not *why*. Human review before publish is a hard gate, not optional.

### `builder-plan-feature` integration

Feature Docs can be passed directly as input to `builder-plan-feature`, closing the loop between the KMS and the builder:

```
/builder-plan-feature .claude/reference/feature-docs/time-off.md
```

**How it fits:** The skill's Step 0 already handles local file paths — it passes them as `raw_paths` to the orchestrator. A Feature Doc path is classified as type `knowledge` — distinct from a PRD (requirements) or Figma (design). The orchestrator treats it as existing architecture context, not new requirements.

**Value to planners:**

| Planner | What it gets from the Feature Doc |
|---|---|
| `builder-domain-planner` | Data model — knows what entities already exist |
| `builder-data-planner` | Data flow + API contracts — skips rediscovery round |
| `builder-pres-planner` | Artifacts per platform — knows existing class names |
| `builder-app-planner` | HLD layer map — knows current wiring |

For feature modifications (not greenfield), planners skip the first discovery round entirely — they already know what's locked vs. what needs changing. This reduces planning rounds and improves artifact accuracy.

**Step 0 extension required in `builder-plan-feature`:**

| Pattern | Type | Action |
|---|---|---|
| Path matching `.claude/reference/feature-docs/*.md` | `knowledge` | Add to `raw_paths` as type `knowledge` — orchestrator reads it as architecture context |

### `librarian-merge` (Type W)

A continuous improvement tool — not a setup tool. Used after articles already exist and a merge becomes obviously worth it.

**Flow:**
1. Accept 2+ Feature Doc file paths under `.claude/reference/feature-docs/`
2. Read each via `Read` tool
3. Merge sections per strategy:

| Section | Strategy |
|---|---|
| References | Union |
| API Contracts | Union, deduplicate shared endpoints |
| Data Model | Merge entities, detect inheritance |
| HLD | Regenerate combined component diagram spanning both screens |
| Data Flow | Re-stitch into single end-to-end flow |
| Artifacts | Union rows, deduplicate shared components (e.g. bridge) |
| Platform Variants | Reconcile conflicts per platform |
| Gotchas | Union |

4. Run `librarian-audit-worker` on merged draft
5. Present merged draft for human review — highlight conflicts and decisions made
6. On approval: write merged doc to `.claude/reference/feature-docs/<name>.md`
7. Ask what to do with originals — delete or keep as archived (`_archived/` subfolder)

Human review before publish is a hard gate — HLD and Data Flow require judgment the skill can't fully automate when originals have divergent Platform Variants.

### `librarian-explain` (Type W)

Read-only skill — no file written. Explains a feature to the user in the current conversation.

**Input:**
- Feature name (skill resolves to `.claude/reference/feature-docs/<name>.md`)
- Or explicit Feature Doc path
- Optional focus: `--aspect=data-flow | hld | artifacts | api | gotchas` (default: full summary)
- Optional audience: `--for=engineer | non-engineer` (default: engineer)

**Flow:**
1. Resolve Feature Doc path — if not found, surface available docs under `.claude/reference/feature-docs/`
2. Read Feature Doc
3. If `--for=non-engineer`: strip class names and layer terminology, explain in plain language
4. If `--aspect` specified: focus explanation on that section only
5. Present explanation in conversation — structured, readable, no jargon unless `--for=engineer`

No worker needed — skill handles the read and synthesis directly. No audit, no approval gate, no file write.

**Examples:**
```
/librarian-explain time-off
/librarian-explain time-off --aspect=data-flow
/librarian-explain live-attendance/clock-in-out --for=non-engineer
```

### `librarian-audit-worker` (future)

Audits a Feature Doc against the rules in `docs/principles/feature-doc-principles.md`. Called internally by `librarian-generate` and `librarian-merge` before presenting the draft for human review — never invoked directly.

Checks: mandatory sections present, summary non-technical, artifacts match `[pre-Clean]`/`[Clean]` markers, data flow text and diagram consistent, HLD format correct if present.

Returns a structured findings block — violations block publish, warnings surface to the reviewer.

### `knowledge-update` trigger (future)

On PR merge: diff what changed, prompt engineer to update the relevant Feature Doc. Covers the "continuously updated" requirement.

---

## Feature Doc Rules

These rules define what makes a valid Feature Doc. Used by the audit agent to check compliance.

### Mandatory sections

| Section | Requirement |
|---|---|
| Feature name | Present, matches Jira epic/story title |
| Summary | 1-2 sentences, non-technical — no class names |
| References | At minimum Jira ticket ID + link |
| API Contracts | At least one entry, or explicit "none" |
| Data Model | At least one entity with fields and types |
| Artifacts | Table present with at least one platform column |
| Platform Variants | Every entry must carry `[pre-Clean]` or `[Clean]` |
| Gotchas | At least 1 bullet |

### Quality rules

- **Summary** must not contain class names, file names, or layer terminology
- **Artifacts** must only list components that actually exist in the codebase — no aspirational Clean layers on pre-Clean platforms
- **Platform Variants** must cover all platforms present in the Artifacts table
- **Data flow text and diagram must be consistent** — every class name in the diagram must appear in the numbered steps, and vice versa
- **HLD is optional** — but if present, the component diagram must use lane-based format (Network → Data → Domain → Presentation columns with vertical dividers)

### Structural rules

- One Feature Doc covers one sub-feature (unit of work matching a Jira epic/story)
- Shared screens or components must live in a `_shared/` article, not duplicated across Feature Docs
- Feature group articles contain HLD only — no API contracts, data flow, or artifacts

---

## Output Strategy

**Phase 1 — Repo (now)**

Feature Docs live in the downstream project repo under `.claude/reference/feature-docs/`:

```
.claude/reference/
  feature-docs/
    time-off.md
    overtime.md
    live-attendance/
      _group.md
      clock-in-out.md
      break-in-out.md
      async-attendance.md
      offline-attendance.md
    _shared/
      attendance-map-screen.md
```

Benefits over Confluence:
- Git-versioned — every change is reviewable via PR
- Directly readable by agents via `Read`/`Grep` — no MCP call needed
- `builder-plan-feature` reads Feature Docs as local files, not remote fetches
- `librarian-audit-worker` can lint on every PR

Skill output: `librarian-generate` and `librarian-merge` write to `.claude/reference/feature-docs/` via `Write` tool. No `mmpa_save_confluence_page` needed.

**Phase 2 — Confluence publish (optional, future)**

Publish from repo to Confluence as a sharing/visibility layer for non-engineers. The repo remains the source of truth — Confluence is a read-only mirror.

**Phase 3 — Semantic search (when corpus is large)**

RAG layer over `.claude/reference/feature-docs/` — local embeddings or CI-indexed. No migration needed if Phase 1 structure is consistent.

---

## Examples

- [TimeOff — cross-platform: native list → Flutter detail](knowledge-management-example-timeoff.md)

---

## Kickoff Deliverables

Before the first Feature Doc is written or any skill is built, the following must exist:

- [x] **`docs/principles/feature-doc-principles.md`** — canonical reference for what a Feature Doc is, the schema, scoping rules, naming conventions, and audit criteria. Extracted from this initiative doc. This is what `librarian-audit-worker` reads and what engineers reference when writing Feature Docs manually.
- [x] **Agents and skills implemented** — all 6 agents + 4 skills written, living in `.claude/` (internal only, not shipped downstream)
- [x] **`.claude/reference/feature-docs/`** folder created in talenta-ios repo
- [x] Naming convention confirmed: kebab-case filenames (e.g. `time-off.md`, `live-attendance/clock-in-out.md`)

---

## Open Questions

- Which features get backfilled first — new features only, or retroactive for high-traffic ones?
- Who owns the Feature Doc — the feature squad, or a dedicated knowledge role?
- Should the schema be enforced via a Confluence template, or validated by the `prd-to-knowledge` skill?
- ~~For `codebase-to-knowledge`: should repo paths live in `CLAUDE.md` (zero-arg UX) or be passed as args (more portable across team members)?~~ **Resolved:** paths are passed as `--ios/--android/--flutter` flags — no CLAUDE.md config needed.
- ADR coverage for legacy features is likely sparse — is there a fallback source (e.g., PR descriptions, Slack threads) the worker should also scan?
