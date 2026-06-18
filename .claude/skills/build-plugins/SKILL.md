---
name: build-plugins
description: Rebuild all plugins and push — without cutting a release.
user-invocable: true
disable-model-invocation: true
tools: Read, Bash
---

## Steps

### 1 — Check KMS seed freshness

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

### 2 — Rebuild and commit all plugins

```bash
bash scripts/build-plugin.sh --platform=all
git add dist/plugins/
git commit -m "chore(plugin): build $(cat VERSION)"
for remote in $(git remote); do
  git push "$remote" main
done
```

Report per-remote push confirmations when done.
