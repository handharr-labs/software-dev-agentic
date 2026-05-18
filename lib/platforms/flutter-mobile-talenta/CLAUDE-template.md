# CLAUDE.md

<!-- BEGIN software-dev-agentic:flutter -->
Flutter · Clean Architecture + BLoC · get_it/injectable

## Architecture

Module structure and path conventions: `.claude/reference/`

## Principles

Clean Architecture · DRY · SOLID — apply to all new code.

**Layer dependency rule:** Presentation → Domain ← Data. Domain depends on nothing.

## Workflow

Use trigger skills as entry points — `/builder-build-feature`, `/auditor-arch-review`, `/detective-debug`, etc.

**Feature work → always start with `/builder-build-feature`, never inline.**
<!-- END software-dev-agentic:flutter -->
