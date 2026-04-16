# CLAUDE.md

<!-- BEGIN software-dev-agentic:web -->
Next.js 15 App Router · React 19 · Clean Architecture

## Architecture

Module structure and path conventions: `.claude/reference/`

## Principles

Clean Architecture · DRY · SOLID — apply to all new code.

## Workflow

Agents: `feature-orchestrator` · `backend-orchestrator` · `debug-worker` · `test-worker` · `arch-review-worker` · `.claude/skills/`

**Feature work (create or update, any scope) → always delegate to `feature-orchestrator`, never inline.**

**If the delegation guard hook blocks an edit → always stop and ask the user: inline or `feature-orchestrator`? Never resolve it autonomously.**

## Agent Spawning Rules

**Explore agent — always Grep-first.** When spawning an Explore agent, include this in the prompt:
> Use Grep for all symbol and pattern discovery before deciding which files to Read. Only Read a file in full after Grep confirms it is the right target. Do not speculatively read large view or component files.

Pass Explore output as a structured path list to the next agent — never raw file contents. This prevents duplicate reads in the receiving agent.

## Known Configurations

### Tailwind v4 — Dynamic class scanning

Tailwind v4 uses PostCSS and does **not** scan files outside its default source paths. If dynamically composed class names (e.g. `grid-cols-${n}`) are not appearing in production builds, add an explicit `@source` directive to `src/app/globals.css`:

```css
@source "../../path/to/components/**/*.tsx";
```

Do not discover this through trial-and-error builds. Check `globals.css` for an existing `@source` block before running any build.
<!-- END software-dev-agentic:web -->
