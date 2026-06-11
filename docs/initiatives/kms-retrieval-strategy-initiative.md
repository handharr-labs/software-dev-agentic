# KMS Retrieval Strategy Initiative

**Status:** Complete — all 8 steps done; fetch-by-topic contract smoke-tested 7/7 against the clean 653-node DB. Plugins `cipherpol-8` + `cipherpol-aegis` rebuilt @ 12.0.3 (not yet committed/installed).
**Goal:** Define and roll out how `lib/core/` agents and skills load knowledge from the KMS MCP tools, aligned to the restructured four-axis metadata (`scope · platform · project · discipline · artifact · topic · pattern`).
**Depends on:** `kms-knowledge-restructure-initiative.md` (complete — 653 nodes seeded with `artifact` axis).

---

## Problem

The restructure added the `artifact` axis and changed on-disk paths, but the consumption side (`lib/core/` agents and skills) was never updated to match. Three concrete breaks:

1. **Server-name mismatch.** Agents grant and call `mcp__kms__kms_*` in frontmatter and bodies. The MCP server registers as **`cp8`** (`lib/plugins/cipherpol-8/build.sh:83`; live tools are `mcp__cp8__kms_*`). Tool grants don't match real tool names.
2. **`artifact` threaded by nobody.** `kms_list`/`kms_fetch` gained an `artifact` param; no agent or skill passes it. The shipped `cp8` server predates the param.
3. **Dead fallbacks.** ~15 leaf skills fall back to `kms/knowledge-sources/engineering/{platform}-standard-architecture.md` — a path the restructure deleted (now `platform/{platform}/engineering/standard-architecture/standard-architecture.md`).

---

## Design Decisions

### 1. Three tools, two entry paths — not a sequence

`kms_list` → `kms_fetch` and `kms_query` are **alternative entry paths**, chosen by what the caller already knows. Reasoning over a TOC *is* resolving exact node identity — so once you have a TOC, you hold the exact `(discipline, artifact, topic, pattern)` and must `kms_fetch`. Falling back to `kms_query` after `kms_list` throws away the identity just gained and re-derives it fuzzily.

| Caller knows… | Path | Tools |
|---|---|---|
| Exact target, or a TOC to reason over | list → **fetch** | `kms_list` → `kms_fetch` |
| Only intent; doesn't know what node exists | **query** | `kms_query` |

`kms_list` → `kms_query` is the incoherent pairing (pays for the TOC, ignores it) and is removed wherever a known target exists.

### 2. Role split by retrieval determinism

- **Skills (leaf `create-*`, log, audit) — deterministic.** Target is known at authoring time → always `kms_fetch(discipline, artifact, topic, pattern, platform)`. Never `kms_query`. No flat-file fallback; a miss surfaces a seed gap.
- **Planners / workers — discover then fetch.** Steady state is `kms_list` → `kms_fetch`. `kms_query` shrinks to a **cold-start, discovery-only** role: used once on entering an unfamiliar discipline/artifact to learn the slugs, after which loads become `kms_fetch`.

### 3. Anchor once per session

`detect-platform` resolves `platform` + `project`; every KMS call threads both. Unchanged.

### 4. DRY via shared protocol, inline params

The list/fetch/query recipe is authored once in `docs/principles/kms-design-principles.md §Retrieval Protocol`. Agents/skills cite it rather than re-explaining. Each skill keeps only its own `kms_fetch` params inline (inherently specific).

### 5. Server standardizes on `cp8`

The registered server name wins. Rewrite all `mcp__kms__*` → `mcp__cp8__*` in `lib/core/agents/**`.

---

## Contract Table — VERIFIED against built DB (flutter)

Slugs below are **real**, pulled via `ListKnowledge` against `dist/plugins/cipherpol-8/chroma` (artifact-populated nodes only). All `discipline = engineering`, `artifact = standard-architecture` unless noted.

| Skill | artifact | topic | pattern |
|---|---|---|---|
| developer-domain-create-usecase | standard-architecture | domain | `use_case` |
| developer-domain-create-entity | standard-architecture | domain | `entity` |
| developer-domain-create-repository | standard-architecture | domain | `repository_interface` |
| developer-domain-create-service | standard-architecture | domain | `domain_service` |
| developer-data-create-datasource | standard-architecture | data | `data_source` (+ `local_data_source`) |
| developer-data-create-mapper | standard-architecture | data | `mapper` |
| developer-data-create-repository-impl | standard-architecture | data | `repository_implementation` |
| developer-pres-create-screen | standard-architecture | presentation | `screen_structure` |
| developer-pres-create-component | standard-architecture | presentation | `component` |
| developer-pres-create-stateholder | standard-architecture | **state_management** | `bloc` / `cubit` ⚠ platform-specific |
| developer-test-create-domain | standard-architecture | testing | `use_case_test` |
| developer-test-create-data | standard-architecture | testing | `repository_test` |
| developer-test-create-presentation | standard-architecture | testing | `presenter_test` |
| developer-test-create-mock | standard-architecture | testing | `mock_generation` |
| debugger-add-logs / remove-logs | standard-architecture | **utilities** | `logger` ⚠ platform-specific |
| (cross-cutting) null safety | **conventions** | conventions | `null_safety_extensions` |

Corrections vs the projected table: repository→`repository_interface`, service→`domain_service`, datasource→`data_source`, repository_impl→`repository_implementation`, screen→`screen_structure`, stateholder topic→`state_management`, test patterns are `*_test`, debug logging lives at `utilities/logger` not a `debug_logging` pattern.

