---
name: librarian-scan
description: Backfill a Feature Doc by scanning local platform repos. Supports incremental [pending-scan] expansion — only scans platforms not yet covered. Synthesizes, audits, and writes on approval.
user-invocable: true
allowed-tools: Read, Glob, Bash, AskUserQuestion, Agent
---

## Arguments

`$ARGUMENTS` — feature name followed by optional repo paths:

```
/librarian-scan time-off
/librarian-scan time-off --ios=../ios-app --flutter=../flutter-module
/librarian-scan time-off --ios=/abs/path/ios --android=/abs/path/android --flutter=/abs/path/flutter
```

Supported flags: `--ios=<path>`, `--android=<path>`, `--flutter=<path>`. Any omitted platform is treated as unconfigured and marked `[pending-scan]`.

Also accepts a Jira ticket ID as the feature name (e.g. `HR-421`).

## Steps

### 1 — Resolve feature name

Parse `$ARGUMENTS`: extract the first non-flag token as the feature name. If it looks like a Jira ticket ID, attempt `mmpa_get_jira` to resolve the feature name — or ask the user directly.

Extract repo paths from flags: `--ios`, `--android`, `--flutter`. Absent flags → empty string.

Derive default Feature Doc path: `.claude/reference/feature-docs/<kebab-case-name>.md`.

### 2 — Resolve repo paths

No CLAUDE.md config required. Use only the paths passed as flags. If a path is provided but does not exist on disk, warn the user and treat that platform as `[pending-scan]`.

### 3 — Spawn orchestrator

Spawn `librarian-feature-orchestrator` in plan-scan mode:

> **Mode: plan-scan**
>
> feature: <name>
> project_root: <git root>
> repo_config:
> KMS_IOS_REPO=<--ios value or empty>
> KMS_ANDROID_REPO=<--android value or empty>
> KMS_FLUTTER_REPO=<--flutter value or empty>

Capture the decision block.

### 4 — Route on decision

**`Decision: converged`** — no workers needed. Show note to user and stop.

**`Decision: blocked`** — surface question to user via `AskUserQuestion`, then re-invoke orchestrator with the answer.

**`Decision: spawn-workers`** — proceed to Step 5.

### 5 — Spawn platform workers in parallel

For each platform listed in the spawn block, spawn the corresponding worker simultaneously:

| Platform | Worker |
|---|---|
| ios | `librarian-ios-worker` |
| android | `librarian-android-worker` |
| flutter | `librarian-flutter-worker` |

Pass each worker: `feature: <name>`, `repo_path: <path from decision block>`.

Collect all findings blocks.

### 6 — Spawn synthesizer

Spawn `librarian-synthesizer-worker` in scan mode:

> **Mode: scan**
>
> principles_path: docs/principles/feature-doc-principles.md
>
> existing_doc: <contents of existing Feature Doc, or "none">
>
> platform_findings:
> <all collected findings blocks>

Capture the draft.

### 7 — Spawn audit worker

Spawn `librarian-audit-worker`:

> principles_path: docs/principles/feature-doc-principles.md
>
> draft:
> <synthesizer draft>

Capture findings.

### 8 — Present for review

Show the draft (or diff against existing doc if updating) and audit findings.

- `BLOCKED`: display violations. Ask user to correct or provide missing info, then re-run synthesizer + audit.
- `APPROVED_WITH_WARNINGS`: display warnings. Confirm before proceeding.
- `APPROVED`: proceed.

### 9 — Write on approval

Write the draft to `.claude/reference/feature-docs/<name>.md`.

Confirm: "Feature Doc written to `<path>`."

If any platforms remain as `[pending-scan]`, note them: "Run `/librarian-scan <name> --<platform>=<path>` to fill in the missing platforms when the repo is available."
