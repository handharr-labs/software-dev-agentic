# CLAUDE.md

**software-dev-agentic** — Multi-platform Claude Code toolkit for Clean Architecture projects.
Consumed as a git submodule at `software-dev-agentic/` (project root) in downstream projects. No app to run — this repo is agents, skills, hooks, and architecture reference docs.

Platforms: **web** (Next.js 15) · **ios** (Swift/UIKit) · **flutter** (Dart/BLoC)

## Dev Commands

```bash
# Wire into a downstream project (submodule path)
software-dev-agentic/scripts/setup-symlinks.sh --platform=web
software-dev-agentic/scripts/setup-symlinks.sh --platform=ios-talenta

# Build a Claude Code plugin for a platform (plugin path)
software-dev-agentic/scripts/build-plugin.sh --platform=flutter-mobile-talenta
software-dev-agentic/scripts/build-plugin.sh --platform=all

# Test a built plugin locally
claude --plugin-dir software-dev-agentic/dist/plugins/flutter-mobile-talenta

# Cut a release
/release
```

No build, lint, or test commands — all files are Markdown and Bash.

## Structure

`lib/` — ships downstream · `.claude/` — internal tooling (agents, skills, reference) · `docs/` — design docs, observations, perf reports · `scripts/` — setup and sync scripts

See `docs/principles/core-design-principles.md` and `docs/principles/submodule-repo-structure.md` for the full structure and decision rules.

## Workflow

Before any work, invoke the **tracker-issue-worker** agent with a title (new) or number (existing).

```
tracker-issue "add X"   → create GH issue + branch + backlog row
tracker-issue 42        → pick up existing GH issue + branch + backlog row
```

Then work directly on the relevant files in `lib/core/` or `lib/platforms/<platform>/`.

## Agent Architecture

See `docs/principles/core-design-principles.md` — read it before adding any agent, worker, or skill.

## Conventions

**Agents** — `name`, `description`, `model`, `tools` required in frontmatter. Orchestrators list sub-agents in `agents:` and never write files directly. Workers end with `## Extension Point` (check `.claude/agents.local/extensions/<name>.md`).

**Skills** — `name`, `description`, `user-invocable: false` required. Single task only, under 30 lines. User-facing skills omit `user-invocable` or set it to `true`.

## Release

Use `/release` — it bumps `VERSION`, prepends `CHANGELOG.md`, commits, and tags.
Then push: `git push && git push --tags`.
