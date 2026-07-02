# KMS Knowledge Management Redesign

**Status:** Design — approved direction, not yet implemented
**Date:** 2026-07-03
**Author:** Puras Handharmahua
**Related:** [kms-knowledge-restructure-initiative.md](kms-knowledge-restructure-initiative.md) · [kms-retrieval-strategy-initiative.md](kms-retrieval-strategy-initiative.md) · [../principles/glossary.md](../principles/glossary.md)

**Goal:** Make the KMS (a) precise for agent RAG mid-task, (b) supervisable/CRUD-able by humans, (c) scopable per-agent, and (d) manageable from a dashboard — while making it *easy for peers to contribute* knowledge without learning the strict internal taxonomy.

---

## Guiding Principle

**The vector DB is never the source of truth. It is a disposable, rebuildable index.**

ChromaDB is lossy (chunked + embedded), binary, non-diffable, and unreviewable. We never CRUD against it as a record. The canonical layer is **markdown in git** (`knowledge-sources/`), which gives us PR review, version history, agent-authorability, and a single extra representation. If Chroma corrupts, `--force` reseed rebuilds it with zero loss.

```
 Repos · PRDs · design systems · Confluence
            │   extractors (scan → write markdown)
            ▼
   knowledge-sources/   ◄── humans/agents also author here directly
   • git-tracked, diffable, PR-reviewed        = SOURCE OF TRUTH
            │   seed_kms.py  (chunk + contextual-embed)
            ▼
      ChromaDB            = DERIVED INDEX (throw away & rebuild anytime)
            │   cp8 MCP: kms_fetch / kms_query / kms_list
            ▼
        Agents   (each with a scoped retrieval filter)
            ▲
      Dashboard ── reads sources + DB, writes edits back to sources
```

---

## Decisions Locked

| Decision | Choice | Rationale |
|---|---|---|
| Source of truth | **Markdown in git** | PR review, history, agent-authorable, one extra representation only |
| Restructure scope | **Full redesign** | Biggest retrieval-quality gain; one-time reseed |
| Contribution model | **Loose write → agent normalize → human approve** | Keep the canonical strict without making humans produce it by hand |

---

## Node Model (target)

Chunk **at the `##` level — one whole concept per node** (theory + code pattern stay together). This roughly halves node count vs the current `###`-facet split, gives each vector a self-contained concept, and returns something an agent can act on in a single retrieval.

Per-`##`-section node metadata (facet **Source** = frontmatter authoritative, path as fallback — see below):

| Facet | Source | Purpose |
|---|---|---|
| `scope` · `platform` · `project` | frontmatter → path fallback + `repo.yaml` | cascade + run context |
| `discipline` | frontmatter → path fallback | engineering / design / qa / … |
| `layer` | **frontmatter (new)** | `domain` / `data` / `presentation` / `cross` — **per-agent scoping (goal 3)** |
| `artifact` | filename | conventions / standard-architecture / feature-inventory / api-endpoints / … |
| `section` | `##` heading | display label — **replaces topic/subtopic/pattern** |
| `tags` | frontmatter | free-form (absorbs the old `area` value, e.g. `design-system`) |
| `owner` | **frontmatter (new)** | `curated` / `extracted` — lifecycle guard |
| `content_hash` · `source_file` · `updated_at` | seed time | ops / incremental seed |

> **`area` is dropped.** It carried only 2 values (`core` \| `design-system`), ~fully correlated with `discipline` (design→design-system, engineering→core) — pure redundancy. `design-system`-ness moves to a `tag`. This removes one directory level.

Changes vs today:
- **Contextual embedding** — prepend a synthesized context line to the chunk *before embedding* (e.g. `"Flutter engineering / domain — Null Safety Extensions: <body>"`), then discard the prefix for display. Carries the taxonomy into the vector; zero schema change.
- **Opaque `uuid` id** instead of the 8-segment composite. Reclassifying a doc becomes an *update*, not delete+insert.
- **Collapse** `topic` / `subtopic` / `pattern` → one `section` label. Nobody filters `where pattern=theory`; heading depth was a brittle addressing axis.

