---
name: kms-status
description: Validate KMS MCP connectivity and summarize what's seeded — call kms_list, group by platform/project, report counts and topic coverage.
user-invocable: true
---

## Purpose

Confirm the KMS MCP server is reachable and show what knowledge is available in this project's plugin.

## Steps

1. Call `kms_info()` — get DB path, knowledge dir path, and node count.
2. If the call fails or the tool is unavailable: output the OFFLINE block below and stop.
3. Call `kms_list()` with no filters — fetch the full TOC.
4. Group results by `platform` → `project` → `discipline` → count of nodes.
5. For each platform+project pair, list distinct topics covered.
6. Output the ONLINE block below. Do not add any text, suggestions, or next steps beyond the block.

## Step 6 — Scoped load probe

After the summary table, run the same queries agents fire during pre-flight to verify load logic works end-to-end.

Derive context:
- `project` = `basename $(pwd)` (same rule all agents use)
- `platform` = infer from project name prefix (`flutter-*` → `flutter`, `ios-*` → `ios`, `android-*` → `android`, `web-*` → `web`); if ambiguous, run probes for all four platforms

For each `(platform, project)` pair:

```
kms_list(platform="{platform}", project="{project}", discipline="engineering")
kms_list(platform="{platform}", discipline="design")
```

Report results inline:

```
Load probe — project: {project}  platform: {platform}
────────────────────────────────────────────────────
engineering  [platform={platform}, project={project}]   {N nodes}  topics: {list}
design       [platform={platform}]                      {N nodes | ⚠ no catalog — skip}
```

`⚠ no catalog` on design is not an error — it means iOS/Android/web hasn't been catalogued yet and agents will skip gracefully.
`⚠ 0 nodes` on engineering IS a problem — agents would load nothing.

## Step 7 — Project knowledge summary

After the load probe, fetch a brief snapshot of what the current project actually knows.

Using the same `project` and `platform` derived in Step 6:
1. Take the **first two topics** returned from the engineering load probe (Step 6) for this project — do not hardcode topic names.
2. For each topic, call:
   ```
   kms_fetch(platform="{platform}", project="{project}", discipline="engineering", topic="{topic}")
   ```
3. If a node is returned, extract a 2–3 line excerpt (first meaningful sentences or bullet points from the body). If no node or empty body, show `⚠ empty body`.

Output inline after the load probe:

```
Project summary — {project}
────────────────────────────────────────────────────
{topic_1}   {2–3 line excerpt | ⚠ empty body}
{topic_2}   {2–3 line excerpt | ⚠ empty body}
```

`⚠ empty body` means the node was seeded but ChromaDB stored no content — re-seed and rebuild the plugin.

## Output — OFFLINE

```
KMS Status: OFFLINE

The kms_list tool is not available. To enable KMS:
1. Ensure .mcp.json exists at your project root (see README Setup — Plugin).
2. Restart Claude Code to apply MCP server changes.
```

## Output — ONLINE, nodes > 0

```
KMS Status: ONLINE
Total nodes: {N}

ChromaDB:       {db_path}  ✓ present
Knowledge dir:  {knowledge_dir}  ✓ {knowledge_files} pattern files

platform       project                  nodes  topics
──────────────────────────────────────────────────────────
flutter        (base)                   {N}    domain, data, presentation, state_management, ...
flutter        talenta                  {N}    app, project_structure, testing, ...
ios            talenta                  {N}    domain, data, presentation, navigation, ...
...
```

Flag any platform with 0 nodes as `⚠ empty`.
If `db_exists` is false: flag `⚠ ChromaDB directory missing`.
If `knowledge_exists` is false: flag `⚠ knowledge/ directory missing — rebuild plugin`.
If `knowledge_files` is 0: flag `⚠ knowledge/ is empty — rebuild plugin`.

## Output — ONLINE, nodes = 0

```
KMS Status: ONLINE
Total nodes: 0

ChromaDB:       {db_path}  {✓ present | ⚠ MISSING}
Knowledge dir:  {knowledge_dir}  {✓ N pattern files | ⚠ MISSING}

⚠ KMS server is reachable but the knowledge store is empty.
  Restart Claude Code to reload the MCP server, then run /kms-status again.
  If still empty: rebuild the plugin (build-plugin.sh --platform=<platform>).
```
