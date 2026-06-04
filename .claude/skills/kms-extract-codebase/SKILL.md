---
name: kms-extract-codebase
description: Scan a local project codebase and extract project-reality knowledge into kms/knowledge-sources/projects/{repo-name}/. Produces feature inventory, API endpoints, shared components, deviations, and third-party integrations docs. Then seeds ChromaDB.
user-invocable: true
allowed-tools: Agent
---

## Arguments

`$ARGUMENTS` — optional:
- `--project <name>` — project directory name under `kms/knowledge-sources/projects/`
- _(none)_ — list available projects from `kms/knowledge-sources/projects/` and ask which to scan

## Steps

### 1 — Resolve project

If `--project` provided: locate `kms/knowledge-sources/projects/{name}/repo.yaml`.

If not provided: list all directories under `kms/knowledge-sources/projects/` that contain a `repo.yaml` and ask the user which to scan.

### 2 — Spawn orchestrator

Spawn `kms-extract-orchestrator` with:

```
project_dir: kms/knowledge-sources/projects/{name}
repo_yaml:   kms/knowledge-sources/projects/{name}/repo.yaml
```

### 3 — Seed

After extraction completes, run `/kms-seed` to seed the new docs into ChromaDB.

### 4 — Report

Surface the orchestrator's extraction summary and seed result to the user.