### Path depth & frontmatter-authoritative seeding

**Reversal from the prior restructure:** the seeder now reads facets from **frontmatter first, path as fallback** — path becomes *advisory organization*, not the metadata contract.

Why: with path as the contract, directory depth is load-bearing and every misplaced file is **silently skipped**. Making frontmatter authoritative does three things:

1. **Depth becomes optional.** New/loose knowledge can live shallow (`_inbox/` or near-root) and still seed correctly — the facets ride in frontmatter.
2. **Kills the silent-skip footgun.** A file in the "wrong" folder still seeds from its frontmatter.
3. **Depth ≠ node depth.** Chroma nodes are flat regardless of folder depth; directory nesting only ever cost placement/browse burden, never retrieval granularity.

Canonical target path drops from 4 levels to **3** (`area` removed):

```
{tier}/{platform | project}/{discipline}/{artifact}.md
platform/flutter/engineering/conventions.md          ← was …/engineering/core/conventions.md
```

The 3 remaining levels (tier, platform/project, discipline) are the *minimum* needed to express what agents actually filter on — inherent depth, not accidental. The tidy deep tree stays the **normalized target** for browsing and for `kms-classify` output; it is no longer a wall a contributor must climb. A valid shallow contribution:

```
knowledge-sources/_inbox/error-handling.md
---
platform: flutter
discipline: engineering
layer: data
---
## Repository error mapping
...
```

seeds identically to its normalized deep form — `kms-classify` fills any missing frontmatter and moves it to the canonical path on approval.

> The `layer` facet directly closes the "Layer context lost" gap flagged as Pending in the prior restructure initiative — `# Domain`/`# Data`/`# Presentation` markers were invisible to the chunker and captured in no metadata field.

---

## Two Knowledge Lifecycles — Physically Separated

Mixing hand-written and machine-generated content in one file is what causes "the scan clobbered my notes." Split them by file, guarded by the `owner` facet:

| | **Curated** | **Extracted** |
|---|---|---|
| Examples | conventions, standard-architecture, design-system | feature-inventory, api-endpoints, deviations |
| Author | human, or agent-drafted then human-reviewed | repo/PRD/Figma scanner, periodic |
| Edit rule | hand-owned, never auto-overwritten | machine-owned, **regenerated wholesale** |
| `owner` | `curated` | `extracted` |

A periodic scan regenerates only `owner: extracted` files, opens a PR, a human approves the diff, then reseed. The review gate is preserved for both; `owner` is what stops a scan from ever overwriting curation.

---

## Per-Agent Scoping (Goal 3)

The impedance mismatch: knowledge is organized by **discipline/artifact**, but agents are organized by **CLEAN layer** (domain-planner, data-planner, presentation). The new `layer` facet bridges them. Scoping is a declarative filter assembled from three sources:

```
retrieval_where =
    run context    { platform: flutter, project: flex-mobile }   # injected per run
  + agent identity { discipline: engineering, layer: [domain, cross] }  # agent frontmatter
  + task need      { artifact: conventions }                     # optional narrowing
```

- Declare the default `where` in **agent frontmatter** so scoping is data, not code buried in each `kms_query` call.
- Always union in the **`cross`** bucket so scoping narrows without *starving* an agent of cross-cutting knowledge.

Example: `domain-planner → {discipline: engineering, layer: [domain, cross]}` never retrieves data-layer nodes.

---

## Contribution Flow (the on-ramp)

**Problem:** the canonical form is strict for good reason (clean filter facets), but making a peer hand-produce it is a wall — 4 controlled-vocabulary path segments, invisible chunking rules, and judgment-call facets like `layer`. Get any wrong and the seeder **silently skips the file**.

**Fix — keep the target strict, automate reaching it.** Separate the *write surface* from the *canonical surface*, mirroring the toolkit's own Transparent Steering pattern (agents structure, humans supervise):

