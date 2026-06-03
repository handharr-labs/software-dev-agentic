---
name: kms-status
description: Validate KMS MCP connectivity and summarize what's seeded — call kms_list, group by platform/project, report counts and topic coverage.
---

## Purpose

Confirm the KMS MCP server is reachable and show what knowledge is available in this project's plugin.

## Steps

1. Call `kms_list()` with no filters — fetch the full TOC.
2. If the call fails or the tool is unavailable: report **KMS OFFLINE** and stop.
3. Group results by `platform` → `project` → `discipline` → count of nodes.
4. For each platform+project pair, list distinct topics covered.
5. Output the summary below.

## Output

```
KMS Status: ONLINE
Total nodes: {N}

platform       project                  nodes  topics
──────────────────────────────────────────────────────────
flutter        (base)                   {N}    domain, data, presentation, state_management, ...
flutter        flutter-mobile-talenta   {N}    app, project_structure, testing, ...
ios            ios-talenta              {N}    domain, data, presentation, navigation, ...
...
```

If any platform has 0 nodes: flag it as `⚠ empty`.
If total nodes is 0: report **KMS ONLINE but empty — seed may be missing**.
