---
name: aegis-cipherpol-status
description: Full CipherPol health check — shows platform, project, plugin versions, KMS connectivity, and knowledge coverage for the current project.
user-invocable: true
disable-model-invocation: true
---

Run every step in order. Collect all results, then print a single combined report.

## Step 1 — Resolve context

```bash
echo "$CIPHERPOL_PLATFORM"
echo "$CIPHERPOL_PROJECT"
echo "$CIPHERPOL_THINKER_MODEL"
```

Also grep CLAUDE.md for the managed section:

```bash
grep -E "^\*\*(Platform|Project):\*\*" CLAUDE.md 2>/dev/null
```

Determine:
- `PLATFORM` — from `$CIPHERPOL_PLATFORM`; fallback to CLAUDE.md `**Platform:**`
- `PROJECT` — from `$CIPHERPOL_PROJECT`; fallback to CLAUDE.md `**Project:**`; fallback to `basename $(pwd)`
- `THINKER_MODEL` — from `$CIPHERPOL_THINKER_MODEL`; if unset or any value other than `cost-saving`, treat as `optimized` (default)

Cross-check: if `$CIPHERPOL_PLATFORM` and CLAUDE.md `**Platform:**` both exist but disagree — flag `⚠ conflict`.
Same for project.

## Step 2 — Plugin versions

```bash
claude plugin list 2>/dev/null | grep cipherpol || true
```

Check for `cipherpol-aegis` and `cipherpol-8` in the output. Note versions.

Also detect the active KMS server path and its version:

```bash
# Resolve which cipherpol-8 version the MCP server is actually running from
cat ~/.claude/settings.json 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('mcpServers',{}).get('kms',{}).get('args',[''])[1])" 2>/dev/null || true
# Find the latest cached version on disk
ls ~/.claude/plugins/cache/cipherpol/cipherpol-8/ 2>/dev/null | sort -t. -k1,1n -k2,2n -k3,3n | tail -1
```

The MCP server may be running a different version than what `claude plugin list` reports if the session was not restarted after an update. Flag a mismatch.

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

Take the first two topics from the project-scoped engineering probe (Step 4) that have meaningful content.
Skip any topic whose first pattern body is under 100 characters — those are file-header stub nodes produced by the `##`-chunking strategy (the actual content lives in child nodes like `account`, `auth`, `attendance`, etc.).
For each qualifying topic:
1. `kms_list(platform, project, discipline="engineering", topic=<topic>)` — get available patterns for that topic.
2. `kms_fetch(platform, project, discipline="engineering", topic=<topic>, pattern=<first pattern from list>)` — extract a 2–3 line excerpt.

## Report

Print one combined report. Do not add text beyond the blocks below.

```
CipherPol Status
══════════════════════════════════════════════════════

Context
───────────────────────────────────────────────────────
Platform       {PLATFORM} (kms_id)   source: {env | CLAUDE.md | inferred}
Project        {PROJECT}              source: {env | CLAUDE.md | dirname}
Thinker model  {THINKER_MODEL}        (opus planners/strategists | sonnet if cost-saving)
⚠ conflict: CIPHERPOL_PLATFORM=flutter but CLAUDE.md says ios  ← only if mismatch

Plugins
───────────────────────────────────────────────────────
cipherpol-aegis   {version | ✗ not installed}
cipherpol-8    {version | ✗ not installed}
  MCP server  running from: ~/.claude/plugins/cache/cipherpol/cipherpol-8/{active-version}/
              latest on disk: {latest-version}
              ⚠ stale session: MCP is {active-version} but latest is {latest-version} — restart Claude Code  ← only if mismatch

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
- `⚠ stale session` — MCP server is running an older cipherpol-8 version; restart Claude Code to pick up the latest
- `⚠ 0 nodes` on project-scoped probe — run `/kms-seed`
- `⚠ empty body` — node has content under 100 chars after skipping header stubs; may need `/kms-seed` to populate

**KMS OFFLINE block:**
```
KMS: OFFLINE
  kms_info tool unavailable. Ensure mcpServers.kms is configured in ~/.claude/settings.json and restart Claude Code.
```