```
Contributor writes loosely          kms-classify normalizes         Human approves
────────────────────────            ───────────────────────         ──────────────
just markdown + a title      ─►   proposes:                    ─►   review a PR that's
"about flutter data-layer         • correct canonical path          already correct;
 error handling", ## sections     • frontmatter (scope, platform,   tweak or merge.
 dropped in knowledge-sources/      project, discipline, layer,
 _inbox/ OR via dashboard form      artifact, owner, tags)
                                    • ##-chunk preview + dedup check
```

The contributor never learns the vocabulary — they write prose and say roughly what it's about; `kms-classify` infers every facet and emits the strict file as a **proposal**. The human reviews something already correct instead of authoring taxonomy from scratch. Strictness moves from *author burden* to *reviewed machine output*.

Two on-ramps, one path: the `_inbox/` folder and the dashboard "new knowledge" form both feed `kms-classify` → review → seed.

### Footgun fixes (pure wins, independent of the above)

1. **Silent skip → loud feedback.** Unrecognized folder or failed vocab must *report* ("`flx-mobile` not a known project — did you mean `flex-mobile`?"), never drop silently.
2. **Stop discarding preamble.** Content before the first `##` is captured (intro node or folded into the first section), not thrown away.
3. **Forgiving vocab.** Case-insensitive matching, alias map, "did you mean" suggestions.

---

## `kms-classify` Agent — Sketch

Internal worker, called by an orchestrator/skill on an `_inbox/` file (or dashboard submission). Follows Transparent Steering — surfaces its inference reasoning so the human can redirect, not just accept/reject.

```markdown
---
name: kms-classify-worker
description: Reads a loosely-authored markdown draft from knowledge-sources/_inbox/ (or a dashboard submission), infers the full canonical taxonomy (scope, platform, project, discipline, layer, artifact, owner, tags), and writes a normalized proposal file at the correct canonical path with frontmatter. Surfaces its inference reasoning for human review. Called by kms-contribute orchestrator. Internal tooling only.
model: sonnet
user-invocable: false
tools: Read, Write, Glob, Grep
---

You normalize a loose knowledge draft into a canonical KMS source file. You NEVER invent
content — you only classify, place, and add frontmatter to text the contributor wrote.

Think step-by-step: read draft → infer facets → resolve path → dedup check → write proposal → report reasoning.

## Inputs
| Field | Description |
|---|---|
| draft_path | Absolute path to the loose markdown draft (e.g. _inbox/error-handling.md) |
| hint       | Optional free-text from contributor ("about flutter data-layer error handling") |

If draft_path is missing or empty: stop, return `ERROR: missing required input — draft_path`.

## Controlled Vocabulary (never emit a value outside these)
- scope:      universal | platform | project
- platform:   flutter | ios | android | web
- discipline: engineering | design | qa | devops | security | code_review | product | architecture | agile
- layer:      domain | data | presentation | cross      (engineering only; default cross)
- owner:      curated | extracted                        (default curated for _inbox drafts)
- artifact:   kebab-case filename stem (conventions | standard-architecture | ...)

## Inference Rules
1. platform/project — from the hint, then Grep the draft for platform tells (dart/pubspec → flutter,
   swift → ios, kotlin/gradle → android, tsx/next → web). If a project is named, confirm it exists
   under knowledge-sources/projects/ (Glob); if close-but-not-exact, propose the nearest and flag it.
2. discipline — from hint + content (architecture/convention/code → engineering; design tokens/
   components → design; test strategy → qa; ...).
3. layer — engineering only: domain (entities/use-cases), data (repos/datasources/DTOs),
   presentation (BLoC/widgets/UI), else cross. When ambiguous, choose cross and say so.
4. artifact — from the draft's H1/title, kebab-cased; reuse an existing artifact name when the topic matches.
5. section headings — ensure the body uses `##` per concept; if the draft is one blob, propose a `##` split
   and show it. Never discard preamble — fold it into the first section or an intro `##`.

## Canonical Path (3 levels — no `area`; frontmatter is authoritative, path advisory)
- universal: knowledge-sources/universal/{discipline}/{artifact}.md
- platform:  knowledge-sources/platform/{platform}/{discipline}/{artifact}.md
- project:   knowledge-sources/projects/{project}/{discipline}/{artifact}.md

