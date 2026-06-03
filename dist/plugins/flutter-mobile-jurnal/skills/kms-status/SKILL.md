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
flutter        flutter-mobile-talenta   {N}    app, project_structure, testing, ...
ios            ios-talenta              {N}    domain, data, presentation, navigation, ...
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
