# CLAUDE.md

**web-agentic** — Claude Code toolkit for Next.js 15 Clean Architecture projects.
Consumed as a git submodule at `.claude/web-agentic/` in downstream projects. No app to run — this repo is agents, skills, hooks, and architecture reference docs.

## Dev Commands

```bash
# Wire into a downstream project (run from that project's root)
.claude/web-agentic/scripts/setup-symlinks.sh

# Cut a release
/release
```

No build, lint, or test commands — all files are Markdown and Bash.

## Structure

```
agents/          # Claude Code subagents — orchestrators and workers
skills/          # Slash command skills — called by workers or users directly
  <skill>/
    SKILL.md     # Skill definition and instructions
    template.md  # Code template (optional)
reference/       # Architecture docs consumed by agents and skills
hooks/           # Claude Code hooks (PreToolUse / PostToolUse)
scripts/         # setup-symlinks.sh, sync.sh
docs/            # Internal design docs (not consumed by agents)
CLAUDE-template.md   # Template for downstream projects' CLAUDE.md
settings-template.json  # Template for downstream .claude/settings.local.json
```

## Workflow

Before any work: `@issue-worker "title"` (new) or `@issue-worker N` (existing).

```
@issue-worker "add X"   → create GH issue + branch + backlog row
@issue-worker 42        → pick up existing GH issue + branch + backlog row
```

Then work directly on the relevant files (agents, skills, reference docs).

## Agent Conventions

Every agent file must have this frontmatter:

```yaml
---
name: agent-name
description: one-line description used for routing
model: sonnet          # or opus for complex orchestration
tools: Read, Glob, Grep, ...
permissionMode: plan   # for read-only workers; omit for write workers
---
```

**Orchestrators** — coordinate workers, never write files directly. List sub-agents in `agents:` frontmatter.

**Workers** — domain specialists, execute skills, write files. End with an extension point:

```markdown
## Extension Point
After completing, check for `.claude/agents.local/extensions/<name>.md` — if it exists, read and follow its additional instructions.
```

## Skill Conventions

Every skill must have this frontmatter:

```yaml
---
name: skill-name
description: one-line description
user-invocable: false    # omit or set true if user can invoke directly
tools: Read, Write, Edit, Glob
---
```

Skills called only by workers: `user-invocable: false`.
User-facing skills (slash commands): no `user-invocable` field or `true`.

## Release

Use `/release` — it bumps `VERSION`, prepends `CHANGELOG.md`, commits, and tags.
Then push: `git push && git push --tags`.
