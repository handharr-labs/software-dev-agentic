---
name: kms-extract-codebase
description: Scan a local project codebase and extract project-reality knowledge into kms/knowledge-sources/projects/{repo-name}/. Produces feature inventory, API endpoints, shared components, deviations, and third-party integrations docs.
user-invocable: true
allowed-tools: Agent
---

## Arguments

`$ARGUMENTS` — optional:
- `--project <name>` — project directory name under `kms/knowledge-sources/projects/`
- _(none)_ — list available projects from `kms/knowledge-sources/projects/` and ask which to scan

## Steps

### 1 — Resolve project

**If `--project` provided:**
- Look for `kms/knowledge-sources/projects/{name}/repo.yaml`
- If not found: treat as a new project — go to **Bootstrap** below

**If not provided:**
- List all directories under `kms/knowledge-sources/projects/` that contain a `repo.yaml`
- If any exist: ask the user which to scan, or offer "new project" as an option
- If none exist: go to **Bootstrap** below

**Bootstrap — new project:**

Ask the user:
1. Project name (used as directory name, e.g. `flutter-mobile-jurnal`)
2. Platform: `flutter` | `ios` | `android` | `web`
3. Absolute local path to the repo clone

Create `kms/knowledge-sources/projects/{name}/` and write `repo.yaml`:
```yaml
name: {name}
platform: {platform}
remote: null
last_scanned: null
last_scanned_local_path: {local_path}
```

Then proceed — no existing docs, so step 2 check is skipped.

### 2 — Check for existing docs

Check which doc files already exist in `kms/knowledge-sources/projects/{name}/`:

```
feature-inventory.md  api-endpoints.md  shared-components.md
deviations.md  third-party-integrations.md
```

If any exist, ask the user:

> The following docs already exist: {list}. Re-extraction will overwrite them completely.
> Choose:
> - **overwrite-all** — regenerate all docs
> - **missing-only** — only generate docs that don't exist yet
> - **select** — choose which docs to regenerate

Wait for the user's choice before proceeding. Pass the selected doc types to the orchestrator.

If no docs exist: proceed without asking.

### 3 — Spawn orchestrator

Spawn `kms-extract-orchestrator` with:

```
project_dir:  kms/knowledge-sources/projects/{name}
repo_yaml:    kms/knowledge-sources/projects/{name}/repo.yaml
doc_types:    {selected doc types from step 2}
```

### 4 — Audit

Run `/kms-audit projects/{name}/` to validate the extracted docs against `docs/principles/kms-knowledge-source-rules.md`.

If any **Error**-severity findings are reported: surface them to the user and stop.

### 5 — Report

Surface the orchestrator's extraction summary and audit result to the user. Remind the user to run `/kms-seed` manually when ready to load into ChromaDB.
