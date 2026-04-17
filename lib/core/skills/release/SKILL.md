---
name: release
description: Cut a new release of this project — bumps VERSION, prepends a CHANGELOG entry, commits, and creates a git tag.
context: fork
allowed-tools: Read, Write, Edit, Bash
---

You are cutting a new release of the project.

## Step 1 — Read current state

Read the current `VERSION` file and the top of `CHANGELOG.md` to understand what version we're on.

## Step 2 — Determine the next version

Ask the user:
1. **Release type**: patch / minor / major?
   - `patch` — bug fixes, typo corrections, doc clarifications (x.y.Z)
   - `minor` — new agents, new skills, new reference docs, backward-compatible additions (x.Y.0)
   - `major` — breaking changes to architecture conventions, renamed/removed files (X.0.0)
2. **What changed** — ask for a brief description if they haven't provided one.

Compute the next version by incrementing the appropriate segment of the current version.

## Step 3 — Update files

1. **`VERSION`** — overwrite with the new version number (single line, no `v` prefix).

2. **`CHANGELOG.md`** — prepend a new section at the top (below the header) using this format:

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

Only include sections that have entries. Use today's date (available in your system context).

## Step 4 — Commit and tag

Run:
```bash
git add VERSION CHANGELOG.md
git commit -m "chore: release vX.Y.Z"
git tag vX.Y.Z
```

Then tell the user:
- The new version number
- The git tag created
- To push with: `git push && git push --tags`
