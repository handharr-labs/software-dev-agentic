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

### 3 — Update files

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

### 4 — Commit, tag, and push

```bash
git add VERSION CHANGELOG.md
git commit -m "chore(release): vX.Y.Z"
git tag vX.Y.Z
for remote in $(git remote); do
  git push "$remote" main && git push "$remote" --tags
done
```

### 5 — Check KMS seed freshness

```bash
stored=$(cat dist/.kms_seeds/.version 2>/dev/null || echo "")
shared_chroma="dist/.kms_seeds/.shared/chroma"
echo "stored: $stored"
echo "shared chroma: $([ -d "$shared_chroma" ] && echo present || echo MISSING)"
```

Check `dist/.kms_seeds/.version` against the current `lib/core/knowledge` tree hash:

```bash
git rev-parse HEAD:lib/core/knowledge
```

If `.version` doesn't match the tree hash, or if `.shared/chroma` is missing: report stale.

  Ask: "KMS seed is stale — seed now? (yes / skip)"
  - `yes` → run `bash scripts/seed-kms.sh` before continuing
  - `skip` → continue (plugin will bundle no chroma or an outdated one)

### 6 — Rebuild and commit all plugins

```bash
bash scripts/build-plugin.sh --platform=all
git add dist/plugins/
git commit -m "chore(plugin): build vX.Y.Z"
for remote in $(git remote); do
  git push "$remote" main
done
```

Report the version, tag, and per-remote push confirmations when done.
