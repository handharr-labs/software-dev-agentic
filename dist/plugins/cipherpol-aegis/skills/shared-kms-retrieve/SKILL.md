---
name: shared-kms-retrieve
description: Execute one KMS list+fetch pass for a given discipline and artifact. Covers platform-tier TOC scan, selective fetch, optional project-tier lookup, and codebase explore. Call once per knowledge domain; call twice for two domains.
user-invocable: false
allowed-tools: Grep, Read, mcp__cp8__kms_list, mcp__cp8__kms_fetch, mcp__cp8__kms_query
---

## Input

| Parameter | Required | Description |
|---|---|---|
| `discipline` | Yes | KMS discipline — e.g. `engineering`, `design` |
| `platform` | Yes | Platform slug — e.g. `flutter`, `ios`, `web` |
| `artifact` | No | Narrow the TOC to a specific artifact — e.g. `standard-architecture`, `conventions` |
| `topic` | No | Narrow further to a specific topic within the artifact — e.g. `domain`, `data` |
| `project` | No | Project id for project-tier lookup — e.g. `talenta`. Omit to skip project tier. |
| `project_artifacts` | No | List of project-tier artifacts to check — e.g. `["deviations", "feature-inventory"]`. Each is checked and skipped if empty. |
| `codebase_grep` | Yes | Grep pattern for existing implementation — e.g. `class.*UseCase`, `class.*RepositoryImpl` |
| `codebase_exclude` | No | Paths to exclude from codebase Grep. Default: `test/`, `mock/`, `fake/` |

## Steps

### 1 — Scan platform-tier TOC

`kms_list(discipline="{discipline}", platform="{platform}"[, artifact="{artifact}"][, topic="{topic}"])` → returns available `(artifact, topic, pattern)` rows.

From the TOC, identify which patterns are relevant to the current task. Reason over the row list — do not fetch everything blindly.

### 2 — Fetch identified patterns

For each identified pattern: `kms_fetch(discipline="{discipline}", artifact="{artifact}", topic="{topic}", pattern="{pattern}", platform="{platform}")` — exact, cascade-resolved content.

**Cold-start fallback only:** if the TOC vocabulary cannot be mapped to a needed concept, use `kms_query(text="<concept>", platform="{platform}", discipline="{discipline}", n_results=3)`. Prefer `kms_fetch` — it is deterministic and cheaper.

### 3 — Project-tier lookup (if `project` provided)

For each entry in `project_artifacts`:
`kms_list(discipline="{discipline}", project="{project}", artifact="{entry}")` — scan TOC. If empty, skip. If non-empty, `kms_fetch` nodes relevant to the current task (deviations that override platform conventions, inventory nodes that define existing boundaries).

### 4 — Codebase explore

`Grep` for `{codebase_grep}` in source, excluding `{codebase_exclude}` paths → read the most complete match (most method definitions, fewest TODO stubs) as live code reference.

## Output

Produce a `## Knowledge Loaded` block as defined in `$CLAUDE_PLUGIN_ROOT/reference/shared/kms-retrieval-output.md`. Always both Theory and Code Pattern — never one without the other.
