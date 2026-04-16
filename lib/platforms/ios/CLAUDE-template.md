# CLAUDE.md

<!-- BEGIN software-dev-agentic:ios -->
Swift/UIKit · Clean Architecture + MVVM-Coordinator · RxSwift

## Architecture

Module structure and path conventions: `.claude/reference/`

## Principles

Clean Architecture · DRY · SOLID — apply to all new code.

## Workflow

Agents: `feature-orchestrator` · `backend-orchestrator` · `pres-orchestrator` · `debug-worker` · `test-worker` · `arch-review-worker` · `.claude/skills/`

**Feature work (create or update, any scope) → always delegate to `feature-orchestrator`, never inline.**

**If the delegation guard hook blocks an edit → always stop and ask the user: inline or `feature-orchestrator`? Never resolve it autonomously.**
<!-- END software-dev-agentic:ios -->
