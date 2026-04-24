---
name: arch-review
description: Audit code for Clean Architecture violations — layer boundaries, entity immutability, service purity, mapper patterns, and naming conventions.
allowed-tools: AskUserQuestion, Agent
---

## Arguments

`$ARGUMENTS` — optional scope: a file path, feature folder name, or `"full"` for the full codebase.

## Steps

1. If `$ARGUMENTS` is empty, call `AskUserQuestion`:
   ```
   question    : "What would you like to review?"
   header      : "Scope"
   multiSelect : false
   options     :
     - label: "A specific file",    description: "Provide a file path to audit"
     - label: "A feature folder",   description: "Audit all layers for one feature"
     - label: "Full codebase",      description: "Audit every layer across the project"
   ```
   Follow up with a second question for the path or feature name if needed.

2. Spawn `arch-review-worker` using the Agent tool with:

   > Scope: <file path / feature folder / "full codebase">
   > Run the full review process — universal rules (U1–U5) and platform skill.
