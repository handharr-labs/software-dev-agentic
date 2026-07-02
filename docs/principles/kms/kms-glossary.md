> Author: Puras Handharmahua · 2026-06-13
> Related: [kms-design-principles.md](kms-design-principles.md) · [kms-conventions.md](kms-conventions.md) · [../glossary.md](../glossary.md)

## What This Doc Covers

A quick-reference list of KMS vocabulary terms with one-line definitions — for when you just need a reminder of what a term means, not the full path/metadata mapping. For the complete Rosetta Stone (storage paths, DB metadata fields, vocabulary sources, worked examples), see [kms-conventions.md](kms-conventions.md).

---

## Glossary

| Term | Definition |
|---|---|
| **KMS** | Knowledge Management System — the ChromaDB-backed knowledge store, queried via the `cp8` MCP server (`kms_list`/`kms_fetch`/`kms_query`/`kms_upsert`). |
| **Scope** | The cascade tier of a knowledge node — how general vs. specific it is: `universal`, `platform`, or `project`. |
| **Platform** | Which client platform a knowledge node applies to — `flutter`, `ios`, `android`, or `web`. |
| **Project** | Which specific downstream codebase a knowledge node is a deviation/inventory for — the folder name under `projects/`. |
| **Discipline** | The role / work-area a knowledge artifact serves — `engineering`, `design`, `qa`, `devops`, `security`, `code_review`, `product`, `architecture`, `agile`. |
| **Area** | *Removed 2026-07-03.* Formerly a `core`/`design-system` path segment between `discipline` and `artifact`; redundant with `discipline`. Design-system catalogs now use `discipline: design` + `tags: [design-system]`. |
| **Layer** | CLEAN-architecture facet — `domain` \| `data` \| `presentation` \| `cross`. Enables per-agent scoping (a domain-planner retrieves `layer ∈ {domain, cross}`). Derived: frontmatter → `#`-topic marker → `cross` floor. See `LAYER_VALUES`. |
| **Owner** | Lifecycle facet — `curated` (hand-owned, never auto-overwritten) or `extracted` (scanner-regenerated). See `OWNER_VALUES`. |
| **Artifact** | The named body of knowledge within a discipline — a filename stem (kebab-case, snake_cased for storage), directly the `.md` file under `{discipline}/`, e.g. `conventions`, `standard-architecture`, `feature-inventory`. |
| **Topic** | A `#` heading inside an artifact file — a thematic grouping of related concepts. |
| **Subtopic** | A `##` heading inside an artifact file — a sub-division of the parent `#` topic. Equals `pattern` when the `##` has no `###` children; otherwise groups one or more `###` patterns. |
| **Pattern** | The retrieval unit — a `###` heading when its parent `##` has `###` children, otherwise the `##` heading itself. One self-contained, retrievable concept, and the canonical name used for that concept across all platforms. |
| **Knowledge Path** | The ordered tuple of Rosetta Stone terms (`scope` → `platform`/`project` → `discipline` → `artifact` → optionally `topic` → optionally `section`) that addresses a knowledge node — same shape as a `kms_list`/`kms_fetch` filter set. E.g. `# Domain` in `platform/ios/engineering/standard-architecture.md` → `scope=platform, platform=ios, discipline=engineering, artifact=standard-architecture, topic=domain`. |
| **Knowledge Path Structure** | The overall directory + heading convention that every Knowledge Path is an instance of: `{scope}/[{platform}\|{project}]/{discipline}/{artifact}.md` (3-level), then `#`→`topic` and each `##`→one node (`section`, stored as `subtopic == pattern`) inside the file. Defined in [kms-conventions.md](kms-conventions.md#kmsknowledge-sources--path-conventions). |
| **Rosetta Stone** | The term-to-storage-path-to-metadata-field mapping table in [kms-conventions.md](kms-conventions.md) — the canonical reference when a term's meaning is unclear. |
| **Cascade resolution** | The fallback order KMS uses when fetching a node: `project → platform → universal` — most specific match wins. |
| **Scoping funnel** | The narrowing order for `kms_list` calls: `platform`/`project` → `discipline` → `area` → `artifact` → `topic` → `subtopic` → `pattern` (output, never a filter). |
| **Retrieval Protocol** | The decision table for which KMS MCP tool (`kms_list`/`kms_fetch`/`kms_query`) to use for a given retrieval need. Defined in [kms-conventions.md](kms-conventions.md#retrieval-protocol). |
| **kms_list** | MCP tool — returns a TOC (metadata only) for a given filter combination; narrows one term at a time. |
| **kms_fetch** | MCP tool — exact, cascade-resolved retrieval once `discipline`/`artifact`/`topic`/`subtopic`/`pattern` are known. |
| **kms_query** | MCP tool — semantic search bypass when the exact `pattern` isn't known yet; ranks by similarity. |
| **kms_upsert** | MCP tool — manually seed a knowledge node by supplying `discipline`/`artifact`/`topic`/`pattern` directly (`subtopic` optional, defaults to `pattern`). |

---

## Changelog

See git history for this file.