### ⚠ Finding A — slugs diverge across platforms

The contract is **not platform-agnostic**. Flutter vs Android differ structurally:

| Concept | flutter | android |
|---|---|---|
| StateHolder | `state_management / bloc` | `presentation / presenter` (`mvp_contract`) |
| Tests | `testing / *_test` | `instrumented_tests / *_tests` |
| Debug logging | `utilities / logger` | `presentation / logging` |

**Decision: (b) Fetch-by-topic.** Skills hardcode only `(discipline, artifact, topic)`; they run `kms_list(discipline, artifact, topic, platform)` and `kms_fetch` the returned pattern(s). Survives platform slug divergence with no per-platform maps. The `pattern` column in the table above is reference, not a hardcoded skill value.

### ⚠ Finding B — built DB is dirty (blocks query/list, not fetch)

The bundled `chroma` holds **1379 nodes = 653 artifact-aware (new) + 726 flat `artifact=None` (stale pre-restructure) + 8 `_template`**. The re-seed was **additive, not a wipe** — old and new node IDs differ (artifact is in the ID formula), so both generations coexist.

- **`kms_fetch` is immune** — once `artifact` is threaded, it can't match the `artifact=None` stale nodes.
- **`kms_list` and `kms_query` are polluted** — TOC noise + stale duplicates can outrank new nodes in semantic search.

**Required cleanup (new step 0):** wipe the collection and re-seed clean before relying on list/query, and before shipping the rebuilt plugin. Initiative claim "653 nodes seeded" is true for the *new* generation but the shipped DB carries the old one too.

### ⚠ Finding C — clean reseed exposed empty universal/product disciplines

Post-wipe the DB holds **653 nodes, all platform-scoped: engineering (649) + design (4)**. **Universal and `product` disciplines are 0 nodes** — the stale flat generation had been masking that `universal/` is unpopulated (a known pending item in the restructure initiative). Impact on step 5:
- `qa-testcase-worker` loads `discipline="product"` → now returns nothing. Made resilient: it degrades to codebase-only and treats an empty product TOC as expected (not an error).
- Any future universal-discipline reads (qa strategy, agile, security) will be empty until `universal/` is authored. Not a regression in this work — surfaced by it.

### Step 5+6 scope (done)

All 10 KMS-calling agents migrated to `kms_list`(discipline+artifact+topic scoped) → `kms_fetch`, with `kms_query` reserved for cold-start discovery only:
- 4 planners (domain/data/pres/app), feature-worker, ui-worker, backend-worker, debugger-worker, auditor-arch-review-worker, qa-testcase-worker.
- **Latent bug fixed:** 8 of 10 agents declared only `mcp__cp8__kms_query` in `tools:` yet *called* `kms_list` (undeclared). All now declare `kms_list, kms_fetch, kms_query` to match their bodies.
- **Schema bug fixed:** feature-worker's null-safety `kms_fetch` used `topic="null_safety_extensions"` — corrected to `artifact="conventions", topic="conventions", pattern="null_safety_extensions"`.
- `artifact` threaded into every `kms_list`/`kms_fetch` (`standard-architecture` for architecture patterns, `conventions` for cross-cutting, `deviations` for project audits).

---

## Change Set

| # | Step | Status | Depends on |
|---|---|---|---|
| 1 | Rewrite `mcp__kms__*` → `mcp__cp8__*` in all `lib/core/agents/**` | ✅ done | — |
| 2 | Rebuild `cipherpol-8` (artifact-aware server) | ✅ done | — |
| 3 | Verify Contract Table from real slugs | ✅ done | 2 |
| 0 | **Wipe + clean re-seed** the collection (Finding B) — dropped 726 stale + 8 template nodes; rebuilt cp8 with clean 653-node DB | ✅ done | — |
| — | **Skill design decision** (Finding A) → **(b) fetch-by-topic** | ✅ decided | 3 |
| 4 | Convert leaf skills to fetch-by-topic (`kms_list` topic-scoped → `kms_fetch`); delete flat-file fallbacks | ✅ done | 0, design |
| 5 | Convert planner/worker `kms_list`→`kms_query` to `kms_list`→`kms_fetch`; `kms_query` = cold-start only | ✅ done | 0, design |
| 6 | Thread `artifact` into all surviving `kms_list`/`kms_fetch` calls | ✅ done | design |
| 7 | Rebuild `cipherpol-aegis`; smoke-test the fetch-by-topic contract | ✅ done | 0,1,4,5,6 |

**Sequence:** (1 ✅ ∥ 2 ✅) → 3 ✅ → 0 ✅ → 4 ✅ → **(5, 6) next** → 7.

**Step 4 scope (done):** 18 skills converted to fetch-by-topic + dead flat-file fallbacks removed —
- 14 leaf `create-*` + debugger log skills (the planned set)
- plus `auditor-arch-check` (dependency_rule/layer_invariants) and `developer-test-procedure` (Platform Reference section) which carried the same dead flat path.
- 4 skills had `allowed-tools` that excluded the KMS tools (their old `kms_query` was already unreachable): `debugger-add-logs`, `debugger-remove-logs`, `auditor-arch-check`, `developer-test-procedure` — all now granted `mcp__cp8__kms_list, mcp__cp8__kms_fetch`.

---

## Open Items

- **Verify no existing `mcp__kms__` remap** before bulk rename (step 1) — confirm prod KMS calls are actually dead, not indirected.
- Contract Table slugs are projected, not confirmed — gate step 4 on a real `kms_list`.
