---
name: sync
description: Pull the latest software-dev-agentic updates and re-link all agents, skills, hooks, and reference docs. Auto-detects the project platform from existing symlinks.
user-invocable: true
allowed-tools: Bash
---

## Steps

1. **Detect platform** from the existing skill symlink:
   ```bash
   readlink .claude/skills/domain-create-entity 2>/dev/null
   ```
   - Contains `platforms/ios` → `ios`
   - Contains `platforms/web` → `web`
   - Contains `platforms/flutter` → `flutter`

2. **If detection fails** (no symlink or unknown path), ask the user which platform:
   - `web` — Next.js project
   - `ios` — Swift/UIKit project
   - `flutter` — Dart/BLoC project

3. **Run sync:**
   ```bash
   .claude/software-dev-agentic/scripts/sync.sh --platform=<platform>
   ```

4. **Report:** version pulled from `.claude/software-dev-agentic/VERSION` and confirm new symlinks are live.
