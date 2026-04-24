# CLAUDE.md

**software-dev-agentic** — Multi-platform Claude Code toolkit for Clean Architecture projects.
Consumed as a git submodule at `.claude/software-dev-agentic/` in downstream projects. No app to run — this repo is agents, skills, hooks, and architecture reference docs.

Platforms: **web** (Next.js 15) · **ios** (Swift/UIKit) · **flutter** (Dart/BLoC)

## Dev Commands

```bash
# Wire into a downstream project — links all agents, skills, hooks, and reference
.claude/software-dev-agentic/scripts/setup-symlinks.sh --platform=web
.claude/software-dev-agentic/scripts/setup-symlinks.sh --platform=ios

# Cut a release
/release
```

No build, lint, or test commands — all files are Markdown and Bash.

## Structure

`lib/` — ships downstream · `.claude/` — internal tooling (agents, skills, reference) · `docs/` — design docs, observations, perf reports · `scripts/` — setup and sync scripts

See `docs/core-design-principles.md` and `docs/submodule-repo-structure.md` for the full structure and decision rules.

## Workflow

Before any work, invoke the **issue-worker** agent with a title (new) or number (existing).

```
issue-worker "add X"   → create GH issue + branch + backlog row
issue-worker 42        → pick up existing GH issue + branch + backlog row
```

Then work directly on the relevant files in `lib/core/` or `lib/platforms/<platform>/`.

## Agent Architecture

See `docs/core-design-principles.md` — read it before adding any agent, worker, or skill.

## Conventions

**Agents** — `name`, `description`, `model`, `tools` required in frontmatter. Orchestrators list sub-agents in `agents:` and never write files directly. Workers end with `## Extension Point` (check `.claude/agents.local/extensions/<name>.md`).

**Skills** — `name`, `description`, `user-invocable: false` required. Single task only, under 30 lines. User-facing skills omit `user-invocable` or set it to `true`.

## Release

Use `/release` — it bumps `VERSION`, prepends `CHANGELOG.md`, commits, and tags.
Then push: `git push && git push --tags`.