## Dedup Check
Grep existing files at the resolved path. If the artifact already exists, propose MERGING the new
`##` sections into it (do not create a duplicate file); list which sections are new vs overlapping.

## Output
Write the normalized proposal to the canonical path (or an alongside `.proposed.md` if the target exists),
with YAML frontmatter: scope, platform, project, discipline, layer, artifact, owner, tags.

## Report (Transparent Steering — always return this block)
DRAFT: <draft_path>
INFERRED:
  scope/platform/project: <values> — <why>
  discipline: <value> — <why>
  layer: <value> — <why (note if defaulted to cross)>
  artifact: <value>   owner: <value>
PLACED AT: <canonical path>   (or MERGE INTO: <existing path>)
CHUNKING: <n> sections — <list ## headings; note any proposed split or folded preamble>
FLAGS: <near-miss project names, ambiguous layer, missing platform, dedup overlaps — or "none">
NEXT: human reviews the proposal PR; adjust frontmatter or headings before seeding.
```

Companion `kms-contribute` orchestrator (Type O skill) watches `_inbox/`, spawns `kms-classify-worker` per draft, relays the report, and on approval moves the file to its canonical path for the normal seed run.

---

## Update Pipeline

```
curated:   human/agent drafts markdown ──► PR review ──► merge ──► reseed
loose:     _inbox/ or dashboard form ──► kms-classify proposal ──► PR review ──► merge ──► reseed
extracted: scheduled repo/PRD/Figma scan ──► regenerates owner:extracted files ──► PR ──► merge ──► reseed
```

`content_hash` skips unchanged nodes on every reseed, so re-running a scan is cheap.

---

## Eval & Success Criteria

The full redesign is a **bet that retrieval improves**. It must be measured, not eyeballed — otherwise the reseed can't be judged and cutover is a guess.

**Eval set** — ~20–30 `(query → expected node(s))` pairs drawn from *real agent tasks*, stored in `cipherpol-8-kms/eval/retrieval_cases.yaml`. Each case carries the agent's scope filter so it exercises retrieval the way an agent actually calls it:

```yaml
- query: "how does this project handle nullable fields from the API"
  where: { platform: flutter, discipline: engineering, layer: [data, cross] }
  expect_any: [flutter/engineering/conventions#null_safety_extensions]   # node(s) that SHOULD rank top-k
```

**Metric** — `recall@5` (did an expected node appear in top-5) and `MRR` (how high). A tiny runner queries a collection for each case and prints per-case hit/miss + aggregate.

**Gate** — baseline the metric on the **current** DB (step 1a). The new-schema collection must **beat the baseline** on both metrics before cutover (step 4). If it doesn't, the redesign is not done — investigate chunk size, contextual prefix, or facet correctness rather than shipping.

This eval set also catches the `##`-over-merge risk (chunks grown so large the embedding dilutes) and `layer` mislabeling (expected node filtered out by a wrong facet) — both surface as recall drops.

---

## Risks & Mitigations

| Risk | Why it bites | Mitigation |
|---|---|---|
| **Frontmatter-authoritative removes vocab guardrails** | `platform: fluttr` (typo) now seeds into a garbage facet *silently* — the mirror of the old silent-skip | **Seeder validates every facet value against the controlled vocab**; unknown value → warn + skip (never seed a garbage facet). The classify agent stays forgiving; the seeder does not. |
| **"Contextual embedding" mechanism ambiguous** | LLM-synthesized prefix = ~1300 calls, non-deterministic → **breaks `content_hash` incremental seeding**; template = cheap + deterministic | **Decision: static template from metadata** (`"{platform} {discipline} / {layer} — {section}: "`), no LLM at seed time. Deterministic, hash-stable, free. |
| **`layer` back-fill is a classification pass, not a field add** | ~1300 existing nodes have no `layer`; worst case (android `standard-architecture.md`, 226 nodes) is the monolith where `# Domain`/`# Data` markers were discarded — wrong `layer` = agent silently gets wrong knowledge | **Dedicated migration step (2a)** — classify existing content by layer (heading markers where present, else `kms-classify` proposal), human-reviewed. Not folded into the seeder rewrite. |
| **`##`-chunking over-merges** | Merging `###` facets can yield chunks so large the embedding signal dilutes — the opposite failure of over-fragmentation | Eval set (recall@5) flags it; cap very large sections or keep an intra-`##` split heuristic if a case regresses. |
| **Cutover repoint** | MCP + agents read collection `knowledge`; the new schema seeds a *second* collection | Cutover = repoint MCP to the new collection after the gate passes; old collection retained until agents verified. |

---

## Migration Order (each step independently shippable)

1. **Retrieval playground** — "query-as-agent" view against the *current* DB. *(deferred — the eval runner covers the measurement need; playground is now a dashboard concern, step 7.)*
1a. **Eval set + baseline** — ✅ **DONE** — `eval/retrieval_cases.yaml` + `run_eval.py`; baseline `recall@5=0.80`, `MRR=0.645` (1331 nodes) in `eval/baseline.json`.
2. **Reseed changes** — ✅ **DONE** (schema v3 additive; `directory.py` frontmatter-authoritative + vocab validation + `##`-chunk + preamble capture + relative `source_file`; `chroma_repository.py` template contextual-embed + opaque uuid id keyed on `source_file#topic#section`). **`area` removal still deferred** (subtractive — after cutover) so the live collection/MCP stay intact.
2a. **`layer` back-fill** — ⏭ NEXT. Concrete signal found: the `standard-architecture.md` files already carry `# Domain` / `# Data` / `# Presentation` / `# UI` as `topic` — those map directly to `layer`. Feature/api/component docs are mostly `cross` or `data`. Classify by topic-marker where present, else `kms-classify` proposal; human-reviewed.
3. **`--force` reseed into a second collection** — ✅ **DONE** — `knowledge_v2` seeded (836 nodes, down from 1331). **Gate PASSES: recall@5=0.90 (▲0.10), MRR=0.70 (▲0.055).**
4. **Cutover + reconcile the docs** — repoint MCP to the new collection. The prior restructure made **path authoritative, frontmatter documentation-only**; this initiative reverses that. Update `cipherpol-8-kms/docs/kms-knowledge-source-rules.md` and `kms-design-principles.md` (and the `kms-knowledge-restructure-initiative.md` header) to state frontmatter-authoritative + path-advisory, the dropped `area`, and the 3-level canonical path — otherwise the specs contradict. Also update `kms-source-audit-worker` (it validates against the old path-as-contract rules) and re-point the stale `sources.yaml` `path: kms/knowledge-sources` → `cipherpol-8-kms/knowledge-sources`.
5. **Agent scoping** — add default `where` to cipherpol-aegis planner frontmatter + wire the MCP filter.
6. **Contribution flow** — `_inbox/`, `kms-classify-worker`, `kms-contribute` orchestrator.
7. **Dashboard** — source tree + source→node lineage + staleness + the playground from step 1 + the contribute form.

Steps 1/1a are first because full redesign is a *bet* on better retrieval — prove it beats the current DB before committing the reseed and touching every agent. Step 4 lands right after the eval gate passes, so the written rules never lag the implemented behavior.

---

## Open Questions

- ~~**`area` facet** — keep or fold?~~ **Resolved (2026-07-03): dropped** — redundant with `discipline`; `design-system` moves to a `tag`. Canonical path is now 3 levels. See *Path depth & frontmatter-authoritative seeding*.
- **`layer` for non-engineering disciplines** — default `cross` and ignore, or omit entirely? (Leaning: default `cross`.)
- **Dashboard write-back** — direct commit vs open-a-PR from the UI. (Leaning: PR, to preserve review.)
- **Stale `source_file` / `sources.yaml` paths** — every node's `source_file` and `sources.yaml`'s `path` still reference the pre-rename `kms/` dir; the step-2 reseed refreshes `source_file`, but `sources.yaml` `path: kms/knowledge-sources` needs a manual fix to `cipherpol-8-kms/knowledge-sources`.
