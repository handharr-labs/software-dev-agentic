# Knowledge Path Structure Evaluation Initiative

**Status:** Proposed — evaluation phase, no implementation yet
**Goal:** Review the current Knowledge Path Structure (`docs/principles/kms/kms-conventions.md` — path conventions + chunk strategy, summarized in [kms-glossary.md](../principles/kms/kms-glossary.md)) against the real authored content in `kms/knowledge-sources/`, to surface placement ambiguities, naming inconsistencies, and chunking edge cases before they compound.

---

## Context

`kms-knowledge-restructure-initiative.md` (Complete) defined the Knowledge Path Structure: `{scope}/[{platform}|{project}]/{discipline}/{artifact}/{file}.md`, with `#`→`topic` and `##`→`pattern` chunking inside each file. That initiative validated the structure with a smoke test (653 nodes seeded) on mostly `engineering` content.

Since then, real content has been authored across other disciplines and shapes — notably `platform/flutter/design/design-system/mekari-pixel-design-system.md`, a catalog-style file with ~228 components. This initiative is a pass to check whether the structure holds for content shapes beyond the engineering theory docs it was designed against.

---

## Open Questions to Evaluate

1. **Discipline placement** — is `design-system` correctly placed under `discipline=design`, or does a component catalog belong under `engineering` (since agents consuming it are writing code)?
2. **Catalog-file granularity** — `mekari-pixel-design-system.md` has 4 `#` topics (`Atoms`, `Components`, `Pages`, `Templates`) and ~228 `##` patterns, one per widget. Does one-`KnowledgeNode`-per-widget make sense for retrieval, or should related widgets be grouped into fewer, larger patterns?
3. **Cross-platform pattern key consistency** — for catalog-style artifacts, do `pattern` keys (e.g. `mp_button`) need to align with equivalent components on other platforms (web/iOS design systems), per the "one concept = one pattern key" rule?
4. **Universal disciplines still empty** — `universal/{discipline}/` directories exist but are unpopulated. When filled, will any `artifact` names collide with platform-level artifacts of the same name under cascade resolution?
5. **Project artifact set completeness** — the current project artifact set (`api-endpoints`, `deviations`, `feature-inventory`, `shared-components`, `third-party-integrations`) is engineering-shaped. Does it need a `design`-discipline equivalent for project-level design deviations?
6. **Frontmatter vs path agreement** — `kms-knowledge-restructure-initiative.md` flagged this as pending: frontmatter is documentation-only today. Should seed-time validation warn when frontmatter disagrees with the derived path?

---

## Motivating Example

`platform/flutter/design/design-system/mekari-pixel-design-system.md`:

| Field | Value |
|---|---|
| scope | `platform` |
| platform | `flutter` |
| discipline | `design` |
| artifact | `design-system` |
| topics | `atoms`, `components`, `pages`, `templates` |
| patterns | ~228 (one per `## MpXxx` widget) |

This is the first non-`engineering`, catalog-shaped artifact in the KMS — a good stress test for whether the Knowledge Path Structure's assumptions (one `##` = one self-contained retrievable concept) generalize beyond architecture theory docs.

---

## Next Steps

- [ ] Inventory all files under `kms/knowledge-sources/` against the Knowledge Path Structure — confirm `scope`/`discipline`/`artifact`/`topic`/`pattern` are unambiguous and consistent for each
- [ ] Decide a granularity policy for catalog-style artifacts (per-component nodes vs grouped)
- [ ] Cross-check `pattern` keys for design-system components against any existing web/iOS design catalogs for naming alignment
- [ ] Document findings and, if needed, propose amendments to `kms-conventions.md` / `kms-knowledge-source-rules.md`

---

## Relation to Other Initiatives

- Builds on `kms-knowledge-restructure-initiative.md` (Complete) — that initiative defined the structure; this initiative evaluates it against real, varied content
- May feed into `kms-retrieval-strategy-initiative.md` if chunking granularity changes affect retrieval behavior

---

## Decision — `area` field added

A new mandatory `area` field/path segment was introduced between `discipline` and `artifact` (`schema_version` 2, was 1): `{scope}/[{platform}|{project}]/{discipline}/{area}/{artifact}/{file}.md` (project tier: `projects/{project}/{area}/{artifact}/{file}.md`, `discipline` still implicit `engineering`).

- `area=core` — default for all existing artifacts (conventions, standard-architecture, feature-inventory, api-endpoints, deviations, shared-components, third-party-integrations, etc.)
- `area=design-system` — for design-system catalogs, where `artifact` becomes the specific design system/library name (e.g. `mekari-pixel`)

This resolves **Open Question 1** (discipline/placement and naming for design-system catalogs): `design-system` catalogs stay under `discipline=design` but get their own `area`, with `artifact` set to the design system's name rather than a generic `design-system` label. It also sets the pattern for future design systems to coexist without collision — e.g. a second catalog would land at `platform/flutter/design/design-system/legacy-kit/legacy-kit-design-system.md` (`area=design-system, artifact=legacy-kit`), alongside `platform/flutter/design/design-system/mekari-pixel/mekari-pixel-design-system.md` (`area=design-system, artifact=mekari-pixel`), with no folder-name collision.
