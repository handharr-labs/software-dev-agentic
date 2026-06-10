---
name: sda-status
description: Full SDA health check — shows platform, project, plugin versions, KMS connectivity, and knowledge coverage for the current project.
user-invocable: true
---

Run every step in order. Collect all results, then print a single combined report.

## Step 1 — Resolve context

```bash
echo "$SDA_PLATFORM"
echo "$SDA_PROJECT"
```

Also grep CLAUDE.md for the managed section:

```bash
grep -E "^\*\*(Platform|Project):\*\*" CLAUDE.md 2>/dev/null
```

Determine:
- `PLATFORM` — from `$SDA_PLATFORM`; fallback to CLAUDE.md `**Platform:**`
- `PROJECT` — from `$SDA_PROJECT`; fallback to CLAUDE.md `**Project:**`; fallback to `basename $(pwd)`

Cross-check: if `$SDA_PLATFORM` and CLAUDE.md `**Platform:**` both exist but disagree — flag `⚠ conflict`.
Same for project.

## Step 2 — Plugin versions

```bash
claude plugin list 2>/dev/null | grep sda || true
```

Check for `sda-core` and `sda-kms` in the output. Note versions.

## Step 3 — KMS connectivity

Call `kms_info()`. If the tool is unavailable or the call fails → KMS is OFFLINE.

If ONLINE:
- Call `kms_list()` with no filters → full TOC
- Group by `platform` → `project` → sum node counts
- Note distinct topics per row

## Step 4 — Scoped load probe

Using resolved `PLATFORM` and `PROJECT`:

```
kms_list(platform="{PLATFORM}", discipline="engineering")
kms_list(platform="{PLATFORM}", project="{PROJECT}", discipline="engineering")
```

Report node counts and topic lists for each call.

## Step 5 — Project knowledge snapshot

Take the first two topics from the project-scoped engineering probe (Step 4).
For each: call `kms_fetch(platform, project, discipline="engineering", topic)` and extract a 2–3 line excerpt.

## Report

Print one combined report. Do not add text beyond the blocks below.

```
SDA Status
══════════════════════════════════════════════════════

Context
───────────────────────────────────────────────────────
Platform   {PLATFORM} (kms_id)   source: {env | CLAUDE.md | inferred}
Project    {PROJECT}              source: {env | CLAUDE.md | dirname}
⚠ conflict: SDA_PLATFORM=flutter but CLAUDE.md says ios  ← only if mismatch

Plugins
───────────────────────────────────────────────────────
sda-core   {version | ✗ not installed}
sda-kms    {version | ✗ not installed}

KMS: {ONLINE | OFFLINE}
───────────────────────────────────────────────────────
Total nodes: {N}

platform   project       nodes   topics
──────────────────────────────────────────────────────
flutter    (base)        {N}     standard_architecture, use_case, ...
flutter    talenta       {N}     api_endpoints, feature_inventory, ...
...

Load probe — platform: {PLATFORM}  project: {PROJECT}
──────────────────────────────────────────────────────
platform base    {N nodes}   topics: {list}
project scoped   {N nodes}   topics: {list | ⚠ 0 nodes — run /kms-seed}

Project snapshot — {PROJECT}
──────────────────────────────────────────────────────
{topic_1}   {2–3 line excerpt | ⚠ empty body}
{topic_2}   {2–3 line excerpt | ⚠ empty body}
```

**Flags:**
- `⚠ conflict` — env var and CLAUDE.md disagree; env var takes precedence
- `⚠ not installed` — plugin missing; run `install-plugin.sh`
- `⚠ 0 nodes` on project-scoped probe — run `/kms-seed`
- `⚠ empty body` — node seeded but no content; rebuild plugin

**KMS OFFLINE block:**
```
KMS: OFFLINE
  kms_info tool unavailable. Ensure .mcp.json exists and restart Claude Code.
```
