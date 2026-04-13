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
<!-- END software-dev-agentic:web -->
