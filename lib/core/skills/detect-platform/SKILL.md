---
name: detect-platform
description: Detect the platform and project for the current session. Returns platform=<kms_id> and project=<id> for use in kms_query calls.
user-invocable: false
allowed-tools: Bash, Glob
---

Detect the current project's platform and project id. Stop at the first resolved value for each.

## Detect platform

**1. Env var**
```bash
echo "$SDA_PLATFORM"
```
If non-empty → `PLATFORM=$SDA_PLATFORM`. Done.

**2. CLAUDE.md managed section**
```bash
grep -i "^\*\*Platform:\*\*" CLAUDE.md 2>/dev/null
```
Extract value after `**Platform:**`. Map to kms_id via `sda.json`. If found → `PLATFORM=<kms_id>`. Done.

**3. Codebase markers**

Glob for each marker defined in `sda.json`:
- `pubspec.yaml` → `PLATFORM=flutter`
- `*.xcodeproj` or `*.xcworkspace` → `PLATFORM=ios`
- `build.gradle` or `build.gradle.kts` → `PLATFORM=android`
- `next.config.*` → `PLATFORM=web`

**4. Unresolvable**
Return: `MISSING INPUT: platform — run install-plugin.sh --platform=<id>`

## Detect project

**1. Env var**
```bash
echo "$SDA_PROJECT"
```
If non-empty → `PROJECT=$SDA_PROJECT`. Done.

**2. CLAUDE.md managed section**
```bash
grep -i "^\*\*Project:\*\*" CLAUDE.md 2>/dev/null
```
If found → `PROJECT=<value>`. Done.

**3. Directory name fallback**
```bash
basename $(pwd)
```
Use as `PROJECT`. Note: may not match a KMS project node — agents should still attempt queries.

## Cross-check

If env var and CLAUDE.md both resolved but disagree for either field — warn:

```
WARNING: SDA_PLATFORM (flutter) conflicts with CLAUDE.md **Platform:** (ios).
Using SDA_PLATFORM. Re-run install-plugin.sh --platform=<id> to realign.
```

## Output

Return two lines, always both:

```
platform=flutter
project=talenta
```

The calling worker passes these to all `kms_query`, `kms_fetch`, and `kms_list` calls.
