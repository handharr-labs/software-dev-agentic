# Agents

Subagents invoked via the `Task` tool or `@agent-name` mention. Each is a focused specialist.

Copy to `.claude/agents/` in the actual project.

| Agent | When to invoke |
|-------|---------------|
| `feature-scaffolder` | Creating a new feature end-to-end (entity → data → view → DI) |
| `arch-reviewer` | Auditing a file, feature, or full codebase for Clean Architecture violations |
| `test-writer` | Generating tests for any layer — auto-selects test type by layer |
| `debug-agent` | Tracing a runtime error or unexpected behavior through the Clean Architecture layers |
| `backend-scaffolder` | Scaffolding a full-stack backend feature — Server Action + Use Case + DB DataSource + DB Repository + DI wiring |
