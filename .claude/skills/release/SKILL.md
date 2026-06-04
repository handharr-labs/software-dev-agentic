---
name: release
description: Cut a new release of software-dev-agentic — bumps VERSION, prepends a CHANGELOG entry, commits, tags, rebuilds all plugins, and pushes.
user-invocable: true
tools: Read, Edit, Bash
---

## Arguments

```
/release [patch|minor|major]
```

- `type` — optional. If omitted, ask the user.

## Steps

### 1 — Read current state

```bash
cat VERSION
```

Read the top section of `CHANGELOG.md` to see what's already recorded.

### 2 — Determine next version

If type was not provided, ask:
- `patch` (x.y.Z) — bug fixes, typo corrections, doc clarifications
- `minor` (x.Y.0) — new agents, new skills, new workers, backward-compatible changes
- `major` (X.0.0) — breaking convention changes, renamed/removed files

Increment the appropriate segment. Ask for a brief description of what changed if the user hasn't provided one.

### 3 — Commit pending working-tree changes

Before touching VERSION or CHANGELOG, flush any uncommitted work:

```bash
git status --short
```

If there are staged or unstaged changes:
1. `git diff --name-only HEAD` — list all modified tracked files
2. Group them into logical chunks by area (e.g. agents, skills, docs, kms, scripts). One commit per group.
3. For each group:
   ```bash
   git add <files in group>
   git commit -m "<conventional-commit prefix>(<area>): <short description>"
   ```
4. Untracked files that belong to the release (new agents, new knowledge sources, new skills): stage and commit in the relevant group.

Skip this step if `git status --short` is clean.

### 4 — Update files

**`VERSION`** — overwrite with the new version (single line, no `v` prefix).

**`CHANGELOG.md`** — prepend below the header (`---` separator) using this format:

```
## [X.Y.Z] — YYYY-MM-DD

### Added
- ...

### Changed
- ...

### Fixed
- ...

### Removed
- ...
```

Only include sections that have entries. Use today's date from system context.

### 5 — Commit, tag, and push

```bash
git add VERSION CHANGELOG.md
git commit -m "chore(release): vX.Y.Z"
git tag vX.Y.Z
for remote in $(git remote); do
  git push "$remote" main && git push "$remote" --tags
done
```

### 6 — Check KMS seed freshness

```bash
stored=$(cat dist/.kms_seeds/.version 2>/dev/null || echo "")
shared_chroma="dist/.kms_seeds/.shared/chroma"
echo "stored: $stored"
echo "shared chroma: $([ -d "$shared_chroma" ] && echo present || echo MISSING)"
```

If `.shared/chroma` is missing or `.version` is empty: report stale.

  Ask: "KMS seed is stale — seed now? (yes / skip)"
  - `yes` → run `/kms-seed` before continuing
  - `skip` → continue (plugin will bundle no chroma or an outdated one)

### 7 — Rebuild and commit all plugins

```bash
bash scripts/build-plugin.sh --platform=all
git add dist/plugins/
git commit -m "chore(plugin): build vX.Y.Z"
for remote in $(git remote); do
  git push "$remote" main
done
```

Report the version, tag, and per-remote push confirmations when done.
